//
//  RecordShareViewController.m
//  Sequence
//
//  Created by Kate Schnippering on 3/25/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "RecordShareViewController.h"
#import "AudioController.h"
#import "AUNodeNetwork.h"
#import "AudioNodeCommon.h"
#import "SoundMaster_.mm"

#define DEFAULT_SONG_NAME @"RecordedSessionPlaceholder.m4a"
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

#define MIN_TRACK_WIDTH 5.0

@interface RecordShareViewController ()
{
    
    FileoutNode *fileNode;
    SamplerBankNode *m_sampleBankNode;
    SampleNode *m_sampNode;
}

@end

@implementation RecordShareViewController

@synthesize delegate;
@synthesize backButton;
@synthesize progressView;
@synthesize instrumentView;
@synthesize trackView;
@synthesize progressViewIndicator;
@synthesize noSessionOverlay;
@synthesize noSessionLabel;
@synthesize processingLabel;
@synthesize shareEmailButton;
@synthesize shareSMSButton;
@synthesize shareSoundcloudButton;
@synthesize shareView;
@synthesize shareScreen;
@synthesize cancelButton;
@synthesize songNameField;
@synthesize songDescriptionField;
@synthesize playbandView;
@synthesize recordingSong;
@synthesize songModel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        tracks = [[NSMutableArray alloc] init];
        tickmarks = [[NSMutableArray alloc] init];
        trackclips = [[NSMutableDictionary alloc] init];
        isAudioPlaying = NO;
        isWritingFile = NO;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	trackView.bounces = NO;
    [trackView setDelegate:self];
    
    [self reloadInstruments];
    [self setMeasures:MIN_MEASURES];
    [self showNoSessionOverlay];
    
    [self initShareScreen];
    
}

- (void)clearAllSubviews
{
    for(UIView * v in instrumentView.subviews){
        [v removeFromSuperview];
    }
    
    for(UIView * v in progressView.subviews){
        [v removeFromSuperview];
    }
    
    for(UIView * v in trackView.subviews){
        [v removeFromSuperview];
    }
    
    for(UIView * v in tickmarks){
        [v removeFromSuperview];
    }
    
    [tickmarks removeAllObjects];
    [trackclips removeAllObjects];
}

- (void)reloadInstruments
{
    instruments = [[NSMutableArray alloc] initWithArray:[delegate getTracks]];
    
    [self clearAllSubviews];
    
    int i = 0;
    
    float instHeight = (instrumentView.frame.size.height+1) / MAX_TRACKS;
    float instWidth = instrumentView.frame.size.width;
    
    for(NSTrack * t in instruments){
        
        NSInstrument * inst = t.m_instrument;
        
        float displayHeight = (i == MAX_TRACKS-1) ? instHeight : instHeight + 1;
        
        //
        // Instrument icon
        //
        
        CGRect instFrame = CGRectMake(-1, i*instHeight, instWidth+2, displayHeight);
        
        UIButton * instView = [[UIButton alloc] initWithFrame:instFrame];
        [instView setImage:[UIImage imageNamed:inst.m_iconName] forState:UIControlStateNormal];
        [instView setUserInteractionEnabled:NO];
        [instView setImageEdgeInsets:UIEdgeInsetsMake(5,14,5,14)];
        
        instView.layer.borderColor = [UIColor whiteColor].CGColor;
        instView.layer.borderWidth = 1.0f;
        
        [instrumentView addSubview:instView];
        
        //
        // Recorded track
        //
        
        float trackWidth = trackView.frame.size.width+2;
        CGRect trackFrame = CGRectMake(-1, i*instHeight, trackWidth, displayHeight);
        
        UIView * track = [[UIView alloc] initWithFrame:trackFrame];
        [track setBackgroundColor:[UIColor grayColor]];
        
        track.layer.borderColor = [UIColor colorWithRed:81/255.0 green:81/255.0 blue:81/255.0 alpha:1.0].CGColor;
        track.layer.borderWidth = 1.0f;
        
        [trackView addSubview:track];
        
        [tracks addObject:track];
        
        i++;
    }
    
    for(;i<MAX_TRACKS;i++){
        
        //
        // Blank instrument
        //
        
        float displayHeight = (i == MAX_TRACKS-1) ? instHeight : instHeight + 1;
        
        CGRect instFrame = CGRectMake(-1, i*instHeight, instWidth+2, displayHeight);
        UIButton * instView = [[UIButton alloc] initWithFrame:instFrame];
        [instView setBackgroundColor:[UIColor colorWithRed:99/255.0 green:99/255.0 blue:99/255.0 alpha:1.0]];
        [instView setUserInteractionEnabled:NO];
        
        instView.layer.borderColor = [UIColor whiteColor].CGColor;
        instView.layer.borderWidth = 1.0f;
        
        [instrumentView addSubview:instView];
        
        //
        // Blank track
        //
        
        float trackWidth = trackView.frame.size.width+2;
        CGRect trackFrame = CGRectMake(-1, i*instHeight, trackWidth, displayHeight);
        
        UIView * track = [[UIView alloc] initWithFrame:trackFrame];
        [track setBackgroundColor:[UIColor grayColor]];
        
        track.layer.borderColor = [UIColor colorWithRed:81/255.0 green:81/255.0 blue:81/255.0 alpha:1.0].CGColor;
        track.layer.borderWidth = 1.0f;
        
        [trackView addSubview:track];
        
        [tracks addObject:track];
        
    }
    
    [self setMeasures:MIN_MEASURES];
    
}

- (BOOL)isValidInstrumentIndex:(int)inst
{
    for(NSTrack * i in instruments){
        if(i.m_instrument.m_id == inst){
            return YES;
        }
    }
    
    return NO;
}

