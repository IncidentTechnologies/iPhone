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
@synthesize shareEmailButton;
@synthesize shareFacebookButton;
@synthesize shareSMSButton;
@synthesize shareSoundcloudButton;
@synthesize shareEmailSelector;
@synthesize shareFacebookSelector;
@synthesize shareSMSSelector;
@synthesize shareSoundcloudSelector;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        tracks = [[NSMutableArray alloc] init];
        tickmarks = [[NSMutableArray alloc] init];
        isAudioPlaying = NO;
        
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
}

- (void)reloadInstruments
{
    instruments = [[NSMutableArray alloc] initWithArray:[delegate getInstruments]];
    
    [self clearAllSubviews];
    
    int i = 0;
    
    float instHeight = (instrumentView.frame.size.height+1) / MAX_INSTRUMENTS;
    float instWidth = instrumentView.frame.size.width;
    
    for(Instrument * inst in instruments){
        
        float displayHeight = (i == MAX_INSTRUMENTS-1) ? instHeight : instHeight + 1;
        
        //
        // Instrument icon
        //
        
        CGRect instFrame = CGRectMake(-1, i*instHeight, instWidth+2, displayHeight);
        
        UIButton * instView = [[UIButton alloc] initWithFrame:instFrame];
        [instView setImage:[UIImage imageNamed:inst.iconName] forState:UIControlStateNormal];
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
    
    for(;i<MAX_INSTRUMENTS;i++){
        
        //
        // Blank instrument
        //
        
        float displayHeight = (i == MAX_INSTRUMENTS-1) ? instHeight : instHeight + 1;
        
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

    for(Instrument * i in instruments){
        if(i.instrument == inst){
            return YES;
        }
    }
    
    return NO;
}

- (int)getIndexForInstrument:(int)inst
{
    int k = 0;
    for(Instrument * i in instruments){
        if(i.instrument == inst){
            return k;
        }
        k++;
    }
    
    return -1;
}

- (void)loadPattern:(NSMutableArray *)patternData withTempo:(int)tempo andSoundMaster:(SoundMaster *)m_soundMaster
{
    if([patternData count] > 0){
        [self hideNoSessionOverlay];
    }else{
        [self showNoSessionOverlay];
    }
    
    [self setMeasures:[patternData count]];
    [self drawPatternsOnMeasures:patternData];
    [self startRecording:patternData withTempo:tempo andSoundMaster:m_soundMaster];
    [self resetProgressView];
    // figure out datastruct for pattern
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

-(void)drawPatternsOnMeasures:(NSMutableArray *)patternData
{

    UIColor * aColor = [UIColor colorWithRed:23/255.0 green:163/255.0 blue:198/255.0 alpha:0.5];
    UIColor * bColor = [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:0.5];
    UIColor * cColor = [UIColor colorWithRed:0/255.0 green:161/255.0 blue:222/255.0 alpha:0.5];
    UIColor * dColor = [UIColor colorWithRed:137/255.0 green:225/255.0 blue:247/255.0 alpha:0.5];
    UIColor * offColor = [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:0.5];
    
    
    //
    // Draw measure content
    //
    
    float measureWidth = trackView.frame.size.width / MEASURES_PER_SCREEN;
    
    // clear prev patterns
    for(int j = 0; j < MAX_INSTRUMENTS; j++){
        prevPattern[j] = @"";
        prevInterruptPattern[j] = nil;
        prevTranspose[j] = 0;
    }
    
    //NSLog(@"pattern data is %@",patternData);
    
    int i = 0;
    for(NSMutableArray * measure in patternData){
        for(NSMutableDictionary * measureData in measure){
            
            int instrumentIndex = [[measureData objectForKey:@"instrument"] intValue];
            
            // First make sure the instrument hasn't been deleted
            if(![self isValidInstrumentIndex:instrumentIndex]){
                
                continue;
            }
            
            int k = [self getIndexForInstrument:instrumentIndex];
            
            UIView * track = [tracks objectAtIndex:k];
            
            CGRect measureBarFrame;
            CGRect measureBarInterruptFrame;
            
            // Check for measure interruption
            NSString * interruptMeasure = [measureData objectForKey:@"delta"];
            if(![interruptMeasure isEqualToString:@""]){
                
                double deltai = [[measureData objectForKey:@"deltai"] doubleValue];
                
                measureBarFrame = CGRectMake(i*measureWidth, track.frame.origin.y+1, measureWidth*deltai, track.frame.size.height-2);
                measureBarInterruptFrame = CGRectMake(i*measureWidth+measureWidth*deltai, track.frame.origin.y+1, measureWidth - measureWidth*deltai, track.frame.size.height-2);
                
            }else{
                measureBarFrame = CGRectMake(i*measureWidth, track.frame.origin.y+1, measureWidth, track.frame.size.height-2);
                measureBarInterruptFrame = CGRectNull;
            }
            
            UIView * measureBar = [[UIView alloc] initWithFrame:measureBarFrame];
            
            NSString * pattern = [measureData objectForKey:@"start"];
            
            // Color the starting measure
            if([pattern isEqualToString:@"A"]){
                [measureBar setBackgroundColor:aColor];
            }else if([pattern isEqualToString:@"B"]){
                [measureBar setBackgroundColor:bColor];
            }else if([pattern isEqualToString:@"C"]){
                [measureBar setBackgroundColor:cColor];
            }else if([pattern isEqualToString:@"D"]){
                [measureBar setBackgroundColor:dColor];
            }else{
                [measureBar setBackgroundColor:offColor];
            }
            
            [trackView addSubview:measureBar];
            
            // Draw progress marker
            if(![pattern isEqualToString:@"OFF"]){
                if(CGRectIsNull(measureBarInterruptFrame)){
                    [self drawProgressMarkerForMeasure:i inRow:k startAt:0.0 withWidth:1.0];
                }else{
                    [self drawProgressMarkerForMeasure:i inRow:k startAt:0.0 withWidth:[[measureData objectForKey:@"deltai"] doubleValue]];
                }
            }
            
            // Draw interrupt measure
            NSString * interruptPattern = [measureData objectForKey:@"delta"];
            double interruptTranspose = 0;
            
            if(!CGRectIsNull(measureBarInterruptFrame)){
                
                UIView * measureInterruptBar = [[UIView alloc] initWithFrame:measureBarInterruptFrame];
                
                interruptTranspose = measureBarInterruptFrame.size.width;
                
                if([interruptPattern isEqualToString:@"A"]){
                    [measureInterruptBar setBackgroundColor:aColor];
                }else if([interruptPattern isEqualToString:@"B"]){
                    [measureInterruptBar setBackgroundColor:bColor];
                }else if([interruptPattern isEqualToString:@"C"]){
                    [measureInterruptBar setBackgroundColor:cColor];
                }else if([interruptPattern isEqualToString:@"D"]){
                    [measureInterruptBar setBackgroundColor:dColor];
                }else{
                    [measureInterruptBar setBackgroundColor:offColor];
                }
                
                [trackView addSubview:measureInterruptBar];
                
                if(![interruptPattern isEqualToString:@"OFF"]){
                    double deltai = [[measureData objectForKey:@"deltai"] doubleValue];
                    [self drawProgressMarkerForMeasure:i inRow:k startAt:deltai withWidth:(1.0-deltai)];
                }
            }
            
            // Draw pattern end markers
            BOOL patternend = [[measureData objectForKey:@"patternrepeat"] boolValue];
            
            if(patternend && i < [patternData count]-1 && ![interruptPattern isEqualToString:@"OFF"] && ![pattern isEqualToString:@"OFF"] && ![pattern isEqualToString:@""]){
                
                CGRect topTickFrame = CGRectMake(i*measureWidth+measureWidth,track.frame.origin.y,1,12);
                CGRect bottomTickFrame = CGRectMake(i*measureWidth+measureWidth,track.frame.origin.y+track.frame.size.height-12,1,12);
                
                UIView * topTick = [[UIView alloc] initWithFrame:topTickFrame];
                UIView * bottomTick = [[UIView alloc] initWithFrame:bottomTickFrame];
                
                [topTick setBackgroundColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0]];
                [bottomTick setBackgroundColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0]];
                
                [tickmarks addObject:topTick];
                [tickmarks addObject:bottomTick];
                
            }
            
            // Indicate letter
            if(![prevPattern[k] isEqualToString:pattern] && ![pattern isEqualToString:@"OFF"] && ([interruptPattern isEqualToString:@""] || interruptPattern == nil)){
                
                CGRect patternLetterFrame;
                float patternLetterWidth = 30;
                float patternLetterIndent = 10;
                
                if(prevInterruptPattern != nil && [prevInterruptPattern[k] isEqualToString:pattern]){
                    patternLetterFrame = CGRectMake(measureBar.frame.origin.x+patternLetterIndent-prevTranspose[k],track.frame.origin.y+track.frame.size.height/2-patternLetterWidth/2,patternLetterWidth,patternLetterWidth);
                }else{
                    patternLetterFrame = CGRectMake(measureBar.frame.origin.x+patternLetterIndent,track.frame.origin.y+track.frame.size.height/2-patternLetterWidth/2,patternLetterWidth,patternLetterWidth);
                }
                
                UILabel * patternLetter = [[UILabel alloc] initWithFrame:patternLetterFrame];
                [patternLetter setText:pattern];
                [patternLetter setTextColor:[UIColor whiteColor]];
                [patternLetter setAlpha:0.5];
                [patternLetter setFont:[UIFont fontWithName:FONT_BOLD size:20.0]];
                
                [trackView addSubview:patternLetter];
            }
            
            prevPattern[k] = pattern;
            prevInterruptPattern[k] = interruptPattern;
            prevTranspose[k] = interruptTranspose;
            
        }
        
        i++;
    }
    
    // Draw tickmarks on top
    for(UIView * tick in tickmarks){
        [trackView addSubview:tick];
    }
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

-(void)drawProgressMarkerForMeasure:(int)m inRow:(int)row startAt:(double)start withWidth:(double)width
{
    float measureWidth = progressView.frame.size.width / numMeasures;
    float rowHeight = (progressView.frame.size.height-10) / MAX_INSTRUMENTS;
    
    CGRect markerFrame = CGRectMake(m*measureWidth+measureWidth*start,row*rowHeight+5,width*measureWidth,1.0);
    
    UIView * marker = [[UIView alloc] initWithFrame:markerFrame];
    [marker setBackgroundColor:[UIColor whiteColor]];
    
    [progressView addSubview:marker];
    
}

#pragma mark - No Session Overlay

-(void) showNoSessionOverlay
{
    [noSessionOverlay setHidden:NO];
}

-(void) hideNoSessionOverlay
{
    [noSessionOverlay setHidden:YES];
}

-(BOOL) showHideSessionOverlay
{
    return [noSessionOverlay isHidden];
}

#pragma mark - Share Screen
-(void)initShareScreen
{
    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    CGRect wholeScreen = CGRectMake(0, 0, x, y);
    
    UIView * shareView = [[UIView alloc] initWithFrame:wholeScreen];
    [shareView setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7]];
    
    UIWindow *window = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    [window addSubview:shareView];
    
    float shareWidth = 364;
    float shareHeight = 276;
    NSArray * nibViews = [[NSBundle mainBundle] loadNibNamed:@"ShareView" owner:self options:nil];
    UIView * shareScreen = nibViews[0];
    [shareScreen setFrame:CGRectMake(x/2-shareWidth/2,y/2-shareHeight/2,shareWidth,shareHeight)];
    [self initRoundedCorners:shareScreen];
    
    [shareView addSubview:shareScreen];
    
    shareEmailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    shareEmailButton.layer.borderWidth = 1.0f;
    shareEmailButton.layer.cornerRadius = 5.0;
    
    shareSMSButton.layer.borderColor = [UIColor whiteColor].CGColor;
    shareSMSButton.layer.borderWidth = 1.0f;
    shareSMSButton.layer.cornerRadius = 5.0;
    
    shareSoundcloudButton.layer.borderColor = [UIColor whiteColor].CGColor;
    shareSoundcloudButton.layer.borderWidth = 1.0f;
    shareSoundcloudButton.layer.cornerRadius = 5.0;
    
    shareFacebookButton.layer.borderColor = [UIColor whiteColor].CGColor;
    shareFacebookButton.layer.borderWidth = 1.0f;
    shareFacebookButton.layer.cornerRadius = 5.0;
    
    shareEmailSelector.layer.cornerRadius = 4.0;
    shareSMSSelector.layer.cornerRadius = 4.0;
    shareSoundcloudSelector.layer.cornerRadius = 4.0;
    shareFacebookSelector.layer.cornerRadius = 4.0;
    
}

-(void)openShareScreen
{
    NSLog(@"Open share screen");
    
    [self initShareScreen];
    
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


#pragma mark - Recording
-(void)startRecording:(NSMutableArray *)patternData withTempo:(int)tempo andSoundMaster:(SoundMaster *)m_soundMaster
{
    if(loadedPattern != patternData){
        
        NSString * placeholderName = @"RecordedSessionPlaceholder.m4a";
        double recordinterval = 1/44100;
        float beatspersecond = 4 * tempo/60.0;
        secondperbeat = 44100 / beatspersecond;
        
        loadedPattern = patternData;
        
        r_measure = 0;
        r_beat = 0;
        
        NSLog(@"Start recording %@",loadedPattern);
        
        fileNode = [m_soundMaster generateFileoutNode:placeholderName];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Sessions"];
        sessionFilepath = [documentsDirectory stringByAppendingPathComponent:placeholderName];
        
        // set background loop
        if(recordTimer == nil){
            
            // TODO: thread? runloop?
            recordTimer = [NSTimer scheduledTimerWithTimeInterval:recordinterval target:self selector:@selector(recordToFile) userInfo:nil repeats:YES];
        }
    }
}

-(void)recordToFile
{
    NSArray * measure = [loadedPattern objectAtIndex:r_measure];
    
    // loop through measures
    for(NSDictionary * measureinst in measure){
        
        int instIndex = [[measureinst objectForKey:@"instrument"] intValue];
        Instrument * inst = [instruments objectAtIndex:[self getIndexForInstrument:instIndex]];
        
        // fret for the beat
        NSMutableArray * frets = [measureinst objectForKey:@"frets"];
        for(NSDictionary * f in frets){
            int fretindex = [[f objectForKey:@"fretindex"] intValue];
            if(fretindex == r_beat%FRETS_ON_GTAR && ![[f objectForKey:@"ismuted"] boolValue]){
               
                // strings for the fret
                NSString * strings = [f objectForKey:@"strings"];
                for(int s = 0; s < STRINGS_ON_GTAR; s++){
                    if([strings characterAtIndex:s] == '1'){
                        [inst.audio pluckString:s];
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
    
    if(r_measure == [loadedPattern count]){
        [self stopRecording];
    }
    
}

-(void)stopRecording
{
    NSLog(@"Stop recording");
    [recordTimer invalidate];
    recordTimer = nil;
    
    // release
    [self releaseFileoutNode];
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
        
        NSLog(@"Play record playback");
        
        NSURL * url = [NSURL fileURLWithPath:sessionFilepath];
        
        NSError * error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        audioPlayer.numberOfLoops = 0;
        audioPlayer.delegate = self;
        
        isAudioPlaying = YES;
    }

    [audioPlayer play];

}

-(void)pauseRecordPlayback
{
    [audioPlayer pause];
}

-(void)stopRecordPlayback
{
    isAudioPlaying = NO;
    [audioPlayer stop];
    [delegate recordPlaybackDidEnd];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"Audio player did finish");
    [self stopRecordPlayback];
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

@end
