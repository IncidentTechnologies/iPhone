//
//  SongDisplayController.m
//  gTarPlay
//
//  Created by Marty Greenia on 8/8/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SongDisplayController.h"

#define PRELOAD_INITIAL 128
#define PRELOAD_MAX 256
#define PRELOAD_INCREMENT 8
#define PRELOAD_TIMER_DURATION 2.0

#define GL_SCREEN_HEIGHT (m_glView.frame.size.height)
#define GL_SCREEN_WIDTH (m_glView.frame.size.width)

// empirically determined ratios defining screen layout for what looks good.
#define GL_SCREEN_TOP_BUFFER ( GL_SCREEN_HEIGHT / 7.0 )
#define GL_SCREEN_BOTTOM_BUFFER ( GL_SCREEN_HEIGHT / 7.0 )
#define GL_SCREEN_SEEK_LINE_OFFSET (GL_SCREEN_WIDTH - GL_SCREEN_WIDTH / 8.0 )

#define GL_NOTE_HEIGHT ( GL_SCREEN_HEIGHT / 7.0 )
#define GL_STRING_HEIGHT ( GL_SCREEN_HEIGHT / 60.0 )
#define GL_STRING_HEIGHT_INCREMENT ( GL_SCREEN_HEIGHT / 320.0 )

#define SONG_BEATS_PER_SCREEN 4.0
#define SONG_BEAT_OFFSET (SONG_BEATS_PER_SCREEN * GL_SCREEN_SEEK_LINE_OFFSET / GL_SCREEN_WIDTH )

@implementation SongDisplayController

- (id)initWithSong:(NSSongModel*)song andView:(EAGLView*)glView isStandalone:(BOOL)standalone setDifficulty:(PlayViewControllerDifficulty)useDifficulty
{
    // Force linking
    [EAGLView class];
    
    self = [super init];
    
    if ( self )
    {
        
        m_noteModelDictionary = [[NSMutableDictionary alloc] init];

        m_numberModels = [[NSMutableArray alloc] init];
        
        m_songModel = [song retain];
        
        m_undisplayedFrames = [[NSMutableArray alloc] initWithArray:m_songModel.m_noteFrames];
        
		m_glView = [glView retain];
        
        m_beatsToPreloadSync = SONG_BEATS_PER_SCREEN;
        m_beatsToPreloadAsync = SONG_BEATS_PER_SCREEN * 4;
        
        m_framesDisplayed = 0;
        
        difficulty = useDifficulty;
        
        isStandalone = standalone;
        
        //
		// Create a renderer and give it to the view, or reuse an existing one.
        // Don't forget to layout the subviews on the GLView or it will be black.
        //
        if ( m_glView.m_renderer == nil )
        {
            m_renderer = [[SongES1Renderer alloc] init];
		
            m_glView.m_renderer = m_renderer;

            m_renderer.m_offset = GL_SCREEN_SEEK_LINE_OFFSET;
            
            [m_glView layoutSubviews];
        }
        else
        {
            m_renderer = (SongES1Renderer*)[m_glView.m_renderer retain];
        }
        
        [self createNoteTexture];
        
        [self createNumberModels];
        
        [self createLineModels];
        
        [self preloadFrames:PRELOAD_INITIAL];
        
        [self createBackgroundTexture];
        
        m_preloadTimer = [NSTimer scheduledTimerWithTimeInterval:PRELOAD_TIMER_DURATION target:self selector:@selector(preloadFramesTimer) userInfo:nil repeats:YES];
        
        fretOne = NO;
        fretTwo = NO;
        fretThree = NO;
        
    }

    return self;
    
}

- (void)cancelPreloading
{
    
    [m_preloadTimer invalidate];
    
    m_preloadTimer = nil;
    
}

- (void)dealloc
{
    
    [m_noteTexture release];
    
    [m_noteModelDictionary release];
    
    [m_undisplayedFrames release];
    
    [m_numberModels release];
    
    [m_mutedTexture release];
    
    [m_songModel release];
    
    [m_glView release];
    
    [m_renderer clearModelData];
    
    [m_renderer release];
    
    [m_preloadTimer invalidate];
    
    m_preloadTimer = nil;
    
    [super dealloc];
    
}