- (int)getIndexForInstrument:(int)inst
{
    int k = 0;
    for(NSTrack * i in instruments){
        if(i.m_instrument.m_id == inst){
            return k;
        }
        k++;
    }
    
    return -1;
}
- (void)loadSong:(NSSong *)song andSoundMaster:(SoundMaster *)soundMaster activeSequence:(NSSequence *)activeSequence activeSong:(NSString *)activeSong
{
    if(song != nil){
        recordingSong = song;
        [self hideNoSessionOverlay];
    }else{
        [self showNoSessionOverlay];
    }
    
    DLog(@"Song is %@, sequence is %@",recordingSong,activeSequence);
    
    [self reloadInstruments];
    
    [self removeDeletedMeasuresFromRecordedSong];
    
    [self setMeasures:[self countMeasuresFromRecordedSong]];
    
    [self drawPatternsOnMeasures];
    
    // record the m4a
    //if(song != nil){
        [self startRecording:nil withTempo:song.m_tempo andSoundMaster:soundMaster activeSequence:activeSequence activeSong:nil];
    //}
    
    // reset the progress bar on top
    [self resetProgressView];
    
    // ensure record playback gbegets refreshed
    [self stopRecordPlayback];
}

- (void)setMeasures:(int)newNumMeasures
{
    //
    // Draw measures
    //
    
    float measureWidth = trackView.frame.size.width / MEASURES_PER_SCREEN;
    
    numMeasures = newNumMeasures;
    numMeasures = MAX(numMeasures,MIN_MEASURES);
    
    CGSize newContentSize = CGSizeMake(numMeasures*measureWidth,trackView.frame.size.height);
    
    for(int i = 0; i < numMeasures; i++){
        CGRect measureLineFrame = CGRectMake(i*measureWidth, 0, 1, trackView.frame.size.height);
        UIView * measureLine = [[UIView alloc] initWithFrame:measureLineFrame];
        [measureLine setBackgroundColor:[UIColor darkGrayColor]];
        
        [trackView addSubview:measureLine];
    }
    //if(newContentSize.width > trackView.frame.size.width){
    // for some reason this needs extra padding
    [trackView setContentSize:newContentSize];
    
    for(UIView * t in tracks){
        [t setFrame:CGRectMake(t.frame.origin.x, t.frame.origin.y, newContentSize.width+2, t.frame.size.height)];
    }
    //}
}

- (void)removeDeletedMeasuresFromRecordedSong
{
    
    NSMutableArray * tracksToRemove = [[NSMutableArray alloc] init];
    
    for(NSTrack * track in recordingSong.m_tracks){
        int instrumentIndex = track.m_instrument.m_id;
        
        if(![self isValidInstrumentIndex:instrumentIndex]){
            DLog(@"Invalid instrument index %i",instrumentIndex);
            [tracksToRemove addObject:track];
        }
    }
    
    [recordingSong.m_tracks removeObjectsInArray:tracksToRemove];
    
}

- (int)countMeasuresFromRecordedSong
{
    float maxMeasure = 0;
    
    for(NSTrack * track in recordingSong.m_tracks){
        for(NSClip * clip in track.m_clips){
            for(NSNote * note in clip.m_notes){
                maxMeasure = MAX(maxMeasure,note.m_beatstart);
            }
        }
    }
    
    maxMeasure /= 4.0;
    
    return (int) ceil(maxMeasure);
}

