//
//  ThirdViewController.h
//  gTarDemo
//
//  Created by Joel Greenia on 11/15/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GtarController/GtarController.h>

@class GuitarEffectSerialized;

@interface ThirdViewController : UIViewController <GtarControllerObserver>
{
    NSInteger m_preDelay;
    NSInteger m_postDelay;
}

@property (unsafe_unretained, nonatomic) UIImageView * m_splashScreen;
@property (unsafe_unretained, nonatomic) UIView * m_blackScreen;
@property (unsafe_unretained, nonatomic) UIView * m_whiteScreen;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *m_blackWhiteSwitch;
@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *m_rotationControl;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *m_preLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *m_postLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *m_connectionLabel;

@property (unsafe_unretained, nonatomic) NSArray * m_effectsSequence;
@property (retain, nonatomic) NSMutableArray * m_effectsSequenceSerialized;

- (IBAction)prePlusClicked:(id)sender;
- (IBAction)preMinusClicked:(id)sender;
- (IBAction)postPlusClicked:(id)sender;
- (IBAction)postMinusClicked:(id)sender;

- (IBAction)startButtonClicked:(id)sender;

- (void)fadeInBlack;
- (void)fadeOutBlack;
- (void)fadeInSplash;
- (void)fadeOutSplash;

- (void)startEffectsSequence;
- (void)startEffectsSequenceLoop;
- (void)sendEffectToGuitar:(GuitarEffectSerialized*)effect;

@end
