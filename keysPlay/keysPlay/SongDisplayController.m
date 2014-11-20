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

@implementation SongDisplayController

- (id)initWithSong:(NSSongModel*)song andView:(EAGLView*)glView isStandalone:(BOOL)standalone setDifficulty:(PlayViewControllerDifficulty)useDifficulty andLoops:(int)numLoops
{
    // Force linking
    [EAGLView class];
    
    self = [super init];
    
    if ( self )
    {
        m_noteModelDictionary = [[NSMutableDictionary alloc] init];
        m_noteModelUniversalDictionary = [[NSMutableDictionary alloc] init];
        
        //m_numberModels = [[NSMutableArray alloc] init];
        
        m_songModel = song;
        
        m_undisplayedFrames = [[NSMutableArray alloc] initWithArray:m_songModel.m_noteFrames];
        
        m_allFrames = [[NSMutableArray alloc] initWithArray:m_songModel.m_noteFrames];
        
        m_glView = glView;
        
        m_beatsToPreloadSync = SONG_BEATS_PER_SCREEN;
        m_beatsToPreloadAsync = SONG_BEATS_PER_SCREEN * 4;
        
        m_framesDisplayed = 0;
        
        difficulty = useDifficulty;
        
        isStandalone = standalone;
        
        m_loops = numLoops;
        
        //
        // Create a renderer and give it to the view, or reuse an existing one.
        // Don't forget to layout the subviews on the GLView or it will be black.
        //
        if ( m_glView.m_renderer == nil )
        {
            m_renderer = [[SongES1Renderer alloc] init];
            
            m_glView.m_renderer = m_renderer;
            
            [self shiftViewToKey:[g_keysController range].keyMin];
            m_renderer.m_offset = GL_SEEK_LINE_Y;
            
            [m_glView layoutSubviews];
            
        }else{
            m_renderer = (SongES1Renderer*)m_glView.m_renderer;
        }
        
        //[self cancelPreloading];
        
        [self createNoteTexture];
        
        //[self createNumberModels];
        
        [self preloadFrames:PRELOAD_INCREMENT*4];
        
        //[self createLoopModels];
        
        [self setNoteRangeForSong];
        
        [self createLineModels];
        
        m_preloadTimer = [NSTimer scheduledTimerWithTimeInterval:PRELOAD_TIMER_DURATION target:self selector:@selector(preloadFramesTimer) userInfo:nil repeats:YES];
        
    }
    
    return self;
    
}

- (void)updateDifficulty:(PlayViewControllerDifficulty)useDifficulty
{
    if(difficulty != useDifficulty){
        difficulty = useDifficulty;
        
        @synchronized(self){
            
            // Remove all displayed notes
            NSArray * displayedNotesKeys = [m_noteModelDictionary allKeys];
            
            NSMutableArray * keysToRemove = [[NSMutableArray alloc] init];
            
            for ( NSValue * key in displayedNotesKeys )
            {
                NoteModel * note = [m_noteModelDictionary objectForKey:key];
                [m_renderer removeModel:note];
                [keysToRemove addObject:key];
            }
            
            [m_noteModelDictionary removeObjectsForKeys:keysToRemove];
            
            // Redisplay them
            m_undisplayedFrames = [[NSMutableArray alloc] initWithArray:m_songModel.m_noteFrames];
            
            [self updateDisplayedFrames];
            
        }
        
    }
}

- (NSDictionary *)getNoteRangeForSong
{
    KeyPosition minKey = KEYS_KEY_COUNT;
    KeyPosition maxKey = 0;
    
    for(NSNoteFrame * noteFrame in m_songModel.m_noteFrames){
        for(NSNote * note in noteFrame.m_notes){
            minKey = MIN(minKey,note.m_key);
            maxKey = MAX(maxKey,note.m_key);
        }
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:minKey],@"Min",[NSNumber numberWithInt:maxKey],@"Max", nil];
}

- (void)setNoteRangeForSong
{
    NSDictionary * songRange = [self getNoteRangeForSong];
    
    int minKey = [[songRange objectForKey:@"Min"] intValue];
    int maxKey = [[songRange objectForKey:@"Max"] intValue];
    
    DLog(@"Min in song is %i, max is %i",minKey,maxKey);
    
    [g_keysMath setSongRangeFromMin:minKey andMax:maxKey];
}

