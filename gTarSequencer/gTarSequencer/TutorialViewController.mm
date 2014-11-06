//
//  TutorialView.m
//  Sequence
//
//  Created by Kate Schnippering on 3/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "TutorialViewController.h"
#import "SoundMaster_.mm"


#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

@interface TutorialViewController(){
    
    SoundMaster * soundMaster;
    
    SampleNode * m_sampNode;
    SamplerBankNode * m_bankNode;
}

@end

@implementation TutorialViewController

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andTutorial:(NSString *)tutorial
{
    self = [self initWithFrame:frame];
    
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    
    isScreenLarge = [frameGenerator isScreenLarge];
    
    screenX = [frameGenerator getFullscreenWidth];
    screenY = [frameGenerator getFullscreenHeight];;
    
    tutorialName = tutorial;
    
    conditionalScreen = -1;
    showConditionalScreen = NO;
    
    if([tutorialName isEqualToString:@"Intro"]){
        tutorialTotalSteps = 6;
        conditionalScreen = 5;
    }else if([tutorialName isEqualToString:@"Instrument"]){
        tutorialTotalSteps = 2;
    }else if([tutorialName isEqualToString:@"Custom"]){
        tutorialTotalSteps = 1;
    }else if([tutorialName isEqualToString:@"SeqSet"]){
        tutorialTotalSteps = 1;
    }else{
        tutorialTotalSteps = 0;
    }
    
    tutorialScreen = self;
    
    return self;
}

- (void)launch
{
    // Make sure animations are enabled
    [UIView setAnimationsEnabled:YES];
    
    tutorialStep = 1;
    
    [self drawTutorialScreenForStep:tutorialStep isReverseDirection:NO];
}

- (void)incrementFTUTutorial
{
    tutorialStep++;
    
    [self drawTutorialScreenForStep:tutorialStep isReverseDirection:NO];
}

- (void)decrementFTUTutorial
{
    tutorialStep--;
    
    [self drawTutorialScreenForStep:tutorialStep isReverseDirection:YES];
}

-(void)skipTutorial
{
    [delegate presentGatekeeper:YES];
    [self end];
    //tutorialStep = tutorialTotalSteps;
    //[self drawTutorialScreenForStep:tutorialStep isReverseDirection:NO];
}

- (void)end
{
    [self endSequenceLoop];
    [tutorialScreen setBackgroundColor:[UIColor clearColor]];
    [self fadeOutTutorialSubviews:YES isReverseDirection:NO];
    [delegate notifyTutorialEnded];
}

- (void)clear
{
    [tutorialScreen removeFromSuperview];
}

- (void)drawTutorialScreenForStep:(int)step isReverseDirection:(BOOL)reverse
{
    if([tutorialName isEqualToString:@"Intro"]){
        [self drawIntroTutorialScreen:step isReverseDirection:reverse];
    }else if([tutorialName isEqualToString:@"Instrument"]){
        [self drawInstrumentTutorialScreen:step isReverseDirection:reverse];
    }else if([tutorialName isEqualToString:@"Custom"]){
        [self drawCustomTutorialScreen:step];
    }else if([tutorialName isEqualToString:@"SeqSet"]){
        [self drawSeqSetTutorialScreen:step];
    }
}

- (void)fadeOutTutorialSubviews:(BOOL)removeAll isReverseDirection:(BOOL)reverse
{
    NSArray * views = [tutorialScreen subviews];
    
    float screenWidth = tutorialScreen.frame.size.width;
    
    [tutorialBottomBar setAlpha:0.0];
    [tutorialTopBar setAlpha:0.0];
    
    [UIView animateWithDuration:0.5 animations:^(void){
        for (UIView * v in views) {
            if(!reverse){
                [v setFrame:CGRectMake(-1*screenWidth+v.frame.origin.x,v.frame.origin.y,v.frame.size.width,v.frame.size.height)];
             }else{
                 [v setFrame:CGRectMake(screenWidth+v.frame.origin.x, v.frame.origin.y, v.frame.size.width, v.frame.size.height)];
             }
            [v setAlpha:0.0];
        }
    } completion:^(BOOL finished){
        if(removeAll){
            [tutorialScreen removeFromSuperview];
            [tutorialBottomBar removeFromSuperview];
            [tutorialTopBar removeFromSuperview];
        }else{
            for (UIView * v in views) {
                [v removeFromSuperview];
            }
        }
    }];
}