- (void)renderImage
{

    m_framesDisplayed++;
    
    [self updateDisplayedFrames];
    
    double position = [self convertBeatToCoordSpace:m_songModel.m_currentBeat isStandalone:isStandalone];
    
    // pull down the shift as time goes by
    double end = [self calculateMaxShiftCoordSpace:isStandalone];

    // Don't pass the end
    if(m_renderer.m_viewShift < end){
        m_renderer.m_viewShift = end;
    }
    
    // Don't linger at the end if scrolled over and autoscrolling
    if(m_songModel.m_lengthBeats - m_songModel.m_currentBeat < SONG_BEATS_PER_SCREEN){
        [self shiftView:m_songModel.m_lengthBeats - m_songModel.m_currentBeat];
    }
    
    [m_renderer updatePositionAndRender:position];
    
    if(isStandalone){
        [m_glView drawViewWithHighlightsFretOne:fretOne fretTwo:fretTwo fretThree:fretThree];
    }else{
        [m_glView drawView];
    }
    
}

- (void)updateDisplayedFrames
{
    
    double currentBeat = m_songModel.m_currentBeat;
    
    NSArray * displayedNotesKeys = [m_noteModelDictionary allKeys];
    
    NSMutableArray * keysToRemove = [[NSMutableArray alloc] init];
    
    //
    // Check for objects that should no longer be displayed
    //
    for ( NSValue * key in displayedNotesKeys )
    {
        
        NSNote * note = [key nonretainedObjectValue];
            
        if ( note.m_absoluteBeatStart < ( currentBeat - SONG_BEAT_OFFSET ) )
        {
            
            NoteModel * note = [m_noteModelDictionary objectForKey:key];
            
            [m_renderer removeModel:note];
            
            [keysToRemove addObject:key];
            
        }
    }
    
    [m_noteModelDictionary removeObjectsForKeys:keysToRemove];
    
    //
    // Check if we need to display / preload any new frames
    // Note that there is an async thread that should prevent this
    // from needing to do much most of the time.
    //
    NSMutableArray * framesToRemove = [[NSMutableArray alloc] init];
    
    @synchronized( m_undisplayedFrames )
    {
        for ( NSNoteFrame * frame in m_undisplayedFrames )
        {
            if ( frame.m_absoluteBeatStart < (currentBeat + m_beatsToPreloadSync) )
            {
                
                [self displayFrame:frame];
                
                [framesToRemove addObject:frame];
                
            }
            else
            {
                // break out after first failure since these are sorted.
                break;
            }
            
        }

        [m_undisplayedFrames removeObjectsInArray:framesToRemove];
        
    }
    
    [framesToRemove release];
    [keysToRemove release];
}

- (void)preloadFramesTimer
{
    
    if ( [m_noteModelDictionary count] < PRELOAD_MAX )
    {
        [self preloadFrames:PRELOAD_INCREMENT];
    }
    else
    {
        //NSLog(@"Loaded %d", [m_noteModelDictionary count] );
    }
    
    // nothing left to preload
    if ( [m_undisplayedFrames count] == 0 )
    {
        [m_preloadTimer invalidate];
        
        m_preloadTimer = nil;
    }
    
}

- (void)preloadFrames:(NSInteger)count
{
    
    NSMutableArray * framesToRemove = [[NSMutableArray alloc] init];
    
    NSInteger framesLoaded = 0;
    
    @synchronized( m_undisplayedFrames )
    {
        for ( NSNoteFrame * frame in m_undisplayedFrames )
        {
            [self displayFrame:frame];
                
            [framesToRemove addObject:frame];
                
            framesLoaded++;
            
            if ( framesLoaded == count )
            {
                break;
            }

        }
        
        [m_undisplayedFrames removeObjectsInArray:framesToRemove];
        
    }
    
    [framesToRemove release];

}

