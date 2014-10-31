//
//  SettingsViewController.m
//  keysPlay
//
//  Created by Kate Schnippering on 5/20/14.
//
//

#import "SettingsViewController.h"
#import "UIButton+Keys.h"

BOOL g_fPendingAction = false;
unsigned char g_sensitivity[6];

@interface SettingsViewController ()
{
    NSLock *pendingLock;
    UIColor * highlightColor;
}

@end

@implementation SettingsViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
        _firmwareVersion = nil;
        _serialNumber = nil;
        
        m_isLoading = NO;
        m_isRegistered = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeViews];
    
    [g_keysController addObserver:self];
    
    [_settingsSelector setTitles:[NSArray arrayWithObjects:NSLocalizedString(@"KEYS",NULL), NSLocalizedString(@"CONTROLS",NULL), nil]];
    [_topBar addShadow];
    
    [self updateKeysRegistered];
    [self updateCalibrate];
    [self updateFirmwareVersion];
    [self updateSerialNumber];
    
    [self initControls];
    
    [self initCalibration];
    
}

- (void)dealloc
{
    [g_keysController removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)localizeViews
{
    _settingsLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Settings", NULL)];
    
    _keysSerialLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Keys Serial", NULL)];
    _firmwareVersionLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Firmware", NULL)];
    
    [_updateButton setTitle:[[NSString alloc] initWithString:NSLocalizedString(@"CHECK FOR UPDATES", NULL)] forState:UIControlStateNormal];
    [_buttonCommitFW setTitle:[[NSString alloc] initWithString:NSLocalizedString(@"COMMIT", NULL)] forState:UIControlStateNormal];
    [_buttonResetFactory setTitle:[[NSString alloc] initWithString:NSLocalizedString(@"RESET", NULL)] forState:UIControlStateNormal];
    [_buttonLoadValues setTitle:[[NSString alloc] initWithString:NSLocalizedString(@"LOAD", NULL)] forState:UIControlStateNormal];
    
    _postToFeedLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"POST TO FEED", NULL)];
    _completeChordsLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"COMPLETE CHORDS", NULL)];
    _offLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"OFF", NULL)];
    _onLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"ON", NULL)];
}

- (void)initControls
{
    
    // Post To Feed?
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    BOOL disablePostToFeed = [settings boolForKey:@"DisablePostToFeed"];
    BOOL completeChords = [settings boolForKey:@"DisableCompleteChords"];
    
    [_feedSwitch setOn:!disablePostToFeed];
    [_chordSwitch setOn:!completeChords];
}

- (IBAction)backButtonClicked:(id)sender
{
    if(!m_isLoading){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)registerButtonClicked:(id)sender
{
    if(!m_isRegistered){
        [delegate registerDevice];
        
        [self updateKeysRegistered];
    }
}

- (IBAction)updateButtonClicked:(id)sender
{
    [g_keysController sendRequestFirmwareVersion];
}

- (void)updateKeysRegistered
{
    
    if([delegate isDeviceRegistered]){
        
        m_isRegistered = YES;
        
        [_registerButton setEnabled:NO];
        [_registerButton setTitle:[[NSString alloc] initWithString:NSLocalizedString(@"REGISTERED", NULL)] forState:UIControlStateNormal];
        [_registerButton setBackgroundColor:[UIColor colorWithRed:0/255.0 green:180/255.0 blue:50/255.0 alpha:1.0]];
        
        
    }else{
        
        m_isRegistered = NO;
        
        [_registerButton setEnabled:YES];
        [_registerButton setTitle:[[NSString alloc] initWithString:NSLocalizedString(@"REGISTER", NULL)] forState:UIControlStateNormal];
        [_registerButton setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:220/255.0 alpha:1.0]];
        
    }
}

- (void)updateSerialNumber
{
    
    if(g_keysController.connected){
        
        NSString * serialNumber = [g_keysController GetSerialNumber];
        
        _serialNumber = serialNumber;
        
    }else{
        
        _serialNumber = nil;
        
    }
    
    [self showHideSerialNumber];
}

- (void)showHideSerialNumber
{
    if(_serialNumber != nil){
        
        [_serialLabel setText:_serialNumber];
        
        if(!m_isRegistered){
            [_registerButton setEnabled:YES];
            [_registerButton setAlpha:1.0];
        }
        
    }else{
        
        [_serialLabel setText:NSLocalizedString(@"Unavailable", NULL)];
        
        if(!m_isRegistered){
            [_registerButton setEnabled:NO];
            [_registerButton setAlpha:0.5];
        }
        
    }
}