- (void)drawPatternsOnMeasures
{
    //
    // Draw measure content
    //
    
    int numTracks = [recordingSong.m_tracks count];
    
    float measureWidth = trackView.frame.size.width / MEASURES_PER_SCREEN;
    float measureHeight = trackView.frame.size.height / MAX_TRACKS;
    
    CGRect clipFrame;
    
    float trackPosition = 0;
    for(NSTrack * track in recordingSong.m_tracks){
        
        int clipIndex = 0;
        for(NSClip * clip in track.m_clips){
            
            //
            // Draw each clip segment
            //
            double firstBeat = [self getFirstBeatFromClip:clip];
            double lastBeat = [self getLastBeatFromClip:clip];
            
            // Revise clip end if it's the last measure
            // (or first measure just to be safe)
            if(clip == [track.m_clips firstObject]){
                firstBeat = 0.0;
            }
            
            if(clip == [track.m_clips lastObject]){
                lastBeat = [self countMeasuresFromRecordedSong]*4.0;
            }
            
            double clipStart = [self getXPositionForClipBeat:firstBeat];
            double clipEnd = [self getXPositionForClipBeat:lastBeat];
            
            clipFrame = CGRectMake(clipStart,trackPosition * measureHeight + 1,clipEnd - clipStart,measureHeight);
            
            UIView * clipView = [[UIView alloc] initWithFrame:clipFrame];
            
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
                [clipDict addObject:clipView];
            }else{
                NSMutableArray * clipDict = [[NSMutableArray alloc] init];
                [clipDict addObject:clipView];
                [trackclips setObject:clipDict forKey:track.m_name];
            }
            
            //
            // Draw the pattern letters
            //
            
            CGRect patternLetterFrame = CGRectMake(PATTERN_LETTER_INDENT,0,PATTERN_LETTER_WIDTH,measureHeight);
            
            UILabel * patternLetter = [[UILabel alloc] initWithFrame:patternLetterFrame];
            [patternLetter setText:[clip.m_name stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            [patternLetter setTextColor:[UIColor whiteColor]];
            [patternLetter setAlpha:0.5];
            [patternLetter setFont:[UIFont fontWithName:FONT_BOLD size:20.0]];
            
            if(clip.m_muted){
                [patternLetter setText:@""];
            }

            [clipView addSubview:patternLetter];
            
            //
            // Draw the top progress view
            //
            float measureHeight = progressView.frame.size.height / (double)numTracks;
            double progressClipStart = [self getProgressXPositionForClipBeat:firstBeat];
            double progressClipEnd = [self getProgressXPositionForClipBeat:lastBeat];
            
            DLog(@"Clip start %f end %f beats %f to %f numMeasures %i",progressClipStart,progressClipEnd,firstBeat,lastBeat,numMeasures);
            
            CGRect clipProgressFrame = CGRectMake(progressClipStart,trackPosition * measureHeight + measureHeight / 2.0,progressClipEnd - progressClipStart,1);
            
            UIView * progressClip = [[UIView alloc] initWithFrame:clipProgressFrame];
            [progressClip setBackgroundColor:[UIColor whiteColor]];
            
            if(!clip.m_muted){
                [progressView addSubview:progressClip];
            }
            
            //
            // Draw the repeat tickmarks
            //
            
            NSTrack * instTrack = [instruments objectAtIndex:[self getIndexForInstrument:track.m_instrument.m_id]];
            
            // Length of pattern
            int patternLength = [instTrack getPatternLengthByName:clip.m_name];
            int clipStartMeasure = (int)[clip getMeasureForBeat:clip.m_startbeat]; // Start measure
            int clipEndMeasure = (int)[clip getMeasureForBeat:clip.m_endbeat];
            int fillMeasures = clipEndMeasure - clipStartMeasure; // Total measures
            
            int fillOffset = patternLength - clipStartMeasure % patternLength;
            
            // Start filling every % patternLength == 0 measures;
            for(int m = clipStartMeasure+fillOffset; m <= clipStartMeasure+fillMeasures; m+= patternLength)
            {
                UIView * t = [tracks objectAtIndex:trackPosition];
                
                CGRect topTickFrame = CGRectMake((m-1)*measureWidth+measureWidth,t.frame.origin.y,1,12);
                CGRect bottomTickFrame = CGRectMake((m-1)*measureWidth+measureWidth,t.frame.origin.y+t.frame.size.height-12,1,12);
                
                UIView * topTick = [[UIView alloc] initWithFrame:topTickFrame];
                UIView * bottomTick = [[UIView alloc] initWithFrame:bottomTickFrame];
                
                [topTick setBackgroundColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0]];
                [bottomTick setBackgroundColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0]];
                
                if(!clip.m_muted){
                    [tickmarks addObject:topTick];
                    [tickmarks addObject:bottomTick];
                }
            }
            
            clipIndex++;
        }
        
        trackPosition++;
    }
    
    
    //
    // Draw overlaying dark horizontal lines
    //
    
    for(trackPosition = 0; trackPosition < [recordingSong.m_tracks count]; trackPosition++){
        
        UIView * t = [tracks objectAtIndex:trackPosition];
        
        CGRect overlayLine = CGRectMake(0,t.frame.origin.y, numMeasures*measureWidth,1);
        
        UIView * overlayLineView = [[UIView alloc] initWithFrame:overlayLine];
        [overlayLineView setBackgroundColor:[UIColor darkGrayColor]];
        
        [trackView addSubview:overlayLineView];
    
    }
    
    //
    // Draw overlaying pattern tickmarks
    //
    
    for(UIView * tick in tickmarks){
        [trackView addSubview:tick];
    }
    
}

- (void)addLongPressGestureToView:(UIView *)view
{
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEvent:)];
    longPress.minimumPressDuration = 0.5;
    
    [view addGestureRecognizer:longPress];
}

- (float)getFirstBeatFromClip:(NSClip *)clip
{
    return clip.m_startbeat;
}

- (float)getLastBeatFromClip:(NSClip *)clip
{
    return clip.m_endbeat;
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
    
    double x = beat * measureWidth / 4.0;
    
    return x;
}

#pragma mark - Scrolling and Progress View
-(void)resetProgressView
{
    float indicatorWidth = (MEASURES_PER_SCREEN/numMeasures) * progressView.frame.size.width;
    
    CGRect progressViewIndicatorFrame = CGRectMake(0, 0, indicatorWidth, progressView.frame.size.height);
    progressViewIndicator = [[UIView alloc] initWithFrame:progressViewIndicatorFrame];
    [progressViewIndicator setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3]];
    
    [progressView addSubview:progressViewIndicator];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    double percentMoved = scrollView.contentOffset.x / scrollView.contentSize.width;
    
    double newIndicatorX = progressView.frame.size.width * percentMoved;
    
    [progressViewIndicator setFrame:CGRectMake(newIndicatorX, 0, progressViewIndicator.frame.size.width, progressViewIndicator.frame.size.height)];
}

#pragma mark - No Session Overlay

-(void)showNoSessionOverlay
{
    [noSessionOverlay setHidden:NO];
    [noSessionLabel setHidden:NO];
    [processingLabel setHidden:YES];
}

-(void)hideNoSessionOverlay
{
    if(!isWritingFile){
        [noSessionOverlay setHidden:YES];
    }
}

-(BOOL)showHideSessionOverlay
{
    return [noSessionOverlay isHidden];
}

-(void)showProcessingOverlay
{
    [noSessionOverlay setHidden:NO];
    [noSessionLabel setHidden:YES];
    [processingLabel setHidden:NO];
}

-(void)showRecordOverlay
{
    [delegate showRecordOverlay];
}

-(void)hideRecordOverlay
{
    [delegate hideRecordOverlay];
}