- (void)displayFrame:(NSNoteFrame*)frame
{
    
    //NSLog(@"Frame is %@",frame);
    
    NSMutableDictionary * standaloneNotesForStrings = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
               [NSNull null],[NSNumber numberWithInt:1],
               [NSNull null],[NSNumber numberWithInt:2],
               [NSNull null],[NSNumber numberWithInt:3], nil];
    
    //NSLog(@"Standalone notes for strings is %@",standaloneNotesForStrings);
    
    int countFrets = 0;
    
    NSNote * firstNote = nil;
    
    for ( NSNote * note in frame.m_notes )
    //for(int k = [frame.m_notes count]-1; k >= 0; k--)
    {
        
        //NSNote * note = [frame.m_notes objectAtIndex:k];
        
        if(!firstNote){
            firstNote = note;
        }
        
        // Determine if active for standalone (first in a row)
        int standalonestring = [self getMappedStringFromString:note.m_string];
        if([standaloneNotesForStrings objectForKey:[NSNumber numberWithInt:standalonestring]] == [NSNull null]){
            [standaloneNotesForStrings setObject:note forKey:[NSNumber numberWithInt:standalonestring]];
            note.m_standaloneActive = YES;
        }else{
            note.m_standaloneActive = NO;
        }
        
        //NSLog(@"Standalone notes for strings is %@",standaloneNotesForStrings);
        
        CGPoint center;
		center.x = [self convertBeatToCoordSpace:note.m_absoluteBeatStart isStandalone:isStandalone];
		center.y = [self convertStringToCoordSpace:note.m_string isStandalone:isStandalone];
		
		// number texture overlay
		NumberModel * overlay;
        
        if(isStandalone){
            overlay = nil;
        }else if ( note.m_fret == GTAR_GUITAR_FRET_MUTED)
        {
            overlay = m_mutedTexture;
        }
        else
        {
            overlay = [m_numberModels objectAtIndex:(note.m_fret%GTAR_GUITAR_FRET_COUNT) ];
        }
        
        NoteModel * model;
        
        // Check mode + difficulty for note color
        GLubyte * noteColor;
        
        if(!isStandalone){
            
            noteColor = g_stringColors[note.m_string - 1];
            
        }else if(difficulty == PlayViewControllerDifficultyEasy){ // Easy
            
            noteColor = g_standaloneFretColors[0];
            
        }else if(difficulty == PlayViewControllerDifficultyMedium){ // Medium
            
            noteColor = g_standaloneFretColors[firstNote.m_fret];
            
            if(note.m_standaloneActive){
                countFrets = (firstNote.m_fret > 0) ? countFrets+1 : countFrets;
            }
            
        }else{ // Hard
            
            noteColor = g_standaloneFretColors[note.m_fret];
            
            if(note.m_standaloneActive){
                countFrets = (note.m_fret > 0) ? countFrets+1 : countFrets;
            }
            
        }
        
        model = [[NoteModel alloc] initWithCenter:center andColor:noteColor andTexture:m_noteTexture andOverlay:overlay];
        
        model.m_fret = note.m_fret;
        
        if(isStandalone){
            
            if(note.m_standaloneActive == NO){
                
                model.m_standalonefret = -1;
                
            }else{
                if(difficulty == PlayViewControllerDifficultyEasy){
                    model.m_standalonefret = 0;
                }else if(difficulty == PlayViewControllerDifficultyMedium){
                    model.m_standalonefret = ceil(firstNote.m_fret/4.0);
                }else if(difficulty == PlayViewControllerDifficultyHard){
                    model.m_standalonefret = ceil(note.m_fret/4.0);
                }
            }
        }
        
        NSValue * key = [NSValue valueWithNonretainedObject:note];
        
        [m_noteModelDictionary setObject:model forKey:key];
        
        [m_renderer addModel:model];
        
        [model release];
        
    }
    
    // Set the note counts for the model
    if(isStandalone){
        for ( NSNote * note in frame.m_notes )
        {
            if(note.m_standaloneActive){
                
                NSValue * key = [NSValue valueWithNonretainedObject:note];
                NoteModel * model = [m_noteModelDictionary objectForKey:key];
                
                model.m_notecount = countFrets;
            }
        }
    }
    
}