- (void)updateFirmwareVersion
{
    // Update in settings
    if(g_keysController.connected){
        
        NSString * currentVersion = [NSLocalizedString(@"version", NULL) stringByAppendingFormat:@" %u.%u", g_keysController.m_firmwareMajorVersion, g_keysController.m_firmwareMinorVersion];
        
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
        
        // keys
        [_keysView setHidden:NO];
        [_calibrateView setHidden:YES];
        [_controlsView setHidden:YES];
        
    }else{
        
        // settings
        [_keysView setHidden:YES];
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

- (IBAction)chordSwitchChanged:(id)sender
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [settings setBool:!_chordSwitch.isOn forKey:@"DisableCompleteChords"];
    
    [settings synchronize];
}

- (void)keysConnected
{
    [self updateKeysRegistered];
    [self updateCalibrate];
    [self updateFirmwareVersion];
    [self updateSerialNumber];
}

- (void)keysDisconnected
{
    [self updateKeysRegistered];
    [self updateCalibrate];
    [self updateFirmwareVersion];
    [self updateSerialNumber];
}

//
// Calibration
//

- (void)initCalibration
{
    
    pendingLock = [NSLock new];
    //memset(g_sensitivity, 0, sizeof(unsigned char) * 6);
    memset(m_sensitivity, 0, sizeof(unsigned char) * 6);
    memset(m_ctmatrix, 0, sizeof(unsigned char) * 6 * 6);
    
    m_selectedRow = -1;
    m_selectedCol = -1;
    m_selectedSensString = -1;
    
    m_fPendingRequest = false;
    
    highlightColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:2200/255.0 alpha:1.0];
    
    // Set up the CT buttons
    int rowDiv = (_piezoCTView.frame.size.height / 6.0f);
    int colDiv = (_piezoCTView.frame.size.width / 6.0f);
    
    for(int i = 0; i < 6; i++) {
        for(int j = 0; j < 6; j++) {
            CGRect newFrame = CGRectMake(i * colDiv, j * rowDiv, colDiv, rowDiv);
            m_ppCTSettingsButtons[i][j] = [[UIButton alloc] initWithFrame:newFrame];
            [m_ppCTSettingsButtons[i][j] setTitle:[[NSString alloc] initWithFormat:@"%d", [g_keysController GetCTMatrixRow:i Column:j]] forState:UIControlStateNormal];
            [m_ppCTSettingsButtons[i][j] addTarget:self action:@selector(OnCTButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [_piezoCTView addSubview:m_ppCTSettingsButtons[i][j]];
        }
    }
    
    // Set up the sensitivity buttons
    rowDiv = (_piezoSensView.frame.size.height / 6.0f);
    colDiv = (_piezoSensView.frame.size.width);
    for(int i = 0; i < 6; i++) {
        CGRect newFrame = CGRectMake(0.0f, i * rowDiv, colDiv, rowDiv);
        m_pSensSettingsButtons[i] = [[UIButton alloc] initWithFrame:newFrame];
        [m_pSensSettingsButtons[i] setTitle:[[NSString alloc] initWithFormat:@"%d", [g_keysController GetSensitivityString:i]] forState:UIControlStateNormal];
        [m_pSensSettingsButtons[i] addTarget:self action:@selector(OnSensButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_piezoSensView addSubview:m_pSensSettingsButtons[i]];
    }
    
    // Select something (string 0 sensitivity
    m_selectedSensString = 0;
    [self UpdateSelectedView];
}

- (void)updateCalibrate
{
    if(g_keysController.connected){
        
        [_incButton setEnabled:YES];
        [_decButton setEnabled:YES];
        [_buttonCommitFW setEnabled:YES];
        [_buttonLoadValues setEnabled:YES];
        [_buttonResetFactory setEnabled:YES];
        
        [_incButton setAlpha:1.0];
        [_decButton setAlpha:1.0];
        [_buttonCommitFW setAlpha:1.0];
        [_buttonLoadValues setAlpha:1.0];
        [_buttonResetFactory setAlpha:1.0];
        [_selectedCtrlLabel setAlpha:1.0];
        [_selectedCtrlValue setAlpha:1.0];
        [_piezoCTView setAlpha:1.0];
        [_piezoSensView setAlpha:1.0];
        
    }else{
        
        [_incButton setEnabled:NO];
        [_decButton setEnabled:NO];
        [_buttonCommitFW setEnabled:NO];
        [_buttonLoadValues setEnabled:NO];
        [_buttonResetFactory setEnabled:NO];
        
        [_incButton setAlpha:0.5];
        [_decButton setAlpha:0.5];
        [_buttonCommitFW setAlpha:0.5];
        [_buttonLoadValues setAlpha:0.5];
        [_buttonResetFactory setAlpha:0.5];
        [_selectedCtrlLabel setAlpha:0.5];
        [_selectedCtrlValue setAlpha:0.5];
        [_piezoCTView setAlpha:0.5];
        [_piezoSensView setAlpha:0.5];
        
    }
}

#pragma mark - keys Delegate Functions
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

- (void)receivedSerialNumber:(unsigned char *)number {
    
    [self updateSerialNumber];
    
}

- (void)receivedPiezoWindow:(unsigned char)value {
    // TODO: Set window
}



- (void)receivedCommitUserspaceAck:(unsigned char)status {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        m_fPendingRequest = false;
        [self stopAllLoading];
        [self OnLoadValuesClicked:NULL];
    }];
}

- (void)receivedResetUserspaceAck:(unsigned char)status {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        m_fPendingRequest = false;
        [self stopAllLoading];
        [self OnLoadValuesClicked:NULL];
    }];
}