- (void)fadeInTutorialSubview:(UIView *)v isReverseDirection:(BOOL)reverse
{
    
    float screenWidth = tutorialScreen.frame.size.width;
    CGRect frame = CGRectMake(v.frame.origin.x,v.frame.origin.y,v.frame.size.width,v.frame.size.height);
    
    if(!reverse){
        [v setFrame:CGRectMake(screenWidth+frame.origin.x,frame.origin.y,frame.size.width,frame.size.height)];
    }else{
        [v setFrame:CGRectMake(-1*screenWidth+frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    }
    [v setAlpha:0.0];
    
    [tutorialScreen addSubview:v];
    
    [UIView animateWithDuration:0.5 animations:^(void){
        [v setFrame:frame];
        [v setAlpha:1.0];
    } completion:^(BOOL finished){
        
    }];
}

#pragma mark - Swipe Gestures
-(void)startSwipeGestures
{
    DLog(@"Start swipe gestures");
    
    [self stopLeftSwipeGesture];
    [self stopRightSwipeGesture];
    
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(incrementFTUTutorial)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [swipeLeft setNumberOfTouchesRequired:1];
    
    swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(decrementFTUTutorial)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [swipeRight setNumberOfTouchesRequired:1];
    
    [tutorialScreen addGestureRecognizer:swipeLeft];
    [tutorialScreen addGestureRecognizer:swipeRight];
}

-(void)startSingleSwipeGesture
{
    
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(end)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [swipeLeft setNumberOfTouchesRequired:1];
    
    [tutorialScreen addGestureRecognizer:swipeLeft];
}

-(void)startFinalSwipeGesture
{
    [self startSingleSwipeGesture];
    
    swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(decrementFTUTutorial)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [swipeRight setNumberOfTouchesRequired:1];
    
    [tutorialScreen addGestureRecognizer:swipeRight];
}

-(void)stopLeftSwipeGesture
{
    [tutorialScreen removeGestureRecognizer:swipeLeft];
}

-(void)stopRightSwipeGesture
{
    [tutorialScreen removeGestureRecognizer:swipeRight];
}

-(int)checkShowConditionalScreen:(int)screenIndex
{
    if(screenIndex == conditionalScreen && !showConditionalScreen){
        screenIndex++;
    }
    
    return screenIndex;
}

-(void)startSwipeToPlayGesture
{
    DLog(@"Start swipe to play");
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToPlay)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [swipeLeft setNumberOfTouchesRequired:1];
    
    [tutorialScreen addGestureRecognizer:swipeLeft];
}

-(void)swipeToPlay
{
    DLog(@"Start to play");
    [delegate forceToPlay];
    [self end];
}

#pragma mark - Intro Tutorial

- (void)drawIntroTutorialScreen:(int)screenIndex isReverseDirection:(BOOL)reverse
{    
    UIColor * fadedGray = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    UIColor * blueColor = [UIColor colorWithRed:33/255.0 green:173/255.0 blue:211/255.0 alpha:1.0];
    
    float circleBorderWidth = 8.0;
    float circleWidth = 90;
    float defaultLabelHeight = 32;
    float stripeWidth = 20;
    
    // Clear out previous screen
    [self fadeOutTutorialSubviews:NO isReverseDirection:reverse];
    
    // Show conditional screen?
    screenIndex = [self checkShowConditionalScreen:screenIndex];
    
    if(screenIndex == 1){
        
        [self startSwipeGestures];
        [self stopRightSwipeGesture];
        [delegate closeLeftNavigator];
        
        //
        // WELCOME TO SEQUENCE
        //
        
        [tutorialScreen setBackgroundColor:blueColor];
        
        // Title label
        
        CGRect titleFrame = CGRectMake(0,30,tutorialScreen.frame.size.width,30);
        //CGRect subtitleFrame = CGRectMake(30,60,180,30);
        
        UILabel * titleLabel = [self drawTutorialLabel:titleFrame withTitle:@"WELCOME TO SEQUENCE" withColor:[UIColor clearColor] isHeader:YES isReverseDirection:reverse];
        
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        //[self drawTutorialLabel:subtitleFrame withTitle:@"Let's get started..." withColor:[UIColor clearColor] isHeader:NO isReverseDirection:reverse];
        
        
        // Title label
        float desctitleWidth = 440;
        
        //CGRect titleFrame = CGRectMake(30,30,300,30);
        CGRect desctitleFrame = CGRectMake(tutorialScreen.frame.size.width/2 - desctitleWidth/2,90,desctitleWidth,30);
        CGRect desctitle2Frame = CGRectMake(tutorialScreen.frame.size.width/2 - desctitleWidth/2,120,desctitleWidth,30);
        CGRect desctitle3Frame = CGRectMake(tutorialScreen.frame.size.width/2 - desctitleWidth/2,150,desctitleWidth,35);
        
        //[self drawTutorialLabel:titleFrame withTitle:@"WHAT IS SEQUENCE" withColor:[UIColor clearColor] isHeader:YES isReverseDirection:reverse];
        [self drawTutorialLabel:desctitleFrame withTitle:@"Sequence is like a drum machine" withColor:[UIColor clearColor] isHeader:NO isReverseDirection:reverse];
        
        [self drawTutorialLabel:desctitle2Frame withTitle:@"you can use to create looping" withColor:[UIColor clearColor] isHeader:NO isReverseDirection:reverse];
        
        UILabel * titleLabel3 = [self drawTutorialLabel:desctitle3Frame withTitle:@"" withColor:[UIColor clearColor] isHeader:NO isReverseDirection:reverse];
        
        NSMutableAttributedString * title3String = [[NSMutableAttributedString alloc] initWithString:@"rhythms & melodies."];
        [title3String addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_BOLD size:30.0] range:NSMakeRange(0,8)];
        [title3String addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_BOLD size:30.0] range:NSMakeRange(10,8)];
        
        [titleLabel3 setAttributedText:title3String];
        
        // Draw boxes
        float boxWidth = 30;
        float boxSpace = 2;
        float boxFrameWidth = boxWidth*NUM_SEQUENCE_NOTES+boxSpace*NUM_SEQUENCE_NOTES;
        sequenceNotes = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < NUM_SEQUENCE_NOTES; i++){
            
            CGRect noteFrame = CGRectMake(tutorialScreen.frame.size.width/2-boxFrameWidth/2+boxWidth*i+boxSpace*i, 200, boxWidth, boxWidth);
            UIButton * note = [[UIButton alloc] initWithFrame:noteFrame];
            
            note.layer.borderColor = [UIColor whiteColor].CGColor;
            note.layer.borderWidth = 0.5;
            
            if(i == 0 || i == 4 || i == 6){
                [note setBackgroundColor:[UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]];
                sequenceNoteActive[i] = YES;
            }else{
                sequenceNoteActive[i] = NO;
            }
            
            [note addTarget:self action:@selector(toggleSequenceNoteActive:) forControlEvents:UIControlEventTouchUpInside];
            
            [sequenceNotes addObject:note];
            [self fadeInTutorialSubview:note isReverseDirection:reverse];
            
        }
        
        [self initAudioForSequence];
        
        // Swipe arrow
        float swipeFrameWidth = 200;
        float swipeFrameHeight = 30;
        CGRect swipeFrame = CGRectMake(tutorialScreen.frame.size.width/2 - swipeFrameWidth/2,tutorialScreen.frame.size.height-59,swipeFrameWidth,swipeFrameHeight);

        [self drawSwipeDottedLines:swipeFrame swipeText:@"swipe to learn how" swipeLeft:YES swipeRight:NO withAlpha:0.7 isReverseDirection:reverse];
        
        // Skip tutorial
        float skipWidth = 60;
        CGRect skipFrame = CGRectMake(tutorialScreen.frame.size.width - skipWidth,10,skipWidth,20);
        
        UIButton * skipButton = [[UIButton alloc] initWithFrame:skipFrame];
        [skipButton setTitle:@"SKIP" forState:UIControlStateNormal];
        [skipButton.titleLabel setAlpha:0.7];
        [skipButton.titleLabel setFont:[UIFont fontWithName:FONT_DEFAULT size:15.0]];
        
        [skipButton addTarget:self action:@selector(skipTutorial) forControlEvents:UIControlEventTouchUpInside];
        
        [self fadeInTutorialSubview:skipButton isReverseDirection:reverse];
        
    }else if(screenIndex == tutorialTotalSteps){
        
        [delegate presentGatekeeper:YES];
        [self stopLeftSwipeGesture];
        [self startSwipeToPlayGesture];
        
        //
        // PLAY TO START
        //
        FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
        float screenHeight = [frameGenerator getFullscreenHeight];
        float screenWidth = [frameGenerator getFullscreenWidth];
        
        // pointer to play
        CGRect newTutorialFrame = CGRectMake(0, 0, screenWidth, screenHeight);
        [tutorialScreen setFrame:newTutorialFrame];
        [tutorialScreen setBackgroundColor:[UIColor clearColor]];
        
        DLog(@"tutorial screen bounds %f %f %f %f",tutorialScreen.bounds.origin.x,tutorialScreen.bounds.origin.y,tutorialScreen.bounds.size.width,tutorialScreen.bounds.size.height);
        
        float playButtonWidth = 65;
        
        CGRect topBarFrame = CGRectMake(0, 0, screenWidth, screenHeight-BOTTOMBAR_HEIGHT);
        tutorialTopBar = [[UIView alloc] initWithFrame:topBarFrame];
        [tutorialTopBar setBackgroundColor:fadedGray];
        
        [self fadeInTutorialSubview:tutorialTopBar isReverseDirection:reverse];
        
        CGRect bottomBarFrame = CGRectMake(playButtonWidth, screenHeight-BOTTOMBAR_HEIGHT, tutorialScreen.frame.size.width - playButtonWidth, BOTTOMBAR_HEIGHT);
        tutorialBottomBar = [[UIView alloc] initWithFrame:bottomBarFrame];
        [tutorialBottomBar setBackgroundColor:fadedGray];
        
        [self fadeInTutorialSubview:tutorialBottomBar isReverseDirection:reverse];
        
        // Start playing
        float playLabelWidth = 195;
        
        CGRect playLabelFrame = CGRectMake(23, screenHeight-BOTTOMBAR_HEIGHT-85, playLabelWidth, defaultLabelHeight+15);
        [self drawTutorialLabel:playLabelFrame withTitle:@"Tap to PLAY" withColor:blueColor isHeader:YES isReverseDirection:reverse];
        
        // Play stripe
        CGRect playStripeFrame = CGRectMake(playLabelFrame.origin.x,playLabelFrame.origin.y+playLabelFrame.size.height,stripeWidth,30);
        
        UIView * playStripe = [[UIView alloc] initWithFrame:playStripeFrame];
        
        [playStripe setBackgroundColor:blueColor];
        
        [self fadeInTutorialSubview:playStripe isReverseDirection:reverse];
        
        // Play frame
        float playBorderWidth = 8.0;
        
        CGRect playButtonFrame = CGRectMake(0-playBorderWidth,tutorialBottomBar.frame.origin.y-playBorderWidth,65+2*playBorderWidth,55+2*playBorderWidth);
        UIView * playButton = [[UIView alloc] initWithFrame:playButtonFrame];
        
        playButton.layer.borderColor = blueColor.CGColor;
        playButton.layer.borderWidth = playBorderWidth;
        
        [self fadeInTutorialSubview:playButton isReverseDirection:reverse];
        
        [tutorialNext removeFromSuperview];
        
    }else{
        
        [tutorialScreen setBackgroundColor:fadedGray];
        [tutorialScreen setFrame:CGRectMake(0,0,screenX,screenY)];
        
        //CGRect buttonFrame = CGRectMake(0, 0, tutorialScreen.frame.size.width, tutorialScreen.frame.size.height);
        //tutorialNext = [[UIButton alloc] initWithFrame:buttonFrame];
        
        //[tutorialScreen addSubview:tutorialNext];
        //[tutorialNext addTarget:self action:@selector(incrementFTUTutorial) forControlEvents:UIControlEventTouchUpInside];
        
        [self startSwipeGestures];
        
        if(screenIndex == 2){
            
            //
            // SET VIEW
            //
            
            [self endSequenceLoop];
            
            // Header
            float trackHeaderHeight = defaultLabelHeight + 15;
            float trackHeaderWidth = 390;
            CGRect titleFrame = CGRectMake(0,218,trackHeaderWidth,trackHeaderHeight);
            
            UILabel * titleLabel = [self drawTutorialLabel:titleFrame withTitle:@"" withColor:blueColor isHeader:NO isReverseDirection:reverse];
            
            NSMutableAttributedString * titleString = [[NSMutableAttributedString alloc] initWithString:@"Work with tracks to build a set."];
            [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_BOLD size:30.0] range:NSMakeRange(27,4)];
            [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_BOLD size:30.0] range:NSMakeRange(9,8)];
            
            [titleLabel setAttributedText:titleString];
            
            // View track
            CGRect viewTrackFrame;
            float viewTrackLabelWidth = 120;
            
            if(isScreenLarge){
                viewTrackFrame = CGRectMake(101, 30, viewTrackLabelWidth, defaultLabelHeight);
                
                // Toggle circle
                CGRect toggleCircleFrame = CGRectMake(16,0,circleWidth,circleWidth);
                [self drawTutorialCircle:toggleCircleFrame withTitle:nil size:0 andImage:@"Icon_Percussion" andEdgeInsets:UIEdgeInsetsMake(12, 12, 13, 12) withColor:blueColor andAction:nil isReverseDirection:reverse];
            }else{
                viewTrackFrame = CGRectMake(79, 30, viewTrackLabelWidth, defaultLabelHeight);
                
                // Toggle circle
                CGRect toggleCircleFrame = CGRectMake(-6,0,circleWidth,circleWidth);
                [self drawTutorialCircle:toggleCircleFrame withTitle:nil size:0 andImage:@"Icon_Percussion" andEdgeInsets:UIEdgeInsetsMake(12, 12, 13, 12) withColor:blueColor andAction:nil isReverseDirection:reverse];
            }
            
            [self drawTutorialLabel:viewTrackFrame withTitle:@"View track" withColor:blueColor isHeader:NO isReverseDirection:reverse];
            
            // Toggle tracks
            CGRect toggleLabelFrame;
            CGRect volumeFrame;
            float toggleLabelWidth = 155;
            
            if(isScreenLarge){
                toggleLabelFrame = CGRectMake(tutorialScreen.frame.size.width-toggleLabelWidth-96, 25, toggleLabelWidth, defaultLabelHeight);
                
                // Toggle circle
                CGRect toggleCircleFrame = CGRectMake(tutorialScreen.frame.size.width-circleWidth-13,-1,circleWidth,circleWidth);
                [self drawTutorialCircle:toggleCircleFrame withTitle:nil size:0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil isReverseDirection:reverse];
                
                // Volume knob
                volumeFrame = CGRectMake(toggleCircleFrame.origin.x+13,toggleCircleFrame.origin.y+11,66,66);
                
            }else{
                toggleLabelFrame = CGRectMake(tutorialScreen.frame.size.width-toggleLabelWidth-76, 25, toggleLabelWidth, defaultLabelHeight);
                
                // Toggle circle
                CGRect toggleCircleFrame = CGRectMake(tutorialScreen.frame.size.width-circleWidth+7,-1,circleWidth,circleWidth);
                [self drawTutorialCircle:toggleCircleFrame withTitle:nil size:0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil isReverseDirection:reverse];
                
                // Volume knob
                volumeFrame = CGRectMake(toggleCircleFrame.origin.x+13,toggleCircleFrame.origin.y+11,66,66);
            }
            
            [self drawTutorialLabel:toggleLabelFrame withTitle:@"Adjust sound" withColor:blueColor isHeader:NO isReverseDirection:reverse];
            
            UIKnob * volumeKnob = [[UIKnob alloc] initWithFrame:volumeFrame];
            [volumeKnob SetValue:0.27];
            [volumeKnob setUserInteractionEnabled:NO];
            [volumeKnob setBackgroundColor:[UIColor clearColor]];
            [volumeKnob setOuterColor:[UIColor whiteColor]];
            [volumeKnob setLineColor:[UIColor whiteColor]];
            [volumeKnob setHighlightColor:[UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]];
            [self fadeInTutorialSubview:volumeKnob isReverseDirection:reverse];
            
            
            // Delete
            float deleteLabelWidth = 110;
            
            CGRect deleteLabelFrame = CGRectMake(tutorialScreen.frame.size.width-deleteLabelWidth-72, 112, deleteLabelWidth, defaultLabelHeight);
            [self drawTutorialLabel:deleteLabelFrame withTitle:@"Remove" withColor:blueColor isHeader:NO isReverseDirection:reverse];
            
            // Delete image
            float deleteImageWidth = 82;
            CGRect deleteImageFrame = CGRectMake(tutorialScreen.frame.size.width-deleteImageWidth, 89, deleteImageWidth, 87.5);
            UIButton * deleteImageView = [[UIButton alloc] initWithFrame:deleteImageFrame];
            [deleteImageView setBackgroundColor:[UIColor colorWithRed:216/255.0 green:64/255.0 blue:64/255.0 alpha:1.0]];
            [deleteImageView setImage:[UIImage imageNamed:@"Trash_Icon"] forState:UIControlStateNormal];
            [deleteImageView setImageEdgeInsets:UIEdgeInsetsMake(20, 25, 20, 25)];
            [deleteImageView setUserInteractionEnabled:NO];
            
            [self fadeInTutorialSubview:deleteImageView isReverseDirection:reverse];
            
            // Delete arrow
            float arrowWidth = 44;
            float arrowHeight = 50;
            CGRect deleteArrowFrame = CGRectMake(deleteLabelFrame.origin.x-arrowWidth, deleteLabelFrame.origin.y-(arrowHeight-defaultLabelHeight)/2, arrowWidth, arrowHeight);
            [self drawTutorialArrow:deleteArrowFrame facesDirection:9 width:arrowWidth height:arrowHeight withColor:blueColor isReverseDirection:reverse];
            
            // Swipe arrow
            float swipeFrameWidth = 140;
            float swipeFrameHeight = 30;
            CGRect swipeFrame = CGRectMake(0,tutorialScreen.frame.size.height-43,swipeFrameWidth,swipeFrameHeight);
            
            [self drawSwipeDottedLines:swipeFrame swipeText:@"continue" swipeLeft:YES swipeRight:YES withAlpha:0.7 isReverseDirection:reverse];
            
            
        }else if(screenIndex == 3){
            
            //
            // TEMPO VOLUME
            //
            
            // Tempo circle
            CGRect tempoCircleFrame = CGRectMake(tutorialScreen.frame.size.width/2-circleWidth/2+39.5,tutorialScreen.frame.size.height-3*circleWidth/4-3,circleWidth,circleWidth);
            [self drawTutorialCircle:tempoCircleFrame withTitle:@"120" size:30.0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil isReverseDirection:reverse];
            
            // Tempo label
            float tempoLabelWidth = 220;
            
            //CGRect tempoLabelTopFrame = CGRectMake(tempoCircleFrame.origin.x+circleWidth-tempoLabelWidth-35,tutorialScreen.frame.size.height-143+defaultLabelHeight,tempoLabelWidth,defaultLabelHeight);
            
            CGRect tempoLabelBottomFrame = CGRectMake(tempoCircleFrame.origin.x+circleWidth-tempoLabelWidth-35, tutorialScreen.frame.size.height-133, tempoLabelWidth, defaultLabelHeight);
            
            //[self drawTutorialLabel:tempoLabelTopFrame withTitle:@"Change the speed" withColor:blueColor isHeader:NO];
            [self drawTutorialLabel:tempoLabelBottomFrame withTitle:@"Control play speed" withColor:blueColor isHeader:NO isReverseDirection:reverse];
            
            // Tempo stripe
            CGRect tempoStripeFrame = CGRectMake(tempoLabelBottomFrame.origin.x+tempoLabelBottomFrame.size.width-stripeWidth,tempoLabelBottomFrame.origin.y+tempoLabelBottomFrame.size.height,stripeWidth,32);
            
            UIView * tempoStripe = [[UIView alloc] initWithFrame:tempoStripeFrame];
            
            [tempoStripe setBackgroundColor:blueColor];
            
            [self fadeInTutorialSubview:tempoStripe isReverseDirection:reverse];
            
            // Tempo arrows
            float arrowWidth = 35;
            float arrowHeight = 40;
            
            CGRect tempoArrowLeftFrame = CGRectMake(tempoCircleFrame.origin.x-arrowWidth-5, tempoCircleFrame.origin.y+arrowHeight/2+5, arrowWidth, arrowHeight);
            CGRect tempoArrowRightFrame = CGRectMake(tempoCircleFrame.origin.x+tempoCircleFrame.size.width+5, tempoCircleFrame.origin.y+arrowHeight/2+5, arrowWidth, arrowHeight);
            
            [self drawTutorialArrow:tempoArrowLeftFrame facesDirection:9 width:arrowWidth height:arrowHeight withColor:blueColor isReverseDirection:reverse];
            [self drawTutorialArrow:tempoArrowRightFrame facesDirection:3 width:arrowWidth height:arrowHeight withColor:blueColor isReverseDirection:reverse];
            
            // Tempo arrow stripes
            float tempoArrowWidth = 8.0;
            CGRect leftStripeFrame = CGRectMake(tempoArrowLeftFrame.origin.x+tempoArrowLeftFrame.size.width,tempoArrowLeftFrame.origin.y+tempoArrowLeftFrame.size.height/2-stripeWidth/2,tempoArrowWidth,stripeWidth);
            CGRect rightStripeFrame = CGRectMake(tempoArrowRightFrame.origin.x-tempoArrowWidth,tempoArrowLeftFrame.origin.y+tempoArrowLeftFrame.size.height/2-stripeWidth/2,tempoArrowWidth,stripeWidth);
            
            UIView * leftStripe = [[UIView alloc] initWithFrame:leftStripeFrame];
            UIView * rightStripe = [[UIView alloc] initWithFrame:rightStripeFrame];
            
            [leftStripe setBackgroundColor:blueColor];
            [rightStripe setBackgroundColor:blueColor];
            
            [self fadeInTutorialSubview:leftStripe isReverseDirection:reverse];
            [self fadeInTutorialSubview:rightStripe isReverseDirection:reverse];
            
            // Volume circle
            CGRect volumeCircleFrame = CGRectMake(tutorialScreen.frame.size.width-circleWidth-20,tutorialScreen.frame.size.height-3*circleWidth/4-3,circleWidth,circleWidth);
            [self drawTutorialCircle:volumeCircleFrame withTitle:nil size:0 andImage:@"Volume_Icon" andEdgeInsets:UIEdgeInsetsMake(13.5, 14, 16, 14) withColor:blueColor andAction:nil isReverseDirection:reverse];
            
            // Volume
            float volumeLabelWidth = 107;
            
            CGRect volumeLabelFrame = CGRectMake(volumeCircleFrame.origin.x+circleWidth-volumeLabelWidth-35, tutorialScreen.frame.size.height-133, volumeLabelWidth, defaultLabelHeight);
            [self drawTutorialLabel:volumeLabelFrame withTitle:@"Volume" withColor:blueColor isHeader:NO isReverseDirection:reverse];
            
            // Volume stripe
            CGRect volumeStripeFrame = CGRectMake(volumeLabelFrame.origin.x+volumeLabelFrame.size.width-stripeWidth,volumeLabelFrame.origin.y+volumeLabelFrame.size.height,stripeWidth,32);
            UIView * volumeStripe = [[UIView alloc] initWithFrame:volumeStripeFrame];
            [volumeStripe setBackgroundColor:blueColor];
            [self fadeInTutorialSubview:volumeStripe isReverseDirection:reverse];
            
            
            //
            // CHANGE LOOP LENGTH
            //
            
            // Minus/Plus frames
            CGRect minusCircleFrame;
            CGRect plusCircleFrame;
            
            if(isScreenLarge){
                minusCircleFrame = CGRectMake(88,24,circleWidth,circleWidth);
                plusCircleFrame = CGRectMake(389,24,circleWidth,circleWidth);
            }else{
                minusCircleFrame = CGRectMake(44,24,circleWidth,circleWidth);
                plusCircleFrame = CGRectMake(345,24,circleWidth,circleWidth);
            }
            
            [self drawTutorialCircle:minusCircleFrame withTitle:nil size:0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil isReverseDirection:reverse];
            [self drawTutorialCircle:plusCircleFrame withTitle:nil size:0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil isReverseDirection:reverse];
            
            // Minus/Plus
            float minusPlusWidth = 28;
            
            CGRect minusSymbolFrame;
            CGRect plusSymbolFrame;
            
            if(isScreenLarge){
                minusSymbolFrame = CGRectMake(117,55,minusPlusWidth,minusPlusWidth);
                plusSymbolFrame = CGRectMake(422,55,minusPlusWidth,minusPlusWidth);
            }else{
                minusSymbolFrame = CGRectMake(73,55,minusPlusWidth,minusPlusWidth);
                plusSymbolFrame = CGRectMake(378,55,minusPlusWidth,minusPlusWidth);
            }
            
            UIButton * minusSymbol = [[UIButton alloc] initWithFrame:minusSymbolFrame];
            UIButton * plusSymbol = [[UIButton alloc] initWithFrame:plusSymbolFrame];
            
            [minusSymbol setTitle:@"-" forState:UIControlStateNormal];
            [minusSymbol.titleLabel setFont:[UIFont systemFontOfSize:42.0]];
            [minusSymbol setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [plusSymbol setTitle:@"+" forState:UIControlStateNormal];
            [plusSymbol.titleLabel setFont:[UIFont boldSystemFontOfSize:28.0]];
            [plusSymbol setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            minusSymbol.layer.borderColor = [UIColor whiteColor].CGColor;
            minusSymbol.layer.borderWidth = 1.0f;
            minusSymbol.layer.cornerRadius = minusPlusWidth/2;
            
            plusSymbol.layer.borderColor = [UIColor whiteColor].CGColor;
            plusSymbol.layer.borderWidth = 1.0f;
            plusSymbol.layer.cornerRadius = minusPlusWidth/2;
            
            [minusSymbol setTitleEdgeInsets:UIEdgeInsetsMake(-5, 0, 0, 1)];
            [plusSymbol setTitleEdgeInsets:UIEdgeInsetsMake(-4, 0, 0, 1)];
            
            [self fadeInTutorialSubview:minusSymbol isReverseDirection:reverse];
            [self fadeInTutorialSubview:plusSymbol isReverseDirection:reverse];
            
            // 1, 2, 4
            /*CGRect loopOneFrame;
            CGRect loopTwoFrame;
            CGRect loopFourFrame;
            
            if(isScreenLarge){
                loopOneFrame = CGRectMake(172,53,defaultLabelHeight,defaultLabelHeight);
                loopTwoFrame = CGRectMake(235,53,defaultLabelHeight,defaultLabelHeight);
                loopFourFrame = CGRectMake(335,53,defaultLabelHeight,defaultLabelHeight);
            }else{
                loopOneFrame = CGRectMake(142,53,defaultLabelHeight,defaultLabelHeight);
                loopTwoFrame = CGRectMake(205,53,defaultLabelHeight,defaultLabelHeight);
                loopFourFrame = CGRectMake(305,53,defaultLabelHeight,defaultLabelHeight);
            }
            
            [self drawTutorialLabel:loopOneFrame withTitle:@"1" withColor:blueColor isHeader:YES isReverseDirection:reverse];
            [self drawTutorialLabel:loopTwoFrame withTitle:@"2" withColor:blueColor isHeader:YES isReverseDirection:reverse];
            [self drawTutorialLabel:loopFourFrame withTitle:@"4" withColor:blueColor isHeader:YES isReverseDirection:reverse];
            */
            
            // Change Loop Length
            float trackHeaderHeight = defaultLabelHeight;
            float trackHeaderWidth = 217;
            CGRect titleFrame = CGRectMake(minusCircleFrame.origin.x+minusCircleFrame.size.width-3,minusCircleFrame.origin.y+(minusCircleFrame.size.height-trackHeaderHeight)/2,trackHeaderWidth,trackHeaderHeight);
            
            [self drawTutorialLabel:titleFrame withTitle:@"Change loop length" withColor:blueColor isHeader:NO isReverseDirection:reverse];
            
            // Change loop stripe
            //CGRect changeLoopStripeFrame = CGRectMake(titleFrame.origin.x,minusCircleFrame.origin.y+minusCircleFrame.size.height-3,stripeWidth,18);
            //UIView * changeLoopStripe = [[UIView alloc] initWithFrame:changeLoopStripeFrame];
            //[changeLoopStripe setBackgroundColor:blueColor];
            //[self fadeInTutorialSubview:changeLoopStripe isReverseDirection:reverse];
            
            
            // Swipe arrow
            float swipeFrameWidth = 140;
            float swipeFrameHeight = 30;
            CGRect swipeFrame = CGRectMake(0,tutorialScreen.frame.size.height-43,swipeFrameWidth,swipeFrameHeight);
            
            [self drawSwipeDottedLines:swipeFrame swipeText:@"continue" swipeLeft:YES swipeRight:YES withAlpha:0.7 isReverseDirection:reverse];
            
        }else if(screenIndex == 4){
            
            //[self stopLeftSwipeGesture];
            
            //
            // CONNECT GTAR
            //
            
            [tutorialScreen setBackgroundColor:blueColor];
            
            // Do you have a gTar
            float midtitleWidth = 300;
            CGRect titleFrame = CGRectMake(tutorialScreen.frame.size.width/2 - midtitleWidth/2,50,midtitleWidth,35);
            
            UILabel * titleLabel = [self drawTutorialLabel:titleFrame withTitle:@"" withColor:[UIColor clearColor] isHeader:NO isReverseDirection:reverse];
            
            NSMutableAttributedString * titleString = [[NSMutableAttributedString alloc] initWithString:@"Do you have a gTar ?"];
            [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_BOLD size:30.0] range:NSMakeRange(13,5)];
            
            [titleLabel setAttributedText:titleString];
            
            // Yes + No buttons
            CGRect yesButtonFrame = CGRectMake(tutorialScreen.frame.size.width/2 - 223,150,circleWidth,circleWidth);
            CGRect noButtonFrame = CGRectMake(tutorialScreen.frame.size.width/2 + 120,150,circleWidth,circleWidth);
            
            [self drawTutorialCircle:yesButtonFrame withTitle:@"YES" size:30.0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:[UIColor whiteColor] andAction:@selector(setIntroConditionalScreenOn) isReverseDirection:reverse];
            
            [self drawTutorialCircle:noButtonFrame withTitle:@"NO" size:30.0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:[UIColor whiteColor] andAction:@selector(setIntroConditionalScreenOff) isReverseDirection:reverse];
            
            // Yes+No stripes/arrows
            CGRect yesStripeFrame = CGRectMake(yesButtonFrame.origin.x+yesButtonFrame.size.width-circleBorderWidth/2,yesButtonFrame.origin.y+yesButtonFrame.size.height/2-stripeWidth/2,15,stripeWidth);
            CGRect noStripeFrame = CGRectMake(noButtonFrame.origin.x+noButtonFrame.size.width-circleBorderWidth/2,noButtonFrame.origin.y+noButtonFrame.size.height/2-stripeWidth/2,tutorialScreen.frame.size.width - (noButtonFrame.origin.x+noButtonFrame.size.width)+circleBorderWidth/2,stripeWidth);
            
            UIView * noStripe = [[UIView alloc] initWithFrame:noStripeFrame];
            UIView * yesStripe = [[UIView alloc] initWithFrame:yesStripeFrame];
            
            [noStripe setBackgroundColor:[UIColor whiteColor]];
            [yesStripe setBackgroundColor:[UIColor whiteColor]];
            
            [self fadeInTutorialSubview:noStripe isReverseDirection:reverse];
            [self fadeInTutorialSubview:yesStripe isReverseDirection:reverse];
            
            // Yes arrow
            float arrowWidth = 35;
            float arrowHeight = 40;
            CGRect yesArrowFrame = CGRectMake(yesButtonFrame.origin.x+yesButtonFrame.size.width-circleBorderWidth/2+yesStripeFrame.size.width,yesButtonFrame.origin.y+yesButtonFrame.size.height/2-stripeWidth/2-(arrowHeight-stripeWidth)/2,arrowWidth,arrowHeight);
            
            [self drawTutorialArrow:yesArrowFrame facesDirection:3 width:arrowWidth height:arrowHeight withColor:[UIColor whiteColor] isReverseDirection:reverse];
            
            // Dock graphic
            CGRect dockFrame = CGRectMake(yesArrowFrame.origin.x+yesArrowFrame.size.width + 10,yesArrowFrame.origin.y - 30,185,100);
            UIImageView * dock = [[UIImageView alloc] initWithFrame:dockFrame];
            [dock setImage:[UIImage imageNamed:@"Tutorial_Dock"]];
            
            [self fadeInTutorialSubview:dock isReverseDirection:reverse];
            
            
        }else if(screenIndex == 5){
            
            
            //
            // USE GTAR AS A CONTROLLER
            //
            
            // Measure image frame
            CGRect measureImageFrame;
            
            if(isScreenLarge){
                measureImageFrame = CGRectMake(154,60,64,18);
            }else{
                measureImageFrame = CGRectMake(110,60,64,18);
            }
            
            // Measure Background
            float borderWidth = 3;
            CGRect measureBackgroundFrame = CGRectMake(measureImageFrame.origin.x-borderWidth,measureImageFrame.origin.y-borderWidth,measureImageFrame.size.width+2*borderWidth,measureImageFrame.size.height+2*borderWidth);
            
            UIView * measureBackground = [[UIView alloc] initWithFrame:measureBackgroundFrame];
            
            [measureBackground setBackgroundColor:[UIColor whiteColor]];
            
            [self fadeInTutorialSubview:measureBackground isReverseDirection:reverse];
            
            // Measure image
            UIImage * measureImage = [self drawMeasure:measureImageFrame];
            UIImageView * measureImageView = [[UIImageView alloc] initWithImage:measureImage];
            
            [self fadeInTutorialSubview:measureImageView isReverseDirection:reverse];
            
            // gTarBackground
            CGRect gtarBackgroundFrame = CGRectMake(0,88,tutorialScreen.frame.size.width,tutorialScreen.frame.size.height-88);
            CGRect gtarBorderFrame = CGRectMake(0,88,tutorialScreen.frame.size.width,1);
            
            UIView * gtarBackground = [[UIView alloc] initWithFrame:gtarBackgroundFrame];
            UIView * gtarBorder = [[UIView alloc] initWithFrame:gtarBorderFrame];
            
            [gtarBackground setBackgroundColor:blueColor];
            [gtarBorder setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
            
            [self fadeInTutorialSubview:gtarBackground isReverseDirection:reverse];
            [self fadeInTutorialSubview:gtarBorder isReverseDirection:reverse];
         
            
            // Dock graphic
            float gtarWidth = 1.5*480;
            //float gtarHeight = gtarWidth*0.56;
            float gtarHeight = gtarWidth*0.37;
            CGRect gtarFrame = CGRectMake(10,39,gtarWidth,gtarHeight);
            UIImageView * gtar = [[UIImageView alloc] initWithFrame:gtarFrame];
            [gtar setImage:[UIImage imageNamed:@"Tutorial_gTar"]];
            
            [self fadeInTutorialSubview:gtar isReverseDirection:reverse];
            
            
            // Use the fretboard
            
            float desctitleWidth = 440;
            float descIndent = (isScreenLarge) ? -10 : 30;
            
            //CGRect titleFrame = CGRectMake(30,30,300,30);
            CGRect desctitleFrame = CGRectMake(descIndent+tutorialScreen.frame.size.width/2 - desctitleWidth/2,106,desctitleWidth,30);
            CGRect desctitle3Frame = CGRectMake(60,217,desctitleWidth,35);
            CGRect desctitle4Frame = CGRectMake(60,247,desctitleWidth,35);
            
            UILabel * desctitle = [self drawTutorialLabel:desctitleFrame withTitle:@"" withColor:[UIColor clearColor] isHeader:NO isReverseDirection:reverse];
            
            NSMutableAttributedString * desctitleString = [[NSMutableAttributedString alloc] initWithString:@"Choose a track measure."];
            [desctitleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_BOLD size:30.0] range:NSMakeRange(15,8)];
            [desctitle setAttributedText:desctitleString];
            
            UILabel * desctitle3 = [self drawTutorialLabel:desctitle3Frame withTitle:@"" withColor:[UIColor clearColor] isHeader:NO isReverseDirection:reverse];
            
            NSMutableAttributedString * desctitle3String = [[NSMutableAttributedString alloc] initWithString:@"To control notes, fret down"];
            [desctitle3String addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_BOLD size:30.0] range:NSMakeRange(10,6)];
            [desctitle3 setAttributedText:desctitle3String];
            
            
            UILabel * desctitle4 = [self drawTutorialLabel:desctitle4Frame withTitle:@"and pluck on the gTar." withColor:[UIColor clearColor] isHeader:NO isReverseDirection:reverse];
            
            [desctitle3 setTextAlignment:NSTextAlignmentLeft];
            [desctitle4 setTextAlignment:NSTextAlignmentLeft];
            
            // Swipe arrow
            float swipeFrameWidth = 140;
            float swipeFrameHeight = 30;
            CGRect swipeFrame = CGRectMake(0,tutorialScreen.frame.size.height-35,swipeFrameWidth,swipeFrameHeight);
            
            [self drawSwipeDottedLines:swipeFrame swipeText:@"continue" swipeLeft:YES swipeRight:YES withAlpha:0.7 isReverseDirection:reverse];
        }
        
    }
    
    tutorialScreen.userInteractionEnabled = YES;
    
}