- (void)activateNoteAnimation:(NSNote*)note
{
    // this is disabled for now for performance reasons.
#if 0 
    NSValue * key = [NSValue valueWithNonretainedObject:note];
    
    NoteAnimation * animation = [m_noteAnimationDictionary objectForKey:key];
    
    if ( animation != nil )
    {
        [animation startAnimation:NO];
    }
    else
    {
        
        
    }
#endif
}

- (void)shiftView:(double)shift
{
    
    m_viewShift = shift;
    
    // Let us shift through the entire song .. but nothing more.
    double end = [self calculateMaxShiftCoordSpace:isStandalone];
    
    /*if ( m_viewShift < 0.0 )
    {
        m_viewShift = 0.0;
    }
    else if ( end < m_viewShift )
    {
        m_viewShift = end;
    }*/
    
    if( m_viewShift > 0.0)
    {
        m_viewShift = 0.0;
    }
    else if (end > m_viewShift)
    {
        m_viewShift = end;
    }
    
    double viewShiftBeats = [self convertCoordSpaceToBeat:m_viewShift isStandalone:isStandalone] + SONG_BEATS_PER_SCREEN;
    
//    if ( viewShiftBeats > m_beatsToPreload )
    {
        m_beatsToPreloadSync = MAX(m_beatsToPreloadSync, viewShiftBeats);
        m_beatsToPreloadAsync = MAX(m_beatsToPreloadSync, m_beatsToPreloadAsync);
    }
    
    m_renderer.m_viewShift = m_viewShift;
    
}

- (void)shiftViewDelta:(double)shift
{

    m_viewShift += shift;
    
    // Let us shift through the entire song .. but nothing more.
    double end = [self calculateMaxShiftCoordSpace:isStandalone];
    
    /*if ( m_viewShift < 0.0 )
    {
        m_viewShift = 0.0;
    }
    else if ( end < m_viewShift )
    {
        m_viewShift = end;
    }*/
    
    if(m_viewShift > 0.0)
    {
        m_viewShift = 0.0;
    }
    else if (end > m_viewShift)
    {
        m_viewShift = end;
    }
    
    double viewShiftBeats = [self convertCoordSpaceToBeat:m_viewShift isStandalone:isStandalone] + SONG_BEATS_PER_SCREEN;
    
//    if ( viewShiftBeats > m_beatsToPreload )
    {
        m_beatsToPreloadSync = MAX(m_beatsToPreloadSync, viewShiftBeats);
        m_beatsToPreloadAsync = MAX(m_beatsToPreloadSync, m_beatsToPreloadAsync);
    }
    
    m_renderer.m_viewShift = m_viewShift;
    
}


#pragma mark - Init models
    