- (void) UpdateViews {
    for(int i = 0; i < 6; i++) {
        for(int j = 0; j < 6; j++) {
            [m_ppCTSettingsButtons[j][i] setAttributedTitle:NULL forState:UIControlStateNormal];
            [m_ppCTSettingsButtons[j][i] setTitle:[[NSString alloc] initWithFormat:@"%d", [g_keysController GetCTMatrixRow:i Column:j]] forState:UIControlStateNormal];
        }
        
        [m_pSensSettingsButtons[i] setAttributedTitle:NULL forState:UIControlStateNormal];
        [m_pSensSettingsButtons[i] setTitle:[[NSString alloc] initWithFormat:@"%d", [g_keysController GetSensitivityString:i]] forState:UIControlStateNormal];
    }
    
    [self stopAllLoading];
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
        [m_ppCTSettingsButtons[m_selectedCol][m_selectedRow] setTitle:[[NSString alloc] initWithFormat:@"%d", [g_keysController GetCTMatrixRow:m_selectedRow Column:m_selectedCol]] forState:UIControlStateNormal];
        [m_ppCTSettingsButtons[m_selectedCol][m_selectedRow] setBackgroundColor:highlightColor];
        
        // Load in value widget
        NSString *labelString = [[NSString alloc] initWithFormat:@"CT str:%d to %d", m_selectedRow, m_selectedCol];
        NSString *labelValue = [[NSString alloc] initWithFormat:@"%d", [g_keysController GetCTMatrixRow:m_selectedRow Column:m_selectedCol]];
        [_selectedCtrlLabel setText:labelString];
        [_selectedCtrlValue setText:labelValue];
    }
    else if(m_selectedSensString != -1){
        [m_pSensSettingsButtons[m_selectedSensString] setAttributedTitle:NULL forState:UIControlStateNormal];
        [m_pSensSettingsButtons[m_selectedSensString] setTitle:[[NSString alloc] initWithFormat:@"%d", [g_keysController GetSensitivityString:m_selectedSensString]] forState:UIControlStateNormal];
        [m_pSensSettingsButtons[m_selectedSensString] setBackgroundColor:highlightColor];
        
        // Load in value widget
        NSString *labelString = [[NSString alloc] initWithFormat:NSLocalizedString(@"String %d Sensitivity", NULL), m_selectedSensString];
        NSString *labelValue = [[NSString alloc] initWithFormat:@"%d", [g_keysController GetSensitivityString:m_selectedSensString]];
        [_selectedCtrlLabel setText:labelString];
        [_selectedCtrlValue setText:labelValue];
    }
}