#pragma mark - Share Screen
-(void)initShareScreen
{
    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    CGRect wholeScreen = CGRectMake(0, 0, x, y);
    
    shareView = [[UIView alloc] initWithFrame:wholeScreen];
    [shareView setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7]];
    
    UIWindow *window = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    [window addSubview:shareView];
    
    float shareWidth = 364;
    float shareHeight = 276;
    NSArray * nibViews = [[NSBundle mainBundle] loadNibNamed:@"ShareView" owner:self options:nil];
    shareScreen = nibViews[0];
    [shareScreen setFrame:CGRectMake(x/2-shareWidth/2,y+y/2-shareHeight/2,shareWidth,shareHeight)];
    [self initRoundedCorners:shareScreen];
    
    [shareView addSubview:shareScreen];
    
    [self drawBackButtonForView:shareView withX:shareScreen.frame.origin.x];
    
    // Setup buttons
    shareEmailButton.layer.cornerRadius = 35.0;
    shareSMSButton.layer.cornerRadius = 35.0;
    shareSoundcloudButton.layer.cornerRadius = 35.0;
    
    selectedShareType = @"Email";
    
    // Setup text field listeners
    songNameField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [songNameField addTarget:self action:@selector(songNameFieldStartEdit:) forControlEvents:UIControlEventEditingDidBegin];
    [songNameField addTarget:self action:@selector(songNameFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [songNameField addTarget:self action:@selector(songNameFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    songNameField.delegate = self;
    
    [songNameField setFont:[UIFont fontWithName:FONT_DEFAULT size:22.0]];
    
    songDescriptionField.delegate = self;
    
    [shareView setHidden:YES];
    
}

-(void)openShareScreen
{
    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    
    CGRect offScreenFrame = shareScreen.frame;
    CGRect onScreenFrame = CGRectMake(shareScreen.frame.origin.x,shareScreen.frame.origin.y-y,shareScreen.frame.size.width,shareScreen.frame.size.height);
    
    [shareView setHidden:NO];
    
    [shareView setAlpha:0.0];
    [shareScreen setFrame:offScreenFrame];
    [UIView animateWithDuration:0.4f animations:^(void){
        [shareView setAlpha:1.0];
        [shareScreen setFrame:onScreenFrame];
    }];
    
    [self setRecordDefaultText];
    
}

- (IBAction)userDidSelectShare:(id)sender
{
    UIButton * senderButton = (UIButton *)sender;
    
    NSString * songname = [[self renameSongToSongname] stringByAppendingString:@".m4a"];
    
    if(senderButton == shareEmailButton){
        
        selectedShareType = @"Email";
        [delegate userDidLaunchEmailWithAttachment:songname];
        
    }else if(senderButton == shareSMSButton){
        
        selectedShareType = @"SMS";
        [delegate userDidLaunchSMSWithAttachment:songname];
        
    }else if(senderButton == shareSoundcloudButton){
        
        selectedShareType = @"SoundCloud";
        [delegate userDidLaunchSoundCloudAuthWithFile:songname];
        
    }
}

- (void)userDidCloseShare
{
    // Wrap up song name editing in progress
    [self songNameFieldDoneEditing:songNameField];
    
    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    
    CGRect onScreenFrame = shareScreen.frame;
    CGRect offScreenFrame = CGRectMake(shareScreen.frame.origin.x,y+shareScreen.frame.origin.y,shareScreen.frame.size.width,shareScreen.frame.size.height);
    
    [shareView setAlpha:1.0];
    [shareScreen setFrame:onScreenFrame];
    [UIView animateWithDuration:0.4f animations:^(void){
        [shareView setAlpha:0.0];
        [shareScreen setFrame:offScreenFrame];
    } completion:^(BOOL finished){
        [shareView setHidden:YES];
    }];
    
}


#pragma mark - Drawing
- (void)initRoundedCorners:(UIView *)view
{
    UIBezierPath * pathRecord = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:(UIRectCornerAllCorners) cornerRadii:CGSizeMake(5.0,5.0)];
    
    [self drawShapedView:view withBezierPath:pathRecord];
}

-(void)drawShapedView:(UIView *)view withBezierPath:(UIBezierPath *)bezierPath
{
    CAShapeLayer * bodyLayer = [CAShapeLayer layer];
    
    [bodyLayer setPath:bezierPath.CGPath];
    view.layer.mask = bodyLayer;
    view.clipsToBounds = YES;
    view.layer.masksToBounds = YES;
}

- (void)drawBackButtonForView:(UIView *)view withX:(int)x
{
    CGFloat cancelWidth = 40;
    CGFloat cancelHeight = 50;
    CGFloat insetX = 44;
    CGFloat insetY = 17;
    CGRect cancelFrame = CGRectMake(x-insetX, insetY, cancelWidth, cancelHeight);
    cancelButton = [[UIButton alloc] initWithFrame:cancelFrame];
    
    [cancelButton addTarget:self action:@selector(userDidCloseShare) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview: cancelButton];
    
    CGSize size = CGSizeMake(cancelButton.frame.size.width, cancelButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int buttonWidth = 20;
    int buttonX = cancelButton.frame.size.width-buttonWidth/2-5;
    int buttonY = 9;
    CGFloat buttonHeight = cancelButton.frame.size.height - 2*buttonY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 6.0);
    
    CGContextMoveToPoint(context, buttonX, buttonY);
    CGContextAddLineToPoint(context, buttonX-buttonWidth, buttonY+(buttonHeight/2));
    CGContextAddLineToPoint(context, buttonX, buttonY+buttonHeight);
    
    CGContextStrokePath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [cancelButton addSubview:image];
    
    UIGraphicsEndImageContext();
    
    
}

#pragma mark - Playband
-(void)resetPlayband
{
    measurePlaybandView.userInteractionEnabled = NO;
    
    if(!isPlaybandAnimating){
        [playbandView setFrame:CGRectMake(0,0,playbandView.frame.size.width,playbandView.frame.size.height)];
        
        if(measurePlaybandView){
            [measurePlaybandView removeFromSuperview];
        }
        
        CGRect measurePlaybandViewFrame = CGRectMake(0,1,4,trackView.frame.size.height);
        measurePlaybandView = [[UIView alloc] initWithFrame:measurePlaybandViewFrame];
        [measurePlaybandView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7]];
        [trackView addSubview:measurePlaybandView];
        
        isPlaybandAnimating = YES;
        [playbandView setHidden:YES];
        [measurePlaybandView setHidden:YES];
    }
}

-(void)movePlaybandToMeasure:(int)m andFret:(int)f andHide:(BOOL)hide
{
    float measureWidth = trackView.frame.size.width / MEASURES_PER_SCREEN;
    float fretWidth = measureWidth / FRETS_ON_GTAR;
    
    float pb_x = ((m*measureWidth+f*fretWidth)/(numMeasures*measureWidth))*playbandView.superview.frame.size.width;
    float mpb_x = m*measureWidth+f*fretWidth;
    
    [UIView animateWithDuration:0.1 animations:^(void){
        
        [playbandView setFrame:CGRectMake(pb_x-1,0,playbandView.frame.size.width,playbandView.frame.size.height)];
        [measurePlaybandView setFrame:CGRectMake(mpb_x,1,measurePlaybandView.frame.size.width,measurePlaybandView.frame.size.height)];
        
    } completion:^(BOOL finished){
        
        if(hide){
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(resetPlayband) userInfo:nil repeats:NO];
        }
    }];
    
    if(!hide){
        [playbandView setHidden:NO];
        [measurePlaybandView setHidden:NO];
    }
}