- (void)createLineModels
{

    //
	// Create the seek line
    //
    
	CGSize size;
    if(isStandalone){
        size.width = GL_NOTE_HEIGHT;
        size.height = GL_SCREEN_HEIGHT;
    }else{
        size.width = GL_NOTE_HEIGHT / 3.0;
        size.height = GL_SCREEN_HEIGHT;
    }
    
    // The center will automatically be offset in the rendering
	CGPoint center;
    if(isStandalone){
        center.y = GL_SCREEN_HEIGHT / 2.0;
        center.x = - GL_SCREEN_WIDTH / 8.0;
    }else{
        center.y = GL_SCREEN_HEIGHT / 2.0;
        center.x = 0;
    }
    
	m_renderer.m_seekLineModel = [[[LineModel alloc] initWithCenter:center andSize:size andColor:g_whiteColorTransparentLight] autorelease];
    
    // Draw a wider seek line area for standalone
    if(isStandalone){
        
        size.width = GL_NOTE_HEIGHT * 3;
        size.height = GL_SCREEN_HEIGHT;
        
        m_renderer.m_seekLineStandaloneModel = [[[LineModel alloc] initWithCenter:center andSize:size andColor:g_whiteColorTransparentLight] autorelease];
        
    }else{
        
        m_renderer.m_seekLineStandaloneModel = nil;
        
    }
    
    
    
    //
    // Create the strings
    // 
        
    center.x = GL_SCREEN_WIDTH / 2.0;
    
    size.width = GL_SCREEN_WIDTH;
    
    for ( unsigned int i = 0; i < GTAR_GUITAR_STRING_COUNT; i++ )
    {
        
        // strings number and size are inversely proportional -- get slightly bigger
        size.height = GL_STRING_HEIGHT + (GTAR_GUITAR_STRING_COUNT - 1 - i) * GL_STRING_HEIGHT_INCREMENT;
        center.y = [self convertStringToCoordSpace:(i+1) isStandalone:isStandalone];
        
        
        GLubyte * stringColor = (isStandalone) ? g_standaloneStringColors[i] : g_stringColors[i];
        
        StringModel * stringModel = [[StringModel alloc] initWithCenter:center andSize:size andColor:stringColor];
        
        [m_renderer addString:stringModel];
        
        [stringModel release];
        
    }
    /*
#if 0
    // This takes too long to load right now. Do something lazily
    
    //
    // Create the measures
    //
    for ( NSMeasure * measure in m_songModel.m_song.m_measures )
    {
        size.width = GL_STRING_HEIGHT/4.0;
        size.height = GL_SCREEN_HEIGHT;
        center.x = [self convertBeatToCoordSpace:measure.m_startBeat];
        center.y = GL_SCREEN_HEIGHT/2.0;
        
        LineModel * lineModel = [[LineModel alloc] initWithCenter:center andSize:size andColor:g_measureColors];
        
        [m_renderer addLine:lineModel];
        
        [lineModel release];
        
        // Also allocate some beat markers
        for ( NSInteger beat = 1; beat < measure.m_beatCount; beat++ )
        {
            
            center.x = [self convertBeatToCoordSpace:measure.m_startBeat + (measure.m_beatValue*beat)];
            
            LineModel * lineModel = [[LineModel alloc] initWithCenter:center andSize:size andColor:g_beatColors];
            
            [m_renderer addLine:lineModel];
            
            [lineModel release];
            
        }
        
    }
    
#endif
     */
    
}

- (void)createNumberModels
{
	
	CGSize size;
	size.width = GL_NOTE_HEIGHT;
	size.height = GL_NOTE_HEIGHT-3;
	
    // Create number models for 0..16
	for ( unsigned int i = 0; i < (GTAR_GUITAR_FRET_COUNT+1); i++ )
	{
		
		NumberModel * numberModel = [[NumberModel alloc] initWithCenter:CGPointMake(0, 0)
                                                                andSize:size
                                                               andColor:g_whiteColor
                                                               andValue:i];
		
		[m_numberModels addObject:numberModel];
		
		[numberModel release];
	}
    
    [m_mutedTexture release];
    
    m_mutedTexture = [[NumberModel alloc] initWithCenter:CGPointMake(0, 0)
                                                 andSize:size
                                                andColor:g_whiteColor
                                                andValue:-1];
}

- (void)createNoteTexture
{
    
    [m_noteTexture release];
    
    UIImage * scaledImage;
    UIImage * image = [UIImage imageNamed:@"NoteGreyscale.png"];
    
    CGSize size;
    size.height = GL_NOTE_HEIGHT;
    size.width = GL_NOTE_HEIGHT;
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    
    m_noteTexture = [[Texture2D alloc] initWithImage:scaledImage];
        
}