- (int) nudgeSelectedValuefIncrement:(BOOL)fIncrement {
    int retVal = -1;
    
    if(m_selectedCol != -1 && m_selectedRow != -1) {
        unsigned char curVal = [g_keysController GetCTMatrixRow:m_selectedRow Column:m_selectedCol];
        curVal = (fIncrement == true) ? curVal + 5 : curVal - 5;
        
        // clamp
        if(curVal > 70)
            curVal = 70;
        else if(curVal < 30)
            curVal = 30;
        
        [g_keysController sendPiezoCrossTalkMatrixRow:m_selectedRow Column:m_selectedCol value:curVal];
        retVal = curVal;
    }
    else if(m_selectedSensString != -1){
        unsigned char curVal = [g_keysController GetSensitivityString:m_selectedSensString];
        curVal = (fIncrement == true) ? curVal + 1 : curVal - 1;
        
        // clamp
        if(curVal > 50)
            curVal = 50;
        else if(curVal < 3)
            curVal = 3;
        
        [g_keysController sendPiezoSensitivityString:m_selectedSensString thresh:curVal];
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
    
    //if(g_keysController.m_delegate != self)
    //    g_keysController.m_delegate = self;
    
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
    
    DLog(@"CT button clicked row %d col %d", row, col);
    [g_keysController sendRequestPiezoCrossTalkMatrixRow:row Column:col];
    [NSThread sleepForTimeInterval:SCAN_INT];
    
    [self loseFocusSelected];
    
    // Update Display
    m_selectedRow = row;
    m_selectedCol = col;
    [self UpdateSelectedView];
}

- (IBAction)OnSensButtonClicked:(id)sender {
    int str;
    
    //if(g_keysController.m_delegate != self)
    //    g_keysController.m_delegate = self;
    
    for(str = 0; str < 6; str++)
        if((id)(m_pSensSettingsButtons[str]) == sender)
            break;
    
    DLog(@"Sens button clicked string %d", str);
    [g_keysController sendRequestPiezoSensitivityString:str];
    [NSThread sleepForTimeInterval:SCAN_INT];
    
    [self loseFocusSelected];
    
    // Update Display
    m_selectedSensString = str;
    [self UpdateSelectedView];
    
}

- (IBAction)OnCommitFWClicked:(id)sender {
    DLog(@"Commit FW");
    
    //if(g_keysController.m_delegate != self)
    //    g_keysController.m_delegate = self;
    
    // Loading
    [self startLoading:_buttonCommitFW];
    
    [g_keysController sendRequestCommitUserspace];
}

- (IBAction)OnResetFactoryClicked:(id)sender {
    DLog(@"Reset Userspace");
    
    //if(g_keysController.m_delegate != self)
    //    g_keysController.m_delegate = self;
    
    // Loading
    [self startLoading:_buttonResetFactory];
    
    [g_keysController sendRequestResetUserspace];
}

- (IBAction)OnLoadValuesClicked:(id)sender {
    //if(g_keysController.m_delegate != self)
    //    g_keysController.m_delegate = self;
    
    // Loading
    [self startLoading:_buttonLoadValues];
    
    NSString *buttonText = [[_buttonLoadValues titleLabel] text];
    NSString *buttonTitle = [[NSString alloc] initWithString:buttonText];
    [_buttonLoadValues setTitle:@"" forState:UIControlStateNormal];
    
    for(int i = 0; i < 6; i++) {
        [g_keysController sendRequestPiezoSensitivityString:i];
        [NSThread sleepForTimeInterval:SCAN_INT];
        
        for(int j = 0; j < 6; j++) {
            [g_keysController sendRequestPiezoCrossTalkMatrixRow:i Column:j];
            [NSThread sleepForTimeInterval:SCAN_INT];
        }
    }
    
    [NSThread sleepForTimeInterval:SCAN_INT * 2];
    [self UpdateViews];
    
    [_buttonLoadValues setTitle:buttonTitle forState:UIControlStateNormal];
}

- (IBAction)OnIncButtonClicked:(id)sender {
    //if(g_keysController.m_delegate != self)
    //    g_keysController.m_delegate = self;
    
    [self nudgeSelectedValuefIncrement:true];
}

- (IBAction)OnDecButtonClicked:(id)sender {
    //if(g_keysController.m_delegate != self)
    //    g_keysController.m_delegate = self;
    
    [self nudgeSelectedValuefIncrement:false];
}

#pragma mark - Loading
- (void)stopAllLoading
{
    m_isLoading = NO;
    
    [_buttonCommitFW setEnabled:YES];
    [_buttonLoadValues setEnabled:YES];
    [_buttonResetFactory setEnabled:YES];
    
    [_buttonCommitFW stopActivityIndicator];
    [_buttonLoadValues stopActivityIndicator];
    [_buttonResetFactory stopActivityIndicator];
    
    [_piezoCTView setUserInteractionEnabled:YES];
    [_piezoSensView setUserInteractionEnabled:YES];
    
    [_incButton setEnabled:YES];
    [_decButton setEnabled:YES];
}

- (void)startLoading:(UIButton *)button
{
    m_isLoading = YES;
    
    [button startActivityIndicator];
    
    if(button != _buttonCommitFW){
        [_buttonCommitFW setEnabled:NO];
    }
    
    if(button != _buttonResetFactory){
        [_buttonResetFactory setEnabled:NO];
    }
    
    if(button != _buttonLoadValues){
        [_buttonLoadValues setEnabled:NO];
    }
    
    [_piezoCTView setUserInteractionEnabled:NO];
    [_piezoSensView setUserInteractionEnabled:NO];
    
    [_incButton setEnabled:NO];
    [_decButton setEnabled:NO];
}

@end