-(void)setIntroConditionalScreenOn
{
    showConditionalScreen = YES;
    [self incrementFTUTutorial];
}

-(void)setIntroConditionalScreenOff
{
    showConditionalScreen = NO;
    [self incrementFTUTutorial];
}

#pragma mark - Seq Set Tutorial

-(void)drawSeqSetTutorialScreen:(int)screenIndex
{
    UIColor * blueColor = [UIColor colorWithRed:33/255.0 green:173/255.0 blue:211/255.0 alpha:1.0];
    
    float circleWidth = 90;
    float defaultLabelHeight = 32;
    //float stripeWidth = 20;
    
    [tutorialScreen setBackgroundColor:[UIColor clearColor]];
    
    [tutorialScreen setFrame:CGRectMake(0,89*3,tutorialScreen.frame.size.width,88)];
    
    CGRect buttonFrame = CGRectMake(0, 0, tutorialScreen.frame.size.width, tutorialScreen.frame.size.height);
    tutorialNext = [[UIButton alloc] initWithFrame:buttonFrame];
    
    [tutorialScreen addSubview:tutorialNext];
    [tutorialNext addTarget:self action:@selector(end) forControlEvents:UIControlEventTouchUpInside];
    [self startSingleSwipeGesture];
    
    if(screenIndex == 1){
        
        //
        // DOUBLE TAP VOLUME
        //
        
        CGRect toggleLabelFrame;
        float toggleLabelWidth = 230;
        
        if(isScreenLarge){
            toggleLabelFrame = CGRectMake(tutorialScreen.frame.size.width-toggleLabelWidth-96, 25, toggleLabelWidth, defaultLabelHeight);
            
            // Toggle circle
            CGRect toggleCircleFrame = CGRectMake(tutorialScreen.frame.size.width-circleWidth-12,-1,circleWidth,circleWidth);
            [self drawTutorialCircle:toggleCircleFrame withTitle:nil size:0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil isReverseDirection:NO];
            
        }else{
            toggleLabelFrame = CGRectMake(tutorialScreen.frame.size.width-toggleLabelWidth-78, 25, toggleLabelWidth, defaultLabelHeight);
            
            // Toggle circle
            CGRect toggleCircleFrame = CGRectMake(tutorialScreen.frame.size.width-circleWidth+7,-1,circleWidth,circleWidth);
            [self drawTutorialCircle:toggleCircleFrame withTitle:nil size:0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil isReverseDirection:NO];
        }
        
        [self drawTutorialLabel:toggleLabelFrame withTitle:@"Double tap to turn on" withColor:blueColor isHeader:NO isReverseDirection:NO];
        
    }
}