- (void)cancelPreloading
{
    [m_renderer clearModelData];
    
    //m_renderer = nil;
    
    [m_preloadTimer invalidate];
    
    m_preloadTimer = nil;
    
}

- (void)renderImage
{
    m_framesDisplayed++;
    
    [self updateDisplayedFrames];
    
    double position = [g_keysMath convertBeatToCoordSpace:m_songModel.m_currentBeat];
    
    // pull down the shift as time goes by
    double end = [g_keysMath calculateMaxShiftCoordSpace:m_songModel.m_currentBeat lengthBeats:m_songModel.m_lengthBeats];
    
    // Don't pass the end
    if(m_renderer.m_viewShift < end){
        m_renderer.m_viewShift = end;
    }
    
    // Don't linger at the end if scrolled over and autoscrolling
    if(m_songModel.m_lengthBeats - m_songModel.m_currentBeat < SONG_BEATS_PER_SCREEN){
        [self shiftView:m_songModel.m_lengthBeats - m_songModel.m_currentBeat];
    }
    
    [m_renderer updatePositionAndRender:position];
    
    float hitCorrect = TOUCH_HIT_EASY_CORRECT;
    float hitNear = TOUCH_HIT_EASY_NEAR;
    float hitIncorrect = TOUCH_HIT_EASY_INCORRECT;
    
    if(difficulty == PlayViewControllerDifficultyMedium){
        hitCorrect = TOUCH_HIT_MEDIUM_CORRECT;
        hitNear = TOUCH_HIT_MEDIUM_NEAR;
        hitIncorrect = TOUCH_HIT_MEDIUM_INCORRECT;
    }else if(difficulty == PlayViewControllerDifficultyHard){
        hitCorrect = TOUCH_HIT_HARD_CORRECT;
        hitNear = TOUCH_HIT_HARD_NEAR;
        hitIncorrect = TOUCH_HIT_HARD_INCORRECT;
    }
    
    [m_glView drawViewWithHighlightsHitCorrect:hitCorrect hitNear:hitNear hitIncorrect:hitIncorrect];
    
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
                
                //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [self displayFrame:frame];
                //});
                
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
    
}