-(void)incrementMeasureForPlayband
{
    [self movePlaybandToMeasure:playMeasure andFret:playFret andHide:NO];
    
    playFret = (playFret+1)%FRETS_ON_GTAR;
    
    if(playFret == 0){
        playMeasure++;
    }
    
    if(playMeasure > [self countMeasuresFromRecordedSong]){
    //if(playMeasure > [loadedPattern count]){
        [self stopPlaybandAnimation];
    }
}

-(void)startPlaybandAnimation
{
    isPlaybandAnimating = NO;
    playMeasure = 0;
    playFret = 0;
    [self resetPlayband];
    [self resumePlaybandAnimation];
}

-(void)resumePlaybandAnimation
{
    // determine timing from tempo
    if(loadedTempo > 0){
        
        float beatspersecond = 1 / (4 * loadedTempo / 60);
        
        if(playbandTimer == nil){
            
            [self pausePlaybandAnimation];
            
            playbandTimer = [NSTimer scheduledTimerWithTimeInterval:beatspersecond target:self selector:@selector(incrementMeasureForPlayband) userInfo:nil repeats:YES];
            
            [[NSRunLoop currentRunLoop] addTimer:playbandTimer forMode:NSRunLoopCommonModes];
        }
    }
}

-(void)pausePlaybandAnimation
{
    [playbandTimer invalidate];
    playbandTimer = nil;
}

-(void)stopPlaybandAnimation
{
    [playbandTimer invalidate];
    playbandTimer = nil;
    
    // Animate to the end
    isPlaybandAnimating = NO;
    //[self movePlaybandToMeasure:[loadedPattern count]-1 andFret:FRETS_ON_GTAR-1 andHide:YES];
    [self movePlaybandToMeasure:[self countMeasuresFromRecordedSong]-1 andFret:FRETS_ON_GTAR-1 andHide:YES];
    
}

#pragma mark - Recording
-(void)startRecording:(NSMutableArray *)patternData withTempo:(int)tempo andSoundMaster:(SoundMaster *)m_soundMaster activeSequence:(NSSequence *)activeSequence activeSong:(NSString *)activeSong
{
    //if(loadedPattern != patternData){
    
    // TODO: reinstate this?
    //if(![activeSong isEqualToString:recordingSong.m_title]){
    
        isWritingFile = YES;
        
        //loadedPattern = patternData;
        loadedTempo = tempo;
        loadedSoundMaster = m_soundMaster;
        loadedSequence = activeSequence;
        
        r_measure = 0;
        r_beat = 0;
        
        //DLog(@"Start recording %@",loadedPattern);
        [self showProcessingOverlay];
        [delegate forceShowSessionOverlay];
        
        [self resetAudio];
        [self showRecordOverlay];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(beginRecordSession) userInfo:nil repeats:NO];
    //}
    //}
}