#pragma mark - Instrument Tutorial

-(void)drawInstrumentTutorialScreen:(int)screenIndex isReverseDirection:(BOOL)reverse
{
    
    UIColor * fadedGray = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    UIColor * blueColor = [UIColor colorWithRed:33/255.0 green:173/255.0 blue:211/255.0 alpha:1.0];
    
    float circleWidth = 90;
    float defaultLabelHeight = 32;
    float stripeWidth = 20;
    
    // Clear out previous screen
    [self fadeOutTutorialSubviews:NO isReverseDirection:reverse];
    
    [tutorialScreen setBackgroundColor:fadedGray];
    
    if(screenIndex == 1){
        
        [self startSwipeGestures];
        [self stopRightSwipeGesture];
        
        //
        // TRACK VIEW
        //
        
        // Pattern circles
        CGRect patternAFrame;
        
        if(isScreenLarge){
            patternAFrame = CGRectMake(115.5,-21,circleWidth,circleWidth);
        }else{
            patternAFrame = CGRectMake(71.5,-21,circleWidth,circleWidth);
        }
        
        [self drawTutorialCircle:patternAFrame withTitle:@"A" size:40.0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil isReverseDirection:reverse];
        
        // Program patterns
        float patternHeaderWidth = 265;
        CGRect titleFrame = CGRectMake(patternAFrame.origin.x+35,patternAFrame.origin.y+patternAFrame.size.height+10,patternHeaderWidth,defaultLabelHeight);
        
        [self drawTutorialLabel:titleFrame withTitle:@"Program up to 4 patterns" withColor:blueColor isHeader:NO isReverseDirection:reverse];
        
        // Pattern stripe
        CGRect patternStripeFrame = CGRectMake(titleFrame.origin.x,patternAFrame.origin.y+patternAFrame.size.height-3,stripeWidth,15);
        UIView * patternStripe = [[UIView alloc] initWithFrame:patternStripeFrame];
        [patternStripe setBackgroundColor:blueColor];
        [self fadeInTutorialSubview:patternStripe isReverseDirection:reverse];
        
        // Note circle
        CGRect noteCircleFrame;
        
        if(isScreenLarge){
            noteCircleFrame = CGRectMake(254,143,circleWidth,circleWidth);
        }else{
            noteCircleFrame = CGRectMake(210,143,circleWidth,circleWidth);
        }
        
        [self drawTutorialCircle:noteCircleFrame withTitle:nil size:0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil isReverseDirection:reverse];
        
        // Note box
        float noteWidth = 28;
        CGRect noteBoxFrame = CGRectMake(noteCircleFrame.origin.x+(noteCircleFrame.size.width-noteWidth)/2,noteCircleFrame.origin.y+(noteCircleFrame.size.height-noteWidth)/2,noteWidth,noteWidth);
        UIView * noteBox = [[UIView alloc] initWithFrame:noteBoxFrame];
        [noteBox setBackgroundColor:[UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]];
        noteBox.layer.borderColor = [UIColor whiteColor].CGColor;
        noteBox.layer.borderWidth = 0.5f;
        [self fadeInTutorialSubview:noteBox isReverseDirection:reverse];
        
        // Control notes
        float noteHeaderWidth = 160;
        CGRect noteTitleFrame = CGRectMake(noteCircleFrame.origin.x+noteCircleFrame.size.width-3,noteCircleFrame.origin.y+noteCircleFrame.size.height/2-defaultLabelHeight/2,noteHeaderWidth,defaultLabelHeight);
        
        [self drawTutorialLabel:noteTitleFrame withTitle:@"Toggle sounds" withColor:blueColor isHeader:NO isReverseDirection:reverse];
        
        // Swipe arrow
        float swipeFrameWidth = 140;
        float swipeFrameHeight = 30;
        CGRect swipeFrame = CGRectMake(0,tutorialScreen.frame.size.height-35,swipeFrameWidth,swipeFrameHeight);
        
        [self drawSwipeDottedLines:swipeFrame swipeText:@"continue" swipeLeft:YES swipeRight:NO withAlpha:0.7 isReverseDirection:reverse];
        
    }else if(screenIndex == 2){
        
        //
        // ADJUSTING MEASURES
        //
        
        [self startFinalSwipeGesture];
        
        // Measure
        CGRect measureFrame;
        CGRect measureAddFrame;
        CGRect measureSubFrame;
        float measureBorder = 8;
        
        if(isScreenLarge){
            measureFrame = CGRectMake(142-measureBorder,51-measureBorder,141+2*measureBorder,31+2*measureBorder);
        }else{
            measureFrame = CGRectMake(120-measureBorder,51-measureBorder,119+2*measureBorder,31+2*measureBorder);
        }
        
        UIView * measureView = [[UIView alloc] initWithFrame:measureFrame];
        measureView.layer.borderColor = blueColor.CGColor;
        measureView.layer.borderWidth = measureBorder;
        [measureView setBackgroundColor:[UIColor colorWithRed:28/255.0 green:75/255.0 blue:87/255.0 alpha:1.0]];
        
        [self fadeInTutorialSubview:measureView isReverseDirection:reverse];
        
        // Measure add label
        float measureStripe = 20;
        
        measureAddFrame = CGRectMake(measureFrame.origin.x+measureBorder,measureFrame.origin.y+measureFrame.size.height+measureStripe,298,defaultLabelHeight);
        
        measureSubFrame = CGRectMake(measureAddFrame.origin.x,measureAddFrame.origin.y+measureAddFrame.size.height+measureStripe,155,defaultLabelHeight);
        
        [self drawTutorialLabel:measureAddFrame withTitle:@"Double tap to add measures" withColor:blueColor isHeader:NO isReverseDirection:reverse];
        
        [self drawTutorialLabel:measureSubFrame withTitle:@"Hold to delete" withColor:blueColor isHeader:NO isReverseDirection:reverse];
        
        // Measure stripes
        CGRect addStripeFrame = CGRectMake(measureAddFrame.origin.x,measureAddFrame.origin.y-measureStripe,stripeWidth,measureStripe);
        CGRect subStripeFrame = CGRectMake(measureAddFrame.origin.x,measureAddFrame.origin.y+measureAddFrame.size.height,stripeWidth,measureStripe);
        
        UIView * addStripe = [[UIView alloc] initWithFrame:addStripeFrame];
        UIView * subStripe = [[UIView alloc] initWithFrame:subStripeFrame];
        
        [addStripe setBackgroundColor:blueColor];
        [subStripe setBackgroundColor:blueColor];
        
        [self fadeInTutorialSubview:addStripe isReverseDirection:reverse];
        [self fadeInTutorialSubview:subStripe isReverseDirection:reverse];

        
        // Swipe arrow
        float swipeFrameWidth = 140;
        float swipeFrameHeight = 30;
        CGRect swipeFrame = CGRectMake(0,tutorialScreen.frame.size.height-35,swipeFrameWidth,swipeFrameHeight);
        
        [self drawSwipeDottedLines:swipeFrame swipeText:@"continue" swipeLeft:YES swipeRight:YES withAlpha:0.7 isReverseDirection:reverse];
        
    }
    
}

