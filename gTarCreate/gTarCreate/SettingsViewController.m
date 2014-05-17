//
//  SettingsViewController.m
//  gTarCreate
//
//  Created by Idan Beck on 5/8/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import "SettingsViewController.h"

extern GtarController *g_gtarController;
BOOL g_fPendingAction = false;
unsigned char g_sensitivity[6];

@interface SettingsViewController () {
    NSLock *pendingLock;
}

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Attached gTar Controller Delegate to self
    g_gtarController.m_delegate = self;
    
    pendingLock = [NSLock new];
    memset(g_sensitivity, 0, sizeof(unsigned char) * 6);
    memset(m_sensitivity, 0, sizeof(unsigned char) * 6);
    memset(m_ctmatrix, 0, sizeof(unsigned char) * 6 * 6);
    
    m_selectedRow = -1;
    m_selectedCol = -1;
    m_selectedSensString = -1;
    
    m_fPendingRequest = false;
    
    // Set up the CT buttons
    int rowDiv = (_m_piezoCTView.frame.size.height / 6.0f);
    int colDiv = (_m_piezoCTView.frame.size.width / 6.0f);
    
    for(int i = 0; i < 6; i++) {
        for(int j = 0; j < 6; j++) {
            CGRect newFrame = CGRectMake(i * colDiv, j * rowDiv, colDiv, rowDiv);
            m_ppCTSettingsButtons[i][j] = [[UIButton alloc] initWithFrame:newFrame];
            [m_ppCTSettingsButtons[i][j] setTitle:[[NSString alloc] initWithFormat:@"%d", [g_gtarController GetCTMatrixRow:i Column:j]] forState:UIControlStateNormal];
            [m_ppCTSettingsButtons[i][j] addTarget:self action:@selector(OnCTButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [_m_piezoCTView addSubview:m_ppCTSettingsButtons[i][j]];
        }
    }
    
    // Set up the sensitivity buttons
    rowDiv = (_m_piezoSensView.frame.size.height / 6.0f);
    colDiv = (_m_piezoSensView.frame.size.width);
    for(int i = 0; i < 6; i++) {
        CGRect newFrame = CGRectMake(0.0f, i * rowDiv, colDiv, rowDiv);
        m_pSensSettingsButtons[i] = [[UIButton alloc] initWithFrame:newFrame];
        [m_pSensSettingsButtons[i] setTitle:[[NSString alloc] initWithFormat:@"%d", [g_gtarController GetSensitivityString:i]] forState:UIControlStateNormal];
        [m_pSensSettingsButtons[i] addTarget:self action:@selector(OnSensButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_m_piezoSensView addSubview:m_pSensSettingsButtons[i]];
    }
    
    // Select something (string 0 sensitivity
    m_selectedSensString = 0;
    [self UpdateSelectedView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - gTar Delegate Functions
- (void)receivedCTMatrixValue:(unsigned char)value row:(unsigned char)row col:(unsigned char)col {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        m_ctmatrix[col][row] = value;
        //[m_ppCTSettingsButtons[col][row] setAttributedTitle:NULL forState:UIControlStateNormal];
        //[m_ppCTSettingsButtons[col][row] setTitle:[[NSString alloc] initWithFormat:@"%d", value] forState:UIControlStateNormal];
    }];
}

- (void)receivedSensitivityValue:(unsigned char)value string:(unsigned char)str {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        m_sensitivity[str] = value;
        //[m_pSensSettingsButtons[str] setAttributedTitle:NULL forState:UIControlStateNormal];
        //[m_pSensSettingsButtons[str] setTitle:[[NSString alloc] initWithFormat:@"%d", value] forState:UIControlStateNormal];
    }];
}

- (void)receivedPiezoWindow:(unsigned char)value {
    // TODO: Set window
}

- (void)receivedCommitUserspaceAck:(unsigned char)status {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        m_fPendingRequest = false;
        [self OnLoadValuesClicked:NULL];
    }];
}

- (void)receivedResetUserspaceAck:(unsigned char)status {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        m_fPendingRequest = false;
        [self OnLoadValuesClicked:NULL];
    }];
}

