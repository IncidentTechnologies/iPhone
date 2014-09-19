//
//  RecordEditor.m
//  Sequence
//
//  Created by Kate Schnippering on 9/18/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "RecordEditor.h"

#define PATTERN_A @"-A"
#define PATTERN_B @"-B"
#define PATTERN_C @"-C"
#define PATTERN_D @"-D"
#define PATTERN_OFF @"-ø"

#define PATTERN_LETTER_WIDTH 30.0
#define PATTERN_LETTER_INDENT 10.0

#define A_COLOR [UIColor colorWithRed:23/255.0 green:163/255.0 blue:198/255.0 alpha:0.5]
#define B_COLOR [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:0.5]
#define C_COLOR [UIColor colorWithRed:0/255.0 green:161/255.0 blue:222/255.0 alpha:0.5]
#define D_COLOR [UIColor colorWithRed:137/255.0 green:225/255.0 blue:247/255.0 alpha:0.5]
#define OFF_COLOR [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:0.5]

#define EDITING_COLOR [UIColor colorWithRed:148/255.0 green:102/255.0 blue:176/255.0 alpha:0.5]
#define A_COLOR_SOLID [UIColor colorWithRed:76/255.0 green:146/255.0 blue:163/255.0 alpha:1.0]
#define B_COLOR_SOLID [UIColor colorWithRed:71/255.0 green:161/255.0 blue:184/255.0 alpha:1.0]
#define C_COLOR_SOLID [UIColor colorWithRed:64/255.0 green:145/255.0 blue:175/255.0 alpha:1.0]
#define D_COLOR_SOLID [UIColor colorWithRed:133/255.0 green:177/255.0 blue:188/255.0 alpha:1.0]
#define OFF_COLOR_SOLID [UIColor colorWithRed:99/255.0 green:99/255.0 blue:99/255.0 alpha:1.0]

#define MIN_TRACK_WIDTH 15.0

@implementation RecordEditor

@synthesize delegate;