#pragma mark - Custom Tutorial

-(void)drawCustomTutorialScreen:(int)screenIndex
{
    
    UIColor * fadedGray = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    UIColor * blueColor = [UIColor colorWithRed:33/255.0 green:173/255.0 blue:211/255.0 alpha:1.0];
    
    float circleWidth = 90;
    float defaultLabelHeight = 32;
    float stripeWidth = 20;
    float borderWidth = 8.0;
    
    [tutorialScreen setBackgroundColor:fadedGray];
    
    CGRect buttonFrame = CGRectMake(0, 0, tutorialScreen.frame.size.width, tutorialScreen.frame.size.height);
    tutorialNext = [[UIButton alloc] initWithFrame:buttonFrame];
    
    [tutorialScreen addSubview:tutorialNext];
    [tutorialNext addTarget:self action:@selector(end) forControlEvents:UIControlEventTouchUpInside];
    [self startSingleSwipeGesture];
    
    if(screenIndex == 1){
        
        //
        // CUSTOM VIEW
        //
        
        // Header
        float customHeaderHeight = defaultLabelHeight + 15;
        float customHeaderWidth = 340;
        CGRect titleFrame = CGRectMake(tutorialScreen.frame.size.width/2-180,218,customHeaderWidth,customHeaderHeight);
        
        UILabel * titleLabel = [self drawTutorialLabel:titleFrame withTitle:@"" withColor:[UIColor clearColor] isHeader:NO isReverseDirection:NO];
        
        NSMutableAttributedString * titleString = [[NSMutableAttributedString alloc] initWithString:@"Build a track from 6 sounds."];
        [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_BOLD size:30.0] range:NSMakeRange(18,10)];
        
        [titleLabel setAttributedText:titleString];
        
        // First string / first sample
        float stringWidth = 153;
        float sampleWidth = 213;
        float stringHeight = 39;
        
        CGRect stringBoxFrame;
        CGRect sampleBoxFrame;
        
        if(isScreenLarge){
            stringBoxFrame = CGRectMake(314-borderWidth,22-borderWidth,stringWidth+2*borderWidth,stringHeight+2*borderWidth);
            sampleBoxFrame = CGRectMake(103-borderWidth,101-borderWidth,sampleWidth+2*borderWidth,stringHeight-1+2*borderWidth);
        }else{
            stringBoxFrame = CGRectMake(270-borderWidth,22-borderWidth,stringWidth+2*borderWidth,stringHeight+2*borderWidth);
            sampleBoxFrame = CGRectMake(59-borderWidth,101-borderWidth,sampleWidth+2*borderWidth,stringHeight-1+2*borderWidth);
        }
        
        UIView * stringBox = [[UIView alloc] initWithFrame:stringBoxFrame];
        UIView * sampleBox = [[UIView alloc] initWithFrame:sampleBoxFrame];
        [stringBox setBackgroundColor:[UIColor colorWithRed:170/255.0 green:114/255.0 blue:233/255.0 alpha:1.0]];
        [sampleBox setBackgroundColor:[UIColor whiteColor]];
        
        sampleBox.layer.borderWidth = 8.0;
        sampleBox.layer.borderColor = blueColor.CGColor;
        
        stringBox.layer.borderWidth = 8.0;
        stringBox.layer.borderColor = blueColor.CGColor;
        
        [self fadeInTutorialSubview:stringBox isReverseDirection:NO];
        [self fadeInTutorialSubview:sampleBox isReverseDirection:NO];
        
        // First string+sample text
        CGRect stringTextFrame = CGRectMake(stringBoxFrame.origin.x+8, stringBoxFrame.origin.y+1, stringBoxFrame.size.width, stringBoxFrame.size.height);
        CGRect sampleTextFrame = CGRectMake(sampleBoxFrame.origin.x+18, sampleBoxFrame.origin.y+1, sampleBoxFrame.size.width, sampleBoxFrame.size.height);
        
        UILabel * stringText = [self drawTutorialLabel:stringTextFrame withTitle:@"House/Snare" withColor:[UIColor clearColor] isHeader:NO isReverseDirection:NO];
        UILabel * sampleText = [self drawTutorialLabel:sampleTextFrame withTitle:@"Snare" withColor:[UIColor clearColor] isHeader:NO isReverseDirection:NO];
        
        [stringText setFont:[UIFont fontWithName:FONT_DEFAULT size:18.0]];
        [sampleText setFont:[UIFont fontWithName:FONT_DEFAULT size:18.0]];
        
        [sampleText setTextAlignment:NSTextAlignmentLeft];
        [sampleText setTextColor:[UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1.0]];
        
        // Sample and string circles
        CGRect sampleCircleFrame;
        CGRect stringCircleFrame;
        
        if(isScreenLarge){
            sampleCircleFrame = CGRectMake(100,75,circleWidth,circleWidth);
            stringCircleFrame = CGRectMake(308,-5,circleWidth,circleWidth);
        }else{
            sampleCircleFrame = CGRectMake(54,75,circleWidth,circleWidth);
            stringCircleFrame = CGRectMake(262,-5,circleWidth,circleWidth);
        }
        /*
        [self drawTutorialCircle:sampleCircleFrame withTitle:nil size:0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil];
        [self drawTutorialCircle:stringCircleFrame withTitle:nil size:0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil];
        */
        
        // First string arrow
        CGRect tutorialArrowFrame = CGRectMake(stringBoxFrame.origin.x + 12+borderWidth, stringBoxFrame.origin.y + 12+borderWidth, 10, 15);
        [self drawTutorialArrow:tutorialArrowFrame facesDirection:3 width:10 height:15 withColor:[UIColor whiteColor] isReverseDirection:NO];
        
        // Add sounds
        //float addSoundsTitleWidth = 277;
       // CGRect addSoundsTitleFrame = CGRectMake(sampleBoxFrame.origin.x,sampleBoxFrame.origin.y+sampleBoxFrame.size.height+10,addSoundsTitleWidth,defaultLabelHeight);
        
        //[self drawTutorialLabel:addSoundsTitleFrame withTitle:@"Assign sounds to 6 colors" withColor:blueColor isHeader:NO isReverseDirection:NO];
        
        // Sample/sound stripes
        CGRect sampleStripeFrame = CGRectMake(sampleBoxFrame.origin.x+sampleBoxFrame.size.width-3,sampleBoxFrame.origin.y+(sampleBoxFrame.size.height-stripeWidth)/2,79.5,stripeWidth);
        CGRect stringStripeFrame = CGRectMake(stringBoxFrame.origin.x+(stringBoxFrame.size.width-stripeWidth)/2,stringBoxFrame.origin.y+stringBoxFrame.size.height-3,stripeWidth,45);
        
        UIView * sampleStripe = [[UIView alloc] initWithFrame:sampleStripeFrame];
        UIView * stringStripe = [[UIView alloc] initWithFrame:stringStripeFrame];
        
        [sampleStripe setBackgroundColor:blueColor];
        [stringStripe setBackgroundColor:blueColor];
        
        [self fadeInTutorialSubview:sampleStripe isReverseDirection:NO];
        [self fadeInTutorialSubview:stringStripe isReverseDirection:NO];
        
        // Add sounds stripe
        //CGRect addSoundsStripeFrame = CGRectMake(stringStripeFrame.origin.x,sampleStripeFrame.origin.y+sampleStripeFrame.size.height,stripeWidth,37);
        //UIView * addSoundsStripe = [[UIView alloc] initWithFrame:addSoundsStripeFrame];
        //[addSoundsStripe setBackgroundColor:blueColor];
        //[self fadeInTutorialSubview:addSoundsStripe isReverseDirection:NO];
    }
}

