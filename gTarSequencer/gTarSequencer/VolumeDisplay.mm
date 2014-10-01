//
//  VolumeDisplay.m
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "VolumeDisplay.h"
#import "AudioController.h"
#import "AUNodeNetwork.h"
#import "AudioNodeCommon.h"

#define ANIMATION_DURATION 0.2f
#define SIDEBAR_WIDTH 130
#define SLIDER_WIDTH 40
#define SLIDER_HEIGHT 250

@implementation VolumeDisplay

@synthesize delegate;
@synthesize sliderCircle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    float x = [frameGenerator getFullscreenWidth];
    
    self.userInteractionEnabled = YES;
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = x;
    
    outline = [[UIImageView alloc] initWithFrame:frame];
    [self addSubview:outline];
    
    filling = [[UIImageView alloc] initWithFrame:frame];
    filling.clearsContextBeforeDrawing = NO;
    [self addSubview:filling];
    
    // Get dimensions for filling
    CGSize fullScreen = CGSizeMake(x, 320);
    UIGraphicsBeginImageContextWithOptions(fullScreen, NO, 0);
    
    // Prepare for touches
    zeroPosition.x = self.frame.size.width / 2;
    zeroPosition.y = self.frame.size.height / 4;
    
    // Prepare for dynamic instruments
    instrumentFrameContainer = [[UIView alloc] initWithFrame:CGRectMake(0, -1, outline.frame.size.width + 2, outline.frame.size.height+2)];
    instrumentFrameContainer.userInteractionEnabled = YES;
    outline.userInteractionEnabled = YES;
    [outline addSubview:instrumentFrameContainer];
    
    instrumentIcons = [[NSMutableDictionary alloc] init];
    
}

- (void)setVolume:(double)value
{
    DLog(@"Set volume to %f",value);
    
    currentValue = value;
    
    //[self setVolumeGainTo:value];
    [self fillToPercent:[self percentFull:value]];
}

- (void)setVolumeByPercent:(double)percent
{
    currentValue = MAX_VOLUME*percent;
    
    [self fillToPercent:percent];
}

#pragma mark Filling

- (double)percentFull:(double)value
{
    double percentFull = (value-MIN_VOLUME)/(MAX_VOLUME-MIN_VOLUME);
    
    //DLog(@" *** fill to %f percent ", percentFull);
    
    return percentFull;
}

- (void)fillToPercent:(double)percent
{
    /*double y = sliderCircleMinY - (sliderCircleMinY - sliderCircleMaxY)*percent;
     
     //DLog(@"y is %f",y);
     
     CGRect newFrame = CGRectMake(sliderCircle.frame.origin.x, y, sliderCircle.frame.size.width, sliderCircle.frame.size.height);
     
     [UIView animateWithDuration:0.1 animations:^(void){[sliderCircle setFrame:newFrame];}];
     */
    
    [masterSlider setSliderValue:(1-percent)];
    
}


#pragma mark Outline

