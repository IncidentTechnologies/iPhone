//
//  SettingsViewController.m
//  gTarPlay
//
//  Created by Kate Schnippering on 5/20/14.
//
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
        _firmwareVersion = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeViews];
    
    [g_gtarController addObserver:self];
    
    [_settingsSelector setTitles:[NSArray arrayWithObjects:NSLocalizedString(@"GTAR",NULL), NSLocalizedString(@"CALIBRATE",NULL), NSLocalizedString(@"CONTROLS",NULL), nil]];
    [_topBar addShadow];
    
    [self updateFirmwareVersion];
    
    [self initControls];
    
}

- (void)dealloc
{
    [g_gtarController removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)localizeViews
{
    _settingsLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Settings", NULL)];
    
    _gtarSerialLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"gTar Serial", NULL)];
    _firmwareVersionLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Firmware", NULL)];
    
    [_registerButton setTitle:[[NSString alloc] initWithString:NSLocalizedString(@"REGISTER", NULL)] forState:UIControlStateNormal];
    [_updateButton setTitle:[[NSString alloc] initWithString:NSLocalizedString(@"CHECK FOR UPDATES", NULL)] forState:UIControlStateNormal];
    
    _postToFeedLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"POST TO FEED", NULL)];
    _offLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"OFF", NULL)];
    _onLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"ON", NULL)];
}

- (void)initControls
{
    
    // Post To Feed?
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    BOOL disablePostToFeed = [settings boolForKey:@"DisablePostToFeed"];
    
    [_feedSwitch setOn:!disablePostToFeed];
}

- (IBAction)backButtonClicked:(id)sender
{    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)registerButtonClicked:(id)sender
{
    NSLog(@"Register gTar");
}

- (IBAction)updateButtonClicked:(id)sender
{
    [g_gtarController sendRequestFirmwareVersion];
}

- (void)updateFirmwareVersion
{
    // Update in settings
    if(g_gtarController.connected){
     
    NSString * currentVersion = [NSLocalizedString(@"version", NULL) stringByAppendingFormat:@" %u.%u", g_gtarController.m_firmwareMajorVersion, g_gtarController.m_firmwareMinorVersion];
    
    _firmwareVersion = currentVersion;
        
    }else{
        
        _firmwareVersion = nil;
    }
    
    [self showHideFirmwareVersion];
}

- (void)showHideFirmwareVersion
{
    if(_firmwareVersion != nil){
        
        [_versionLabel setText:_firmwareVersion];
        [_updateButton setEnabled:YES];
        [_updateButton setAlpha:1.0];
        
    }else{
        
        [_versionLabel setText:NSLocalizedString(@"Unavailable", NULL)];
        [_updateButton setEnabled:NO];
        [_updateButton setAlpha:0.5];
    }
}

- (void)noUpdates
{
    [_updateButton setTitle:NSLocalizedString(@"UP TO DATE", NULL) forState:UIControlStateNormal];
    [_updateButton setEnabled:NO];
    [_updateButton setAlpha:0.5];
}

- (IBAction)settingsSelectorChanged:(id)sender
{
    if(_settingsSelector.selectedIndex == 0){
        
        // gtar
        [_gtarView setHidden:NO];
        [_calibrateView setHidden:YES];
        [_controlsView setHidden:YES];
        
    }else if(_settingsSelector.selectedIndex == 1){
        
        // calibrate
        [_gtarView setHidden:YES];
        [_calibrateView setHidden:NO];
        [_controlsView setHidden:YES];
        
    }else{
        
        // settings
        [_gtarView setHidden:YES];
        [_calibrateView setHidden:YES];
        [_controlsView setHidden:NO];
    }

}

- (IBAction)feedSwitchChanged:(id)sender
{
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [settings setBool:!_feedSwitch.isOn forKey:@"DisablePostToFeed"];
    
    [settings synchronize];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