#pragma mark - Draw reusable interface

-(UIView *)drawSwipeDottedLines:(CGRect)frame swipeText:(NSString *)swipeText swipeLeft:(BOOL)showSwipeLeft swipeRight:(BOOL)showSwipeRight withAlpha:(float)alpha isReverseDirection:(BOOL)reverse
{
    float swipeFrameWidth = frame.size.width;
    float swipeFrameHeight = frame.size.height;
    
    UIView * swipeArrowTop = [[UIView alloc] initWithFrame:frame];
    
    CGSize size = CGSizeMake(frame.size.width, frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    CGFloat pattern[] = {3,6};
    CGContextSetLineDash(context,0.0,pattern,2);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, swipeFrameWidth, 0);
    CGContextClosePath(context);
    
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, swipeFrameHeight);
    CGContextAddLineToPoint(context, swipeFrameWidth, swipeFrameHeight);
    CGContextClosePath(context);
    
    CGContextStrokePath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [swipeArrowTop addSubview:image];
    
    UIGraphicsEndImageContext();
    
    [self fadeInTutorialSubview:swipeArrowTop isReverseDirection:reverse];
    
    UILabel * swipeTextLabel = [self drawTutorialLabel:frame withTitle:swipeText withColor:[UIColor clearColor] isHeader:NO isReverseDirection:reverse];
    [swipeTextLabel setFont:[UIFont fontWithName:@"AvenirNext-Italic" size:15.0]];
    
    if(showSwipeLeft){
        UIView * lArrow = [self drawTutorialArrow:CGRectMake(frame.origin.x+17,frame.origin.y+10,10,10) facesDirection:9 width:10 height:10 withColor:[UIColor whiteColor] isReverseDirection:reverse];
        [lArrow setAlpha:alpha];
    }
    
    if(showSwipeRight){
        UIView * rArrow = [self drawTutorialArrow:CGRectMake(frame.origin.x+frame.size.width-28,frame.origin.y+10,10,10) facesDirection:3 width:10 height:10 withColor:[UIColor whiteColor] isReverseDirection:reverse];
        [rArrow setAlpha:alpha];
    }
    
    [swipeTextLabel setAlpha:alpha];
    [swipeArrowTop setAlpha:alpha];
    
    return swipeArrowTop;
}