- (void) UpdateViews {
    for(int i = 0; i < 6; i++) {
        for(int j = 0; j < 6; j++) {
            [m_ppCTSettingsButtons[j][i] setAttributedTitle:NULL forState:UIControlStateNormal];
            [m_ppCTSettingsButtons[j][i] setTitle:[[NSString alloc] initWithFormat:@"%d", [g_gtarController GetCTMatrixRow:i Column:j]] forState:UIControlStateNormal];
        }

        [m_pSensSettingsButtons[i] setAttributedTitle:NULL forState:UIControlStateNormal];
        [m_pSensSettingsButtons[i] setTitle:[[NSString alloc] initWithFormat:@"%d", [g_gtarController GetSensitivityString:i]] forState:UIControlStateNormal];
    }
}

- (void) loseFocusSelected {
    // De-focus other element
    if(m_selectedCol != -1 && m_selectedRow != -1) {
        [m_ppCTSettingsButtons[m_selectedCol][m_selectedRow] setBackgroundColor:[UIColor clearColor]];
        m_selectedRow = -1;
        m_selectedCol = -1;
    }
    else if(m_selectedSensString != -1){
        [m_pSensSettingsButtons[m_selectedSensString] setBackgroundColor:[UIColor clearColor]];
        m_selectedSensString = -1;
    }
}

- (void) UpdateSelectedView {
    if(m_selectedCol != -1 && m_selectedRow != -1) {
        [m_ppCTSettingsButtons[m_selectedCol][m_selectedRow] setAttributedTitle:NULL forState:UIControlStateNormal];
        [m_ppCTSettingsButtons[m_selectedCol][m_selectedRow] setTitle:[[NSString alloc] initWithFormat:@"%d", [g_gtarController GetCTMatrixRow:m_selectedRow Column:m_selectedCol]] forState:UIControlStateNormal];
        [m_ppCTSettingsButtons[m_selectedCol][m_selectedRow] setBackgroundColor:[UIColor greenColor]];
        
        // Load in value widget
        NSString *labelString = [[NSString alloc] initWithFormat:@"CT str:%d to %d", m_selectedRow, m_selectedCol];
        NSString *labelValue = [[NSString alloc] initWithFormat:@"%d", [g_gtarController GetCTMatrixRow:m_selectedRow Column:m_selectedCol]];
        [_m_selectedCtrlLabel setText:labelString];
        [_m_selectedCtrlValue setText:labelValue];
    }
    else if(m_selectedSensString != -1){
        [m_pSensSettingsButtons[m_selectedSensString] setAttributedTitle:NULL forState:UIControlStateNormal];
        [m_pSensSettingsButtons[m_selectedSensString] setTitle:[[NSString alloc] initWithFormat:@"%d", [g_gtarController GetSensitivityString:m_selectedSensString]] forState:UIControlStateNormal];
        [m_pSensSettingsButtons[m_selectedSensString] setBackgroundColor:[UIColor greenColor]];
        
        // Load in value widget
        NSString *labelString = [[NSString alloc] initWithFormat:@"String %d Sensitivity", m_selectedSensString];
        NSString *labelValue = [[NSString alloc] initWithFormat:@"%d", [g_gtarController GetSensitivityString:m_selectedSensString]];
        [_m_selectedCtrlLabel setText:labelString];
        [_m_selectedCtrlValue setText:labelValue];
    }
}

- (int) nudgeSelectedValuefIncrement:(BOOL)fIncrement {
    int retVal = -1;
    
    if(m_selectedCol != -1 && m_selectedRow != -1) {
        unsigned char curVal = [g_gtarController GetCTMatrixRow:m_selectedRow Column:m_selectedCol];
        curVal = (fIncrement == true) ? curVal + 5 : curVal - 5;
        
        // clamp
        if(curVal > 70)
            curVal = 70;
        else if(curVal < 30)
            curVal = 30;
        
        [g_gtarController sendPiezoCrossTalkMatrixRow:m_selectedRow Column:m_selectedCol value:curVal];
        retVal = curVal;
    }
    else if(m_selectedSensString != -1){
        unsigned char curVal = [g_gtarController GetSensitivityString:m_selectedSensString];
        curVal = (fIncrement == true) ? curVal + 1 : curVal - 1;
        
        // clamp
        if(curVal > 50)
            curVal = 50;
        else if(curVal < 3)
            curVal = 3;
        
        [g_gtarController sendPiezoSensitivityString:m_selectedSensString thresh:curVal];
        retVal = curVal;
    }
    
    [self UpdateSelectedView];
    return retVal;
}

