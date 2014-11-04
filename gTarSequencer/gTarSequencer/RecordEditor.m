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
#define PATTERN_E @"-★" // Custom
#define PATTERN_E_PENDING @"-E" // Custom pending
#define PATTERN_OFF @"-ø"

#define PATTERN_LETTER_WIDTH 30.0
#define PATTERN_LETTER_INDENT 10.0

#define A_COLOR [UIColor colorWithRed:23/255.0 green:163/255.0 blue:198/255.0 alpha:0.5]
#define B_COLOR [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:0.5]
#define C_COLOR [UIColor colorWithRed:0/255.0 green:161/255.0 blue:222/255.0 alpha:0.5]
#define D_COLOR [UIColor colorWithRed:137/255.0 green:225/255.0 blue:247/255.0 alpha:0.5]
#define E_COLOR [UIColor colorWithRed:0/255.0 green:140/255.0 blue:217/255.0 alpha:0.5]
#define OFF_COLOR [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:0.5]

#define EDITING_COLOR [UIColor colorWithRed:148/255.0 green:102/255.0 blue:176/255.0 alpha:0.5]
#define ADDING_COLOR [UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:0.8]
#define A_COLOR_SOLID [UIColor colorWithRed:76/255.0 green:146/255.0 blue:163/255.0 alpha:1.0]
#define B_COLOR_SOLID [UIColor colorWithRed:71/255.0 green:161/255.0 blue:184/255.0 alpha:1.0]
#define C_COLOR_SOLID [UIColor colorWithRed:64/255.0 green:145/255.0 blue:175/255.0 alpha:1.0]
#define D_COLOR_SOLID [UIColor colorWithRed:133/255.0 green:177/255.0 blue:188/255.0 alpha:1.0]
#define E_COLOR_SOLID [UIColor colorWithRed:0/255.0 green:140/255.0 blue:217/255.0 alpha:1.0]
#define OFF_COLOR_SOLID [UIColor colorWithRed:99/255.0 green:99/255.0 blue:99/255.0 alpha:1.0]

#define MIN_TRACK_WIDTH 30.0
#define MIN_LEFT_TRACK_WIDTH 5.0
#define MAX_MOVING_MEASURES 5.0

@implementation RecordEditor

@synthesize delegate;

- (id)initWithScrollView:(UIScrollView *)scrollView progressView:(UIView *)progress editingPanel:(UIView *)editingView instrumentPanel:(UIView *)instrumentView
{
    self = [super init];
    
    if ( self )
    {
        trackView = scrollView;
        
        
        FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
        
        measureWidth = [frameGenerator getRecordedTrackScreenWidth] / MEASURES_PER_SCREEN;
        
        measureHeight = trackView.frame.size.height / MAX_TRACKS;
        
        progressView = progress;
        
        trackclips = [[NSMutableDictionary alloc] init];
        
        trackaddclips = [[NSMutableDictionary alloc] init];
        
        editingPanel = editingView;
        
        instrumentPanel = instrumentView;
        
        [self initColors];
        
    }
    
    return self;
}

- (void)initColors
{
    CGFloat initColors[STRINGS_ON_GTAR][4] = {
        {148/255.0, 102/255.0, 177/255.0, 1},
        {0/255.0, 141/255.0, 218/255.0, 1},
        {43/255.0, 198/255.0, 34/255.0, 1},
        {204/255.0, 234/255.0, 0/255.0, 1},
        {234/255.0, 154/255.0, 41/255.0, 1},
        {239/255.0, 92/255.0, 53/255.0, 1}
    };
    
    memcpy(colors, initColors, sizeof(initColors));
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

- (void)refreshLoadedTrack:(NSTrack *)track
{
    editingTrack = track;
    
    // Ensure data is up to date
    [self mergeNeighboringIdenticalClips:YES];
    [self correctMeasureLengths];
    [self shrinkExpandMeasuresOnScreen];
    [delegate drawTickmarks];
    [delegate drawGridOverlayLines];
    [self refreshProgressView];
    [delegate regenerateDataForTrack:editingTrack];
    
    [self redrawAllPatternNotes];
    
    track = nil;
    
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
    }else{
        [clipView setBackgroundColor:E_COLOR];
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

// Draw all the notes from a clip
- (void)drawPatternNotesForClip:(NSClip *)clip inView:(UIView *)view
{
    
    if(clip.m_muted){
        return;
    }
 
    CGSize size = CGSizeMake(view.frame.size.width, view.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size,NO,0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    double lineWidth = 0.2;
    
    CGFloat noteFrameWidth = measureWidth / FRETS_ON_GTAR;
    CGFloat noteFrameHeight = view.frame.size.height / STRINGS_ON_GTAR;
    CGFloat noteSquare = MIN(noteFrameWidth,noteFrameHeight);
    CGFloat noteVerticalPadding = (noteFrameHeight > noteFrameWidth) ? (noteFrameHeight-noteFrameWidth)/2.0 : 0;
    
    CGRect noteFrame = CGRectMake(0, 0, noteSquare, noteSquare);
    
    // Set line width:
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // Update all the notes:
    int f, s;
    for(NSNote * note in clip.m_notes){
        
        if(note.m_beatstart < clip.m_endbeat){
            s = STRINGS_ON_GTAR - 1 - note.m_stringvalue;
            f = (int)((note.m_beatstart - clip.m_startbeat) * 4.0);
            
            // Adjust frame:
            noteFrame.origin.x = f*noteFrameWidth+1.0;
            noteFrame.origin.y = s*noteFrameHeight+noteVerticalPadding;
            
            //CGContextSetFillColorWithColor(context, [UIColor colorWithRed:colors[s][0] green:colors[s][1] blue:colors[s][2] alpha:colors[s][3]].CGColor);  // Get color for that string and fill
            
            CGContextSetFillColorWithColor(context,[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3].CGColor);
            
            CGContextFillEllipseInRect(context, noteFrame);
        }
    }
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,view.frame.size.width,view.frame.size.height)];
    [imageView setImage:newImage];
    
    [view addSubview:imageView];
    UIGraphicsEndImageContext();
    
}

// Draw notes from a pattern without finalizing beat situation
- (void)drawTempPatternNotesForClip:(NSClip *)clip inView:(UIView *)view withPattern:(NSPattern *)pattern patternLength:(float)patternLength
{
    if(clip.m_muted){
        return;
    }
    
    CGSize size = CGSizeMake(view.frame.size.width, view.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size,NO,0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    double lineWidth = 0.2;
    
    CGFloat noteFrameWidth = measureWidth / FRETS_ON_GTAR;
    CGFloat noteFrameHeight = view.frame.size.height / STRINGS_ON_GTAR;
    CGFloat noteSquare = MIN(noteFrameWidth,noteFrameHeight);
    CGFloat noteVerticalPadding = (noteFrameHeight > noteFrameWidth) ? (noteFrameHeight-noteFrameWidth)/2.0 : 0;
    
    CGRect noteFrame = CGRectMake(0, 0, noteSquare, noteSquare);
    
    // Set line width:
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    float patternStartbeat = 4.0*floorf(clip.m_startbeat/(4.0*patternLength))*patternLength;
    float patternBeatsOffset = clip.m_startbeat - patternStartbeat;
    float patternOffset = 4.0*patternBeatsOffset;
    
    float clipWidth = clip.m_endbeat - clip.m_startbeat;
    
    // Update all the notes:
    int f, s;
    for(float relBeat = 0.0, patternRepeat = 0.0; relBeat < clipWidth+patternOffset; relBeat += 4.0*patternLength){
        
        for(NSNote * note in pattern.m_notes){
            
            float noteBeat = note.m_beatstart + patternRepeat*(FRETS_ON_GTAR)*patternLength - patternOffset;
            
            if(noteBeat >= 0.0 && noteBeat < 4.0*(clipWidth)){
                
                s = STRINGS_ON_GTAR - 1 - note.m_stringvalue;
                f = noteBeat; // Pattern notes have this set differently than song notes
                
                // Adjust frame:
                noteFrame.origin.x = f*noteFrameWidth+1.0;
                noteFrame.origin.y = s*noteFrameHeight+noteVerticalPadding;
                
                CGContextSetFillColorWithColor(context,[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3].CGColor);
                
                CGContextFillEllipseInRect(context, noteFrame);
                    
            }else{
                continue;
            }
        }
        
        patternRepeat += 1.0;
    }
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,view.frame.size.width,view.frame.size.height)];
    [imageView setImage:newImage];
    
    [view addSubview:imageView];
    UIGraphicsEndImageContext();
    
}