-(void)beginRecordSession
{
    
    DLog(@"Recording song is %@",recordingSong);
    
    fileNode = [loadedSoundMaster generateFileoutNode:DEFAULT_SONG_NAME];
    
    // Then write the file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Sessions"];
    
    // First clear the directory
    NSFileManager * fm = [[NSFileManager alloc] init];
    NSError * error = nil;
    for(NSString * file in [fm contentsOfDirectoryAtPath:documentsDirectory error:&error]){
        DLog(@"Remove item at path %@",[NSString stringWithFormat:@"%@/%@",documentsDirectory,file]);
        if(![file isEqualToString:DEFAULT_SONG_NAME]){
            [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@",documentsDirectory,file] error:&error];
        }
    }
    
    sessionFilepath = [documentsDirectory stringByAppendingPathComponent:DEFAULT_SONG_NAME];
    
    double recordinterval = 1/44100;
    float beatspersecond = 4 * loadedTempo/60.0;
    secondperbeat = 44100 / beatspersecond;
    
    // set background loop
    if(recordTimer == nil){
        
        // TODO: thread? runloop?
        recordTimer = [NSTimer scheduledTimerWithTimeInterval:recordinterval target:self selector:@selector(recordToFile) userInfo:nil repeats:YES];
    }
}

-(void)resetAudio
{
    [loadedSoundMaster reset];
}

-(void)recordToFile
{
    @synchronized(recordingSong){
        for(NSTrack * track in recordingSong.m_tracks){
            for(NSClip * clip in track.m_clips){
                if(!clip.m_muted){
                    for(NSNote * note in clip.m_notes){
                        
                        if(note.m_beatstart == r_beat/4.0){
                            
                            NSTrack * instTrack = [instruments objectAtIndex:[self getIndexForInstrument:track.m_instrument.m_id]];
                            
                            // Record to m4a file
                            [instTrack.m_instrument.m_sampler.audio pluckString:note.m_stringvalue];
                                
                        }
                    }
                }
            }
        }
        
    }
    
    // todo: buffer this
    fileNode->SaveSamples(secondperbeat);
    
    r_beat++;
    if(r_beat%FRETS_ON_GTAR==FRETS_ON_GTAR-1){
        r_measure++;
    }
    
    if(r_measure == [self countMeasuresFromRecordedSong]){
        [self stopRecording];
    }
    
}

-(void)stopRecording
{
    isWritingFile = NO;
    
    DLog(@"Stop recording");
    [self hideNoSessionOverlay];
    [self hideRecordOverlay];
    [delegate forceHideSessionOverlay];
    
    [recordTimer invalidate];
    recordTimer = nil;
    
    // save XMP
    //[recordingSong printTree];
    DLog(@"RecordingSong is %@",recordingSong);
    
    [recordingSong saveToFile:recordingSong.m_title];
    
    // release
    [self releaseFileoutNode];
    [self resetAudio];
}

-(void)interruptRecording
{
    if(isWritingFile){
        DLog(@"Interrupt recording");
        [self stopRecording];
    }else{
        DLog(@"Ignore interrupt recording");
    }
}

-(void)releaseFileoutNode
{
    if(fileNode != NULL) {
        delete fileNode;
        fileNode = NULL;
    }
}

#pragma mark - Record Playback
-(void)playRecordPlayback
{
    if(!isAudioPlaying){
        
        DLog(@"Play record playback");
        
        NSURL * url = [NSURL fileURLWithPath:sessionFilepath];
        
        NSError * error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        audioPlayer.numberOfLoops = 0;
        audioPlayer.delegate = self;
        
        isAudioPlaying = YES;
        
        [self initSongModel];
        [self startPlaybandAnimation];
        
    }else{
        [self resumePlaybandAnimation];
    }
    
    [delegate startSoundMaster];
    [self performSelectorInBackground:@selector(startBackgroundLoop:) withObject:[NSNumber numberWithFloat:SECONDS_PER_EVENT_LOOP]];
    
    
    [self startMainEventLoop:SECONDS_PER_EVENT_LOOP];
    
    //[audioPlayer play];
    
}

- (void)startBackgroundLoop:(NSNumber *)spb
{
    DLog(@"Starting Background Loop with %f seconds per beat",[spb floatValue]);

    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];

    [self startMainEventLoop:[spb floatValue]];
    
    [runLoop run];
}

-(void)pauseRecordPlayback
{
    [delegate stopSoundMaster];
    [self stopMainEventLoop];
    
    //[audioPlayer pause];
    [self pausePlaybandAnimation];
}

-(void)stopRecordPlayback
{
    isAudioPlaying = NO;
    [self stopPlaybandAnimation];
    //[audioPlayer stop];
    [delegate recordPlaybackDidEnd];
}

- (void)delayedStopSound
{
    [delegate stopSoundMaster];
    [self stopMainEventLoop];
}

- (void)songModelEndOfSong
{
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(delayedStopSound) userInfo:nil repeats:NO];
    
    [self stopRecordPlayback];
}

- (void)initSongModel
{
    DLog(@"recordingSong is %@",recordingSong);
    
    if(songModel == nil){
        songModel = [[NSSongModel alloc] initWithSong:recordingSong andInstruments:instruments];
    }
        
    [songModel startWithDelegate:self];
}

- (void)mainEventLoop
{
    [songModel incrementTimeSerialAccess:SECONDS_PER_EVENT_LOOP];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    DLog(@"Audio player did finish");
    [self stopRecordPlayback];
}

#pragma mark - Song Description Field
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [songDescriptionField resignFirstResponder];
    
    [recordingSong renameToName:recordingSong.m_title andDescription:songDescriptionField.text];
    [recordingSong saveToFile:recordingSong.m_title];
    
}
- (void)textViewDidChange:(UITextView *)textView
{
    int maxLength = 200;
    
    if([songDescriptionField.text length] > maxLength){
        songDescriptionField.text = [songDescriptionField.text substringToIndex:maxLength];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Song Name Field
- (void)songNameFieldStartEdit:(id)sender
{
    [self initAttributedStringForText:songNameField];
}

- (void)initAttributedStringForText:(UITextField *)textField
{
    
    // Create attributed
    UIColor * blueColor = [UIColor colorWithRed:53/255.0 green:194/266.0 blue:241/255.0 alpha:1.0];
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:textField.text];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:40/255.0 green:47/255.0 blue:51/255.0 alpha:1.0] range:NSMakeRange(0, textField.text.length)];
    
    [textField setTextColor:blueColor];
    [textField setAttributedText:str];
}

