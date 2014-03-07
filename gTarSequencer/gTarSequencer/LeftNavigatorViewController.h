//
//  LeftNavigation.h
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import <UIKit/UIKit.h>

@protocol LeftNavigatorDelegate <NSObject>

- (void) toggleLeftNavigator;
- (void) selectNavChoice:(NSString *)nav withShift:(BOOL)shift;

@end

@interface LeftNavigatorViewController : UIViewController
{
    BOOL instrumentViewEnabled;
    UIColor * silverColor;
    UIColor * redColor;
    UIColor * greenColor;
    UIColor * blueColor;
    
    NSString * defaultInstrumentIcon;
}

-(IBAction)selectNav:(id)sender;
-(void)setNavButtonOn:(NSString *)navChoice;
-(void)enableInstrumentViewWithIcon:(NSString *)instIcon showCustom:(BOOL)isCustom;
-(void)disableInstrumentView;
-(void)changeConnectedButton:(BOOL)isConnected;

@property (weak, nonatomic) id<LeftNavigatorDelegate> delegate;
@property (nonatomic) CGRect viewFrame;

@property (weak, nonatomic) IBOutlet UIButton * optionsButton;
@property (weak, nonatomic) IBOutlet UIButton * seqSetButton;
@property (weak, nonatomic) IBOutlet UIButton * instrumentButton;
@property (weak, nonatomic) IBOutlet UIButton * shareButton;
@property (weak, nonatomic) IBOutlet UIButton * connectedButton;
@property (weak, nonatomic) IBOutlet UIView * leftSlider;
@property (weak, nonatomic) IBOutlet UIView * customIndicator;
@property (weak, nonatomic) IBOutlet UIImageView * connectedLeftArrow;

@end