- (void)clearPatternNotesForEditingClip
{
    for(UIView * subview in editingClipView.subviews){
        if([subview isKindOfClass:[UIImageView class]]){
            [subview removeFromSuperview];
        }
    }
}

- (void)clearPatternNotesForTrackClips
{
    NSMutableArray * clipDict = [trackclips objectForKey:editingTrack.m_name];
    
    for(int c = 0; c < [clipDict count]; c++){
        UIView * v = [clipDict objectAtIndex:c];
        
        for(UIView * subview in v.subviews){
            if([subview isKindOfClass:[UIImageView class]]){
                [subview removeFromSuperview];
            }
        }
    }
}

- (void)redrawEditingPatternNotesWithPattern:(NSString *)newPattern
{
    [self clearPatternNotesForEditingClip];
    
    if(!editingClip.m_muted){
        
        NSTrack * instTrack = [delegate instTrackAtId:editingTrack.m_instrument.m_id];
        
        NSPattern * pattern = [instTrack getPatternByName:newPattern];
        
        if(pattern != nil){
            [self drawTempPatternNotesForClip:editingClip inView:editingClipView withPattern:[instTrack getPatternByName:newPattern] patternLength:[instTrack getPatternLengthByName:newPattern]];
        }else{
            
            [self drawPatternNotesForClip:editingClip inView:editingClipView];
            
        }
    }
}

- (void)redrawAllPatternNotes
{
    [self clearPatternNotesForTrackClips];
    
    NSMutableArray * clipDict = [trackclips objectForKey:editingTrack.m_name];
    
    for(int c = 0; c < [clipDict count]; c++){
        NSClip * clip = [editingTrack.m_clips objectAtIndex:c];
        UIView * clipView = [clipDict objectAtIndex:c];
        NSTrack * instTrack = [delegate instTrackAtId:editingTrack.m_instrument.m_id];
        //NSString * clipPattern = (clip == editingClip) ? newPattern : clip.m_name;
        NSString * clipPattern = clip.m_name;
        
        if(![clipPattern isEqualToString:PATTERN_E]){
        
            [self drawTempPatternNotesForClip:clip inView:clipView withPattern:[instTrack getPatternByName:clipPattern] patternLength:[instTrack getPatternLengthByName:clipPattern]];
            
        }else{
            
            [self drawPatternNotesForClip:clip inView:clipView];
            
        }
    }
}

- (void)drawProgressBarForClip:(NSClip *)clip atIndex:(float)trackIndex
{
    float progressMeasureHeight = progressView.frame.size.height / (float)MAX_TRACKS;
    double progressClipStart = [self getProgressXPositionForClipBeat:clip.m_startbeat];
    double progressClipEnd = [self getProgressXPositionForClipBeat:clip.m_endbeat];
    
    CGRect clipProgressFrame = CGRectMake(progressClipStart,trackIndex * progressMeasureHeight + progressMeasureHeight / 2.0,progressClipEnd - progressClipStart,1);
    
    UIView * progressClip = [[UIView alloc] initWithFrame:clipProgressFrame];
    [progressClip setBackgroundColor:[UIColor whiteColor]];
    
    [progressClip setUserInteractionEnabled:NO];
    
    if(!clip.m_muted){
        [progressView addSubview:progressClip];
    }
    
}

- (void)addLongPressGestureToView:(UIView *)view
{
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(clipLongPressEvent:)];
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
- (void)clipLongPressEvent:(UILongPressGestureRecognizer *)recognizer
{
    UIView * pressedClip = (UIView *)recognizer.view;
    [self clipViewPressed:pressedClip];
}

- (void)clipViewPressed:(UIView *)pressedClipView
{
    if(pressedClipView != editingClipView){
        
        [self deactivateEditingClip];

        [self startClipViewEditing:pressedClipView];
    }
}

- (void)startClipViewEditing:(UIView *)clipView
{
    
    for(id t in trackclips){
        NSMutableArray * clipDict = [trackclips objectForKey:t];
        NSString * trackName = (NSString *)t;
        
        for(int c = 0; c < [clipDict count]; c++){
            UIView * v = [clipDict objectAtIndex:c];
            
            if(v == clipView){
                
                editingTrack = [delegate trackWithName:trackName];
                
                editingClip = [editingTrack.m_clips objectAtIndex:c];
                editingClipView = clipView;
                editingTrackView = [delegate trackViewWithName:trackName];
                
                DLog(@"Editing track %@ at clip %i with name %@",trackName,c,editingClip.m_name);
            }
        }
    }
    
    if(editingClipView != nil){
        [self activateEditingClip];
    }
}

// This is called when the blank area of a valid track is pressed
- (void)trackViewPressed:(UIView *)pressedTrackView
{
    
    if(!isTrackViewPressed){
        
        // Avoid retriggering
        isTrackViewPressed = YES;
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(unpressTrackView) userInfo:nil repeats:NO];
        
        // Must have pressed in the track we're already editing
        if(editingTrack != nil){
            
            [self addClipInEditing];
            
        }else{
            
            // Just to be safe
            [self deactivateEditingClip];
            
            // Open the track for editing
            NSString * trackName = [delegate trackNameFromView:pressedTrackView];
            
            editingTrack = [delegate trackWithName:trackName];
            editingClip = nil;
            editingClipView = nil;
            editingTrackView = pressedTrackView;
            
            [self activateEditingTrack];
            
        }
            
    }
}

- (void)unpressTrackView
{
    isTrackViewPressed = NO;
}

// Holding a blank part of the track
- (void)trackLongPressEvent:(UILongPressGestureRecognizer *)recognizer
{
    UIView * pressedTrack = (UIView *)recognizer.view;
    
    [self trackViewPressed:pressedTrack];
    
}

// End the editing on another clip
- (void)deactivateEditingClip
{
    [horizontalAdjustor hideControls];
    
    [self clearEditingMeasure:YES];
    [self mergeNeighboringIdenticalClips:YES];
    [self correctMeasureLengths];
    [self shrinkExpandMeasuresOnScreen];
    [delegate drawTickmarks];
    [delegate drawGridOverlayLines];
    [self refreshProgressView];
    
    if(editingTrack != nil){
        
        [delegate regenerateDataForTrack:editingTrack];
        
        [self redrawAllPatternNotes];
        
    }
    
    if(editingClipView != nil){
        
        //[editingClipView removeGestureRecognizer:moveClipPan];
        
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
        }else{
            oldColor = E_COLOR;
        }
        
        [UIView animateWithDuration:0.3 animations:^(void){
            [editingClipView setBackgroundColor:oldColor];
        }];
        
        [self resetEditingClipPattern];
    }
    
    editingClip = nil;
    editingClipView = nil;
    editingPatternLetter = nil;
    editingPatternLetterOverlay = nil;
    horizontalAdjustor = nil;
    
}

