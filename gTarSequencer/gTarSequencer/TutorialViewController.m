//
//  TutorialView.m
//  Sequence
//
//  Created by Kate Schnippering on 3/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "TutorialViewController.h"

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

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
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    isScreenLarge = (screenBounds.size.height == XBASE_LG) ? YES : NO;
    
    tutorialName = tutorial;
    
    if([tutorialName isEqualToString:@"Intro"]){
        tutorialTotalSteps = 5;
    }else if([tutorialName isEqualToString:@"Instrument"]){
        tutorialTotalSteps = 1;
    }else if([tutorialName isEqualToString:@"Custom"]){
        tutorialTotalSteps = 1;
    }else{
        tutorialTotalSteps = 0;
    }
    
    tutorialScreen = self;
    
    
    return self;
}

- (void)launch
{
    tutorialStep = 1;
    
    if([tutorialName isEqualToString:@"Intro"]){
        [self drawIntroTutorialScreen:tutorialStep];
    }else if([tutorialName isEqualToString:@"Instrument"]){
        [self drawInstrumentTutorialScreen:tutorialStep];
    }else if([tutorialName isEqualToString:@"Custom"]){
        [self drawCustomTutorialScreen:tutorialStep];
    }
}

- (void)end
{
    [self fadeOutTutorialSubviews:YES];
    [delegate notifyTutorialEnded];
}

- (void)incrementFTUTutorial
{
    tutorialStep++;
    
    if([tutorialName isEqualToString:@"Intro"]){
        [self drawIntroTutorialScreen:tutorialStep];
    }
}

- (void)fadeOutTutorialSubviews:(BOOL)removeAll
{
    NSArray * views = [tutorialScreen subviews];
    
    float screenWidth = tutorialScreen.frame.size.width;
    
    [UIView animateWithDuration:0.5 animations:^(void){
        for (UIView * v in views) {
            [v setFrame:CGRectMake(-1*screenWidth/2,v.frame.origin.y,v.frame.size.width,v.frame.size.height)];
            [v setAlpha:0.0];
        }
    } completion:^(BOOL finished){
        if(removeAll){
            [tutorialScreen removeFromSuperview];
            [tutorialBottomBar removeFromSuperview];
        }else{
            for (UIView * v in views) {
                [v removeFromSuperview];
            }
        }
    }];
}

- (void)fadeInTutorialSubview:(UIView *)v
{
    
    float screenWidth = tutorialScreen.frame.size.width;
    CGRect frame = v.frame;
    
    [v setFrame:CGRectMake(screenWidth+screenWidth/2,frame.origin.y,frame.size.width,frame.size.height)];
    [v setAlpha:0.0];
    
    [tutorialScreen addSubview:v];
    
    [UIView animateWithDuration:0.5 animations:^(void){
        [v setFrame:frame];
        [v setAlpha:1.0];
    } completion:^(BOOL finished){
        
    }];
}

#pragma mark - Intro Tutorial