- (void)createBackgroundTexture
{
    
    NSString * filePath;
	UIImage * normalImage;
	UIImage * scaledImage;
	
	CGSize newSize;
	newSize.height = m_renderer.m_backingHeight;
	newSize.width = m_renderer.m_backingWidth;
    
    filePath = [[NSBundle mainBundle] pathForResource:@"PlayBG" ofType:@"png"];
    normalImage = [[UIImage alloc] initWithContentsOfFile:filePath];
    
    UIGraphicsBeginImageContext(newSize);
    [normalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    
    Texture2D * backgroundTexture = [[Texture2D alloc] initWithImage:scaledImage];
    
    Model * model = [[Model alloc] initWithCenter:CGPointMake(m_renderer.m_backingWidth, m_renderer.m_backingHeight)
                                         andColor:g_whiteColor
                                       andTexture:backgroundTexture];
    
    m_renderer.m_backgroundTexture = model;
    
    [model release];
    [backgroundTexture release];
    [normalImage release];
    
}

#pragma mark - Helpers

- (double)convertTimeToCoordSpace:(double)delta isStandalone:(BOOL)standalone
{
    return [self convertBeatToCoordSpace:(m_songModel.m_beatsPerSecond * delta) isStandalone:standalone];
}
 
- (double)convertBeatToCoordSpace:(double)beat isStandalone:(BOOL)standalone
{
	//return (beat/(GLfloat)SONG_BEATS_PER_SCREEN) * GL_SCREEN_WIDTH;
    
    return GL_SCREEN_WIDTH - (beat/(GLfloat)SONG_BEATS_PER_SCREEN) * GL_SCREEN_WIDTH;
}

- (double)convertCoordSpaceToBeat:(double)coord isStandalone:(BOOL)standalone
{
	//return coord * ((GLfloat)SONG_BEATS_PER_SCREEN / GL_SCREEN_WIDTH);
    
    return 1 - (coord * (GLfloat)SONG_BEATS_PER_SCREEN) / GL_SCREEN_WIDTH;
}

- (double)convertStringToCoordSpace:(NSInteger)str isStandalone:(BOOL)standalone
{
    if(standalone){
        str = [self getMappedStringFromString:str];
    }
    
	GLfloat effectiveScreenHeight = (GL_SCREEN_HEIGHT) - (GL_SCREEN_TOP_BUFFER + GL_SCREEN_BOTTOM_BUFFER);
	
	GLfloat heightPerString = effectiveScreenHeight / ((GLfloat)GTAR_GUITAR_STRING_COUNT-1);
    
    if(standalone){
        heightPerString *= 2;
    }
	
    // bias it down to zero-base it
	return GL_SCREEN_BOTTOM_BUFFER + ( (str-1) * heightPerString );
}

- (double)calculateMaxShiftCoordSpace:(BOOL)standalone
{
    //double beatsToShift = m_songModel.m_lengthBeats - m_songModel.m_currentBeat - SONG_BEATS_PER_SCREEN + SONG_BEAT_OFFSET;
    
    double beatsToShift = ceil(m_songModel.m_lengthBeats) - m_songModel.m_currentBeat + SONG_BEATS_PER_SCREEN;
    
    double end = [self convertBeatToCoordSpace:MAX(beatsToShift,0) isStandalone:standalone];
    
    if(m_songModel.m_lengthBeats - m_songModel.m_currentBeat <= SONG_BEATS_PER_SCREEN){
        return end;
    }else{
        return end+GL_SCREEN_WIDTH;
    }
}

#pragma mark - Standalone helper functions

-(int)getMappedStringFromString:(int)str
{
    int newstr = floor(((double)str-1)/2.0) + 1;
    return newstr;
}

- (NSMutableDictionary *)getStringPluckFromTap:(CGPoint)touchPoint
{
    if(!isStandalone){
        return nil;
    }
    
    // Make sure x is on the touchband
    double touchBuffer = 5;
    
    /*
    double xmax = GL_SCREEN_WIDTH - GL_SCREEN_WIDTH/8 + [m_renderer.m_seekLineModel getCenter].x + [m_renderer.m_seekLineModel getSize].width/2 + touchBuffer;
    double xmin = GL_SCREEN_WIDTH - GL_SCREEN_WIDTH/8 + [m_renderer.m_seekLineModel getCenter].x - [m_renderer.m_seekLineModel getSize].width/2 - touchBuffer;
    */
    
    double xmax = GL_SCREEN_WIDTH - GL_SCREEN_WIDTH/8 + [m_renderer.m_seekLineStandaloneModel getCenter].x + [m_renderer.m_seekLineStandaloneModel getSize].width/2 + touchBuffer;
    double xmin = GL_SCREEN_WIDTH - GL_SCREEN_WIDTH/8 + [m_renderer.m_seekLineStandaloneModel getCenter].x - [m_renderer.m_seekLineStandaloneModel getSize].width/2 - touchBuffer;
    
    if(touchPoint.x > xmax || touchPoint.x < xmin){
        return nil;
    }
    
    // TODO: get the frame from the touchpoint so we know note they tried to play
    // Since it's in our touchzone we'll score it
    // (If it's in our special touchzone we'll score it 100%)
    // Do we care about currentFrame?
    
    // Determine which frame was played
    NSNoteFrame * activeFrame = nil;
    
    for(NSNoteFrame * frame in m_songModel.m_noteFrames){
        
        if(frame.m_absoluteBeatStart > m_songModel.m_currentBeat + SONG_BEATS_PER_SCREEN){
            
            return nil;
            
        }else if(m_songModel.m_currentBeat <= frame.m_absoluteBeatStart){
            
            float beatMinusBeat = [self convertBeatToCoordSpace:frame.m_absoluteBeatStart-m_songModel.m_currentBeat isStandalone:isStandalone];
            
            // what is renderer offset?
            float noteCenter = beatMinusBeat - GL_SCREEN_WIDTH/8.0;
            float noteMin = noteCenter - GL_NOTE_HEIGHT/2.0;
            float noteMax = noteCenter + GL_NOTE_HEIGHT/2.0;
           
            //NSLog(@"Touchpoint x is %f in note range %f to %f",touchPoint.x,noteMin,noteMax);
            
            if(touchPoint.x >= noteMin && touchPoint.x <= noteMax){
                
                NSLog(@"Touchpoint x is %f in note range %f to %f",touchPoint.x,noteMin,noteMax);
                
                activeFrame = frame;
                break;
            }
        }
    }
    
    if(activeFrame == nil || [activeFrame.m_notesPending count] == 0){
        
        return nil;
        
    }else{
        
        NSLog(@"Found frame %@",activeFrame);
        
    }
    
    // Determine string
    
	GLfloat effectiveScreenHeight = (GL_SCREEN_HEIGHT) - (GL_SCREEN_TOP_BUFFER + GL_SCREEN_BOTTOM_BUFFER);
	
	GLfloat heightPerString = effectiveScreenHeight / ((GLfloat)GTAR_GUITAR_STRING_COUNT-1);
    heightPerString *= 2;

    double stringBuffer = 15;
    
    double string1Center = heightPerString;
    double string2Center = 2*heightPerString;
    double string3Center = 3*heightPerString;

    NSMutableDictionary * frameWithString = [[NSMutableDictionary alloc] initWithObjectsAndKeys:activeFrame,@"Frame",[NSNumber numberWithInt:-1],@"String",nil];
    
    // Top string
    if(touchPoint.y > string1Center-stringBuffer && touchPoint.y < string1Center+stringBuffer){
        
        //NSLog(@"*** hit string 1 *** ");
        
        [frameWithString setObject:[NSNumber numberWithInt:3] forKey:@"String"];
        
        // return 3;
    }
    
    // Middle string
    if(touchPoint.y > string2Center-stringBuffer && touchPoint.y < string2Center+stringBuffer){
        
        //NSLog(@"*** hit string 2 *** ");
        
        [frameWithString setObject:[NSNumber numberWithInt:2] forKey:@"String"];
        
        //return 2;
    }
    
    // Bottom string
    if(touchPoint.y > string3Center-stringBuffer && touchPoint.y < string3Center+stringBuffer){
        
        //NSLog(@"*** hit string 3 *** ");
        
        [frameWithString setObject:[NSNumber numberWithInt:1] forKey:@"String"];
        
        //return 1;
    }
    
    return frameWithString;
}

#pragma mark - Live Info from Play Controller


- (void)fretsDownOne:(BOOL)fretOneOn fretTwo:(BOOL)fretTwoOn fretThree:(BOOL)fretThreeOn
{
    fretOne = fretOneOn;
    fretTwo = fretTwoOn;
    fretThree = fretThreeOn;
}

- (void)hitNote:(NSNote *)note
{
    NSValue * key = [NSValue valueWithNonretainedObject:note];
    NoteModel * notehit = [m_noteModelDictionary objectForKey:key];
    if(notehit != nil){
        [notehit hitNote];
    }
}

- (void)missNote:(NSNote *)note
{
    NSValue * key = [NSValue valueWithNonretainedObject:note];
    NoteModel * notehit = [m_noteModelDictionary objectForKey:key];
    if(notehit != nil){
        [notehit missNote];
    }
}

@end