- (void)deactivateEditingClipUnfocusTrack:(UILongPressGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateBegan){
        [self unfocusTrackHideEditingPanel];
        [self deactivateEditingClip];
    }
}

// Start editing a clip
- (void)activateEditingClip
{
    DLog(@"Activate editing clip");
    
    [delegate stopRecordPlaybackAnimatePlayband:NO];
    
    // Activate
    [UIView animateWithDuration:0.3 animations:^(void){
        [editingClipView setBackgroundColor:EDITING_COLOR];
    }];
    
    // Draw sliders
    [self initEditingClipSliders];
    
    // Blink the letter label
    [self initEditingClipPattern];
    
    // Focus the track and show editing panel
    [self focusTrackShowEditingPanel];
    
    // Select measure for editing
    [self selectDefaultMeasureInEditing];
    
    // Add pan to move selection
    //moveClipPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEditingClip:)];
    //moveClipPan.delegate = self;
    //[editingClipView addGestureRecognizer:moveClipPan];
    
}

// Start editing a track
- (void)activateEditingTrack
{
    DLog(@"Activate editing track");
    
    [delegate stopRecordPlaybackAnimatePlayband:NO];
    
    [self addClipInEditing];
    
    [self focusTrackShowEditingPanel];
    
}

// Allow the table to scroll during editing
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // Not the left nav
    if([otherGestureRecognizer isMemberOfClass:[UISwipeGestureRecognizer class]]){
        DLog(@"RETURN NO 1");
        return NO;
    }
    
    if(gestureRecognizer != editingMeasurePan && editingClipView.frame.size.width > MAX_MOVING_MEASURES*measureWidth){
        DLog(@"RETURN YES 1");
        return YES;
    }
    
    DLog(@"RETURN NO 2");
    return NO;
}


#pragma mark - Measure Moving
/*
- (void)panEditingClip:(UIPanGestureRecognizer *)sender
{
    // Only small clips are mobile
    if(editingClipView.frame.size.width > MAX_MOVING_MEASURES*measureWidth){
        return;
    }
    
    DLog(@"Pan editing clip");
    
    CGPoint newPoint = [sender translationInView:editingTrackView];
    
    if([sender state] == UIGestureRecognizerStateBegan){
        moveClipPanFirstX = editingClipView.frame.origin.x;
        
        moveClipPhantom = [[UIView alloc] initWithFrame:editingClipView.frame];
        
        [moveClipPhantom setBackgroundColor:[UIColor whiteColor]];
        
        [moveClipPhantom setAlpha:0.3];
        
        [editingClipView.superview addSubview:moveClipPhantom];
    }
    
    float minX = 0.0;
    float maxX = MAX(editingTrackView.frame.size.width-editingClipView.frame.size.width-measureWidth,0.0);
    float newX = newPoint.x + moveClipPanFirstX;
    
    // wrap to boundaries
    if(newX < minX){
        newX=minX;
    }
    
    if(newX > maxX){
        newX=maxX;
    }
    
    if(newX >= minX && newX <= maxX){
        
        // Show a ghost
        CGRect newPhantomFrame = CGRectMake(newX, moveClipPhantom.frame.origin.y, moveClipPhantom.frame.size.width, moveClipPhantom.frame.size.height);
        
        [moveClipPhantom setFrame:newPhantomFrame];
        
    }
    
    if([sender state] == UIGestureRecognizerStateEnded){
        
        [self moveClip:editingClip toStartbeat:[self getBeatFromXPosition:newX] forTrack:editingTrack];
        
        // Ensure data is up to date
        [self mergeNeighboringIdenticalClips];
        [self correctMeasureLengths];
        [self shrinkExpandMeasuresOnScreen];
        [delegate drawTickmarks];
        [delegate drawGridOverlayLines];
        [self refreshProgressView];
        [delegate regenerateDataForTrack:editingTrack];
        
        // Move the clip, adjust timings
        [horizontalAdjustor showControlsRelativeToView:editingClipView];
        
        [moveClipPhantom removeFromSuperview];
        moveClipPhantom = nil;
    }
}
 */

#pragma mark - Pattern Editing