- (void)createOutline
{
    // DLog(@"outline frame is %f %f %f %f",outline.frame.origin.x,outline.frame.origin.y,outline.frame.size.width,outline.frame.size.height);
    
    // Draw black background:
    [outline setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    
    // Draw right sidebar
    CGRect sidebarFrame = CGRectMake(outline.frame.size.width - SIDEBAR_WIDTH, -1, SIDEBAR_WIDTH+1, outline.frame.size.height+2);
    if(sidebar == nil){
        sidebar = [[UIView alloc] initWithFrame:sidebarFrame];
        sidebar.backgroundColor = [UIColor colorWithRed:40/255.0 green:47/255.0 blue:51/255.0 alpha:1.0];
        sidebar.layer.borderColor = [UIColor whiteColor].CGColor;
        sidebar.layer.borderWidth = 1.0;
        sidebar.userInteractionEnabled = YES;
        
        [outline addSubview:sidebar];
    }
    
    // Draw sidebar slider
    /*CGRect sliderFrame = CGRectMake((sidebar.frame.size.width-SLIDER_WIDTH)/2, (sidebar.frame.size.height-SLIDER_HEIGHT)/2, SLIDER_WIDTH, SLIDER_HEIGHT);
     
     slider = [[UIView alloc] initWithFrame:sliderFrame];
     slider.layer.borderColor = [UIColor whiteColor].CGColor;
     slider.layer.borderWidth = 3.0f;
     slider.layer.cornerRadius = SLIDER_WIDTH/2;
     
     [slider setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3]];
     
     [sidebar addSubview:slider];
     
     // Draw sidebar slider circle
     float baseX = slider.frame.origin.x+sidebar.frame.origin.x;
     float baseY = slider.frame.origin.y;
     float indent = 5;
     float circleWidth = SLIDER_WIDTH-2*indent;
     sliderCircleMaxY = indent+baseY-1;
     sliderCircleMinY = slider.frame.size.height - circleWidth - indent - 1 + baseY;
     
     CGRect sliderCircleFrame = CGRectMake(baseX+indent, sliderCircleMinY, circleWidth, circleWidth);
     
     sliderCircle = [[UIButton alloc] initWithFrame:sliderCircleFrame];
     sliderCircle.backgroundColor = [UIColor colorWithRed:141/255.0 green:112/255.0 blue:166/255.0 alpha:1.0];
     sliderCircle.layer.cornerRadius = SLIDER_WIDTH/2-indent;
     
     [self addSubview:sliderCircle];
     */
    
    // Master volume level slider
    if(masterSlider == nil){
        CGRect levelSliderFrame = CGRectMake(sidebarFrame.size.width/2 - SLIDER_WIDTH/2,10,SLIDER_WIDTH,SLIDER_HEIGHT);
        UILevelSlider * volumeSlider = [[UILevelSlider alloc] initWithFrame:levelSliderFrame];
        [volumeSlider setBackgroundColor:[UIColor clearColor]];
        //[volumeSlider setSliderValue:(1-inst.amplitude)];
        
        [volumeSlider setRedColor:[UIColor colorWithRed:203/255.0 green:81/255.0 blue:26/255.0 alpha:1.0]];
        [volumeSlider setGreenColor:[UIColor colorWithRed:5/255.0 green:195/255.0 blue:77/255.0 alpha:1.0]];
        [volumeSlider setLightGreenColor:[UIColor colorWithRed:105/255.0 green:214/255.0 blue:90/255.0 alpha:1.0]];
        [volumeSlider setYellowColor:[UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]];
        [volumeSlider setControlColor:[UIColor whiteColor]];
        
        volumeSlider.delegate = self;
        
        masterSlider = volumeSlider;
        
        [sidebar addSubview:volumeSlider];
    }
    
    // Link volume sliders to soundmaster
    [delegate commitMasterLevelSlider:masterSlider];
    
}

- (void)addGestures
{
    /*
     [sliderCircle setUserInteractionEnabled:YES];
     
     UIPanGestureRecognizer * sliderPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panVolume:)];
     
     [sliderCircle addGestureRecognizer:sliderPan];
     */
}

#pragma mark - Instruments
- (void)drawInstruments
{
    if(tracks != nil){
        [tracks removeAllObjects];
        
        // clear previous
        for(UIView * v in instrumentFrameContainer.subviews){
            [v removeFromSuperview];
        }
    }
    
    tracks = [[NSMutableArray alloc] initWithArray:[delegate getTracks]];
    sliders = [[NSMutableDictionary alloc] init];
    
    int i = 0;
    float instrumentWidth = instrumentFrameContainer.frame.size.width / ([tracks count]+1);
    
    // reset other frames
    if(instrumentWidth < 130){
        [sidebar setFrame:CGRectMake([tracks count]*instrumentWidth-1, -1, instrumentWidth, instrumentFrameContainer.frame.size.height)];
        //[slider setFrame:CGRectMake((sidebar.frame.size.width-SLIDER_WIDTH)/2, (sidebar.frame.size.height-SLIDER_HEIGHT)/2, SLIDER_WIDTH, SLIDER_HEIGHT)];
        //[sliderCircle setFrame:CGRectMake(slider.frame.origin.x+sidebar.frame.origin.x+5,sliderCircle.frame.origin.y,sliderCircle.frame.size.width,sliderCircle.frame.size.height)];
        
        [masterSlider setFrame:CGRectMake(sidebar.frame.size.width/2 - SLIDER_WIDTH/2,10,SLIDER_WIDTH,SLIDER_HEIGHT)];
        
    }else{
        instrumentWidth = (instrumentFrameContainer.frame.size.width-SIDEBAR_WIDTH) / ([tracks count]);
        
        [sidebar setFrame:CGRectMake(outline.frame.size.width - SIDEBAR_WIDTH+1, -1, SIDEBAR_WIDTH, outline.frame.size.height+2)];
        //[slider setFrame:CGRectMake((sidebar.frame.size.width-SLIDER_WIDTH)/2, (sidebar.frame.size.height-SLIDER_HEIGHT)/2, SLIDER_WIDTH, SLIDER_HEIGHT)];
        //[sliderCircle setFrame:CGRectMake(slider.frame.origin.x+sidebar.frame.origin.x+5,sliderCircle.frame.origin.y,sliderCircle.frame.size.width,sliderCircle.frame.size.height)];
        
        [masterSlider setFrame:CGRectMake(sidebar.frame.size.width/2 - SLIDER_WIDTH/2,10,SLIDER_WIDTH,SLIDER_HEIGHT)];
    }
    
    for(NSTrack * track in tracks){
        
        // draw partial frame
        CGRect instrumentFrame = CGRectMake(i*instrumentWidth-1, 0, instrumentWidth+1, instrumentFrameContainer.frame.size.height);
        UIView * instrumentView = [[UIView alloc] initWithFrame:instrumentFrame];
        
        instrumentView.layer.borderColor = [UIColor whiteColor].CGColor;
        instrumentView.layer.borderWidth = 1.0f;
        
        [instrumentFrameContainer addSubview:instrumentView];
        
        // draw instrument icon
        float iconWidth = 58;
        CGRect instrumentIconFrame = CGRectMake(instrumentFrame.size.width/2 - iconWidth/2 - 0.66667,16,iconWidth,iconWidth);
        UIButton * instrumentIcon = [[UIButton alloc] initWithFrame:instrumentIconFrame];
        
        DLog(@"Position is %f",instrumentIconFrame.origin.x);
        
        [instrumentIcon setImage:[UIImage imageNamed:track.m_instrument.m_iconName] forState:UIControlStateNormal];
        [instrumentIcon setContentEdgeInsets:UIEdgeInsetsMake(10,10,10,10)];
        
        instrumentIcon.layer.cornerRadius = 5.0;
        instrumentIcon.layer.borderWidth = 1.0;
        instrumentIcon.layer.borderColor = [UIColor whiteColor].CGColor;
        
        if(track.m_muted){
            [instrumentIcon setAlpha:0.5];
        }
        
        [instrumentIcons setObject:instrumentIcon forKey:[NSNumber numberWithInt:i]];
        
        [instrumentIcon addTarget:self action:@selector(openInstrument:) forControlEvents:UIControlEventTouchUpInside];
        
        [instrumentView addSubview:instrumentIcon];
        
        // draw level slider
        float levelSliderWidth = 40.0;
        float levelSliderHeight = 170.0;
        CGRect levelSliderFrame = CGRectMake(instrumentFrame.size.width/2 - levelSliderWidth/2,90,levelSliderWidth,levelSliderHeight);
        UILevelSlider * volumeSlider = [[UILevelSlider alloc] initWithFrame:levelSliderFrame];
        [volumeSlider setBackgroundColor:[UIColor clearColor]];
        [volumeSlider setSliderValue:(1-track.m_level)];
        
        [volumeSlider setRedColor:[UIColor colorWithRed:203/255.0 green:81/255.0 blue:26/255.0 alpha:1.0]];
        [volumeSlider setGreenColor:[UIColor colorWithRed:5/255.0 green:195/255.0 blue:77/255.0 alpha:1.0]];
        [volumeSlider setLightGreenColor:[UIColor colorWithRed:105/255.0 green:214/255.0 blue:90/255.0 alpha:1.0]];
        [volumeSlider setYellowColor:[UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]];
        [volumeSlider setControlColor:[UIColor whiteColor]];
        
        volumeSlider.delegate = self;
        
        [sliders setObject:volumeSlider forKey:[NSNumber numberWithInt:i]];
        
        [instrumentView addSubview:volumeSlider];
        
        // Link volume sliders to instruments
        [track.m_instrument.m_sampler.audio releaseLevelSlider];
        [track.m_instrument.m_sampler.audio commitLevelSlider:volumeSlider];
        
        i++;
    }
}

- (void)openInstrument:(id)sender
{
    /*
     UIButton * senderButton = (UIButton *)sender;
     
     for(NSNumber * instIndex in instrumentIcons){
     if(senderButton == [instrumentIcons objectForKey:instIndex]){
     [delegate openInstrument:[instIndex intValue]];
     }
     }
     
     [self contract];*/
    
    // Toggle instrument muted
    UIButton * senderButton = (UIButton *)sender;
    
    for(NSNumber * instIndex in instrumentIcons){
        if(senderButton == [instrumentIcons objectForKey:instIndex]){
            
            int index = [instIndex intValue];
            NSTrack * track = [tracks objectAtIndex:index];
            
            if(track.m_muted){
                [delegate enableInstrument:track.m_instrument.m_id];
                [senderButton setAlpha:1.0];
            }else{
                [delegate disableInstrument:track.m_instrument.m_id];
                [senderButton setAlpha:0.5];
            }
            
        }
    }
}

#pragma mark - Expand Contract
- (void)expand
{
    [self createOutline];
    [self drawInstruments];
    [self setVolume:[delegate getVolume]];
    
    // Animate...
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = VISIBLE;
                     }
                     completion:nil];
}

