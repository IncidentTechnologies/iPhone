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
@synthesize shareEmailSelector;
@synthesize shareSMSSelector;
@synthesize shareSoundcloudSelector;
@synthesize shareView;
@synthesize shareScreen;
@synthesize cancelButton;
@synthesize songNameField;
@synthesize playbandView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        tracks = [[NSMutableArray alloc] init];
        tickmarks = [[NSMutableArray alloc] init];
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

- (void)loadPattern:(NSMutableArray *)patternData withTempo:(int)tempo andSoundMaster:(SoundMaster *)m_soundMaster activeSequence:(NSString *)activeSequence
{
    if([patternData count] > 0){
        [self hideNoSessionOverlay];
    }else{
        [self showNoSessionOverlay];
    }
    
    [self setMeasures:[patternData count]];
    [self drawPatternsOnMeasures:patternData];
    
    if(patternData != nil && [patternData count] > 0){
        [self startRecording:patternData withTempo:tempo andSoundMaster:m_soundMaster activeSequence:activeSequence];
    }
    
    [self resetProgressView];
    
    // ensure record playback gets refreshed
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

-(void)drawPatternsOnMeasures:(NSMutableArray *)patternData
{
    
    UIColor * aColor = [UIColor colorWithRed:23/255.0 green:163/255.0 blue:198/255.0 alpha:0.5];
    UIColor * bColor = [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:0.5];
    UIColor * cColor = [UIColor colorWithRed:0/255.0 green:161/255.0 blue:222/255.0 alpha:0.5];
    UIColor * dColor = [UIColor colorWithRed:137/255.0 green:225/255.0 blue:247/255.0 alpha:0.5];
    UIColor * offColor = [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:0.5];
    
    
    UIColor * aColorSolid = [UIColor colorWithRed:76/255.0 green:146/255.0 blue:163/255.0 alpha:1.0];
    UIColor * bColorSolid = [UIColor colorWithRed:71/255.0 green:161/255.0 blue:184/255.0 alpha:1.0];
    UIColor * cColorSolid = [UIColor colorWithRed:64/255.0 green:145/255.0 blue:175/255.0 alpha:1.0];
    UIColor * dColorSolid = [UIColor colorWithRed:133/255.0 green:177/255.0 blue:188/255.0 alpha:1.0];
    UIColor * offColorSolid = [UIColor colorWithRed:99/255.0 green:99/255.0 blue:99/255.0 alpha:1.0];
    
    
    //
    // Draw measure content
    //
    
    float measureWidth = trackView.frame.size.width / MEASURES_PER_SCREEN;
    
    // clear prev patterns
    for(int j = 0; j < MAX_TRACKS; j++){
        prevPattern[j] = @"";
        prevInterruptPattern[j] = nil;
        prevTranspose[j] = 0;
    }
    
    DLog(@"pattern data is %@",patternData);
    
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
            
            
            // Draw fret before interrupt pattern
            NSMutableArray * frets = [measureData objectForKey:@"frets"];
            NSMutableDictionary * tempPattern = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:-1],[NSNumber numberWithInt:-1],@"",@"",nil] forKeys:[NSArray arrayWithObjects:@"start",@"end",@"ismute",@"pattern",nil, nil]];
            NSMutableArray * tempFretPatterns = [[NSMutableArray alloc] init];
            
            for(NSDictionary * fret in frets){
                
                // Mute -> Unmute before off
                if(![[fret objectForKey:@"ismuted"] boolValue] && [pattern isEqualToString:@"OFF"] && [[tempPattern objectForKey:@"start"] intValue] == -1){
                    
                    // Start a temp pattern
                    [tempPattern setObject:[fret objectForKey:@"fretindex"] forKey:@"start"];
                    [tempPattern setObject:[NSNumber numberWithBool:false] forKey:@"ismute"];
                    [tempPattern setObject:[fret objectForKey:@"pattern"] forKey:@"pattern"];
                    
                }else if([[fret objectForKey:@"ismuted"] boolValue] && ![pattern isEqualToString:@"OFF"] && [[tempPattern objectForKey:@"start"] intValue] == -1){
                    
                    // Start a temp pattern
                    [tempPattern setObject:[fret objectForKey:@"fretindex"] forKey:@"start"];
                    [tempPattern setObject:[NSNumber numberWithBool:true] forKey:@"ismute"];
                    [tempPattern setObject:@"OFF" forKey:@"pattern"];
                }
                
                // Reached the end
                if([[fret objectForKey:@"fretindex"] intValue] > [[tempPattern objectForKey:@"start"] intValue] && [[tempPattern objectForKey:@"start"] intValue] > -1 && ((![[fret objectForKey:@"ismuted"] boolValue] && ![pattern isEqualToString:@"OFF"]) || ([[fret objectForKey:@"ismuted"] boolValue] && [pattern isEqualToString:@"OFF"]))){
                    
                    [tempPattern setObject:[fret objectForKey:@"fretindex"] forKey:@"end"];
                    [tempFretPatterns addObject:tempPattern];
                    
                    tempPattern = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:-1],[NSNumber numberWithInt:-1],@"",@"",nil] forKeys:[NSArray arrayWithObjects:@"start",@"end",@"ismute",@"pattern",nil, nil]];
                    
                }
                
                if(((double)[[fret objectForKey:@"fretindex"] intValue])/FRETS_ON_GTAR >= [[measureData objectForKey:@"deltai"] doubleValue]){
                    
                    //DLog(@"Return at fret %i",[[fret objectForKey:@"fretindex"] intValue]);
                    break;
                }
            }
            
            // Draw the fret patterns
            double fretWidth = measureWidth/FRETS_ON_GTAR;
            for(int t = 0; t < [tempFretPatterns count]; t++){
                
                int start = [[[tempFretPatterns objectAtIndex:t] objectForKey:@"start"] intValue];
                int end = [[[tempFretPatterns objectAtIndex:t] objectForKey:@"end"] intValue];
                int fretslong = end - start;
                
                CGRect fretFrame = CGRectMake(measureBarFrame.origin.x+fretWidth*start,measureBarFrame.origin.y,fretslong*fretWidth,measureBarFrame.size.height);
                
                UIView * tempFret = [[UIView alloc] initWithFrame:fretFrame];
                double deltastart = ((double)start)/FRETS_ON_GTAR;
                double deltawidth = ((double)(end-start))/FRETS_ON_GTAR;
                
                if([[[tempFretPatterns objectAtIndex:t] objectForKey:@"ismute"] boolValue]){
                    
                    [tempFret setBackgroundColor:offColorSolid];
                    
                    [self eraseProgressMarkerForMeasure:i inRow:k startAt:deltastart withWidth:deltawidth];
                    
                }else{
                    // record the color and get it
                    NSString * fretPattern = [[tempFretPatterns objectAtIndex:t] objectForKey:@"pattern"];
                    if([fretPattern isEqualToString:@"A"]){
                        [tempFret setBackgroundColor:aColorSolid];
                    }else if([fretPattern isEqualToString:@"B"]){
                        [tempFret setBackgroundColor:bColorSolid];
                    }else if([fretPattern isEqualToString:@"C"]){
                        [tempFret setBackgroundColor:cColorSolid];
                    }else if([fretPattern isEqualToString:@"D"]){
                        [tempFret setBackgroundColor:dColorSolid];
                    }else{
                        [tempFret setBackgroundColor:offColor];
                    }
                    
                    [self drawProgressMarkerForMeasure:i inRow:k startAt:deltastart withWidth:deltawidth];
                }
                
                [trackView addSubview:tempFret];
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
    float rowHeight = (progressView.frame.size.height-10) / MAX_TRACKS;
    
    CGRect markerFrame = CGRectMake(m*measureWidth+measureWidth*start,row*rowHeight+5,width*measureWidth,1.0);
    
    UIView * marker = [[UIView alloc] initWithFrame:markerFrame];
    [marker setBackgroundColor:[UIColor whiteColor]];
    
    [progressView addSubview:marker];
    
}