# pragma mark - Button Handlers
#define SCAN_INT 0.05f

- (IBAction)OnCTButtonClicked:(id)sender {
    int row, col;
    BOOL fFound = false;
    
    if(g_gtarController.m_delegate != self)
        g_gtarController.m_delegate = self;
    
    for(int i = 0; i < 6; i++) {
        for(int j = 0; j < 6; j++) {
            if((id)(m_ppCTSettingsButtons[i][j]) == sender) {
                col = i;
                row = j;
                fFound = true;
                break;
            }
        }
        if(fFound)
            break;
    }
    
    NSLog(@"CT button clicked row %d col %d", row, col);
    [g_gtarController sendRequestPiezoCrossTalkMatrixRow:row Column:col];
    [NSThread sleepForTimeInterval:SCAN_INT];
    
    [self loseFocusSelected];
    
    // Update Display
    m_selectedRow = row;
    m_selectedCol = col;
    [self UpdateSelectedView];
}

- (IBAction)OnSensButtonClicked:(id)sender {
    int str;
    
    if(g_gtarController.m_delegate != self)
        g_gtarController.m_delegate = self;
    
    for(str = 0; str < 6; str++)
        if((id)(m_pSensSettingsButtons[str]) == sender)
            break;
    
    NSLog(@"Sens button clicked string %d", str);
    [g_gtarController sendRequestPiezoSensitivityString:str];
    [NSThread sleepForTimeInterval:SCAN_INT];
    
    [self loseFocusSelected];
    
    // Update Display
    m_selectedSensString = str;
    [self UpdateSelectedView];

}

- (IBAction)OnCommitFWClicked:(id)sender {
    NSLog(@"Commit FW");
    
    if(g_gtarController.m_delegate != self)
        g_gtarController.m_delegate = self;
    
    [g_gtarController sendRequestCommitUserspace];
}

- (IBAction)OnResetFactoryClicked:(id)sender {
    NSLog(@"Reset Userspace");
    
    if(g_gtarController.m_delegate != self)
        g_gtarController.m_delegate = self;
    
    [g_gtarController sendRequestResetUserspace];
}

- (IBAction)OnLoadValuesClicked:(id)sender {
    if(g_gtarController.m_delegate != self)
        g_gtarController.m_delegate = self;
    
    NSString *buttonText = [[_m_buttonLoadValues titleLabel] text];
    NSString *buttonTitle = [[NSString alloc] initWithString:buttonText];
    [_m_buttonLoadValues setTitle:@"" forState:UIControlStateNormal];
    
    for(int i = 0; i < 6; i++) {
        [g_gtarController sendRequestPiezoSensitivityString:i];
        [NSThread sleepForTimeInterval:SCAN_INT];

        for(int j = 0; j < 6; j++) {
            [g_gtarController sendRequestPiezoCrossTalkMatrixRow:i Column:j];
            [NSThread sleepForTimeInterval:SCAN_INT];
        }
    }
    
    [NSThread sleepForTimeInterval:SCAN_INT * 2];
    [self UpdateViews];
    
    [_m_buttonLoadValues setTitle:buttonTitle forState:UIControlStateNormal];
}

- (IBAction)OnIncButtonClicked:(id)sender {
    if(g_gtarController.m_delegate != self)
        g_gtarController.m_delegate = self;
    
    [self nudgeSelectedValuefIncrement:true];
}
 
- (IBAction)OnDecButtonClicked:(id)sender {
    if(g_gtarController.m_delegate != self)
        g_gtarController.m_delegate = self;
    
    [self nudgeSelectedValuefIncrement:false];
}

@end