// Reset the pattern name from editing
- (void)resetEditingClipPattern
{
    [editingPatternLetterOverlay removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    //[editingPatternLetterOverlay removeGestureRecognizer:editingPatternPressGesture];
    
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
    
    [UIView animateWithDuration:0.4 delay:0.3 options:NULL animations:^(void){
        
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
    
    [UIView animateWithDuration:0.4 delay:0.1 options:NULL animations:^(void){
        
        [editingPatternLetter setAlpha:0.8];
        
    }completion:^(BOOL finished){
        
        [self blinkEditingClipOff];
    }];
    
}

- (void)changeLetterPattern:(id)sender
{
    
    NSString * newPattern;
    
    if([editingClip.m_name isEqualToString:PATTERN_E_PENDING]){
        newPattern = PATTERN_E;
        [editingClip changePattern:PATTERN_E];
        editingClip.m_muted = NO;
    }else if(editingClip.m_muted){
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
    }else if([editingClip.m_name isEqualToString:PATTERN_E]){
        newPattern = PATTERN_A;
        [editingClip changePattern:PATTERN_A];
        [self clearEditingMeasure:YES];
    }
    
    // Don't override data for custom pattern
    //if(![newPattern isEqualToString:PATTERN_E]){
    
        // TODO: figure out how to not clear new track with data made custom
    
        [delegate regenerateDataForTrack:editingTrack];
        [self redrawEditingPatternNotesWithPattern:newPattern];
        [self drawEditingMeasureNotes];
        
    //}
    
    newPattern = [newPattern stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    [editingPatternLetter setText:newPattern];
    
    [delegate drawTickmarks];
    
}

- (void)initEditingPanelPosition
{
    [editingPanel setFrame:CGRectMake(editingPanel.frame.origin.x, 320, editingPanel.frame.size.width, editingPanel.frame.size.height)];
}

- (void)focusTrackShowEditingPanel
{
    if([editingPanel isHidden]){
        [self initEditingPanelPosition];
    }
    
    [editingPanel setAlpha:1.0];
    [editingPanel setHidden:NO];
    
    [UIView animateWithDuration:0.3 animations:^(void){
        
        // slide up the track
        [delegate setContentVerticalOffset:editingTrackView.frame.origin.y];
        
        // slide up the instrument panel subviews
        int index = 0;
        for(UIView * subview in instrumentPanel.subviews){
            [subview setFrame:CGRectMake(subview.frame.origin.x,index*measureHeight-editingTrackView.frame.origin.y+1,subview.frame.size.width,subview.frame.size.height)];
            index++;
        }
        
        // slide up the editing panel
        [editingPanel setFrame:CGRectMake(editingPanel.frame.origin.x, 80, editingPanel.frame.size.width, editingPanel.frame.size.height)];
        
        
    }completion:^(BOOL finished){
        
    }];

}

- (void)unfocusTrackHideEditingPanel
{
    [UIView animateWithDuration:0.3 animations:^(void){
        
        // slide down the track
        [delegate setContentVerticalOffset:0.0];
        
        // slide up the instrument panel subviews
        int index = 0;
        for(UIView * subview in instrumentPanel.subviews){
            [subview setFrame:CGRectMake(subview.frame.origin.x,index*measureHeight,subview.frame.size.width,subview.frame.size.height)];
            index++;
        }
        
        [editingPanel setAlpha:0.0];
        
        // TODO: figure out why this repeat-flashes
        // slide down editing panel
        //[editingPanel setFrame:CGRectMake(editingPanel.frame.origin.x, 320, editingPanel.frame.size.width, editingPanel.frame.size.height)];
        
    }completion:^(BOOL finished){
        [editingPanel setHidden:YES];
        editingTrack = nil;
        editingTrackView = nil;
        
    }];
}

#pragma mark - Pan Gesture Reactions

// Init horizontal trimming sliders
- (void)initEditingClipSliders
{
    DLog(@"Init Editing Clip Sliders");
    
    horizontalAdjustor = [[HorizontalAdjustor alloc] initWithContainer:trackView background:trackView bar:editingClipView];
    
    horizontalAdjustor.delegate = self;
    
    [horizontalAdjustor setBarDefaultWidth:trackView.contentSize.width minWidth:MIN_TRACK_WIDTH];
    
    [horizontalAdjustor showControlsRelativeToView:editingClipView];
    
    lastDiff = 0;
    
    // Ensure that the last muted clip doesn't get overflowing adjustors
    if(editingClip.m_muted && editingClip == [editingTrack.m_clips lastObject]){
        [horizontalAdjustor setAbsoluteMaxWidth:measureWidth*(ceilf([self getSongMaxBeat] / 4.0))];
    }
}

- (void)panLeft:(float)diff
{
    NSMutableArray * clipDict = [trackclips objectForKey:editingTrack.m_name];
    
    int editingClipIndex = -1;
    for(int c = 0; c < [clipDict count]; c++){
        UIView * clipView = [clipDict objectAtIndex:c];
        
        if(clipView == editingClipView){
            editingClipIndex = c;
            break;
        }
    }
    
    if(editingClipIndex < 0){
        DLog(@"ERROR: editing clip not valid");
        return;
    }
    
    // Set beats for editing clip
    if(editingClipView != nil){
        [self setLeftBeatsForClip:editingClip withView:editingClipView];
    }
    
    // Trim the leftward clip in track
    if(editingClipIndex > 0){
        UIView * leftClipView = [clipDict objectAtIndex:editingClipIndex-1];
        
        [leftClipView setFrame:CGRectMake(leftClipView.frame.origin.x,leftClipView.frame.origin.y,editingClipView.frame.origin.x-leftClipView.frame.origin.x,leftClipView.frame.size.height)];
        
        if((editingClipIndex > 1 && editingClipView.frame.origin.x <= leftClipView.frame.origin.x+MIN_TRACK_WIDTH) || (editingClipIndex == 1 && editingClipView.frame.origin.x <= leftClipView.frame.origin.x+MIN_LEFT_TRACK_WIDTH)){
            
            [self removeClipInEditing:leftClipView];
            
        }else{
            
            // Set beats for left clip
            NSClip * leftClip = [editingTrack.m_clips objectAtIndex:editingClipIndex-1];
            [self setLeftBeatsForClip:leftClip withView:leftClipView];
            
        }
        
    }
    
    // Create new muted clip to the left
    if(editingClipIndex == 0 && editingClipView.frame.origin.x > 0){
        [self createNewClipFrom:0.0 to:editingClipView.frame.origin.x at:editingClipView.frame.origin.y forTrack:editingTrack.m_name startEditing:NO isMuted:YES withPattern:PATTERN_E];
    }
    
    // Delete the measure if it's been shrunken too much
    if(editingClipView.frame.size.width < MIN_TRACK_WIDTH){
        [self removeClipInEditing:editingClipView];
    }
    
    // Redraw tickmarks
    [delegate drawTickmarks];
    
    // Redraw pattern notes
    [self redrawAllPatternNotes];
    
    // Clear editing measure
    [self clearEditingMeasure:YES];
    
    lastDiff = diff;
}

- (void)panRight:(float)diff
{
    // Move all rightward clips in the track
    
    NSMutableArray * clipDict = [trackclips objectForKey:editingTrack.m_name];
    
    int editingClipIndex = -1;
    for(int c = 0; c < [clipDict count]; c++){
        UIView * clipView = [clipDict objectAtIndex:c];
        
        if(clipView == editingClipView){
            editingClipIndex = c;
            break;
        }
    }
    
    // Set beats for editing clip
    if(editingClipView != nil){
        [self setLeftBeatsForClip:editingClip withView:editingClipView];
    }
    
    // Fill right blank
    if(editingClipIndex < [clipDict count] - 1){
        UIView * nextClipView = [clipDict objectAtIndex:editingClipIndex+1];
        NSClip * nextClip = [editingTrack.m_clips objectAtIndex:editingClipIndex+1];
        
        if(nextClip.m_muted || diff > 0){
            
            DLog(@"Next clip muted or diff up");
            
            float newWidth = nextClipView.frame.origin.x+nextClipView.frame.size.width-(editingClipView.frame.origin.x+editingClipView.frame.size.width);
            [nextClipView setFrame:CGRectMake(editingClipView.frame.origin.x+editingClipView.frame.size.width,nextClipView.frame.origin.y,newWidth,nextClipView.frame.size.height)];
            
            [self setLeftBeatsForClip:nextClip withView:nextClipView];
            
            if(diff > 0 && nextClipView.frame.size.width < MIN_TRACK_WIDTH){
                
                DLog(@"Remove next clip");
                
                [self removeClipInEditing:nextClipView];
            }
            
        }else if(editingClip.m_muted && diff < 0){
            
            DLog(@"Editing clip muted, diff down");
            
            float newWidth = nextClipView.frame.origin.x+nextClipView.frame.size.width-(editingClipView.frame.origin.x+editingClipView.frame.size.width);
            [nextClipView setFrame:CGRectMake(editingClipView.frame.origin.x+editingClipView.frame.size.width,nextClipView.frame.origin.y,newWidth,nextClipView.frame.size.height)];
            
            [self setLeftBeatsForClip:nextClip withView:nextClipView];
            
        }else if(!editingClip.m_muted && diff < 0){
            [self createNewClipFrom:editingClipView.frame.origin.x+editingClipView.frame.size.width to:nextClipView.frame.origin.x at:editingClipView.frame.origin.y forTrack:editingTrack.m_name startEditing:NO isMuted:YES withPattern:PATTERN_E];
        }
    }
    
    if(editingClipView.frame.size.width < MIN_TRACK_WIDTH){
        [self removeClipInEditing:editingClipView];
    }
    
    // Adjust add clip measure
    [self shrinkExpandMeasuresOnScreen];
    [delegate drawTickmarks];
    
    // Clear editing measure
    [self clearEditingMeasure:YES];
    
    lastDiff = diff;
    
}

- (void)endPanLeft
{
    lastDiff = 0;
    
    // Ensure data is up to date
    [self mergeNeighboringIdenticalClips:NO];
    [self correctMeasureLengths];
    [self shrinkExpandMeasuresOnScreen];
    [delegate drawTickmarks];
    [delegate drawGridOverlayLines];
    [self refreshProgressView];
    [delegate regenerateDataForTrack:editingTrack];
    
    [self redrawAllPatternNotes];
    
    [horizontalAdjustor showControlsRelativeToView:editingClipView];
    
    // Select measure for editing
    [self selectDefaultMeasureInEditing];
    
}

- (void)endPanRight
{
    lastDiff = 0;
    
    // Ensure data is up to date
    [self mergeNeighboringIdenticalClips:NO];
    [self correctMeasureLengths];
    [self shrinkExpandMeasuresOnScreen];
    [delegate drawTickmarks];
    [delegate drawGridOverlayLines];
    [self refreshProgressView];
    [delegate regenerateDataForTrack:editingTrack];
    
    [self redrawAllPatternNotes];
    
    [horizontalAdjustor showControlsRelativeToView:editingClipView];
    
    // Select measure for editing
    [self selectDefaultMeasureInEditing];
    
}

- (void)setBeatsForClip:(NSClip *)clip withView:(UIView *)view
{
    double startbeat = [self getBeatFromXPosition:view.frame.origin.x];
    double endbeat = [self getBeatFromXPosition:view.frame.origin.x+view.frame.size.width];
    
    [clip setTempStartbeat:startbeat tempEndbeat:endbeat];

    //DLog(@"Set temp beats for clip %@ from %f to %f",clip.m_name,startbeat,endbeat);
   
}

// Set beats and round left for fret origin
- (void)setLeftBeatsForClip:(NSClip *)clip withView:(UIView *)view
{
    double prevStartbeat = clip.m_startbeat;
    
    [self setBeatsForClip:clip withView:view];
    
    // Ensure that the start beat is rounded to a fret
    double roundstart = [self getXPositionForClipBeat:clip.m_startbeat];
    double roundend = [self getXPositionForClipBeat:clip.m_endbeat];
    
    [view setFrame:CGRectMake(roundstart, view.frame.origin.y, roundend-roundstart, view.frame.size.height)];
    
    // Adjust all the notes for a custom pattern if startbeat moves
    double noteDiff = clip.m_startbeat-prevStartbeat;
    [self moveNotesForClip:clip byDiff:noteDiff];

}

- (void)moveNotesForClip:(NSClip *)clip byDiff:(float)noteDiff
{
    NSString * clipPattern = clip.m_name;
    if([clipPattern isEqualToString:PATTERN_E]){
        for(NSNote * note in clip.m_notes){
            note.m_beatstart += noteDiff;
        }
    }
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
    
    // If possible end the previous track in its place
    if(clipToRemoveIndex > 0 && clipToRemoveIndex < [clipDict count]){
        
        DLog(@"End the previous track in its place %i",clipToRemoveIndex);
        
        UIView * prevTrack = [clipDict objectAtIndex:clipToRemoveIndex-1];
        UIView * nextTrack = [clipDict objectAtIndex:clipToRemoveIndex];
        
        NSClip * prevTrackClip = [editingTrack.m_clips objectAtIndex:clipToRemoveIndex-1];
        
        [prevTrack setFrame:CGRectMake(prevTrack.frame.origin.x, prevTrack.frame.origin.y, nextTrack.frame.origin.x-prevTrack.frame.origin.x, prevTrack.frame.size.height)];
        
        [prevTrackClip setTempStartbeat:prevTrackClip.m_startbeat tempEndbeat:clip.m_endbeat];
        
        
    }else if(clipToRemoveIndex < [clipDict count]){
        
        // Otherwise start the next track in its place
        
        DLog(@"Start the next track in its place %i",clipToRemoveIndex);
        
        UIView * nextTrack = [clipDict objectAtIndex:clipToRemoveIndex];
        UIView * nextNextTrack = (clipToRemoveIndex+1 < [clipDict count]) ? [clipDict objectAtIndex:clipToRemoveIndex+1] : nil;
        NSClip * nextTrackClip = [editingTrack.m_clips objectAtIndex:clipToRemoveIndex+1];
        
        float newWidth = (nextNextTrack == nil) ? nextTrack.frame.size.width : nextNextTrack.frame.origin.x-clipToRemove.frame.origin.x;
        
        [nextTrack setFrame:CGRectMake(clipToRemove.frame.origin.x,nextTrack.frame.origin.y,newWidth,nextTrack.frame.size.height)];
        
        [nextTrackClip setTempStartbeat:clip.m_startbeat tempEndbeat:nextTrackClip.m_endbeat];
        
    }
    
    // Don't do this for the last clip if it's muted
    if(clipToRemoveIndex > 0 && !(clip.m_muted && clipToRemoveIndex == [clipDict count])){
        
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
        //[self unfocusTrackHideEditingPanel];
    }
    
    [clipToRemove removeFromSuperview];
    
    [self shrinkExpandMeasuresOnScreen];
    [delegate drawTickmarks];
    [self refreshProgressView];
    
}

//
// Add Clips
//
- (void)addClipInEditing
{
    NSString * senderTrackName = editingTrack.m_name;
    
    UIView * lastClipInTrack = [[trackclips objectForKey:senderTrackName] lastObject];
    
    if(senderTrackName != nil){
        
        float startX = 0;
        float endX = startX+measureWidth;
        float atY = editingTrackView.frame.origin.y;
        
        // Otherwise editing an empty track;
        if (lastClipInTrack != nil) {
            
            startX = lastClipInTrack.frame.origin.x+lastClipInTrack.frame.size.width;
            endX = startX+measureWidth;
            atY = lastClipInTrack.frame.origin.y;
            
        }
        
        [self createNewClipFrom:startX to:endX at:atY forTrack:senderTrackName startEditing:YES isMuted:NO withPattern:PATTERN_A];
        [self redrawAllPatternNotes];
        
    }else{
        DLog(@"ERROR: Sender Track Name is nil");
    }
}

//
// Edit Clips
//
- (void)clearEditingMeasure:(BOOL)hideInterface
{
    if(editingMeasureOverlay != nil){
        [editingMeasureOverlay removeGestureRecognizer:editingMeasurePan];
        [editingMeasureOverlay removeGestureRecognizer:editingMeasureLetter];
        [editingMeasureOverlay removeFromSuperview];
        editingMeasureOverlay = nil;
    }
    
    if(hideInterface){
        [self hideEditingMeasureInterface];
    }
        
    [delegate enableEdit];
}

- (void)selectMeasureInEditing
{
    // Select a draggable region to edit
    [self clearEditingMeasure:NO];
    
    CGRect editingMeasureOverlayFrame = CGRectMake(0,0,MIN(measureWidth,editingClipView.frame.size.width)+1.0,measureHeight);
    editingMeasureOverlay = [[UIView alloc] initWithFrame:editingMeasureOverlayFrame];
    
    [editingMeasureOverlay setBackgroundColor:E_COLOR];
    
    [editingClipView addSubview:editingMeasureOverlay];
    
    // Add drag gesture
    editingMeasurePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEditingMeasure:)];
    editingMeasurePan.delegate = self;
    [editingMeasureOverlay addGestureRecognizer:editingMeasurePan];
    
    editingMeasureLetter = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeLetterPatternFromOverlay:)];
    editingMeasureLetter.minimumPressDuration = 0.2;
    [editingMeasureOverlay addGestureRecognizer:editingMeasureLetter];
    
    // Show editing interface with selected region
    [self showEditingMeasureInterface];
    
    [delegate disableEdit];
    
}