- (id)initWithScrollView:(UIScrollView *)scrollView progressView:(UIView *)progress
{
    self = [super init];
    
    if ( self )
    {
        trackView = scrollView;
        progressView = progress;
        
        trackclips = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)clearAllSubviews
{
    [self clearProgressView];
    
    [trackclips removeAllObjects];
}

- (void)setMeasures:(int)measures
{
    numMeasures = measures;
}

#pragma mark - Drawing

- (UIView *)drawClipViewForClip:(NSClip *)clip track:(NSTrack *)track inFrame:(CGRect)frame atIndex:(int)index;
{
    UIView * clipView = [[UIView alloc] initWithFrame:frame];
    
    // Color according to the pattern
    if(clip.m_muted == true){
        [clipView setBackgroundColor:OFF_COLOR];
    }else if([clip.m_name isEqualToString:PATTERN_A]){
        [clipView setBackgroundColor:A_COLOR];
    }else if([clip.m_name isEqualToString:PATTERN_B]){
        [clipView setBackgroundColor:B_COLOR];
    }else if([clip.m_name isEqualToString:PATTERN_C]){
        [clipView setBackgroundColor:C_COLOR];
    }else if([clip.m_name isEqualToString:PATTERN_D]){
        [clipView setBackgroundColor:D_COLOR];
    }
    
    [trackView addSubview:clipView];
    [self addLongPressGestureToView:clipView];
    
    // Create a dictionary mapping track info to the views
    if([trackclips objectForKey:track.m_name]){
        
        NSMutableArray * clipDict = [trackclips objectForKey:track.m_name];
        
        // Add the view at a specific index
        if(index >= 0){
            
            NSMutableArray * newClipDict = [[NSMutableArray alloc] init];
            
            for(int i = 0; i <= [clipDict count]; i++){
                if(i < index){
                    [newClipDict addObject:[clipDict objectAtIndex:i]];
                }else if(i == index){
                    [newClipDict addObject:clipView];
                }else{
                    [newClipDict addObject:[clipDict objectAtIndex:i-1]];
                }
            }
            
            [trackclips setObject:newClipDict forKey:track.m_name];
            
            DLog(@"trackClips is %@",trackclips);
            
        }else{
            
            // Add it to the end
            [clipDict addObject:clipView];
        }
        
    }else{
        
        // Create a new array
        NSMutableArray * clipDict = [[NSMutableArray alloc] init];
        [clipDict addObject:clipView];
        [trackclips setObject:clipDict forKey:track.m_name];
    }
    
    
    return clipView;
}

- (void)drawPatternLetterForClip:(NSClip *)clip inView:(UIView *)view
{
    CGRect patternLetterFrame = CGRectMake(PATTERN_LETTER_INDENT,0,PATTERN_LETTER_WIDTH,view.frame.size.height);
    
    UILabel * patternLetter = [[UILabel alloc] initWithFrame:patternLetterFrame];
    [patternLetter setText:[clip.m_name stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    [patternLetter setTextColor:[UIColor whiteColor]];
    [patternLetter setAlpha:0.5];
    [patternLetter setFont:[UIFont fontWithName:FONT_BOLD size:20.0]];
    
    if(clip.m_muted){
        [patternLetter setText:@""];
    }
    
    [view addSubview:patternLetter];
}

- (void)drawProgressBarForClip:(NSClip *)clip atIndex:(float)trackIndex
{
    float measureHeight = progressView.frame.size.height / (float)MAX_TRACKS;
    double progressClipStart = [self getProgressXPositionForClipBeat:clip.m_startbeat];
    double progressClipEnd = [self getProgressXPositionForClipBeat:clip.m_endbeat];
    
    DLog(@"Clip start %f end %f beats %f to %f numMeasures %i",progressClipStart,progressClipEnd,clip.m_startbeat,clip.m_endbeat,numMeasures);
    
    CGRect clipProgressFrame = CGRectMake(progressClipStart,trackIndex * measureHeight + measureHeight / 2.0,progressClipEnd - progressClipStart,1);
    
    UIView * progressClip = [[UIView alloc] initWithFrame:clipProgressFrame];
    [progressClip setBackgroundColor:[UIColor whiteColor]];
    
    if(!clip.m_muted){
        [progressView addSubview:progressClip];
    }
    
}

- (void)addLongPressGestureToView:(UIView *)view
{
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEvent:)];
    longPress.minimumPressDuration = 0.5;
    
    [view addGestureRecognizer:longPress];
}

#pragma mark - Progress View

- (void)clearProgressView
{
    for(UIView * v in progressView.subviews){
        [v removeFromSuperview];
    }
}

- (void)refreshProgressView
{
    [self clearProgressView];
    [delegate redrawProgressView];
}

#pragma mark - Track Editing Interface

//
// UI Action to initiate the editing
//
- (void)longPressEvent:(UILongPressGestureRecognizer *)recognizer
{
    UIView * pressedTrack = (UIView *)recognizer.view;
    
    if(pressedTrack != editingClipView){
        
        [self deactivateEditingClip];
        
        for(id t in trackclips){
            NSMutableArray * clipDict = [trackclips objectForKey:t];
            NSString * trackName = (NSString *)t;
            
            for(int c = 0; c < [clipDict count]; c++){
                UIView * v = [clipDict objectAtIndex:c];
                
                if(v == pressedTrack){
                    
                    editingTrack = [delegate trackWithName:trackName];
                    
                    editingClip = [editingTrack.m_clips objectAtIndex:c];
                    editingClipView = pressedTrack;
                    
                    DLog(@"Editing track %@ at clip %i with name %@",trackName,c,editingClip.m_name);
                }
            }
        }
        
        if(editingClipView != nil){
            [self activateEditingClip];
        }
    }
}

// End the editing on another clip
- (void)deactivateEditingClip
{
    [horizontalAdjustor hideControls];
    
    DLog(@"TODO: update the data on patterns that have changed");
    
    [self mergeNeighboringIdenticalClips];
    [self correctMeasureLengths];
    [self refreshProgressView];
    
    if(editingClipView != nil){
        
        // Deactivate
        UIColor * oldColor;
        if(editingClip.m_muted){
            oldColor = OFF_COLOR;
        }else if([editingClip.m_name isEqualToString:PATTERN_A]){
            oldColor = A_COLOR;
        }else if([editingClip.m_name isEqualToString:PATTERN_B]){
            oldColor = B_COLOR;
        }else if([editingClip.m_name isEqualToString:PATTERN_C]){
            oldColor = C_COLOR;
        }else if([editingClip.m_name isEqualToString:PATTERN_D]){
            oldColor = D_COLOR;
        }
        
        [UIView animateWithDuration:0.3 animations:^(void){
            [editingClipView setBackgroundColor:oldColor];
        }];
        
        [self resetEditingClipPattern];
    }
    
    editingTrack = nil;
    editingClip = nil;
    editingClipView = nil;
    editingPatternLetter = nil;
    editingPatternLetterOverlay = nil;
    horizontalAdjustor = nil;
    
}

// Start editing a clip
- (void)activateEditingClip
{
    // Activate
    [UIView animateWithDuration:0.3 animations:^(void){
        [editingClipView setBackgroundColor:EDITING_COLOR];
    }];
    
    // Draw sliders
    [self initEditingClipSliders];
    
    // Blink the letter label
    [self initEditingClipPattern];
}

#pragma mark - Pattern Editing

// Reset the pattern name from editing
- (void)resetEditingClipPattern
{
    [editingPatternLetterOverlay removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    UILabel * labelToFadeOut = editingPatternLetter;
    
    if(editingClip.m_muted){
        
        // Fade text out
        [UIView animateWithDuration:0.1 animations:^(void){
            [labelToFadeOut setAlpha:0.0];
        } completion:^(BOOL finished){
            labelToFadeOut.text = @"";
            [labelToFadeOut setAlpha:1.0];
        }];
        
    }else{
        
        // Shrink and realign text
        [UIView animateWithDuration:0.1 animations:^(void){
            
            [labelToFadeOut setAlpha:0.5];
            [labelToFadeOut setFont:[UIFont fontWithName:FONT_BOLD size:20.0]];
            
            [labelToFadeOut setFrame:CGRectMake(PATTERN_LETTER_INDENT,0,PATTERN_LETTER_WIDTH,labelToFadeOut.frame.size.height)];
        }];
    }
    
}

// Start editing the pattern name
- (void)initEditingClipPattern
{
    editingPatternLetter = (UILabel *)[editingClipView.subviews firstObject];
    
    // Use overlay because treating the letter as a button does not work
    // with the animation and listener simultaneously
    editingPatternLetterOverlay = [[UIButton alloc] initWithFrame:CGRectMake(2*PATTERN_LETTER_INDENT,0,1.5*PATTERN_LETTER_WIDTH,editingPatternLetter.frame.size.height)];
    
    [editingPatternLetterOverlay addTarget:self action:@selector(changeLetterPattern:) forControlEvents:UIControlEventTouchUpInside];
    
    [editingClipView addSubview:editingPatternLetterOverlay];
    
    if([editingPatternLetter.text isEqualToString:@""]){
        editingPatternLetter.text = [PATTERN_OFF stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    [UIView animateWithDuration:0.1 animations:^(void){
        
        [editingPatternLetter setAlpha:0.8];
        [editingPatternLetter setFont:[UIFont fontWithName:FONT_BOLD size:28.0]];
        
        [editingPatternLetter setFrame:CGRectMake(3*PATTERN_LETTER_INDENT,0,PATTERN_LETTER_WIDTH,editingPatternLetter.frame.size.height)];
        
    } completion:^(BOOL finished){
        
        blinkingClip = editingClip;
        [self blinkEditingClipOff];
        
    }];
    
}

- (void)blinkEditingClipOff
{
    if(editingClip != blinkingClip){
        return;
    }
    
    [UIView animateWithDuration:0.4 delay:0.3 options:nil animations:^(void){
        
        [editingPatternLetter setAlpha:0.3];
        
    }completion:^(BOOL finished){
        
        [self blinkEditingClipOn];
    }];
    
}

- (void)blinkEditingClipOn
{
    if(editingClip != blinkingClip){
        return;
    }
    
    [UIView animateWithDuration:0.4 delay:0.1 options:nil animations:^(void){
        
        [editingPatternLetter setAlpha:0.8];
        
    }completion:^(BOOL finished){
        
        [self blinkEditingClipOff];
    }];
    
}

- (void)changeLetterPattern:(id)sender
{
    NSString * newPattern;
    
    if(editingClip.m_muted){
        newPattern = PATTERN_A;
        [editingClip changePattern:PATTERN_A];
        editingClip.m_muted = NO;
    }else if([editingClip.m_name isEqualToString:PATTERN_A]){
        newPattern = PATTERN_B;
        [editingClip changePattern:PATTERN_B];
    }else if([editingClip.m_name isEqualToString:PATTERN_B]){
        newPattern = PATTERN_C;
        [editingClip changePattern:PATTERN_C];
    }else if([editingClip.m_name isEqualToString:PATTERN_C]){
        newPattern = PATTERN_D;
        [editingClip changePattern:PATTERN_D];
    }else if([editingClip.m_name isEqualToString:PATTERN_D]){
        newPattern = PATTERN_OFF;
        editingClip.m_muted = YES;
    }
    
    newPattern = [newPattern stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    [editingPatternLetter setText:newPattern];
}

#pragma mark - Pan Gesture Reactions

// Init horizontal trimming sliders
- (void)initEditingClipSliders
{
    horizontalAdjustor = [[HorizontalAdjustor alloc] initWithContainer:trackView background:trackView bar:editingClipView];
    
    horizontalAdjustor.delegate = self;
    
    [horizontalAdjustor setBarDefaultWidth:trackView.contentSize.width minWidth:MIN_TRACK_WIDTH];
    
    [horizontalAdjustor showControlsRelativeToView:editingClipView];
    
    lastDiff = 0;
    
}

- (void)panLeft:(float)diff
{
    NSMutableArray * clipDict = [trackclips objectForKey:editingTrack.m_name];
    
    int editingClipIndex = 0;
    for(int c = 0; c < [clipDict count]; c++){
        UIView * clipView = [clipDict objectAtIndex:c];
        
        if(clipView == editingClipView){
            editingClipIndex = c;
            break;
        }
    }
    
    // Trim the leftward clip in track
    if(editingClipIndex > 0){
        UIView * leftClipView = [clipDict objectAtIndex:editingClipIndex-1];
        
        [leftClipView setFrame:CGRectMake(leftClipView.frame.origin.x,leftClipView.frame.origin.y,leftClipView.frame.size.width+(diff-lastDiff),leftClipView.frame.size.height)];
        
        if(editingClipView.frame.origin.x <= leftClipView.frame.origin.x){
            [self removeClipInEditing:leftClipView];
        }else{
            
            // Set beats for left clip
            NSClip * leftClip = [editingTrack.m_clips objectAtIndex:editingClipIndex-1];
            [self setBeatsForClip:leftClip withView:leftClipView];
            
        }
        
    }
    
    // Create new muted clip to the left
    if(editingClipIndex == 0 && editingClipView.frame.origin.x > 0){
        [self createNewMutedClipFrom:0.0 to:editingClipView.frame.origin.x];
    }
    
    // Delete the measure if it's been shrunken too much
    if(editingClipView.frame.size.width < MIN_TRACK_WIDTH){
        [self removeClipInEditing:editingClipView];
    }
    
    // Set beats for editing clip
    if(editingClipView != nil){
        [self setBeatsForClip:editingClip withView:editingClipView];
    }
    
    lastDiff = diff;
}

- (void)panRight:(float)diff
{
    // Move all rightward clips in the track
    
    NSMutableArray * clipDict = [trackclips objectForKey:editingTrack.m_name];
    
    for(int c = 0; c < [clipDict count]; c++){
        UIView * clipView = [clipDict objectAtIndex:c];
        
        if(clipView.frame.origin.x > editingClipView.frame.origin.x){
            [clipView setFrame:CGRectMake(clipView.frame.origin.x+(diff-lastDiff),clipView.frame.origin.y,clipView.frame.size.width,clipView.frame.size.height)];
            
            // Set beats
            NSClip * rightClip = [editingTrack.m_clips objectAtIndex:c];
            [self setBeatsForClip:rightClip withView:clipView];
        }
    }
    
    if(editingClipView.frame.size.width < MIN_TRACK_WIDTH){
        [self removeClipInEditing:editingClipView];
    }
    
    // Set beats for editing clip
    if(editingClipView != nil){
        [self setBeatsForClip:editingClip withView:editingClipView];
    }
    
    
    lastDiff = diff;
    
}

- (void)endPanLeft
{
    lastDiff = 0;
}

- (void)endPanRight
{
    lastDiff = 0;
}

- (void)setBeatsForClip:(NSClip *)clip withView:(UIView *)view
{
    double startbeat = [self getBeatFromXPosition:view.frame.origin.x];
    double endbeat = [self getBeatFromXPosition:view.frame.origin.x+view.frame.size.width];
    
    [clip setTempStartbeat:startbeat tempEndbeat:endbeat];
    
    DLog(@"Set temp beats for clip %@ from %f to %f",clip.m_name,startbeat,endbeat);
}

#pragma mark - Track Editing Actions

//
// Delete Track
//
- (void)removeClipInEditing:(UIView *)clipToRemove
{
    DLog(@"Remove clip in editing");
    
    // Update dictionaries
    NSMutableArray * clipDict = [trackclips objectForKey:editingTrack.m_name];
    
    int clipToRemoveIndex = -1;
    for(int c = 0; c < [clipDict count]; c++){
        UIView * clipView = [clipDict objectAtIndex:c];
        
        if(clipView == clipToRemove){
            clipToRemoveIndex = c;
            break;
        }
    }
    
    if(clipToRemoveIndex < 0){
        return;
    }
    
    NSClip * clip = [editingTrack.m_clips objectAtIndex:clipToRemoveIndex];
    
    [clipDict removeObjectAtIndex:clipToRemoveIndex];
    
    // Start the next track in its place
    if(clipToRemoveIndex < [clipDict count]){
        
        DLog(@"Start the next track in its place %i",clipToRemoveIndex);
        
        UIView * nextTrack = [clipDict objectAtIndex:clipToRemoveIndex];
        NSClip * nextTrackClip = [editingTrack.m_clips objectAtIndex:clipToRemoveIndex+1];
        
        [nextTrack setFrame:CGRectMake(clipToRemove.frame.origin.x,nextTrack.frame.origin.y,nextTrack.frame.size.width,nextTrack.frame.size.height)];
        
        [nextTrackClip setTempStartbeat:clip.m_startbeat tempEndbeat:nextTrackClip.m_endbeat];
        
    }else if(clipToRemoveIndex > 0){
        
        DLog(@"Stretch out the previous track %i",clipToRemoveIndex-1);
        
        // Or stretch out the previous track if there is no next track
        UIView * prevTrack = [clipDict objectAtIndex:clipToRemoveIndex-1];
        NSClip * prevTrackClip = [editingTrack.m_clips objectAtIndex:clipToRemoveIndex-1];
        
        [prevTrack setFrame:CGRectMake(prevTrack.frame.origin.x,prevTrack.frame.origin.y,clipToRemove.frame.origin.x-prevTrack.frame.origin.x+clipToRemove.frame.size.width,prevTrack.frame.size.height)];
        
        [prevTrackClip setTempStartbeat:prevTrackClip.m_startbeat tempEndbeat:clip.m_endbeat];
        
    }
    
    // Remove from clips
    
    DLog(@"TODO: update the pattern data from deleted tracks");
    [editingTrack.m_clips removeObject:clip];
    
    // Remove from superview
    
    if(clipToRemove == editingClipView){
        editingClipView = nil;
        [self deactivateEditingClip];
    }
    
    [clipToRemove removeFromSuperview];
    
    [self mergeNeighboringIdenticalClips];
    [self correctMeasureLengths];
    [self refreshProgressView];
    
}

//
// Merge Tracks
//
- (void)mergeNeighboringIdenticalClips
{
    
    NSMutableArray * clipDict = [trackclips objectForKey:editingTrack.m_name];
    
    if([clipDict count] <= 1 || [editingTrack.m_clips count] <= 1){
        return;
    }
    
    DLog(@"Merge neighboring identical clips");
    
    NSMutableArray * trackClipsToRemove = [[NSMutableArray alloc] init];
    NSMutableArray * trackClipViewsToRemove = [[NSMutableArray alloc] init];
    
    for(int i = [editingTrack.m_clips count]-1; i > 0 ; i--){
        UIView * firstClipView = [clipDict objectAtIndex:i-1];
        UIView * nextClipView = [clipDict objectAtIndex:i];
        
        NSClip * firstClip = [editingTrack.m_clips objectAtIndex:i-1];
        NSClip * nextClip = [editingTrack.m_clips objectAtIndex:i];
        
        // Case to merge!
        if([firstClip.m_name isEqualToString:nextClip.m_name] && firstClip.m_muted == nextClip.m_muted){
            [firstClipView setFrame:CGRectMake(firstClipView.frame.origin.x,firstClipView.frame.origin.y,firstClipView.frame.size.width+nextClipView.frame.size.width,firstClipView.frame.size.height)];
            
            [trackClipsToRemove addObject:nextClip];
            [trackClipViewsToRemove addObject:nextClipView];
            
            // Set beats
            [self setBeatsForClip:firstClip withView:firstClipView];
            [firstClip setTempStartbeat:firstClip.m_startbeat tempEndbeat:nextClip.m_endbeat];
            
        }
    }
    
    // Remove from track clips
    [editingTrack.m_clips removeObjectsInArray:trackClipsToRemove];
    [clipDict removeObjectsInArray:trackClipViewsToRemove];
    
    // Remove UIViews
    for(UIView * v in trackClipViewsToRemove){
        [v removeFromSuperview];
    }
}

//
// Correct measure lengths after editing
//
- (void)correctMeasureLengths
{
    DLog(@"Correct measure lengths after editing");
    
    if(editingTrack == nil){
        DLog(@"ERROR: editingTrack is nil");
        return;
    }
    
    float measureWidth = trackView.frame.size.width / MEASURES_PER_SCREEN;
    
    NSMutableArray * clipDict = [trackclips objectForKey:editingTrack.m_name];
    
    NSTrack * instTrack = [delegate instTrackAtId:editingTrack.m_instrument.m_id];
    
    for(int c = 0; c < [clipDict count]; c++){
        UIView * clipView = [clipDict objectAtIndex:c];
        NSClip * clip = [editingTrack.m_clips objectAtIndex:c];
        
        // No adjustments if the measure is muted
        if(clip.m_muted){
            continue;
        }
        
        int patternLength = [instTrack getPatternLengthByName:clip.m_name];
        
        if(patternLength == 0){
            DLog(@"ERROR: pattern length 0");
            return;
        }
        
        BOOL measureBeforeIsMuted = (c > 0) ? [[editingTrack.m_clips objectAtIndex:c-1] m_muted]: false;
        BOOL measureAfterIsMuted = (c < [clipDict count]-1) ? [[editingTrack.m_clips objectAtIndex:c+1] m_muted] : false;
        
        // Get current start measure/end measure
        int clipStartMeasure;
        int clipEndMeasure;
        
        // Round up or round down
        if(clip.m_startbeat - 4.0*[clip getDownMeasureForBeat:clip.m_startbeat] < 2.0){
            clipStartMeasure = (int)[clip getDownMeasureForBeat:clip.m_startbeat];
        }else{
            clipStartMeasure = (int)[clip getMeasureForBeat:clip.m_startbeat];
        }
        
        if(clip.m_endbeat - 4.0*[clip getDownMeasureForBeat:clip.m_endbeat] < 2.0){
            clipEndMeasure = (int)[clip getDownMeasureForBeat:clip.m_endbeat];
        }else{
            clipEndMeasure = (int)[clip getMeasureForBeat:clip.m_endbeat];
        }
        
        //
        
        double diffBeats = 0;
        
        // Validate ... and adjust ...
        
        // Start it on a valid measure
        if(!measureBeforeIsMuted){
            if(fabs(clip.m_startbeat - 4.0*clipStartMeasure) > 0.05 || clipStartMeasure % patternLength != 0){
                
                DLog(@" *** absmath = %f, modmath = %i",clip.m_startbeat - 4.0*clipStartMeasure,clipStartMeasure % patternLength);
                
                int patternOffset = (clipEndMeasure % patternLength == 0) ? 0 : patternLength - clipStartMeasure % patternLength;
                int targetMeasure = clipStartMeasure + patternOffset;
                double targetStartbeat = targetMeasure * 4.0;
                double targetStartX = targetMeasure * measureWidth;
                double targetEndbeat = clip.m_endbeat + targetStartX - clip.m_startbeat;
                diffBeats = targetStartbeat - clip.m_startbeat;
                
                [clipView setFrame:CGRectMake(targetStartX, clipView.frame.origin.y, clipView.frame.size.width, clipView.frame.size.height)];
                
                DLog(@" *** SHIFT UP RESET CLIP %i STARTBEAT from %f to %f",c,clip.m_startbeat,targetStartbeat);
                
                [clip setTempStartbeat:targetStartbeat tempEndbeat:targetEndbeat];
                
            }
        }
        
        // End it on a valid measure
        if(!measureAfterIsMuted && c < [clipDict count] - 1){
            if(fabs(clip.m_endbeat - 4.0*clipEndMeasure) > 0.05 || clipEndMeasure % patternLength != 0){
                
                DLog(@" *** absmath = %f, modmath = %i",clip.m_endbeat - 4.0*clipEndMeasure,clipEndMeasure % patternLength);
                
                int patternOffset = (clipEndMeasure % patternLength == 0) ? 0 : patternLength - clipEndMeasure % patternLength;
                int targetMeasure = clipEndMeasure + patternOffset;
                double targetEndbeat = targetMeasure * 4.0;
                double targetEndX = targetMeasure * measureWidth;
                diffBeats = targetEndbeat - clip.m_endbeat;
                
                [clipView setFrame:CGRectMake(clipView.frame.origin.x, clipView.frame.origin.y, targetEndX-clipView.frame.origin.x, clipView.frame.size.height)];
                
                DLog(@" *** SHIFT UP RESET CLIP %i ENDBEAT from %f to %f, targetEndX: %f (MW:%f)",c,clip.m_endbeat,targetEndbeat,targetEndX,measureWidth);
                
                [clip setEndbeat:targetEndbeat];
                
            }
        }
        
        // Shift over everything that follows
        if(diffBeats > 0){
            
            for(int k = c+1; k < [clipDict count]; k++){
                NSClip * nextClip = [editingTrack.m_clips objectAtIndex:k];
                UIView * nextClipView = [clipDict objectAtIndex:k];
                [nextClip setTempStartbeat:nextClip.m_startbeat+diffBeats tempEndbeat:nextClip.m_endbeat+diffBeats];
                
                double targetStartX = [self getXPositionForClipBeat:nextClip.m_startbeat];
                double targetEndX = [self getXPositionForClipBeat:nextClip.m_endbeat];
                
                [nextClipView setFrame:CGRectMake(targetStartX,nextClipView.frame.origin.y,targetEndX-targetStartX,nextClipView.frame.size.height)];
                
                DLog(@"SHIFT OVER CLIP %i BY %f BEATS redraw starting X to %f",k,diffBeats,targetStartX);
            }
        }
    }
}

//
// Create new muted measure
//
- (void)createNewMutedClipFrom:(float)fromX to:(float)toX
{
    int newIndex = 0;
    
    DLog(@"Create new muted clip from %f to %f",fromX,toX);
    
    NSClip * newClip = [[NSClip alloc] initWithName:PATTERN_A startbeat:0.0 endBeat:0.0 clipLength:0.0 clipStart:0.0 looping:false loopStart:0.0 looplength:0.0 color:@"" muted:YES];
    
    DLog(@"TODO: more cleverly determine index of new muted clip");
    [editingTrack addClip:newClip atIndex:newIndex];
    
    // Create the clip
    CGRect newClipFrame = CGRectMake(fromX,editingClipView.frame.origin.y,toX-fromX,editingClipView.frame.size.height);
    
    UIView * newClipView = [self drawClipViewForClip:newClip track:editingTrack inFrame:newClipFrame atIndex:newIndex];
    
    // Draw the pattern letters
    [self drawPatternLetterForClip:newClip inView:newClipView];
    
    // Set beats
    [self setBeatsForClip:newClip withView:newClipView];
    
}

#pragma mark - Beats in view arithmetic

-(float)getBeatFromXPosition:(float)x
{
    float measureWidth = trackView.frame.size.width / MEASURES_PER_SCREEN;
    
    float beat = x * 4.0 / measureWidth;
    
    return beat;
}

-(float)getXPositionForClipBeat:(float)beat
{
    float measureWidth = trackView.frame.size.width / MEASURES_PER_SCREEN;
    
    double x = beat * measureWidth / 4.0;
    
    return x;
}


-(float)getProgressXPositionForClipBeat:(float)beat
{
    float measureWidth = progressView.frame.size.width / numMeasures;
    
    float x = beat * measureWidth / 4.0;
    
    return x;
}

@end
