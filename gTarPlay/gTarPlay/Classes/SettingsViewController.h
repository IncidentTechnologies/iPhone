//
//  SettingsViewController.h
//  gTarPlay
//
//  Created by Kate Schnippering on 5/20/14.
//
//

#import <UIKit/UIKit.h>

#import "SelectorControl.h"
#import "UIView+Gtar.h"
#import "GtarController.h"
#import "GtarControllerInternal.h"


@class SelectorControl;

extern GtarController *g_gtarController;

@interface SettingsViewController : UIViewController <GtarControllerObserver>
{
    
}

@property (nonatomic, strong) NSString *firmwareVersion;

@property (nonatomic, strong) IBOutlet UIView *topBar;
@property (nonatomic, strong) IBOutlet UIView *gtarView;
@property (nonatomic, strong) IBOutlet UIView *calibrateView;
@property (nonatomic, strong) IBOutlet UIView *controlsView;
@property (nonatomic, strong) IBOutlet UILabel *settingsLabel;

@property (nonatomic, strong) IBOutlet UILabel *gtarSerialLabel;
@property (nonatomic, strong) IBOutlet UILabel *serialLabel;
@property (nonatomic, strong) IBOutlet UILabel *firmwareVersionLabel;
@property (nonatomic, strong) IBOutlet UILabel *versionLabel;

@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *registerButton;
@property (nonatomic, strong) IBOutlet UIButton *updateButton;
@property (strong, nonatomic) IBOutlet SelectorControl *settingsSelector;

@property (strong, nonatomic) IBOutlet UILabel *postToFeedLabel;
@property (strong, nonatomic) IBOutlet UILabel *offLabel;
@property (strong, nonatomic) IBOutlet UILabel *onLabel;
@property (strong, nonatomic) IBOutlet UISwitch *feedSwitch;

- (IBAction)settingsSelectorChanged:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)registerButtonClicked:(id)sender;
- (IBAction)updateButtonClicked:(id)sender;
- (IBAction)feedSwitchChanged:(id)sender;

- (void)updateFirmwareVersion;
- (void)noUpdates;


@end