// Don't enable unless it's large enough
// This is called by various actions around the view
- (void)selectDefaultMeasureInEditing
{
    if(editingClipView.frame.size.width > measureWidth){
        [self selectMeasureInEditing];
    }
}

// Start editing when the user initiates
- (void)forceSelectMeasureInEditing
{
    [self selectMeasureInEditing];
    [self startEditingClipCustomPattern];
}

- (void)startEditingClipCustomPattern
{
    if(![editingClip.m_name isEqualToString:PATTERN_E]){
        
        // Clear the pattern preset
        [editingClip changePattern:PATTERN_E_PENDING];
        [self changeLetterPattern:nil];
    }
}

- (void)showEditingMeasureInterface
{
    if(editingMeasureInterface == nil){
        
        [self initEditingMeasureOverlay];
        
    }
    
    // Ensure pattern data is up to date
    //[delegate regenerateDataForTrack:editingTrack];
    [self redrawAllPatternNotes];
    
    [self drawEditingMeasureNotes];

    [editingMeasureInterface setAlpha:1.0];
    [editingMeasureInterface setHidden:NO];
}

- (void)drawEditingMeasureNotes
{
    [self clearEditingMeasureNotes];
    
    // Turn on/off notes for the appropriate measure
    float measureStartbeat = [self getBeatFromXPosition:editingMeasureOverlay.frame.origin.x+editingClipView.frame.origin.x];
    
    float measureEndbeat = measureStartbeat+4.0;
    
    for(NSNote * note in editingClip.m_notes){
        if(note.m_beatstart >= measureStartbeat && note.m_beatstart <= measureEndbeat){
            
            int s = STRINGS_ON_GTAR - 1 - note.m_stringvalue;
            int f = floorf((note.m_beatstart - measureStartbeat) * 4.0);
            
            if(s < STRINGS_ON_GTAR && f < FRETS_ON_GTAR){
                
                //DLog(@"Note on at %i, %i",s,f);
                
                UIButton * noteButton = [editingMeasureNoteButtons objectAtIndex:s*FRETS_ON_GTAR+f];
                
                [noteButton setBackgroundColor:[UIColor colorWithRed:colors[s][0] green:colors[s][1] blue:colors[s][2] alpha:colors[s][3]]];
                
                [editingMeasureNoteOn setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:s*FRETS_ON_GTAR+f];
            }
            
        }
    }
    
}