- (void)contract
{
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = NOT_VISIBLE;
                     }
                     completion:nil];
    
}

#pragma mark - Drag slider
- (void)panVolume:(UIPanGestureRecognizer *)sender
{
    /*
     CGPoint newPoint = [sender translationInView:self];
     
     if([sender state] == UIGestureRecognizerStateBegan){
     volumeFirstY = sliderCircle.frame.origin.y;
     }
     
     float newY = newPoint.y + volumeFirstY;
     
     // Wrap to boundary
     if(newY <= sliderCircleMaxY*1.2){
     newY = sliderCircleMaxY;
     }else if(newY >= sliderCircleMinY*1.2){
     newY = sliderCircleMinY;
     }
     
     float height = 1-(newY - sliderCircleMaxY)/(sliderCircleMinY - sliderCircleMaxY);
     float volume = MAX(height*MAX_VOLUME,MIN_VOLUME);
     
     
     if(newY <= sliderCircleMinY && newY >= sliderCircleMaxY){
     [self setVolume:volume];
     }
     
     // Set the volume
     BOOL save = NO;
     if([sender state] == UIGestureRecognizerStateEnded){
     save = YES;
     }
     
     if(volumeChangeTimer == nil){
     
     volumeChangeTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(allowVolumeChange) userInfo:nil repeats:NO];
     [delegate volumeButtonValueDidChange:currentValue withSave:save];
     
     }
     */
}

-(void)valueDidChange:(double)newValue forSlider:(id)sender
{
    NSTrack * track;
    UILevelSlider * levelSender = (UILevelSlider *)sender;
    
    if(levelSender == masterSlider){
        [self setVolumeByPercent:newValue];
        [delegate volumeButtonValueDidChange:currentValue withSave:YES];
        return;
    }
    
    for(NSNumber * key in sliders){
        if(levelSender == [sliders objectForKey:key]){
            track = [tracks objectAtIndex:[key intValue]];
            track.m_level = newValue;
            return;
        }
    }
}


-(void)allowVolumeChange
{
    [volumeChangeTimer invalidate];
    volumeChangeTimer = nil;
}

#pragma mark - Audio Controller
/*
 -(void)setVolumeGainTo:(double)value
 {
 
 DLog(@" **** Set channel gain to %f *** ",value);
 
 AudioController * audioController = [AudioController sharedAudioController];
 AudioNode * root = [[audioController GetNodeNetwork] GetRootNode];
 
 root->SetChannelGain(value, CONN_OUT);
 
 }
 */


@end