- (void)drawIntroTutorialScreen:(int)screenIndex
{    
    UIColor * fadedGray = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    UIColor * blueColor = [UIColor colorWithRed:33/255.0 green:173/255.0 blue:211/255.0 alpha:1.0];
    
    float circleBorderWidth = 8.0;
    float circleWidth = 90;
    float defaultLabelHeight = 32;
    float stripeWidth = 20;
    
    // Clear out previous screen
    [self fadeOutTutorialSubviews:NO];
    
    if(screenIndex == 1){
        
        //
        // WELCOME TO SEQUENCE
        //
        
        [tutorialScreen setBackgroundColor:blueColor];
        
        // Title label
        float midtitleWidth = 300;
        
        CGRect titleFrame = CGRectMake(30,30,380,30);
        CGRect subtitleFrame = CGRectMake(30,60,180,30);
        CGRect midtitleFrame = CGRectMake(tutorialScreen.frame.size.width/2 - midtitleWidth/2,120,midtitleWidth,30);
        
        [self drawTutorialLabel:titleFrame withTitle:@"WELCOME TO SEQUENCE" withColor:[UIColor clearColor] isHeader:YES];
        [self drawTutorialLabel:subtitleFrame withTitle:@"Let's get started..." withColor:[UIColor clearColor] isHeader:NO];
        [self drawTutorialLabel:midtitleFrame withTitle:@"Do you have a gTar?" withColor:[UIColor clearColor] isHeader:NO];
        
        // Yes + No buttons
        CGRect yesButtonFrame = CGRectMake(tutorialScreen.frame.size.width/2 - 233,197,circleWidth,circleWidth);
        CGRect noButtonFrame = CGRectMake(tutorialScreen.frame.size.width/2 + 110,197,circleWidth,circleWidth);
        
        [self drawTutorialCircle:yesButtonFrame withTitle:@"YES" size:30.0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:[UIColor whiteColor] andAction:@selector(incrementFTUTutorial)];
        
        [self drawTutorialCircle:noButtonFrame withTitle:@"NO" size:30.0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:[UIColor whiteColor] andAction:@selector(incrementFTUTutorial)];
        
        // Yes+No stripes/arrows
        CGRect yesStripeFrame = CGRectMake(yesButtonFrame.origin.x+yesButtonFrame.size.width-circleBorderWidth/2,yesButtonFrame.origin.y+yesButtonFrame.size.height/2-stripeWidth/2,15,stripeWidth);
        CGRect noStripeFrame = CGRectMake(noButtonFrame.origin.x+noButtonFrame.size.width-circleBorderWidth/2,noButtonFrame.origin.y+noButtonFrame.size.height/2-stripeWidth/2,tutorialScreen.frame.size.width - (noButtonFrame.origin.x+noButtonFrame.size.width)+circleBorderWidth/2,stripeWidth);
        
        UIView * noStripe = [[UIView alloc] initWithFrame:noStripeFrame];
        UIView * yesStripe = [[UIView alloc] initWithFrame:yesStripeFrame];
        
        [noStripe setBackgroundColor:[UIColor whiteColor]];
        [yesStripe setBackgroundColor:[UIColor whiteColor]];
        
        [self fadeInTutorialSubview:noStripe];
        [self fadeInTutorialSubview:yesStripe];
        
        // Yes arrow
        float arrowWidth = 35;
        float arrowHeight = 40;
        CGRect yesArrowFrame = CGRectMake(yesButtonFrame.origin.x+yesButtonFrame.size.width-circleBorderWidth/2+yesStripeFrame.size.width,yesButtonFrame.origin.y+yesButtonFrame.size.height/2-stripeWidth/2-(arrowHeight-stripeWidth)/2,arrowWidth,arrowHeight);
        
        [self drawTutorialArrow:yesArrowFrame facesDirection:3 width:arrowWidth height:arrowHeight withColor:[UIColor whiteColor]];
        
        // Dock graphic
        CGRect dockFrame = CGRectMake(yesArrowFrame.origin.x+yesArrowFrame.size.width + 10,yesArrowFrame.origin.y - 30,185,100);
        UIImageView * dock = [[UIImageView alloc] initWithFrame:dockFrame];
        [dock setImage:[UIImage imageNamed:@"Tutorial_Dock"]];
        
        [self fadeInTutorialSubview:dock];
        
    }else if(screenIndex == tutorialTotalSteps){
        
        //
        // PLAY TO START
        //
        
        // pointer to play
        CGRect newTutorialFrame = CGRectMake(0, 0, tutorialScreen.frame.size.width, tutorialScreen.frame.size.height - BOTTOMBAR_HEIGHT);
        [tutorialScreen setFrame:newTutorialFrame];
        [tutorialScreen setBackgroundColor:fadedGray];
        
        float playButtonWidth = 130;
        CGRect bottomBarFrame = CGRectMake(playButtonWidth, newTutorialFrame.size.height, tutorialScreen.frame.size.width - playButtonWidth, BOTTOMBAR_HEIGHT);
        tutorialBottomBar = [[UIView alloc] initWithFrame:bottomBarFrame];
        [tutorialBottomBar setBackgroundColor:fadedGray];
        [self addSubview:tutorialBottomBar];
        
        // Start playing
        float playLabelWidth = 145;
        
        CGRect playLabelFrame = CGRectMake(53, tutorialScreen.frame.size.height-70, playLabelWidth, defaultLabelHeight);
        [self drawTutorialLabel:playLabelFrame withTitle:@"Tap to PLAY" withColor:blueColor isHeader:NO];
        
        // Play stripe
        CGRect playStripeFrame = CGRectMake(playLabelFrame.origin.x,playLabelFrame.origin.y+playLabelFrame.size.height,stripeWidth,30);
        
        UIView * playStripe = [[UIView alloc] initWithFrame:playStripeFrame];
        
        [playStripe setBackgroundColor:blueColor];
        
        [self fadeInTutorialSubview:playStripe];
        
        // Play circle
        CGRect playCircleFrame = CGRectMake(17,tutorialBottomBar.frame.origin.y+tutorialBottomBar.frame.size.height-3*circleWidth/4-3,circleWidth,circleWidth);
        [self drawTutorialCircle:playCircleFrame withTitle:nil size:0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:@selector(end)];
        
        [tutorialNext removeFromSuperview];
        
    }else{
        
        [tutorialScreen setBackgroundColor:fadedGray];
        
        CGRect buttonFrame = CGRectMake(0, 0, tutorialScreen.frame.size.width, tutorialScreen.frame.size.height);
        tutorialNext = [[UIButton alloc] initWithFrame:buttonFrame];
        
        [tutorialScreen addSubview:tutorialNext];
        [tutorialNext addTarget:self action:@selector(incrementFTUTutorial) forControlEvents:UIControlEventTouchUpInside];
        
        if(screenIndex == 2){
            
            //
            // SET VIEW
            //
            
            // Header
            float trackHeaderHeight = defaultLabelHeight + 15;
            float trackHeaderWidth = 350;
            CGRect titleFrame = CGRectMake(0,222,trackHeaderWidth,trackHeaderHeight);
            
            UILabel * titleLabel = [self drawTutorialLabel:titleFrame withTitle:@"" withColor:[UIColor clearColor] isHeader:NO];
            
            NSMutableAttributedString * titleString = [[NSMutableAttributedString alloc] initWithString:@"A set is composed of tracks."];
            [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_BOLD size:30.0] range:NSMakeRange(1,5)];
            [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_BOLD size:30.0] range:NSMakeRange(20,7)];
            
            [titleLabel setAttributedText:titleString];
            
            // View track
            CGRect viewTrackFrame;
            float viewTrackLabelWidth = 120;
            
            if(isScreenLarge){
                viewTrackFrame = CGRectMake(101, 30, viewTrackLabelWidth, defaultLabelHeight);
                
                // Toggle circle
                CGRect toggleCircleFrame = CGRectMake(16,0,circleWidth,circleWidth);
                [self drawTutorialCircle:toggleCircleFrame withTitle:nil size:0 andImage:@"Icon_Violin" andEdgeInsets:UIEdgeInsetsMake(12, 12, 13, 12) withColor:blueColor andAction:nil];
            }else{
                viewTrackFrame = CGRectMake(85, 30, viewTrackLabelWidth, defaultLabelHeight);
                
                // Toggle circle
                CGRect toggleCircleFrame = CGRectMake(0,0,circleWidth,circleWidth);
                [self drawTutorialCircle:toggleCircleFrame withTitle:nil size:0 andImage:@"Icon_Violin" andEdgeInsets:UIEdgeInsetsMake(12, 12, 13, 12) withColor:blueColor andAction:nil];
            }
            
            [self drawTutorialLabel:viewTrackFrame withTitle:@"View track" withColor:blueColor isHeader:NO];
            
            // Toggle tracks
            CGRect toggleLabelFrame;
            float toggleLabelWidth = 155;
            
            if(isScreenLarge){
                toggleLabelFrame = CGRectMake(tutorialScreen.frame.size.width-toggleLabelWidth-100, 10, toggleLabelWidth, defaultLabelHeight);
                
                // Toggle circle
                CGRect toggleCircleFrame = CGRectMake(tutorialScreen.frame.size.width-circleWidth-14.5,-21,circleWidth,circleWidth);
                [self drawTutorialCircle:toggleCircleFrame withTitle:nil size:0 andImage:@"Power_Icon" andEdgeInsets:UIEdgeInsetsMake(14, 15.5, 14, 15.5) withColor:blueColor andAction:nil];
            }else{
                toggleLabelFrame = CGRectMake(tutorialScreen.frame.size.width-toggleLabelWidth-71, 10, toggleLabelWidth, defaultLabelHeight);
                
                // Toggle circle
                CGRect toggleCircleFrame = CGRectMake(tutorialScreen.frame.size.width-circleWidth+13.5,-21.5,circleWidth,circleWidth);
                [self drawTutorialCircle:toggleCircleFrame withTitle:nil size:0 andImage:@"Power_Icon" andEdgeInsets:UIEdgeInsetsMake(15, 16, 15, 16) withColor:blueColor andAction:nil];
            }
            
            [self drawTutorialLabel:toggleLabelFrame withTitle:@"Toggle sound" withColor:blueColor isHeader:NO];
            
            // Delete
            float deleteLabelWidth = 110;
            
            CGRect deleteLabelFrame = CGRectMake(tutorialScreen.frame.size.width-deleteLabelWidth-72, 112, deleteLabelWidth, defaultLabelHeight);
            [self drawTutorialLabel:deleteLabelFrame withTitle:@"Remove" withColor:blueColor isHeader:NO];
            
            // Delete image
            float deleteImageWidth = 82;
            CGRect deleteImageFrame = CGRectMake(tutorialScreen.frame.size.width-deleteImageWidth, 89, deleteImageWidth, 87.5);
            UIButton * deleteImageView = [[UIButton alloc] initWithFrame:deleteImageFrame];
            [deleteImageView setBackgroundColor:[UIColor colorWithRed:216/255.0 green:64/255.0 blue:64/255.0 alpha:1.0]];
            [deleteImageView setImage:[UIImage imageNamed:@"Trash_Icon"] forState:UIControlStateNormal];
            [deleteImageView setImageEdgeInsets:UIEdgeInsetsMake(20, 25, 20, 25)];
            
            [self fadeInTutorialSubview:deleteImageView];
            
            // Delete arrow
            float arrowWidth = 44;
            float arrowHeight = 50;
            CGRect deleteArrowFrame = CGRectMake(deleteLabelFrame.origin.x-arrowWidth, deleteLabelFrame.origin.y-(arrowHeight-defaultLabelHeight)/2, arrowWidth, arrowHeight);
            [self drawTutorialArrow:deleteArrowFrame facesDirection:9 width:arrowWidth height:arrowHeight withColor:blueColor];
            
        }else if(screenIndex == 3){
            
            //
            // TEMPO VOLUME
            //
            
            // Tempo circle
            CGRect tempoCircleFrame = CGRectMake(tutorialScreen.frame.size.width/2-circleWidth/2+39.5,tutorialScreen.frame.size.height-3*circleWidth/4-3,circleWidth,circleWidth);
            [self drawTutorialCircle:tempoCircleFrame withTitle:@"120" size:30.0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil];
            
            // Tempo label
            float tempoLabelWidth = 220;
            
            //CGRect tempoLabelTopFrame = CGRectMake(tempoCircleFrame.origin.x+circleWidth-tempoLabelWidth-35,tutorialScreen.frame.size.height-143+defaultLabelHeight,tempoLabelWidth,defaultLabelHeight);
            
            CGRect tempoLabelBottomFrame = CGRectMake(tempoCircleFrame.origin.x+circleWidth-tempoLabelWidth-35, tutorialScreen.frame.size.height-156, tempoLabelWidth, defaultLabelHeight);
            
            //[self drawTutorialLabel:tempoLabelTopFrame withTitle:@"Change the speed" withColor:blueColor isHeader:NO];
            [self drawTutorialLabel:tempoLabelBottomFrame withTitle:@"Control play speed" withColor:blueColor isHeader:NO];
            
            // Tempo stripe
            CGRect tempoStripeFrame = CGRectMake(tempoLabelBottomFrame.origin.x+tempoLabelBottomFrame.size.width-stripeWidth,tempoLabelBottomFrame.origin.y+tempoLabelBottomFrame.size.height,stripeWidth,55);
            
            UIView * tempoStripe = [[UIView alloc] initWithFrame:tempoStripeFrame];
            
            [tempoStripe setBackgroundColor:blueColor];
            
            [self fadeInTutorialSubview:tempoStripe];
            
            // Tempo arrows
            float arrowWidth = 35;
            float arrowHeight = 40;
            
            CGRect tempoArrowLeftFrame = CGRectMake(tempoCircleFrame.origin.x-arrowWidth-5, tempoCircleFrame.origin.y+arrowHeight/2+5, arrowWidth, arrowHeight);
            CGRect tempoArrowRightFrame = CGRectMake(tempoCircleFrame.origin.x+tempoCircleFrame.size.width+5, tempoCircleFrame.origin.y+arrowHeight/2+5, arrowWidth, arrowHeight);
            
            [self drawTutorialArrow:tempoArrowLeftFrame facesDirection:9 width:arrowWidth height:arrowHeight withColor:blueColor];
            [self drawTutorialArrow:tempoArrowRightFrame facesDirection:3 width:arrowWidth height:arrowHeight withColor:blueColor];
            
            // Tempo arrow stripes
            float tempoArrowWidth = 8.0;
            CGRect leftStripeFrame = CGRectMake(tempoArrowLeftFrame.origin.x+tempoArrowLeftFrame.size.width,tempoArrowLeftFrame.origin.y+tempoArrowLeftFrame.size.height/2-stripeWidth/2,tempoArrowWidth,stripeWidth);
            CGRect rightStripeFrame = CGRectMake(tempoArrowRightFrame.origin.x-tempoArrowWidth,tempoArrowLeftFrame.origin.y+tempoArrowLeftFrame.size.height/2-stripeWidth/2,tempoArrowWidth,stripeWidth);
            
            UIView * leftStripe = [[UIView alloc] initWithFrame:leftStripeFrame];
            UIView * rightStripe = [[UIView alloc] initWithFrame:rightStripeFrame];
            
            [leftStripe setBackgroundColor:blueColor];
            [rightStripe setBackgroundColor:blueColor];
            
            [self fadeInTutorialSubview:leftStripe];
            [self fadeInTutorialSubview:rightStripe];
            
            // Volume circle
            CGRect volumeCircleFrame = CGRectMake(tutorialScreen.frame.size.width-circleWidth-20,tutorialScreen.frame.size.height-3*circleWidth/4-3,circleWidth,circleWidth);
            [self drawTutorialCircle:volumeCircleFrame withTitle:nil size:0 andImage:@"Volume_Icon" andEdgeInsets:UIEdgeInsetsMake(13.5, 14, 16, 14) withColor:blueColor andAction:nil];
            
            // Volume
            float volumeLabelWidth = 107;
            
            CGRect volumeLabelFrame = CGRectMake(volumeCircleFrame.origin.x+circleWidth-volumeLabelWidth-35, tutorialScreen.frame.size.height-133, volumeLabelWidth, defaultLabelHeight);
            [self drawTutorialLabel:volumeLabelFrame withTitle:@"Volume" withColor:blueColor isHeader:NO];
            
            // Volume stripe
            CGRect volumeStripeFrame = CGRectMake(volumeLabelFrame.origin.x+volumeLabelFrame.size.width-stripeWidth,volumeLabelFrame.origin.y+volumeLabelFrame.size.height,stripeWidth,32);
            UIView * volumeStripe = [[UIView alloc] initWithFrame:volumeStripeFrame];
            [volumeStripe setBackgroundColor:blueColor];
            [self fadeInTutorialSubview:volumeStripe];
            
        }else if(screenIndex == 4){
            
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
                minusCircleFrame = CGRectMake(58,24,circleWidth,circleWidth);
                plusCircleFrame = CGRectMake(359,24,circleWidth,circleWidth);
            }
            
            [self drawTutorialCircle:minusCircleFrame withTitle:nil size:0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil];
            [self drawTutorialCircle:plusCircleFrame withTitle:nil size:0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil];
            
            // Minus/Plus
            float minusPlusWidth = 28;
            
            CGRect minusSymbolFrame;
            CGRect plusSymbolFrame;
            
            if(isScreenLarge){
                minusSymbolFrame = CGRectMake(120,55,minusPlusWidth,minusPlusWidth);
                plusSymbolFrame = CGRectMake(421,55,minusPlusWidth,minusPlusWidth);
            }else{
                minusSymbolFrame = CGRectMake(90,55,minusPlusWidth,minusPlusWidth);
                plusSymbolFrame = CGRectMake(391,55,minusPlusWidth,minusPlusWidth);
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
            
            [self fadeInTutorialSubview:minusSymbol];
            [self fadeInTutorialSubview:plusSymbol];
            
            // 1, 2, 4
            CGRect loopOneFrame;
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
            
            [self drawTutorialLabel:loopOneFrame withTitle:@"1" withColor:blueColor isHeader:YES];
            [self drawTutorialLabel:loopTwoFrame withTitle:@"2" withColor:blueColor isHeader:YES];
            [self drawTutorialLabel:loopFourFrame withTitle:@"4" withColor:blueColor isHeader:YES];
            
            // Change Loop Length
            float trackHeaderHeight = defaultLabelHeight;
            float trackHeaderWidth = 230;
            CGRect titleFrame = CGRectMake(minusCircleFrame.origin.x+35,minusCircleFrame.origin.y+minusCircleFrame.size.height+15,trackHeaderWidth,trackHeaderHeight);
            
            [self drawTutorialLabel:titleFrame withTitle:@"Change loop length" withColor:blueColor isHeader:NO];
            
            // Change loop stripe
            CGRect changeLoopStripeFrame = CGRectMake(titleFrame.origin.x,minusCircleFrame.origin.y+minusCircleFrame.size.height-3,stripeWidth,18);
            UIView * changeLoopStripe = [[UIView alloc] initWithFrame:changeLoopStripeFrame];
            [changeLoopStripe setBackgroundColor:blueColor];
            [self fadeInTutorialSubview:changeLoopStripe];
            
        }
        
    }
    
    tutorialScreen.userInteractionEnabled = YES;
    
}