-(UIView *)drawTutorialArrow:(CGRect)frame facesDirection:(int)faces width:(float)arrowWidth height:(float)arrowHeight withColor:(UIColor *)arrowColor isReverseDirection:(BOOL)reverse
{
    UIView * newArrow = [[UIView alloc] initWithFrame:frame];
    
    CGSize size = CGSizeMake(newArrow.frame.size.width, newArrow.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, arrowColor.CGColor);
    CGContextSetFillColorWithColor(context, arrowColor.CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    if(faces == 0){ // up
        CGContextMoveToPoint(context, 0, arrowHeight);
        CGContextAddLineToPoint(context, 0, arrowHeight);
        CGContextAddLineToPoint(context, arrowWidth/2, 0);
    }else if(faces == 3){ // left
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, 0, arrowHeight);
        CGContextAddLineToPoint(context, arrowWidth, arrowHeight/2);
    }else if(faces == 6){ // down
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, arrowWidth, 0);
        CGContextAddLineToPoint(context, arrowWidth/2, arrowHeight);
    }else if(faces == 9){ // right
        CGContextMoveToPoint(context, arrowWidth, 0);
        CGContextAddLineToPoint(context, arrowWidth, arrowHeight);
        CGContextAddLineToPoint(context, 0, arrowHeight/2);
    }
    
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [newArrow addSubview:image];
    [self fadeInTutorialSubview:newArrow isReverseDirection:reverse];
    
    UIGraphicsEndImageContext();
    
    return newArrow;
}