- (void)initEditingMeasureOverlay
{
    float interfaceHeight = 50.0;
    float interfacePadding = 7.0;
    float interfaceBottomPadding = 7.0;
    
    CGRect interfaceFrame = CGRectMake(instrumentPanel.frame.size.width+interfacePadding,interfaceHeight,editingPanel.frame.size.width-instrumentPanel.frame.size.width-2*interfacePadding,editingPanel.frame.size.height-interfaceHeight-interfaceBottomPadding);
    
    editingMeasureNoteOn = [[NSMutableArray alloc] init];
    editingMeasureNoteButtons = [[NSMutableArray alloc] init];
    editingMeasureInterface = [[UIView alloc] initWithFrame:interfaceFrame];
    
    [editingPanel addSubview:editingMeasureInterface];
    
    // Add buttons
    float notePad = 1.0;
    float noteWidth = interfaceFrame.size.width/FRETS_ON_GTAR - notePad;
    float noteHeight = interfaceFrame.size.height/STRINGS_ON_GTAR - notePad;
    
    for(int s = 0; s < STRINGS_ON_GTAR; s++){
        for(int f = 0; f < FRETS_ON_GTAR; f++){
            UIButton * noteButton = [[UIButton alloc] initWithFrame:CGRectMake(f*noteWidth+f*notePad,s*noteHeight+s*notePad,noteWidth,noteHeight)];
            
            noteButton.layer.cornerRadius = 1.0f;
            
            [editingMeasureInterface addSubview:noteButton];
            
            [editingMeasureNoteButtons addObject:noteButton];
            [editingMeasureNoteOn addObject:[NSNumber numberWithBool:NO]];
            
            [noteButton addTarget:self action:@selector(toggleMeasureNote:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)clearEditingMeasureNotes
{
    for(UIButton * measureButton in editingMeasureNoteButtons){
        
        [measureButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    }
    
    for(int i = 0; i < [editingMeasureNoteOn count]; i++){
        [editingMeasureNoteOn setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:i];
    }
}

- (void)hideEditingMeasureInterface
{
    [editingMeasureInterface setAlpha:0.0];
}

- (void)toggleMeasureNote:(id)sender
{
    // Change A-D to a star
    [self startEditingClipCustomPattern];
    
    int buttonIndex = [editingMeasureNoteButtons indexOfObject:sender];
    
    int s = floor(buttonIndex / FRETS_ON_GTAR);
    int f = buttonIndex - s * FRETS_ON_GTAR;
    
    float fretWidth = measureWidth / FRETS_ON_GTAR;
    float frameBase = ceilf(editingMeasureOverlay.frame.origin.x / fretWidth) * fretWidth;
    
    float beat = editingClip.m_startbeat + [self getBeatFromXPosition:frameBase+f*fretWidth];
    
    DLog(@"Beat is %f",beat);
    
    BOOL noteOn = [[editingMeasureNoteOn objectAtIndex:s*FRETS_ON_GTAR+f] boolValue];
    
    if(noteOn){
        [sender setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [self turnNoteOffForEditingClipAtBeat:beat atString:s];
    }else{
        [sender setBackgroundColor:[UIColor colorWithRed:colors[s][0] green:colors[s][1] blue:colors[s][2] alpha:colors[s][3]]];
        [self turnNoteOnForEditingClipAtBeat:beat atString:s];
    }
    
    [editingMeasureNoteOn setObject:[NSNumber numberWithBool:!noteOn] atIndexedSubscript:s*FRETS_ON_GTAR+f];
    
    // Redraw pattern
    [self clearPatternNotesForEditingClip];
    [self drawPatternNotesForClip:editingClip inView:editingClipView];
    
}

- (void)changeLetterPatternFromOverlay:(UILongPressGestureRecognizer *)sender
{
    if([sender state] == UIGestureRecognizerStateBegan){
        if(editingMeasureOverlay.frame.origin.x < editingPatternLetter.frame.origin.x){
            
            DLog(@"Change letter pattern from overlay");
        
            [self changeLetterPattern:nil];
        }
    }
}

- (void)panEditingMeasure:(UIPanGestureRecognizer *)sender
{
    
    CGPoint newPoint = [sender translationInView:editingClipView];
    
    if([sender state] == UIGestureRecognizerStateBegan){
        editingMeasurePanFirstX = editingMeasureOverlay.frame.origin.x;
    }
    
    float fretWidth = measureWidth / FRETS_ON_GTAR;
    float minX = 0.0;
    float maxX = MAX(editingClipView.frame.size.width-measureWidth,0.0);
    float newX = newPoint.x + editingMeasurePanFirstX;
    newX = roundf(newX / fretWidth) * fretWidth;
    
    // wrap to boundaries
    if(newX < minX){
        newX=minX;
    }
    
    if(newX > maxX){
        newX=maxX;
    }
    
    [self drawEditingMeasureNotes];
    
    if(newX >= minX && newX <= maxX){
        
        CGRect newFrame = CGRectMake(newX,editingMeasureOverlay.frame.origin.y,editingMeasureOverlay.frame.size.width,editingMeasureOverlay.frame.size.height);
        
        [editingMeasureOverlay setFrame:newFrame];
    }
    
}

- (void)turnNoteOnForEditingClipAtBeat:(float)beat atString:(long)string
{
    DLog(@"Add note for string %li at beat %f",string,beat);
    
    NSNote * newNote = [[NSNote alloc] initWithValue:[NSString stringWithFormat:@"%li",STRINGS_ON_GTAR-string-1] beatstart:beat];
    
    [editingClip addNote:newNote];
    
    
}

- (void)turnNoteOffForEditingClipAtBeat:(float)beat atString:(long)string
{
    DLog(@"Remove note at beat %f for string %li",beat,string);
    
    [editingClip removeNoteAtBeat:beat atValue:STRINGS_ON_GTAR-string-1];
}

//
// Move Clip
//
- (void)moveClip:(NSClip *)clip toStartbeat:(float)startbeat forTrack:(NSTrack *)track
{
    float diff = startbeat - clip.m_startbeat;
    float neighbordiff = clip.m_endbeat-clip.m_startbeat;
    
    //DLog(@"Move original clip from %f to %f (diff of %f, width of %f, neighbor moves %f)",clip.m_startbeat,startbeat,diff,clip.m_endbeat-clip.m_startbeat,neighbordiff);

    [self offsetClip:clip byDifference:diff forTrack:track];
    
    // Adjust surrounding clips
    BOOL splitDown = (diff > 0) ? TRUE : FALSE;
    
    NSMutableArray * clipsToSplit = [[NSMutableArray alloc] init];
    
    for(NSClip * neighbor in track.m_clips){
        // Overlap
        if(neighbor != clip && neighbor.m_startbeat < clip.m_endbeat && neighbor.m_endbeat > clip.m_startbeat){
            
            [clipsToSplit addObject:neighbor];
        }
    }
    
    for(NSClip * neighbor in clipsToSplit){
        
        if(splitDown){
            [neighbor setTempStartbeat:neighbor.m_startbeat-neighbordiff tempEndbeat:neighbor.m_endbeat-neighbordiff];
            [self adjustViewForClip:neighbor inTrack:track];
        }
        
        [self splitClip:neighbor atBeat:clip.m_startbeat toBeat:clip.m_endbeat forTrack:editingTrack splitDown:splitDown];
        
    }
    
    [self removeShrinkingClipsForTrack:(NSTrack *)track];
}

- (void)offsetClip:(NSClip *)clip byDifference:(float)diff forTrack:(NSTrack *)track
{
    DLog(@"Offset clip %@ by %f",clip.m_name,diff);
    
    [clip setTempStartbeat:clip.m_startbeat+diff tempEndbeat:clip.m_endbeat+diff];
    
    // Adjust view
    [self adjustViewForClip:clip inTrack:track];
    
    // Adjust notes
    for(NSNote * note in clip.m_notes){
        note.m_beatstart += diff;
    }
}

- (void)adjustViewForClip:(NSClip *)clip inTrack:(NSTrack *)track
{
    // Adjust view
    int clipIndex = [track getClipIndexForClip:clip];
    
    if(clipIndex >= 0){
        
        DLog(@"Adjust view for clip at index %i",clipIndex);
        
        UIView * clipView = [[trackclips objectForKey:track.m_name] objectAtIndex:clipIndex];
        
        float newX = [self getXPositionForClipBeat:clip.m_startbeat];
        float endX = [self getXPositionForClipBeat:clip.m_endbeat];
        float newWidth = endX-newX;
        
        CGRect newFrame = CGRectMake(newX,clipView.frame.origin.y,newWidth,clipView.frame.size.height);
        
        [clipView setFrame:newFrame];
    }
}

- (void)splitClip:(NSClip *)clip atBeat:(float)splitBeat toBeat:(float)newBeat forTrack:(NSTrack *)track splitDown:(BOOL)splitDown
{
    DLog(@"Split clip at %f to %f",splitBeat,newBeat);
    
    float firstClipXA = [self getXPositionForClipBeat:clip.m_startbeat];
    float firstClipXZ = [self getXPositionForClipBeat:splitBeat];
    float secondClipXA = [self getXPositionForClipBeat:newBeat];
    float secondClipXZ = [self getXPositionForClipBeat:(newBeat+clip.m_endbeat-splitBeat)];
    
    if(splitDown){
        
        DLog(@"SPLIT DOWN");
        
        [self createNewClipFrom:firstClipXA to:firstClipXZ at:editingClipView.frame.origin.y forTrack:track.m_name startEditing:NO isMuted:clip.m_muted withPattern:clip.m_name];
        
        [clip setTempStartbeat:newBeat tempEndbeat:(newBeat+clip.m_endbeat-splitBeat)];
        
        [self adjustViewForClip:clip inTrack:track];
        
    }else{
        DLog(@"SPLIT UP");
        
        [self createNewClipFrom:secondClipXA to:secondClipXZ at:editingClipView.frame.origin.y forTrack:track.m_name startEditing:NO isMuted:clip.m_muted withPattern:clip.m_name];
        
        [clip setTempStartbeat:clip.m_startbeat tempEndbeat:splitBeat];
        
        [self adjustViewForClip:clip inTrack:track];
        
    }
    
    // TODO: adjust notes
    
    
}

// Remove shrunken measures after moving
- (void)removeShrinkingClipsForTrack:(NSTrack *)track
{
    [self reorderTrackClipsForTrack:track];
    
    NSMutableArray * clipsToRemove = [[NSMutableArray alloc] init];
    
    for(UIView * clip in [trackclips objectForKey:track.m_name]){
        if(clip.frame.size.width < MIN_TRACK_WIDTH){
            [clipsToRemove addObject:clip];
        }
    }
    
    for(UIView * clip in clipsToRemove){
        [self removeClipInEditing:clip];
    }
}

//
// Merge Clips
//
- (void)mergeNeighboringIdenticalClips:(BOOL)mergeEditing
{
    // Ensure all the indices are correct
    [self reorderTrackClipsForTrack:editingTrack];
    
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
        
        // Be careful not to merge the clip while editing
        if(!mergeEditing && (firstClip == editingClip || nextClip == editingClip)){
            continue;
        }
        
        // Case to merge!
        if([firstClip.m_name isEqualToString:nextClip.m_name] && firstClip.m_muted == nextClip.m_muted){
            [firstClipView setFrame:CGRectMake(firstClipView.frame.origin.x,firstClipView.frame.origin.y,firstClipView.frame.size.width+nextClipView.frame.size.width,firstClipView.frame.size.height)];
            
            [trackClipsToRemove addObject:nextClip];
            [trackClipViewsToRemove addObject:nextClipView];
            
            // Set beats
            [self setLeftBeatsForClip:firstClip withView:firstClipView];
            [firstClip setTempStartbeat:firstClip.m_startbeat tempEndbeat:nextClip.m_endbeat];
            
            // If it's a custom pattern copy the notes over
            if([firstClip.m_name isEqualToString:PATTERN_E]){
                for(NSNote * note in nextClip.m_notes){
                    [firstClip addNote:note];
                }
            }
            
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
// Reorder track clips
//
- (void)reorderTrackClipsForTrack:(NSTrack *)track
{
    if(track == nil){
        return;
    }
    
    NSMutableArray * newClipArray = [[NSMutableArray alloc] init];
    NSMutableArray * oldClipArray = [trackclips objectForKey:track.m_name];
    
    int numClips = [oldClipArray count];
    
    for(int i = 0; i < numClips; i++){
        [newClipArray addObject:[self removeMinViewFromArray:oldClipArray]];
    }
    
    [trackclips setObject:newClipArray forKey:track.m_name];
    
    [track sortClipsByBeat];
    
}

- (UIView *)removeMinViewFromArray:(NSMutableArray *)array
{
    UIView * minView = [array firstObject];
    for(UIView * v in array){
        if(v.frame.origin.x < minView.frame.origin.x){
            minView = v;
        }
    }
    
    [array removeObject:minView];
    
    return minView;
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
    
    NSMutableArray * clipDict = [trackclips objectForKey:editingTrack.m_name];
    
    NSTrack * instTrack = [delegate instTrackAtId:editingTrack.m_instrument.m_id];
    
    for(int c = 0; c < [clipDict count]; c++){
        UIView * clipView = [clipDict objectAtIndex:c];
        NSClip * clip = [editingTrack.m_clips objectAtIndex:c];
        
        // No adjustments if the measure is muted
        //if(clip.m_muted){
            
            // If it is the first measure?
            //if(c == 0){
                
                // Remove if it's too small
                if(clipView.frame.size.width <= MIN_TRACK_WIDTH){
                    
                    [self removeClipInEditing:clipView];
                    
                    continue;
                }
                
            //}
        
        //}
        
        int patternLength = [instTrack getPatternLengthByName:clip.m_name];
        
        if(patternLength == 0){
            DLog(@"ERROR: pattern length 0");
            return;
        }
        
        //BOOL measureBeforeIsMuted = (c > 0) ? [[editingTrack.m_clips objectAtIndex:c-1] m_muted]: false;
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
        
        // Start it at the end of the previous measure
        if(c > 0){
            NSClip * prevClip = [editingTrack.m_clips objectAtIndex:c-1];
            if(prevClip.m_endbeat != clip.m_startbeat){
                
                double targetStartX = [self getXPositionForClipBeat:prevClip.m_endbeat];
                double targetEndbeat = clip.m_endbeat - (clip.m_startbeat - prevClip.m_endbeat);
                diffBeats = clip.m_endbeat - targetEndbeat;
                
                [clipView setFrame:CGRectMake(targetStartX, clipView.frame.origin.y, clipView.frame.size.width, clipView.frame.size.height)];
                
                [clip setTempStartbeat:prevClip.m_endbeat tempEndbeat:targetEndbeat];
            }
        }
        
        // Start it on a valid measure
        /*if(!measureBeforeIsMuted){
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
        }*/
        
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
- (NSClip *)createNewClipFrom:(float)fromX to:(float)toX at:(float)atY forTrack:(NSString *)trackName startEditing:(BOOL)edit isMuted:(BOOL)muted withPattern:(NSString *)patternName
{
    
    if(edit){
        if(editingClip != nil){
            [self deactivateEditingClip];
        }
    }
    
    NSTrack * track = [delegate trackWithName:trackName];
    
    // Determine the new index
    NSMutableArray * clipArray = [trackclips objectForKey:trackName];
    
    int clipIndex = 0;
    for(UIView * clipView in clipArray){
    
        if(fromX < clipView.frame.origin.x){
            break;
        }
        
        clipIndex++;
    }
    
    int newIndex = clipIndex;
    //int newIndex = [track.m_clips count];
    
    DLog(@"Create new muted clip from %f to %f at index %i",fromX,toX,newIndex);
    
    double startBeat = [self getBeatFromXPosition:fromX];
    double endBeat = [self getBeatFromXPosition:toX];
    
    NSClip * newClip = [[NSClip alloc] initWithName:patternName startbeat:startBeat endBeat:endBeat clipLength:0.0 clipStart:0.0 looping:false loopStart:0.0 looplength:0.0 color:@"" muted:muted];
    
    [track addClip:newClip atIndex:newIndex];
    
    // Create the clip
    CGRect newClipFrame = CGRectMake(fromX,atY,toX-fromX,measureHeight);
    
    DLog(@"newClipFrame is %f %f %f %f",newClipFrame.origin.x,newClipFrame.origin.y,newClipFrame.size.width,newClipFrame.size.height);
    
    UIView * newClipView = [self drawClipViewForClip:newClip track:track inFrame:newClipFrame atIndex:newIndex];
    
    // Draw the pattern letters
    [self drawPatternLetterForClip:newClip inView:newClipView];
    
    // Set beats
    [self setLeftBeatsForClip:newClip withView:newClipView];
    
    // Start editing?
    if(edit){
        [self startClipViewEditing:newClipView];
        
        // Scroll to measure
        FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
        float offsetX = MIN(fromX,trackView.contentSize.width-[frameGenerator getRecordedTrackScreenWidth]);
        
        [UIView animateWithDuration:0.3 delay:0.3 options:NULL animations:^(void){
            
            [trackView setContentOffset:CGPointMake(offsetX,trackView.contentOffset.y)];
            
        }completion:^(BOOL finished){
            
        }];
    }
    
    // Ensure all the indices are correct
    [self reorderTrackClipsForTrack:track];
    
    return newClip;
}

//
// Crop muted end measures when the (+)measure gets adjusted
//
- (void)cropMutedEndMeasures:(int)newNumMeasures withMaxBeat:(float)maxBeat
{
    // First adjust the view
    
    NSMutableArray * clipViewsToRemove = [[NSMutableArray alloc] init];
    
    for(id trackName in trackclips){
        
        NSTrack * track = [delegate trackWithName:trackName];
        
        NSClip * clip = [track.m_clips lastObject];
        
        if(clip.m_muted && clip.m_endbeat > maxBeat){
            
            UIView * lastClipView = [[trackclips objectForKey:trackName] lastObject];
            
            double newClipEndX = [self getXPositionForClipBeat:newNumMeasures*4.0];
            double newClipWidth = newClipEndX - lastClipView.frame.origin.x;
            
            DLog(@"newClipWidth is %f",newClipWidth);
            
            if(newClipWidth > MIN_TRACK_WIDTH){
                
                [lastClipView setFrame:CGRectMake(lastClipView.frame.origin.x, lastClipView.frame.origin.y, newClipWidth, lastClipView.frame.size.height)];
                
                [self setLeftBeatsForClip:clip withView:lastClipView];
                
            }else{
                
                [clipViewsToRemove addObject:lastClipView];
                
                //[self removeClipInEditing:lastClipView];
                
            }
        }
        
    }
    
    for(UIView * v in clipViewsToRemove){
        [self removeClipInEditing:v];
    }
}

- (float)getSongMaxBeat
{
    
    //int newNumMeasures = 0.0;
    float maxBeat = 0.0;
    
    // count the maximum measure
    // make sure it's not muted
    for(id trackName in trackclips){
        // NSMutableArray * clipArray = [trackclips objectForKey:trackName];
        
        NSMutableArray * clipArray = [[delegate trackWithName:(NSString *)trackName] m_clips];
        NSClip * lastClip = [clipArray lastObject];
        //UIView * lastClipView = [clipArray lastObject];
        
        // Use the second to last muted clip if a lot of editing is going on
        if(lastClip.m_muted && [clipArray count] > 1){
            lastClip = [clipArray objectAtIndex:([clipArray count]-2)];
        }
        
        if(!lastClip.m_muted){
            //[self getBeatFromXPosition:lastClipView.frame.origin.x+lastClipView.frame.size.width]
            maxBeat = MAX(maxBeat, lastClip.m_endbeat);
        }
        
    }
    
    return maxBeat;
}

//
// Adjust the number of measures on screen to reflect changing lengths
//
- (void)shrinkExpandMeasuresOnScreen
{
    DLog(@"Shrink expand measures on screen");
    
    float maxBeat = [self getSongMaxBeat];
    int newNumMeasures = ceil(maxBeat / 4.0);
    
    // call delegate set measures
    // even if it's redundant, because editing might be processing
    [delegate setMeasures:newNumMeasures drawGrid:NO];
    
    [horizontalAdjustor setBarDefaultWidth:trackView.contentSize.width minWidth:MIN_TRACK_WIDTH];

    [self cropMutedEndMeasures:newNumMeasures withMaxBeat:maxBeat];

    // bring grid lines forward
    [delegate drawGridOverlayLines];
    
    [self redrawAllPatternNotes];
    
}

#pragma mark - Beats in view arithmetic

-(float)getBeatFromXPosition:(float)x
{
    float fretWidth = measureWidth / FRETS_ON_GTAR;
    //float beat = x * 4.0 / measureWidth;
    
    // round to fret
    float beat = (fretWidth*floorf(x/fretWidth)) * 4.0 / measureWidth;

    return beat;
}

-(float)getXPositionForClipBeat:(float)beat
{
    double x = beat * measureWidth / 4.0;
    
    return x;
}

-(float)getProgressXPositionForClipBeat:(float)beat
{
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    
    float progressMeasureWidth = [frameGenerator getRecordedTrackScreenWidth] / numMeasures;
    //float progressMeasureWidth = progressView.frame.size.width / (numMeasures);
    
    float x = beat * progressMeasureWidth / 4.0;
    
    return x;
}

@end
