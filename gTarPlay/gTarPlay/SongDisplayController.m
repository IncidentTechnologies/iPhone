//
//  SongDisplayController.m
//  gTarPlay
//
//  Created by Marty Greenia on 8/8/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SongDisplayController.h"

#import <gTarAppCore/AppCore.h>

#import "SongES1Renderer.h"

#import <gTarAppCore/NoteAnimation.h>
#import <gTarAppCore/NoteModel.h>
#import <gTarAppCore/LineModel.h>
#import <gTarAppCore/StringModel.h>
#import <gTarAppCore/NumberModel.h>

#import <gTarAppCore/NSNote.h>
#import <gTarAppCore/NSSong.h>
#import <gTarAppCore/NSMeasure.h>
#import <gTarAppCore/NSSongModel.h>
#import <gTarAppCore/NSNoteFrame.h>

#import "gTarColors.h"

#define PRELOAD_INITIAL 128
#define PRELOAD_MAX 256
#define PRELOAD_INCREMENT 8
#define PRELOAD_TIMER_DURATION 2.0

#define GL_SCREEN_HEIGHT (m_glView.frame.size.height)
#define GL_SCREEN_WIDTH (m_glView.frame.size.width)

// empirically determined ratios defining screen layout for what looks good.
#define GL_SCREEN_TOP_BUFFER ( GL_SCREEN_HEIGHT / 6.30 )
#define GL_SCREEN_BOTTOM_BUFFER ( GL_SCREEN_HEIGHT / 3.35 )
#define GL_SCREEN_SEEK_LINE_OFFSET ( GL_SCREEN_WIDTH / 8.0 )

#define GL_NOTE_HEIGHT ( GL_SCREEN_HEIGHT / 8.0 )
//#define GL_STRING_HEIGHT ( GL_SCREEN_HEIGHT / 50.0 )
#define GL_STRING_HEIGHT ( GL_SCREEN_HEIGHT / 30.0 )
#define GL_STRING_HEIGHT_INCREMENT ( GL_SCREEN_HEIGHT / 320.0 ) 
//#define GL_STRING_HEIGHT_INCREMENT ( GL_SCREEN_HEIGHT / 480.0 ) 

#define SONG_BEATS_PER_SCREEN 4
#define SONG_BEAT_OFFSET (SONG_BEATS_PER_SCREEN * GL_SCREEN_SEEK_LINE_OFFSET / GL_SCREEN_WIDTH )

@implementation SongDisplayController

- (id)initWithSong:(NSSongModel*)song andView:(EAGLView*)glView
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
    
    // increase the preloading window overtime
