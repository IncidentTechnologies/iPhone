//
//  SettingsViewController.h
//  gTarCreate
//
//  Created by Idan Beck on 5/8/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

//#import <GtarController/GtarControllerInternal.h>
#import "GtarControllerInternal.h"
#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <GtarControllerObserver, GtarControllerDelegate>
{
    UIButton *m_ppCTSettingsButtons[6][6];
    UIButton *m_pSensSettingsButtons[6];

    unsigned char m_sensitivity[6];
    unsigned char m_ctmatrix[6][6];
    
    int m_selectedRow;
    int m_selectedCol;
    int m_selectedSensString;
    
    BOOL m_fPendingRequest;
}

@property (nonatomic, retain) IBOutlet UIButton *m_buttonCommitFW;
@property (nonatomic, retain) IBOutlet UIButton *m_buttonResetFactory;
@property (nonatomic, retain) IBOutlet UIButton *m_buttonLoadValues;

@property (nonatomic, retain) IBOutlet UILabel *m_selectedCtrlLabel;
@property (nonatomic, retain) IBOutlet UILabel *m_selectedCtrlValue;

@property (nonatomic, retain) IBOutlet UIButton *m_incButton;
@property (nonatomic, retain) IBOutlet UIButton *m_decButton;

@property (nonatomic, retain) IBOutlet UIView *m_piezoCTView;
@property (nonatomic, retain) IBOutlet UIView *m_piezoSensView;

- (IBAction)OnCTButtonClicked:(id)sender;
- (IBAction)OnSensButtonClicked:(id)sender;
- (IBAction)OnIncButtonClicked:(id)sender;
- (IBAction)OnDecButtonClicked:(id)sender;

- (IBAction)OnLoadValuesClicked:(id)sender;
- (IBAction)OnResetFactoryClicked:(id)sender;
- (IBAction)OnCommitFWClicked:(id)sender;
- (IBAction)OnSetValueClicked:(id)sender;

- (void) UpdateViews;
- (void) loseFocusSelected;
- (void) UpdateSelectedView;
- (int) nudgeSelectedValuefIncrement:(BOOL)fIncrement;

// gTar Delegate Functions
- (void)receivedCTMatrixValue:(unsigned char)value row:(unsigned char)row col:(unsigned char)col;
- (void)receivedSensitivityValue:(unsigned char)value string:(unsigned char)str;
- (void)receivedPiezoWindow:(unsigned char)value;
- (void)receivedCommitUserspaceAck:(unsigned char)status;
- (void)receivedResetUserspaceAck:(unsigned char)status;

@end