- (void)clearAttributedStringForText:(UITextField *)textField
{
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:textField.text];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0, textField.text.length)];
    
    [textField setTextColor:[UIColor whiteColor]];
    [textField setAttributedText:str];
}


-(void)songNameFieldDidChange:(id)sender
{
    int maxLength = 15;
    
    if([songNameField.text length] > maxLength){
        songNameField.text = [songNameField.text substringToIndex:maxLength];
    }else if([songNameField.text length] == 1){
        [self initAttributedStringForText:songNameField];
    }
    
    // enforce capitalizing
    songNameField.text = [songNameField.text capitalizedString];
    
    //[self checkIfRecordingNameReady];
}

-(void)songNameFieldDoneEditing:(id)sender
{
    // hide keyboard
    [songNameField resignFirstResponder];
    
    //[self checkIfRecordingNameReady];
    
    //if(!isRecordingNameReady){
     
     if([self checkDuplicateSongName:songNameField.text]){
         [self alertDuplicateSongName];
     }
     
     //[self resetSongNameIfBlank];
     //}
    
    [self resetSongNameIfBlank];
    
    // hide styles
    [self clearAttributedStringForText:songNameField];
    
    [delegate renameFromName:recordingSong.m_title toName:songNameField.text andType:@"Songs"];
    [recordingSong renameToName:songNameField.text andDescription:songDescriptionField.text];
    [recordingSong saveToFile:recordingSong.m_title];
    
}

-(void)resetSongNameIfBlank
{
    NSString * nameString = songNameField.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""] || [self checkDuplicateSongName:nameString]){
        [self setRecordDefaultText];
        //[self checkIfRecordingNameReady];
    }
}

/*
 - (void)checkIfRecordingNameReady
 {
 NSString * nameString = songNameField.text;
 NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
 
 if([emptyName isEqualToString:@""]){
 isRecordingNameReady = NO;
 }else{
 isRecordingNameReady = YES;
 }
 
 if([self checkDuplicateRecordingName:nameString]){
 isRecordingNameReady = NO;
 }
 
 [self checkIfRecordSaveReady];
 }
 */

-(BOOL)checkDuplicateSongName:(NSString *)filename
{
    NSArray * tempList = [self getRecordedSongSet];
    
    for(NSString * tempname in tempList){
        
        NSString * comparename = [tempname stringByReplacingOccurrencesOfString:@"usr_" withString:@""];
        comparename = [comparename stringByReplacingOccurrencesOfString:@".xml" withString:@""];
        
        if([comparename isEqualToString:filename] && ![comparename isEqualToString:recordingSong.m_title]){
            return YES;
        }
        
    }
    return NO;
}

-(void)alertDuplicateSongName
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Song Name" message:@"Cannot override an existing song." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

- (void)setRecordDefaultText
{
    songNameField.text = recordingSong.m_title;
    
}

- (NSArray *)getRecordedSongSet
{
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSError * error;
    NSString * directoryPath = [paths objectAtIndex:0];
    directoryPath = [directoryPath stringByAppendingPathComponent:@"Songs"];
    
    NSArray * tempList = (NSArray *)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
    
    return tempList;
}

- (NSString *)generateNextRecordedSongName
{
    NSArray * tempList = [self getRecordedSongSet];
    
    DLog(@"SongList is %@",tempList);
    
    int customCount = 0;
    
    // Look through Samples, get the max CustomXXXX name and label +1
    for(NSString * filename in tempList){
        
        if(!([filename rangeOfString:@"Song"].location == NSNotFound)){
            
            NSString * customSuffix = [filename stringByReplacingCharactersInRange:[filename rangeOfString:@"Song"] withString:@""];
            customSuffix = [customSuffix stringByReplacingOccurrencesOfString:@"usr_" withString:@""];
            customSuffix = [customSuffix stringByReplacingOccurrencesOfString:@".xml" withString:@""];
            int numFromSuffix = [customSuffix intValue];
            
            customCount = MAX(customCount,numFromSuffix);
        }
    }
    
    customCount++;
    
    //
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPaddingCharacter:@"0"];
    [numberFormatter setPaddingPosition:NSNumberFormatterPadBeforePrefix];
    [numberFormatter setMinimumIntegerDigits:3];
    
    NSNumber * number = [NSNumber numberWithInt:customCount];
    
    NSString * numberString = [numberFormatter stringFromNumber:number];
    
    NSLog(@"Name to %@",[@"Song" stringByAppendingString:numberString]);
    
    return [@"Song" stringByAppendingString:numberString];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableCharacterSet * allowedCharacters = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowedCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [allowedCharacters formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"_-|"]];
    
    if([string rangeOfCharacterFromSet:allowedCharacters.invertedSet].location == NSNotFound){
        return YES;
    }
    return NO;
}