-(void)eraseProgressMarkerForMeasure:(int)m inRow:(int)row startAt:(double)start withWidth:(double)width
{
    float measureWidth = progressView.frame.size.width / numMeasures;
    float rowHeight = (progressView.frame.size.height-10) / MAX_TRACKS;
    
    CGRect markerFrame = CGRectMake(m*measureWidth+measureWidth*start,row*rowHeight+5,width*measureWidth,1.0);
    
    UIView * marker = [[UIView alloc] initWithFrame:markerFrame];
    [marker setBackgroundColor:[UIColor colorWithRed:105/255.0 green:214/255.0 blue:90/255.0 alpha:1.0]];
    
    [progressView addSubview:marker];
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
    shareEmailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    shareEmailButton.layer.borderWidth = 1.0f;
    shareEmailButton.layer.cornerRadius = 5.0;
    
    shareSMSButton.layer.borderColor = [UIColor whiteColor].CGColor;
    shareSMSButton.layer.borderWidth = 1.0f;
    shareSMSButton.layer.cornerRadius = 5.0;
    
    shareSoundcloudButton.layer.borderColor = [UIColor whiteColor].CGColor;
    shareSoundcloudButton.layer.borderWidth = 1.0f;
    shareSoundcloudButton.layer.cornerRadius = 5.0;
    
    shareEmailSelector.layer.cornerRadius = 5.0;
    shareSMSSelector.layer.cornerRadius = 5.0;
    shareSoundcloudSelector.layer.cornerRadius = 5.0;
    
    selectedShareType = @"Email";
    
    // Setup text field listeners
    songNameField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [songNameField addTarget:self action:@selector(songNameFieldStartEdit:) forControlEvents:UIControlEventEditingDidBegin];
    [songNameField addTarget:self action:@selector(songNameFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [songNameField addTarget:self action:@selector(songNameFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    songNameField.delegate = self;
    
    [songNameField setFont:[UIFont fontWithName:FONT_DEFAULT size:22.0]];
    
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
    
}

- (IBAction)userDidSelectShare:(id)sender
{
    UIButton * senderButton = (UIButton *)sender;
    
    // reset selector backgrounds
    [shareEmailSelector setBackgroundColor:[UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]];
    [shareSMSSelector setBackgroundColor:[UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]];
    [shareSoundcloudSelector setBackgroundColor:[UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]];
    
    if(senderButton == shareEmailButton || senderButton == shareEmailSelector){
        
        selectedShareType = @"Email";
        [shareEmailSelector setBackgroundColor:[UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]];
        
    }else if(senderButton == shareSMSButton || senderButton == shareSMSSelector){
        
        selectedShareType = @"SMS";
        [shareSMSSelector setBackgroundColor:[UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]];
        
    }else if(senderButton == shareSoundcloudButton || senderButton == shareSoundcloudSelector){
        
        selectedShareType = @"SoundCloud";
        [shareSoundcloudSelector setBackgroundColor:[UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]];
        
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

- (void)userDidShare:(id)sender
{
    
    NSString * songname = [[self renameSongToSongname] stringByAppendingString:@".m4a"];
    
    if([selectedShareType isEqualToString:@"Email"]){
        
        [delegate userDidLaunchEmailWithAttachment:songname];
        
    }else if([selectedShareType isEqualToString:@"SMS"]){
        
        [delegate userDidLaunchSMSWithAttachment:songname];
        
    }else if([selectedShareType isEqualToString:@"SoundCloud"]){
        
        [delegate userDidLaunchSoundCloudAuthWithFile:songname];
        
    }
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
    DLog(@"Reset playband");
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
    
    if(playMeasure > [loadedPattern count]){
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
    [self movePlaybandToMeasure:[loadedPattern count]-1 andFret:FRETS_ON_GTAR-1 andHide:YES];
    
    
}

#pragma mark - Recording
-(void)startRecording:(NSMutableArray *)patternData withTempo:(int)tempo andSoundMaster:(SoundMaster *)m_soundMaster activeSequence:(NSString *)activeSequence
{
    if(loadedPattern != patternData){
        
        isWritingFile = YES;
        
        loadedPattern = patternData;
        loadedTempo = tempo;
        loadedSoundMaster = m_soundMaster;
        loadedSequence = activeSequence;
        
        r_measure = 0;
        r_beat = 0;
        
        DLog(@"Start recording %@",loadedPattern);
        [self showProcessingOverlay];
        [delegate forceShowSessionOverlay];
        
        [self resetAudio];
        [self showRecordOverlay];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(beginRecordSession) userInfo:nil repeats:NO];
    }
}

-(void)beginRecordSession
{
    recordingSong = [[NSSong alloc] initWithId:0 Title:loadedSequence author:g_loggedInUser.m_username description:@"" tempo:loadedTempo looping:false loopstart:0 loopend:0];
    
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
    NSArray * measure = [loadedPattern objectAtIndex:r_measure];
    
    // loop through measures
    @synchronized(measure){
        for(NSDictionary * measureinst in measure){
            
            int instIndex = [[measureinst objectForKey:@"instrument"] intValue];
            NSTrack * track = [instruments objectAtIndex:[self getIndexForInstrument:instIndex]];
            NSTrack * songTrack = [recordingSong trackWithName:track.m_name volume:track.m_volume mute:track.m_muted instrument:track.m_instrument];
            NSClip * songClip = [songTrack firstClip];
            
            // fret for the beat
            NSMutableArray * frets = [measureinst objectForKey:@"frets"];
            for(NSDictionary * f in frets){
                int fretindex = [[f objectForKey:@"fretindex"] intValue];
                if(fretindex == r_beat%FRETS_ON_GTAR && ![[f objectForKey:@"ismuted"] boolValue]){
                    
                    // strings for the fret
                    NSString * strings = [f objectForKey:@"strings"];
                    for(int s = 0; s < STRINGS_ON_GTAR; s++){
                        if([strings characterAtIndex:s] == '1'){
                            
                            // Record to m4a file
                            [track.m_instrument.m_sampler.audio pluckString:s];
                            
                            // Save to XMP
                            NSNote * newNote = [[NSNote alloc] initWithValue:[NSString stringWithFormat:@"%i",s] beatstart:r_beat/4.0 duration:0.25];
                            [songClip addNote:newNote];
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
    
    if(r_measure == [loadedPattern count]){
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
    [recordingSong saveToFile:recordingSong.m_title];
    
    // release
    [self releaseFileoutNode];
    
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
        
        [self startPlaybandAnimation];
        
    }else{
        [self resumePlaybandAnimation];
    }
    
    [audioPlayer play];
    
}

-(void)pauseRecordPlayback
{
    [audioPlayer pause];
    [self pausePlaybandAnimation];
}

-(void)stopRecordPlayback
{
    isAudioPlaying = NO;
    [self stopPlaybandAnimation];
    [audioPlayer stop];
    [delegate recordPlaybackDidEnd];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    DLog(@"Audio player did finish");
    [self stopRecordPlayback];
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
    
    /*if(!isRecordingNameReady){
     
     if([self checkDuplicateSongName:songNameField.text]){
     [self alertDuplicateSoundName];
     }
     
     [self resetSongNameIfBlank];
     }*/
    
    [self resetSongNameIfBlank];
    
    // hide styles
    [self clearAttributedStringForText:songNameField];
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
    /*NSArray * tempList = [customSampleList[0] objectForKey:@"Sampleset"];
     
     for(int i = 0; i < [tempList count]; i++){
     if([tempList[i] isEqualToString:filename]){
     return YES;
     }
     }*/
    
    return NO;
}

- (void)setRecordDefaultText
{
    /*
     NSArray * tempList = [customSampleList[0] objectForKey:@"Sampleset"];
     
     DLog(@"CustomSampleList is %@",tempList);
     
     int customCount = 0;
     
     // Look through Samples, get the max CustomXXXX name and label +1
     for(NSString * filename in tempList){
     
     if(!([filename rangeOfString:@"Song"].location == NSNotFound)){
     
     NSString * customSuffix = [filename stringByReplacingCharactersInRange:[filename rangeOfString:@"Song"] withString:@""];
     int numFromSuffix = [customSuffix intValue];
     
     customCount = MAX(customCount,numFromSuffix);
     }
     }
     
     customCount++;
     */
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPaddingCharacter:@"0"];
    [numberFormatter setPaddingPosition:NSNumberFormatterPadBeforePrefix];
    [numberFormatter setMinimumIntegerDigits:3];
    
    NSNumber * number = [NSNumber numberWithInt:1];
    
    NSString * numberString = [numberFormatter stringFromNumber:number];
    
    songNameField.text = [@"Song" stringByAppendingString:numberString];
    
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

@end