-(UIButton *)drawTutorialCircle:(CGRect)frame withTitle:(NSString *)title size:(float)fontSize andImage:(NSString *)imageName andEdgeInsets:(UIEdgeInsets)insets withColor:(UIColor *)borderColor andAction:(SEL)selector isReverseDirection:(BOOL)reverse
{
    
    float circleBorderWidth = 8.0;
    UIFont * headerFont = [UIFont fontWithName:@"AvenirNext-Bold" size:fontSize];
    UIButton * newCircle = [[UIButton alloc] initWithFrame:frame];
    
    newCircle.layer.borderColor = borderColor.CGColor;
    newCircle.layer.borderWidth = circleBorderWidth;
    newCircle.layer.cornerRadius = newCircle.frame.size.width/2;
    
    if(title != nil){
        [newCircle setTitle:title forState:UIControlStateNormal];
        newCircle.titleLabel.textColor = [UIColor whiteColor];
        [newCircle.titleLabel setFont:headerFont];
    }
    
    if(imageName != nil){
        [newCircle setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [newCircle setImageEdgeInsets:insets];
        [newCircle setContentEdgeInsets:insets];
    }
    
    if(selector != nil){
        [newCircle addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }else{
        [newCircle setUserInteractionEnabled:NO];
    }
    
    [self fadeInTutorialSubview:newCircle isReverseDirection:reverse];
    
    return newCircle;
}

-(UILabel *)drawTutorialLabel:(CGRect)frame withTitle:(NSString *)title withColor:(UIColor *)backgroundColor isHeader:(BOOL)isHeader isReverseDirection:(BOOL)reverse
{
    
    UIFont * labelFont = [UIFont fontWithName:FONT_DEFAULT size:22.0];
    UIFont * headerFont = [UIFont fontWithName:FONT_BOLD size:30.0];
    
    UIFont * font = (isHeader) ? headerFont : labelFont;
    
    UILabel * newLabel = [[UILabel alloc] initWithFrame:frame];
    [newLabel setBackgroundColor:backgroundColor];
    [newLabel setText:title];
    [newLabel setTextColor:[UIColor whiteColor]];
    [newLabel setFont:font];
    newLabel.textAlignment = NSTextAlignmentCenter;
    
    [self fadeInTutorialSubview:newLabel isReverseDirection:reverse];
    
    return newLabel;
}

#pragma mark - Sequence Loop
-(void)startSequenceLoop
{
    sequenceLoopCounter = 0;
    
    if(!sequenceLoopTimer){
        
        sequenceLoopTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(progressSequenceLoop) userInfo:nil repeats:YES];
    }
}

-(void)progressSequenceLoop
{
    for(int i = 0; i < [sequenceNotes count]; i++){
        UIButton * note = [sequenceNotes objectAtIndex:i];
        if(i == sequenceLoopCounter){
            if(sequenceNoteActive[i]){
                [note setBackgroundColor:[UIColor colorWithRed:240/255.0 green:249/255.0 blue:179/255.0 alpha:1.0]];
                [self playSequenceSound];
            }else{
                [note setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7]];            }
        }else{
            if(sequenceNoteActive[i]){
                [note setBackgroundColor:[UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]];
            }else{
                [note setBackgroundColor:[UIColor clearColor]];
            }
        }
    }
    
    sequenceLoopCounter++;
    sequenceLoopCounter %= 8;
    
}

-(void)endSequenceLoop
{
    [sequenceLoopTimer invalidate];
    sequenceLoopTimer = nil;
    
    [soundMaster releaseBankAndDisconnect:m_bankNode];
}

-(void)playSequenceSound
{
    m_bankNode->TriggerSample(0);
}

- (void)initAudioForSequence
{
    if(!soundMaster){
        soundMaster = [[SoundMaster alloc] init];
    }
    
    m_bankNode = [soundMaster generateBank];
    
    // Reload sound into bank after new record
    char * filepath = (char *)malloc(sizeof(char) * 1024);
    filepath = (char *)[[[NSBundle mainBundle] pathForResource:@"Vibraphone_C" ofType:@"wav"] UTF8String];
    
    m_bankNode->LoadSampleIntoBank(filepath, m_sampNode);
    
    [self startSequenceLoop];
    
}

-(void)toggleSequenceNoteActive:(id)sender
{
    UIButton * senderButton = (UIButton *)sender;
    
    for(int i = 0; i < [sequenceNotes count]; i++){
        if([sequenceNotes objectAtIndex:i] == senderButton){
            if(sequenceNoteActive[i] == YES){
                
                [[sequenceNotes objectAtIndex:i] setBackgroundColor:[UIColor clearColor]];
                sequenceNoteActive[i] = NO;
            }else{
                
                [[sequenceNotes objectAtIndex:i] setBackgroundColor:[UIColor colorWithRed:240/255.0 green:249/255.0 blue:179/255.0 alpha:1.0]];
                sequenceNoteActive[i] = YES;
            }
        }
    }
}

#pragma mark - Draw Measure

- (UIImage *)drawMeasure:(CGRect)frame {
    
    CGSize size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size,NO,0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    double lineWidth = 0.2;
    
    CGFloat noteFrameHeight = frame.size.height / STRINGS_ON_GTAR;
    CGFloat noteFrameWidth = frame.size.width / FRETS_ON_GTAR;
    CGRect noteFrame = CGRectMake(frame.origin.x, frame.origin.y, noteFrameWidth, noteFrameHeight);
    
    // Set line width:
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    [self initColors];
    
    // Update all the notes:
    int f, s;
    for (f = 0, s = 0; f < FRETS_ON_GTAR; f++)
    {
        for (s = 0; s < STRINGS_ON_GTAR; s++)
        {
            
            noteFrame.origin.x = frame.origin.x+f*noteFrameWidth;
            noteFrame.origin.y = frame.origin.y+s*noteFrameHeight;
            
            CGContextAddRect(context, noteFrame);
            
            if((s==5 && f%4==0) || (s==2 && f%4==2) || (s==4 && f%8==4)){
                
                CGContextSetFillColorWithColor(context, colors[STRINGS_ON_GTAR-s-1].CGColor);  // Get color for that string and fill
            }else{
                CGContextSetFillColorWithColor(context, [UIColor colorWithRed:110/255.0 green:218/255.0 blue:245/255.0 alpha:1.0].CGColor);  // Get color for that string and fill
            }
            
            CGContextStrokeRect(context, noteFrame);
            
            CGContextFillRect(context, noteFrame);
        }
    }
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
    
}


- (void)initColors
{
    colors[5] = [UIColor colorWithRed:170/255.0 green:114/255.0 blue:233/255.0 alpha:1.0]; // purple
    colors[4] = [UIColor colorWithRed:30/255.0 green:108/255.0 blue:213/255.0 alpha:1.0]; // blue
    colors[3] = [UIColor colorWithRed:5/255.0 green:195/255.0 blue:77/255.0 alpha:1.0]; // green
    colors[2] = [UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]; // yellow
    colors[1] = [UIColor colorWithRed:234/255.0 green:154/255.0 blue:0/255.0 alpha:1.0]; // orange
    colors[0] = [UIColor colorWithRed:238/255.0 green:28/255.0 blue:36/255.0 alpha:1.0]; // red
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