#pragma mark - File System
- (NSString *)renameSongToSongname
{
    NSString * songname = songNameField.text;
    
    // Create a subfolder Samples/{Category} if it doesn't exist yet
    DLog(@"Copying file from %@ to %@.m4a",DEFAULT_SONG_NAME,songname);
    
    NSString * newFilename = [songname stringByAppendingString:@".m4a"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Sessions"];
    
    NSError * err = NULL;
    NSFileManager * fm = [[NSFileManager alloc] init];
    
    [fm createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];
    
    NSString * currentPath = [directory stringByAppendingPathComponent:DEFAULT_SONG_NAME];
    NSString * newPath = [directory stringByAppendingPathComponent:newFilename];
    
    
    if([fm fileExistsAtPath:newPath]){
        [fm removeItemAtPath:newPath error:&err];
    }
    
    BOOL result = [fm copyItemAtPath:currentPath toPath:newPath error:&err];
    
    if(!result)
        DLog(@"Error moving");
    
    return songname;
}

#pragma mark - Other Listeners
- (IBAction)userDidBack:(id)sender
{
    [delegate viewSeqSetWithAnimation:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
                    
                    editingTrack = [recordingSong trackWithName:trackName];
                    
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

// Init horizontal trimming sliders
- (void)initEditingClipSliders
{
    horizontalAdjustor = [[HorizontalAdjustor alloc] initWithContainer:trackView background:trackView bar:editingClipView];
    
    horizontalAdjustor.delegate = self;
    
    [horizontalAdjustor setBarDefaultWidth:trackView.contentSize.width minWidth:MIN_TRACK_WIDTH];
    
    [horizontalAdjustor showControlsRelativeToView:editingClipView];
    
    lastDiff = 0;
    
}

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
        UIView * clipView = [clipDict objectAtIndex:editingClipIndex-1];
    
        [clipView setFrame:CGRectMake(clipView.frame.origin.x,clipView.frame.origin.y,clipView.frame.size.width+(diff-lastDiff),clipView.frame.size.height)];
    
        if(editingClipView.frame.origin.x < clipView.frame.origin.x){
            [self removeClipInEditing:clipView];
        }
        
    }
    
    if(editingClipView.frame.size.width < MIN_TRACK_WIDTH){
        [self removeClipInEditing:editingClipView];
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
        }
    }
    
    if(editingClipView.frame.size.width < MIN_TRACK_WIDTH){
        [self removeClipInEditing:editingClipView];
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

#pragma mark - Track Editing Actions

//
// Delete Track
//
- (void)removeClipInEditing:(UIView *)clipToRemove
{
    // Update dictionaries
    NSMutableArray * clipDict = [trackclips objectForKey:editingTrack.m_name];
    
    int clipToRemoveIndex = 0;
    for(int c = 0; c < [clipDict count]; c++){
        UIView * clipView = [clipDict objectAtIndex:c];
        
        if(clipView == clipToRemove){
            clipToRemoveIndex = c;
            break;
        }
    }
    
    NSMutableArray * newClipDict = [[NSMutableArray alloc] init];
    
    for(int c = 0; c < [clipDict count]; c++){
        
        int newIndex = c;
        
        if(c > clipToRemoveIndex){
            newIndex = c - 1;
        }
        
        if(c != clipToRemoveIndex){
            [newClipDict addObject:[clipDict objectAtIndex:c]];
        }
    }
    
    // Overwrite
    [trackclips setObject:newClipDict forKey:editingTrack.m_name];
    clipDict = newClipDict;
    
    // Start the next track in its place
    if(clipToRemoveIndex < [trackclips count]){
        UIView * nextTrack = [clipDict objectAtIndex:clipToRemoveIndex];
        
        [nextTrack setFrame:CGRectMake(clipToRemove.frame.origin.x,nextTrack.frame.origin.y,nextTrack.frame.size.width,nextTrack.frame.size.height)];
    }else if(clipToRemoveIndex > 0){
        
        // Or stretch out the previous track if there is no next track
        UIView * prevTrack = [clipDict objectAtIndex:clipToRemoveIndex-1];
        
        [prevTrack setFrame:CGRectMake(prevTrack.frame.origin.x,prevTrack.frame.origin.y,clipToRemove.frame.origin.x-prevTrack.frame.origin.x+clipToRemove.frame.size.width,prevTrack.frame.size.height)];
        
    }
    
    // Remove from superview
    
    if(clipToRemove == editingClipView){
        editingClipView = nil;
        [self deactivateEditingClip];
    }
    
    [clipToRemove removeFromSuperview];
    
    DLog(@"TODO: update the timing data from deleted tracks");
    NSClip * clip = [editingTrack.m_clips objectAtIndex:clipToRemoveIndex];
    
    [editingTrack.m_clips removeObject:clip];
    
    [self mergeNeighboringIdenticalClips];
    [self correctMeasureLengths];
    
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
    
    NSMutableArray * trackClipsToRemove = [[NSMutableArray alloc] init];
    NSMutableArray * trackClipViewsToRemove = [[NSMutableArray alloc] init];
    NSMutableArray * viewsToRemove = [[NSMutableArray alloc] init];
    
    for(int i = [clipDict count]-1; i > 0 ; i--){
        UIView * firstClipView = [clipDict objectAtIndex:i-1];
        UIView * nextClipView = [clipDict objectAtIndex:i];
        
        NSClip * firstClip = [editingTrack.m_clips objectAtIndex:i-1];
        NSClip * nextClip = [editingTrack.m_clips objectAtIndex:i];
        
        // Case to merge!
        if([firstClip.m_name isEqualToString:nextClip.m_name]){
            [firstClipView setFrame:CGRectMake(firstClipView.frame.origin.x,firstClipView.frame.origin.y,firstClipView.frame.size.width+nextClipView.frame.size.width,firstClipView.frame.size.height)];
            
            [trackClipsToRemove addObject:nextClip];
            [trackClipViewsToRemove addObject:[NSNumber numberWithInt:i+1]];
            [viewsToRemove addObject:nextClipView];
            
        }
    }
    
    // Remove from track clips
    [editingTrack.m_clips removeObjectsInArray:trackClipsToRemove];
    [clipDict removeObjectsInArray:trackClipViewsToRemove];
    
    // Remove UIViews
    for(UIView * v in viewsToRemove){
        [v removeFromSuperview];
    }
    
    // TODO: check all the data comes out right
    
    DLog(@"TODO: update the data to merge neighboring identical clips");
}

//
// Correct measure lengths after editing
//
- (void)correctMeasureLengths
{
    DLog(@"TODO: correct measure lengths after editing");
}

@end