#pragma mark - Instrument Tutorial

-(void)drawInstrumentTutorialScreen:(int)screenIndex
{
    
    UIColor * fadedGray = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    UIColor * blueColor = [UIColor colorWithRed:33/255.0 green:173/255.0 blue:211/255.0 alpha:1.0];
    
    float circleWidth = 90;
    float defaultLabelHeight = 32;
    float stripeWidth = 20;
    
    [tutorialScreen setBackgroundColor:fadedGray];
    
    CGRect buttonFrame = CGRectMake(0, 0, tutorialScreen.frame.size.width, tutorialScreen.frame.size.height);
    tutorialNext = [[UIButton alloc] initWithFrame:buttonFrame];
    
    [tutorialScreen addSubview:tutorialNext];
    [tutorialNext addTarget:self action:@selector(end) forControlEvents:UIControlEventTouchUpInside];
    
    if(screenIndex == 1){
        
        //
        // TRACK VIEW
        //
        
        // Pattern circles
        CGRect patternAFrame;
        CGRect patternBFrame;
        CGRect patternCFrame;
        CGRect patternDFrame;
        
        if(isScreenLarge){
            patternAFrame = CGRectMake(117,-21,circleWidth,circleWidth);
            patternBFrame = CGRectMake(199,-21,circleWidth,circleWidth);
            patternCFrame = CGRectMake(281,-21,circleWidth,circleWidth);
            patternDFrame = CGRectMake(363,-21,circleWidth,circleWidth);
        }else{
            patternAFrame = CGRectMake(87,-21,circleWidth,circleWidth);
            patternBFrame = CGRectMake(169,-21,circleWidth,circleWidth);
            patternCFrame = CGRectMake(251,-21,circleWidth,circleWidth);
            patternDFrame = CGRectMake(333,-21,circleWidth,circleWidth);
        }
        
        [self drawTutorialCircle:patternAFrame withTitle:@"A" size:40.0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil];
        [self drawTutorialCircle:patternBFrame withTitle:@"B" size:40.0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil];
        [self drawTutorialCircle:patternCFrame withTitle:@"C" size:40.0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil];
        [self drawTutorialCircle:patternDFrame withTitle:@"D" size:40.0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil];
        
        // Program patterns
        float patternHeaderWidth = 350;
        CGRect titleFrame = CGRectMake(patternAFrame.origin.x+35,patternAFrame.origin.y+patternAFrame.size.height+10,patternHeaderWidth,defaultLabelHeight);
        
        [self drawTutorialLabel:titleFrame withTitle:@"Program up to 4 different patterns" withColor:blueColor isHeader:NO];
        
        // Pattern stripe
        CGRect patternStripeFrame = CGRectMake(titleFrame.origin.x,patternAFrame.origin.y+patternAFrame.size.height-3,stripeWidth,15);
        UIView * patternStripe = [[UIView alloc] initWithFrame:patternStripeFrame];
        [patternStripe setBackgroundColor:blueColor];
        [self fadeInTutorialSubview:patternStripe];
        
        // Note circle
        CGRect noteCircleFrame;
        
        if(isScreenLarge){
            noteCircleFrame = CGRectMake(75,113,circleWidth,circleWidth);
        }else{
            noteCircleFrame = CGRectMake(30,113,circleWidth,circleWidth);
        }
        
        [self drawTutorialCircle:noteCircleFrame withTitle:nil size:0 andImage:nil andEdgeInsets:UIEdgeInsetsZero withColor:blueColor andAction:nil];
        
        // Note box
        float noteWidth = 28;
        CGRect noteBoxFrame = CGRectMake(noteCircleFrame.origin.x+(noteCircleFrame.size.width-noteWidth)/2,noteCircleFrame.origin.y+(noteCircleFrame.size.height-noteWidth)/2,noteWidth,noteWidth);
        UIView * noteBox = [[UIView alloc] initWithFrame:noteBoxFrame];
        [noteBox setBackgroundColor:[UIColor colorWithRed:5/255.0 green:195/255.0 blue:77/255.0 alpha:1.0]];
        noteBox.layer.borderColor = [UIColor whiteColor].CGColor;
        noteBox.layer.borderWidth = 0.5f;
        [self fadeInTutorialSubview:noteBox];
        
        // Control notes
        float noteHeaderWidth = 320;
        CGRect noteTitleFrame = CGRectMake(noteCircleFrame.origin.x+35,noteCircleFrame.origin.y+noteCircleFrame.size.height+10,noteHeaderWidth,defaultLabelHeight);
        
        [self drawTutorialLabel:noteTitleFrame withTitle:@"Each color represents a sound" withColor:blueColor isHeader:NO];
        
        // Note stripe
        CGRect noteStripeFrame = CGRectMake(noteTitleFrame.origin.x,noteCircleFrame.origin.y+noteCircleFrame.size.height-3,stripeWidth,15);
        UIView * noteStripe = [[UIView alloc] initWithFrame:noteStripeFrame];
        [noteStripe setBackgroundColor:blueColor];
        [self fadeInTutorialSubview:noteStripe];
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
    
    if(screenIndex == 1){
        
        //
        // CUSTOM VIEW
        //
        
        // Header
        float customHeaderHeight = defaultLabelHeight + 15;
        float customHeaderWidth = 290;
        CGRect titleFrame = CGRectMake(tutorialScreen.frame.size.width/2-190,218,customHeaderWidth,customHeaderHeight);
        
        UILabel * titleLabel = [self drawTutorialLabel:titleFrame withTitle:@"" withColor:[UIColor clearColor] isHeader:NO];
        
        NSMutableAttributedString * titleString = [[NSMutableAttributedString alloc] initWithString:@"Build a custom track."];
        [titleString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_BOLD size:30.0] range:NSMakeRange(7,13)];
        
        [titleLabel setAttributedText:titleString];
        
        // First string / first sample
        float stringWidth = 102;
        float stringHeight = 39;
        
        CGRect stringBoxFrame;
        CGRect sampleBoxFrame;
        
        if(isScreenLarge){
            stringBoxFrame = CGRectMake(314-borderWidth,22-borderWidth,stringWidth+2*borderWidth,stringHeight+2*borderWidth);
            sampleBoxFrame = CGRectMake(106-borderWidth,101-borderWidth,stringWidth+2*borderWidth,stringHeight-1+2*borderWidth);
        }else{
            stringBoxFrame = CGRectMake(268-borderWidth,22-borderWidth,stringWidth+2*borderWidth,stringHeight+2*borderWidth);
            sampleBoxFrame = CGRectMake(60-borderWidth,101-borderWidth,stringWidth+2*borderWidth,stringHeight-1+2*borderWidth);
        }
        
        UIView * stringBox = [[UIView alloc] initWithFrame:stringBoxFrame];
        UIView * sampleBox = [[UIView alloc] initWithFrame:sampleBoxFrame];
        [stringBox setBackgroundColor:[UIColor colorWithRed:170/255.0 green:114/255.0 blue:233/255.0 alpha:1.0]];
        [sampleBox setBackgroundColor:[UIColor whiteColor]];
        
        sampleBox.layer.borderWidth = 8.0;
        sampleBox.layer.borderColor = blueColor.CGColor;
        
        stringBox.layer.borderWidth = 8.0;
        stringBox.layer.borderColor = blueColor.CGColor;
        
        [self fadeInTutorialSubview:stringBox];
        [self fadeInTutorialSubview:sampleBox];
        
        // First string+sample text
        CGRect stringTextFrame = CGRectMake(stringBoxFrame.origin.x+12, stringBoxFrame.origin.y+1, stringBoxFrame.size.width, stringBoxFrame.size.height);
        CGRect sampleTextFrame = CGRectMake(sampleBoxFrame.origin.x-8, sampleBoxFrame.origin.y+1, sampleBoxFrame.size.width, sampleBoxFrame.size.height);
        
        UILabel * stringText = [self drawTutorialLabel:stringTextFrame withTitle:@"Guitar 2" withColor:[UIColor clearColor] isHeader:NO];
        UILabel * sampleText = [self drawTutorialLabel:sampleTextFrame withTitle:@"Guitar 2" withColor:[UIColor clearColor] isHeader:NO];
        
        [stringText setFont:[UIFont fontWithName:FONT_DEFAULT size:18.0]];
        [sampleText setFont:[UIFont fontWithName:FONT_DEFAULT size:18.0]];
        
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
        [self drawTutorialArrow:tutorialArrowFrame facesDirection:3 width:10 height:15 withColor:[UIColor whiteColor]];
        
        // Add sounds
        float addSoundsTitleWidth = 270;
        CGRect addSoundsTitleFrame = CGRectMake(sampleBoxFrame.origin.x+(sampleBoxFrame.size.width-defaultLabelHeight)/2,sampleBoxFrame.origin.y+sampleBoxFrame.size.height+10,addSoundsTitleWidth,defaultLabelHeight);
        
        [self drawTutorialLabel:addSoundsTitleFrame withTitle:@"Assign sounds to 6 colors" withColor:blueColor isHeader:NO];
        
        // Add sounds stripe
        CGRect addSoundsStripeFrame = CGRectMake(addSoundsTitleFrame.origin.x,sampleBoxFrame.origin.y+sampleBoxFrame.size.height-3,stripeWidth,15);
        UIView * addSoundsStripe = [[UIView alloc] initWithFrame:addSoundsStripeFrame];
        [addSoundsStripe setBackgroundColor:blueColor];
        [self fadeInTutorialSubview:addSoundsStripe];
        
        // Sample/sound stripes
        CGRect sampleStripeFrame = CGRectMake(sampleBoxFrame.origin.x+sampleBoxFrame.size.width-3,sampleBoxFrame.origin.y+(sampleBoxFrame.size.height-stripeWidth)/2,162,stripeWidth);
        CGRect stringStripeFrame = CGRectMake(stringBoxFrame.origin.x+(stringBoxFrame.size.width-stripeWidth)/2,stringBoxFrame.origin.y+stringBoxFrame.size.height-3,stripeWidth,45);
        
        UIView * sampleStripe = [[UIView alloc] initWithFrame:sampleStripeFrame];
        UIView * stringStripe = [[UIView alloc] initWithFrame:stringStripeFrame];
        
        [sampleStripe setBackgroundColor:blueColor];
        [stringStripe setBackgroundColor:blueColor];
        
        [self fadeInTutorialSubview:sampleStripe];
        [self fadeInTutorialSubview:stringStripe];
        
    }
}

#pragma mark - Draw reusable interface

-(UIView *)drawTutorialArrow:(CGRect)frame facesDirection:(int)faces width:(float)arrowWidth height:(float)arrowHeight withColor:(UIColor *)arrowColor
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
    [self fadeInTutorialSubview:newArrow];
    
    UIGraphicsEndImageContext();
    
    return newArrow;
}


-(UIButton *)drawTutorialCircle:(CGRect)frame withTitle:(NSString *)title size:(float)fontSize andImage:(NSString *)imageName andEdgeInsets:(UIEdgeInsets)insets withColor:(UIColor *)borderColor andAction:(SEL)selector
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
    }
    
    [self fadeInTutorialSubview:newCircle];
    
    return newCircle;
}

-(UILabel *)drawTutorialLabel:(CGRect)frame withTitle:(NSString *)title withColor:(UIColor *)backgroundColor isHeader:(BOOL)isHeader
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
    
    [self fadeInTutorialSubview:newLabel];
    
    return newLabel;
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