- (void)preloadFramesTimer
{
    
    if ( [m_noteModelDictionary count] < PRELOAD_MAX )
    {
        [self preloadFrames:PRELOAD_INCREMENT];
    }
    else
    {
        //DLog(@"Loaded %d", [m_noteModelDictionary count] );
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
    
    
}

- (void)displayFrame:(NSNoteFrame*)frame
{
    
    //DLog(@"Frame is %@",frame);
    
    NSMutableDictionary * standaloneNotesForStrings = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                       [NSNull null],[NSNumber numberWithInt:1],
                                                       [NSNull null],[NSNumber numberWithInt:2],
                                                       [NSNull null],[NSNumber numberWithInt:3], nil];
    
    //DLog(@"Standalone notes for strings is %@",standaloneNotesForStrings);
    
    // Initialize fret count
    int countFrets[4];
    for(int f = 0; f < 4; f++){
        countFrets[f] = 0;
    }
    
    
    NSNote * firstNote = nil;
    
    NSMutableArray * drawnNoteCentersForFrame = [[NSMutableArray alloc] init];
    
    for ( NSNote * note in frame.m_notes )
        //for(int k = [frame.m_notes count]-1; k >= 0; k--)
    {
        
        //NSNote * note = [frame.m_notes objectAtIndex:k];
        
        if(!firstNote){
            firstNote = note;
        }
        
        // Determine if active for standalone (first in a row)
        /*int standalonestring = [self getMappedKeyFromKey:note.m_key];
        if([standaloneNotesForStrings objectForKey:[NSNumber numberWithInt:standalonestring]] == [NSNull null]){
            [standaloneNotesForStrings setObject:note forKey:[NSNumber numberWithInt:standalonestring]];
            note.m_standaloneActive = YES;
        }else{
            note.m_standaloneActive = NO;
        }
         */
        
        note.m_standaloneActive = NO;
        
        CGPoint center;
        center.y = [g_keysMath convertBeatToCoordSpace:note.m_absoluteBeatStart];
        center.x = [g_keysMath convertKeyToCoordSpace:note.m_key];
        
        
        // These notes will still be sounded, but do not draw multiple notes in the same place for standalone in order to preserve highlight transparency
        if(isStandalone){
            
            BOOL skipNoteInFrame = false;
            
            for(int i = 0; i < [drawnNoteCentersForFrame count]; i++){
                CGPoint noteCenter = [[drawnNoteCentersForFrame objectAtIndex:i] CGPointValue];
                
                if(noteCenter.x == center.x && noteCenter.y == center.y){
                    skipNoteInFrame = true;
                }
            }
            
            if(skipNoteInFrame){
                //DLog(@"SKIPPING Note at %f, %f",center.x,center.y);
                continue;
            }else{
                //DLog(@"Note at %f, %f",center.x,center.y);
                [drawnNoteCentersForFrame addObject:[NSValue valueWithCGPoint:center]];
            }
        }
        
        // number texture overlay
        NumberModel * overlay = nil;
        
        NoteModel * model;
        
        // Check mode + difficulty for note color
        GLubyte * noteColor;
        
        if(!isStandalone){
            
            noteColor = g_keyColors[note.m_key%KEYS_OCTAVE_COUNT];
            
        }else{
            
            noteColor = [m_renderer getHighlightColorForMappedKey:[g_keysMath getMappedKeyFromKey:note.m_key]];
            
        }
        
        /*}else if(difficulty == PlayViewControllerDifficultyEasy){ // Easy
            
            noteColor = g_standaloneKeyColors[0];
            
        }else if(difficulty == PlayViewControllerDifficultyMedium){ // Medium
            
            noteColor = g_standaloneKeyColors[firstNote.m_key%KEYS_OCTAVE_COUNT];
            
            if(note.m_standaloneActive){
                if(firstNote.m_key > 0){
                    countFrets[0]++;
                    countFrets[[self getStandaloneKeyFromKey:firstNote.m_key]]++;
                }
            }
            
        }else{ // Hard
            
            noteColor = g_standaloneKeyColors[note.m_key%KEYS_OCTAVE_COUNT];
            
            if(note.m_standaloneActive){
                if(note.m_key > 0){
                    countFrets[0]++;
                    countFrets[[self getStandaloneKeyFromKey:note.m_key]]++;
                }
            }
            
        }*/
        
        Texture2D * modelTexture = [g_keysMath isKeyBlackKey:note.m_key] ? m_blackKeyTexture : m_whiteKeyTexture;
        
        model = [[NoteModel alloc] initWithCenter:center andColor:noteColor andTexture:modelTexture andOverlay:overlay];
        
        model.m_key = note.m_key;
        model.m_standalonekey = (isStandalone) ? [g_keysMath getMappedKeyFromKey:note.m_key] : KEYS_OCTAVE_COUNT;
        
        
        NSValue * key = [NSValue valueWithNonretainedObject:note];
        
        [m_noteModelDictionary setObject:model forKey:key];
        
        [m_noteModelUniversalDictionary setObject:model forKey:key];
        
        [m_renderer addModel:model];
        
        
    }
    
    // Set the note counts for the model
    /*if(isStandalone){
        for ( NSNote * note in frame.m_notes )
        {
            if(note.m_standaloneActive){
                
                NSValue * key = [NSValue valueWithNonretainedObject:note];
                NoteModel * model = [m_noteModelDictionary objectForKey:key];
                
                for(int f = 0; f < 4; f++){
                    [model setFretNoteCount:countFrets[f] AtIndex:f];
                }
            }
        }
    }*/
    
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

- (void)shiftViewToKey:(double)key
{
    float numWhiteKeys = KEYS_WHITE_KEY_DISPLAY_COUNT;
    
    GLfloat effectiveScreenWidth = (GL_SCREEN_WIDTH);
    GLfloat widthPerWhiteKey = effectiveScreenWidth / ((GLfloat)numWhiteKeys);
    
    // Offset by half a key so it starts at the beginning
    
    if(!isStandalone){
        m_renderer.m_horizontalOffset = -1*[g_keysMath convertKeyToCoordSpace:key] + widthPerWhiteKey/2.0;
    }
    
    [m_renderer render];
}

- (void)shiftView:(double)shift
{
     m_viewShift = shift;
     
     // Let us shift through the entire song .. but nothing more.
    double end = [g_keysMath calculateMaxShiftCoordSpace:m_songModel.m_currentBeat lengthBeats:m_songModel.m_lengthBeats];
     
     //if ( m_viewShift < 0.0 )
     //{
     //m_viewShift = 0.0;
     //}
     //else if ( end < m_viewShift )
     //{
     //m_viewShift = end;
     //}
     
     if( m_viewShift > 0.0)
     {
     m_viewShift = 0.0;
     }
     else if (end > m_viewShift)
     {
     m_viewShift = end;
     }
     
     double viewShiftBeats = [g_keysMath convertCoordSpaceToBeat:m_viewShift] + SONG_BEATS_PER_SCREEN;
     
     //    if ( viewShiftBeats > m_beatsToPreload )
     {
     m_beatsToPreloadSync = MAX(m_beatsToPreloadSync, viewShiftBeats);
     m_beatsToPreloadAsync = MAX(m_beatsToPreloadSync, m_beatsToPreloadAsync);
     }
     
     m_renderer.m_viewShift = m_viewShift;
     
}

- (void)shiftViewDelta:(double)shift
{
    if(!isStandalone){
        m_renderer.m_horizontalOffset = m_renderer.m_horizontalOffset+shift;
    }
        
    [m_renderer render];
    
}


#pragma mark - Init models

- (void)createLineModels
{
    
    //
    // Create the seek line
    //
    
    CGSize size;
    size.width = GL_NOTE_HEIGHT / 3.0;
    size.height = GL_SCREEN_HEIGHT;
    
    // The center will automatically be offset in the rendering
    CGPoint center;
    
    m_renderer.m_seekLineModel = nil;
    m_renderer.m_seekLineStandaloneModel = nil;
    
    GLubyte * stringColor = g_whiteColorTransparentLight; // all white
    
    // Create paths for black keys
    if(!isStandalone){
    
        for ( unsigned int i = 0; i < KEYS_KEY_COUNT; i++ )
        {
            if(![g_keysMath isKeyBlackKey:i]){
                continue;
            }
            
            // Get the position of the black note as the center
            center.x = [g_keysMath convertKeyToCoordSpace:i];
            
            center.y = GL_SCREEN_HEIGHT;
            
            size.width = [g_keysMath getBlackKeyFrameSize:KEYS_WHITE_KEY_DISPLAY_COUNT inSize:CGSizeMake(GL_SCREEN_WIDTH,GL_SCREEN_HEIGHT)].width;
            size.height = 2*GL_SCREEN_HEIGHT;
            
            KeyPathModel * stringModel = [[KeyPathModel alloc] initWithCenter:center andSize:size andColor:stringColor];
            
            [m_renderer addKeyPath:stringModel];
            
        }
            
    }else{
        
        int blackKeyCount = KEYS_BLACK_KEY_EASY_COUNT;
        int whiteKeyCount = KEYS_WHITE_KEY_EASY_COUNT;
        
        if(difficulty == PlayViewControllerDifficultyMedium){
            blackKeyCount = KEYS_BLACK_KEY_MED_COUNT;
            whiteKeyCount = KEYS_WHITE_KEY_MED_COUNT;
        }else if(difficulty == PlayViewControllerDifficultyHard){
            blackKeyCount = KEYS_BLACK_KEY_HARD_COUNT;
            whiteKeyCount = KEYS_WHITE_KEY_HARD_COUNT;
        }
        
        int noteCount = whiteKeyCount + blackKeyCount;
        
        for (unsigned int i = 0; i < noteCount; i++){
            
            if(![g_keysMath isKeyBlackKey:i]){
                continue;
            }
            
            // Get the position of the black note as the center
            center.x = [g_keysMath convertKeyToCoordSpace:i];
            center.y = (GL_SCREEN_HEIGHT-GL_SEEK_LINE_Y) / 2.0 + GL_SEEK_LINE_Y;
            
            size.width = [g_keysMath getBlackKeyFrameSize:whiteKeyCount inSize:CGSizeMake(GL_SCREEN_WIDTH,GL_SCREEN_HEIGHT)].width;
            size.height = GL_SCREEN_HEIGHT-GL_SEEK_LINE_Y;
            
            KeyPathModel * stringModel = [[KeyPathModel alloc] initWithCenter:center andSize:size andColor:stringColor];
            
            [m_renderer addKeyPath:stringModel];

            
        }
    }
    
}

- (void)createLoopModels
{
    /*
    CGSize size;
    CGPoint center;
    
    //
    // Create the loop indicators
    //
    
    for(int i = 0; i <= m_loops; i++){
        
        int numFrames = [m_allFrames count];
        int frameindex = (double)numFrames/(double)(m_loops+1) * (i+1) - 1;
        
        NSNoteFrame * noteFrame = [m_allFrames objectAtIndex:frameindex];
        NSNote * note = [noteFrame.m_notes firstObject];
        
        center.x = [self convertBeatToCoordSpace:note.m_absoluteBeatStart isStandalone:isStandalone]; // get X from note positions
        center.y = GL_SCREEN_HEIGHT / 2;
        
        size.width = 5.0;
        size.height = GL_SCREEN_HEIGHT;
        
        LineModel * loopModel = [[LineModel alloc] initWithCenter:center andSize:size andColor:g_whiteColor];
        
        [m_renderer addLoop:loopModel];
        
    }
    */
}

- (void)createNumberModels
{
    /*
    CGSize size;
    size.width = GL_NOTE_HEIGHT;
    size.height = GL_NOTE_HEIGHT-3;
    
    // Create number models for 0..16
    for ( unsigned int i = 0; i < (KEYS_GUITAR_FRET_COUNT+1); i++ )
    {
        
        NumberModel * numberModel = [[NumberModel alloc] initWithCenter:CGPointMake(0, 0)
                                                                andSize:size
                                                               andColor:g_whiteColor
                                                               andValue:i];
        
        [m_numberModels addObject:numberModel];
        
    }
    
    
    m_mutedTexture = [[NumberModel alloc] initWithCenter:CGPointMake(0, 0)
                                                 andSize:size
                                                andColor:g_whiteColor
                                                andValue:-1];
     */
}

- (void)createNoteTexture
{
    UIImage * whiteKeyScaledImage;
    UIImage * blackKeyScaledImage;
    UIImage * whiteKeyImage = [UIImage imageNamed:@"NoteGreyscale.png"];
    UIImage * blackKeyImage = [UIImage imageNamed:@"NoteGreyscale2.png"];
    
    CGSize size;
    size.height = GL_NOTE_HEIGHT;
    size.width = GL_NOTE_HEIGHT;
    
    UIGraphicsBeginImageContext(size);
    [whiteKeyImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    whiteKeyScaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(size);
    [blackKeyImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    blackKeyScaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    m_whiteKeyTexture = [[Texture2D alloc] initWithImage:whiteKeyScaledImage];
    m_blackKeyTexture = [[Texture2D alloc] initWithImage:blackKeyScaledImage];
    
}

#pragma mark - Standalone helper functions
- (NSMutableDictionary *)getKeyPressFromTap:(NSMutableArray *)touchPoints
{
    if(!isStandalone){
        return nil;
    }
    
    // Make sure touch is within the allowed area near the keyboard
    double touchBuffer = 50.0;
    
    double ymax = GL_SCREEN_HEIGHT;
    double ymin = GL_SCREEN_HEIGHT - GL_TOUCH_AREA_HEIGHT;
    
    double xmax = GL_SCREEN_WIDTH;
    double xmin = 0;
    
    // All touchpoints have to be in range, so mostly look at the first touchpoint
    
    CGPoint firstTouchPoint = [[touchPoints firstObject] CGPointValue];
    if(firstTouchPoint.x > xmax || firstTouchPoint.x < xmin || firstTouchPoint.y > ymax || firstTouchPoint.y < ymin){
        return nil;
    }
    
    // Determine which frame was played by Y intersection
    NSNoteFrame * activeFrame = nil;
    
    for(NSNoteFrame * frame in m_songModel.m_noteFrames){
        
        if(frame.m_absoluteBeatStart > m_songModel.m_currentBeat + SONG_BEATS_PER_SCREEN){
            
            // Too late
            continue;
            //return nil;
            
        }else if(m_songModel.m_currentBeat - SONG_BEAT_OFFSET/2.0 <= frame.m_absoluteBeatStart && [frame.m_notesPending count] > 0){
            
            // Check everything upcoming
            
            float yForBeat = -1*[g_keysMath convertBeatToCoordSpace:frame.m_absoluteBeatStart-m_songModel.m_currentBeat+0.5]; // how to reach further up the screen?
            
            DLog(@"Checking frame at %f on screen of %f",yForBeat,GL_SCREEN_HEIGHT);
            
            // what is renderer offset?
            //float marginoffset =  0.0; //GL_SEEK_LINE_Y?
            float noteCenter = yForBeat; //- marginoffset;
            float noteMax = GL_SCREEN_HEIGHT;// - (noteCenter - GL_NOTE_HEIGHT/2.0 - touchBuffer);
            float noteMin = GL_SCREEN_HEIGHT - (noteCenter + GL_NOTE_HEIGHT/2.0 + touchBuffer);
            
            DLog(@"First touchpoint y is %f in note range %f to %f",firstTouchPoint.y,noteMin,noteMax);
            
            if(firstTouchPoint.y >= noteMin && firstTouchPoint.y <= noteMax){
                
                DLog(@"Setting as active frame");
                
                activeFrame = frame;
                break;
            }
        }
    }
    
    if(activeFrame == nil || [activeFrame.m_notesPending count] == 0){
        
        return nil;
        
    }else{
        
        DLog(@"Found frame %@ | number of touches is %i",activeFrame,[touchPoints count]);
    }
    

    // Calculate all the accuracies
    NSMutableArray * notesHit = [[NSMutableArray alloc] init];
    
    // For each note get the best touchpoint accuracy
    double averageAccuracy = 0.0;
    for(NSNote * note in activeFrame.m_notesPending){
        
        double noteAccuracy = [self getAccuracyForNote:note withTouchPoints:touchPoints];
        averageAccuracy += noteAccuracy;
        
        if(noteAccuracy > 0.0){ // Minimum threshold to hit a note
            [notesHit addObject:[NSNumber numberWithInt:note.m_key]];
        }
    }
    
    averageAccuracy /= [activeFrame.m_notesPending count];
    
    DLog(@"Using average accuracy %f with %i notes hit",averageAccuracy,[notesHit count]);
    
    // Determine keys hit
    NSMutableDictionary * frameWithKey = [[NSMutableDictionary alloc] initWithObjectsAndKeys:activeFrame,@"Frame",notesHit,@"Key",[NSNumber numberWithFloat:averageAccuracy],@"Accuracy",nil];
    
    return frameWithKey;
}

- (double)getAccuracyForNote:(NSNote *)note withTouchPoints:(NSMutableArray *)touchPoints
{
    double maxAccuracy = 0.0;
    
    for(NSValue * touchPointValue in touchPoints){
        CGPoint touchPoint = [touchPointValue CGPointValue];
        
        double noteX = [g_keysMath convertKeyToCoordSpace:note.m_key];
        double accuracy = 1.0 - fabs(touchPoint.x - noteX) / GL_SCREEN_WIDTH;
        
        if(accuracy > maxAccuracy){
            maxAccuracy = accuracy;
        }
        
    }
    
    return maxAccuracy;
}

#pragma mark - Live Info from Play Controller

- (void)hitNote:(NSNote *)note withAccuracy:(double)accuracy
{
    NSValue * key = [NSValue valueWithNonretainedObject:note];
    NoteModel * notehit = [m_noteModelDictionary objectForKey:key];
    if(notehit != nil){
        [notehit hitNoteWithAccuracy:accuracy];
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

- (void)setNoteHit:(NSNote *)note toValue:(double)hit
{
    NSValue * key = [NSValue valueWithNonretainedObject:note];
    NoteModel * notehit = [m_noteModelUniversalDictionary objectForKey:key];
    if(notehit != nil){
        notehit.m_hit = hit;
    }
}

- (double)getNoteHit:(NSNote*)note
{
    NSValue * key = [NSValue valueWithNonretainedObject:note];
    NoteModel * notehit = [m_noteModelUniversalDictionary objectForKey:key];
    
    if(notehit != nil){
        return notehit.m_hit;
    }else{
        return -2;
    }
}

- (void)attemptFrame:(NSNoteFrame *)frame
{
    for(NSNote * note in frame.m_notesPending){
        
        NSValue * key = [NSValue valueWithNonretainedObject:note];
        NoteModel * notehit = [m_noteModelUniversalDictionary objectForKey:key];
        
        [notehit attemptNote];
    }
    
    // set a timer to unset the attempt highlight if not yet green
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(unattemptFrame:) userInfo:frame repeats:NO];
}

- (void)unattemptFrame:(NSTimer *)timer
{
    NSNoteFrame * frame = [timer userInfo];
    
    for(NSNote * note in frame.m_notesPending){
        
        NSValue * key = [NSValue valueWithNonretainedObject:note];
        NoteModel * notehit = [m_noteModelUniversalDictionary objectForKey:key];
        
        [notehit unattemptNote];
    }
}

@end
