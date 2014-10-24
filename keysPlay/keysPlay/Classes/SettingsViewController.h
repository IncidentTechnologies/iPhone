//
//  SettingsViewController.h
//  keysPlay
//
//  Created by Kate Schnippering on 5/20/14.
//
//

#import <UIKit/UIKit.h>

#import "SelectorControl.h"
#import "UIView+Keys.h"
#import "KeysController.h"
#import "KeysControllerInternal.h"

@class SelectorControl;

extern KeysController *g_keysController;

@protocol SettingsDelegate <NSObject>

- (BOOL)isDeviceRegistered;
- (void)registerDevice;

@end

@interface SettingsViewController : UIViewController <KeysControllerObserver>
{
    
    UIButton *m_ppCTSettingsButtons[6][6];
    UIButton *m_pSensSettingsButtons[6];
    
    unsigned char m_sensitivity[6];
    unsigned char m_ctmatrix[6][6];
    
    int m_selectedRow;
    int m_selectedCol;
    int m_selectedSensString;
    
    BOOL m_fPendingRequest;
    BOOL m_isLoading;
    BOOL m_isRegistered;
}

@property (weak, nonatomic) id <SettingsDelegate> delegate;

@property (nonatomic, strong) NSString *firmwareVersion;
@property (nonatomic, strong) NSString *serialNumber;

@property (nonatomic, strong) IBOutlet UIView *topBar;
@property (nonatomic, strong) IBOutlet UIView *keysView;
@property (nonatomic, strong) IBOutlet UIView *calibrateView;
@property (nonatomic, strong) IBOutlet UIView *controlsView;
@property (nonatomic, strong) IBOutlet UILabel *settingsLabel;
@property (strong, nonatomic) IBOutlet SelectorControl *settingsSelector;

// keys
@property (nonatomic, strong) IBOutlet UILabel *keysSerialLabel;
@property (nonatomic, strong) IBOutlet UILabel *serialLabel;
@property (nonatomic, strong) IBOutlet UILabel *firmwareVersionLabel;
@property (nonatomic, strong) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *registerButton;
@property (nonatomic, strong) IBOutlet UIButton *updateButton;

// Controls
@property (strong, nonatomic) IBOutlet UILabel *postToFeedLabel;
@property (strong, nonatomic) IBOutlet UILabel *completeChordsLabel;
@property (strong, nonatomic) IBOutlet UILabel *offLabel;
@property (strong, nonatomic) IBOutlet UILabel *onLabel;
@property (strong, nonatomic) IBOutlet UISwitch *feedSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *chordSwitch;

// Calibration
@property (nonatomic, retain) IBOutlet UIButton *buttonCommitFW;
@property (nonatomic, retain) IBOutlet UIButton *buttonResetFactory;
@property (nonatomic, retain) IBOutlet UIButton *buttonLoadValues;

@property (nonatomic, retain) IBOutlet UILabel *selectedCtrlLabel;
@property (nonatomic, retain) IBOutlet UILabel *selectedCtrlValue;

@property (nonatomic, retain) IBOutlet UIButton *incButton;
@property (nonatomic, retain) IBOutlet UIButton *decButton;

@property (nonatomic, retain) IBOutlet UIView *piezoCTView;
@property (nonatomic, retain) IBOutlet UIView *piezoSensView;

// keys
- (IBAction)settingsSelectorChanged:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)registerButtonClicked:(id)sender;
- (IBAction)updateButtonClicked:(id)sender;

// Controls
- (IBAction)feedSwitchChanged:(id)sender;
- (IBAction)chordSwitchChanged:(id)sender;

// Calibrate
- (IBAction)OnCTButtonClicked:(id)sender;
- (IBAction)OnSensButtonClicked:(id)sender;
- (IBAction)OnIncButtonClicked:(id)sender;
- (IBAction)OnDecButtonClicked:(id)sender;

- (IBAction)OnLoadValuesClicked:(id)sender;
- (IBAction)OnResetFactoryClicked:(id)sender;
- (IBAction)OnCommitFWClicked:(id)sender;
- (IBAction)OnSetValueClicked:(id)sender;

// Calibrate Functions
- (void) UpdateViews;
- (void) loseFocusSelected;
- (void) UpdateSelectedView;
- (int) nudgeSelectedValuefIncrement:(BOOL)fIncrement;

// keys Delegate Functions
- (void)receivedCTMatrixValue:(unsigned char)value row:(unsigned char)row col:(unsigned char)col;
- (void)receivedSensitivityValue:(unsigned char)value string:(unsigned char)str;
- (void)receivedPiezoWindow:(unsigned char)value;
- (void)receivedCommitUserspaceAck:(unsigned char)status;
- (void)receivedResetUserspaceAck:(unsigned char)status;
- (void)receivedSerialNumber:(unsigned char *)number;

// keys Functions
- (void)updateSerialNumber;
- (void)updateFirmwareVersion;
- (void)noUpdates;


@end