//    if ( (m_framesDisplayed % 10) == 0 )
//    {
//        m_beatsToPreloadSync = MIN(m_songModel.m_lengthBeats, m_beatsToPreloadSync+1);
//        m_beatsToPreloadAsync = MAX(m_beatsToPreloadSync, m_beatsToPreloadAsync);
//    }

    [self updateDisplayedFrames];
    
    double position = [self convertBeatToCoordSpace:m_songModel.m_currentBeat];
    
    // pull down the shift as time goes by
    double end = [self calculateMaxShiftCoordSpace];

    if ( m_renderer.m_viewShift > end )
    {
        m_renderer.m_viewShift = end;
    }
    
    [m_renderer updatePositionAndRender:position];
    
    [m_glView drawView];
    
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
        
    for ( NSNote * note in frame.m_notes )
    {
        
        CGPoint center;
		center.x = [self convertBeatToCoordSpace:note.m_absoluteBeatStart];
		center.y = [self convertStringToCoordSpace:note.m_string];
		
		// number texture overlay
		NumberModel * overlay;
        
        if ( note.m_fret == GTAR_GUITAR_FRET_MUTED )
        {
            overlay = m_mutedTexture;
        }
        else
        {
            overlay = [m_numberModels objectAtIndex:note.m_fret];
        }
        
        NoteModel * model;
        
        model = [[NoteModel alloc] initWithCenter:center andColor:g_stringColors[note.m_string - 1] andTexture:m_noteTexture andOverlay:overlay];
        
        NSValue * key = [NSValue valueWithNonretainedObject:note];
        
        [m_noteModelDictionary setObject:model forKey:key];
        
        [m_renderer addModel:model];
        
        [model release];
        
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
    double end = [self calculateMaxShiftCoordSpace];
    
    if ( m_viewShift < 0.0 )
    {
        m_viewShift = 0.0;
    }
    else if ( end < m_viewShift )
    {
        m_viewShift = end;
    }
    
    double viewShiftBeats = [self convertCoordSpaceToBeat:m_viewShift] + SONG_BEATS_PER_SCREEN;
    
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
    double end = [self calculateMaxShiftCoordSpace];
    
    if ( m_viewShift < 0.0 )
    {
        m_viewShift = 0.0;
    }
    else if ( end < m_viewShift )
    {
        m_viewShift = end;
    }
    
    double viewShiftBeats = [self convertCoordSpaceToBeat:m_viewShift] + SONG_BEATS_PER_SCREEN;
    
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
	size.width = GL_STRING_HEIGHT;
	size.height = GL_SCREEN_HEIGHT;
    
    // The center will automatically be offset in the rendering
	CGPoint center;
	center.y = GL_SCREEN_HEIGHT / 2.0;
	center.x = 0;
	
	m_renderer.m_seekLineModel = [[[LineModel alloc] initWithCenter:center andSize:size andColor:g_whiteColor] autorelease];
    
    //
    // Create the strings
    // 
        
    center.x = GL_SCREEN_WIDTH / 2.0;
    
    size.width = GL_SCREEN_WIDTH;
    
    for ( unsigned int i = 0; i < GTAR_GUITAR_STRING_COUNT; i++ )
    {
        
        // strings number and size are inversely proportional -- get slightly bigger
        size.height = GL_STRING_HEIGHT + (GTAR_GUITAR_STRING_COUNT - 1 - i) * GL_STRING_HEIGHT_INCREMENT;
        center.y = [self convertStringToCoordSpace:(i+1)];
        
//        StringModel * stringModel = [[StringModel alloc] initWithCenter:center andSize:size andColor:( g_stringColors[i] )];
        StringModel * stringModel = [[StringModel alloc] initWithCenter:center andSize:size andColor:( g_whiteColor ) andImage:[UIImage imageNamed:@"DoubleString.png"]];
        
        [m_renderer addString:stringModel];
        
        [stringModel release];
        
    }
    
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
    
}

- (void)createNumberModels
{
	
	CGSize size;
	size.width = GL_NOTE_HEIGHT;
	size.height = GL_NOTE_HEIGHT;
	
	for ( unsigned int i = 0; i < GTAR_GUITAR_FRET_COUNT; i++ )
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
    UIImage * image = [UIImage imageNamed:@"note-blank4.png"];
    
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
    
    filePath = [[NSBundle mainBundle] pathForResource:@"WoodBGRev" ofType:@"png"];
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

- (double)convertTimeToCoordSpace:(double)delta
{
    return [self convertBeatToCoordSpace:(m_songModel.m_beatsPerSecond * delta)];
}
 
- (double)convertBeatToCoordSpace:(double)beat
{
	return beat / (GLfloat)SONG_BEATS_PER_SCREEN * GL_SCREEN_WIDTH;
}

- (double)convertCoordSpaceToBeat:(double)coord
{
	return coord * (GLfloat)SONG_BEATS_PER_SCREEN / GL_SCREEN_WIDTH;
}

- (double)convertStringToCoordSpace:(NSInteger)str
{
	GLfloat effectiveScreenHeight = (GL_SCREEN_HEIGHT) - (GL_SCREEN_TOP_BUFFER + GL_SCREEN_BOTTOM_BUFFER);
	
	GLfloat heightPerString = effectiveScreenHeight / ((GLfloat)GTAR_GUITAR_STRING_COUNT-1);
	
    // bias it down to zero-base it
	return GL_SCREEN_BOTTOM_BUFFER + ( (str-1) * heightPerString );
}

- (double)calculateMaxShiftCoordSpace
{
    double beatsToShift = m_songModel.m_lengthBeats - m_songModel.m_currentBeat - SONG_BEATS_PER_SCREEN + SONG_BEAT_OFFSET;
    double end = [self convertBeatToCoordSpace:MAX(beatsToShift,0)];
    return end;    
}

@end
