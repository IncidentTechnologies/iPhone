//
//  CustomInstrumentSelector.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/20/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "CustomInstrumentSelector.h"

#define GTAR_NUM_STRINGS 6
#define MAX_RECORD_SECONDS 3.5
#define RECORD_DRAW_INTERVAL 0.001
#define ADJUSTOR_SIZE 50.0

#define VIEW_CUSTOM_INST 0
#define VIEW_CUSTOM_NAME 1
#define VIEW_CUSTOM_RECORD 2

#define RECORD_STATE_OFF 0
#define RECORD_STATE_RECORDING 1
#define RECORD_STATE_RECORDED 2
#define RECORD_STATE_PLAYING 3

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

@implementation CustomInstrumentSelector

@synthesize isFirstLaunch;
@synthesize tutorialViewController;
@synthesize viewFrame;
@synthesize instName;
@synthesize sampleTable;
@synthesize stringTable;
@synthesize sampleLibraryTitle;
@synthesize sampleLibraryArrow;
@synthesize cancelButton;
@synthesize delegate;
@synthesize audio;
@synthesize nextButton;
@synthesize nextButtonArrow;
@synthesize recordButton;
@synthesize recordCircle;
@synthesize saveButton;
@synthesize nameField;
@synthesize customIcon;
@synthesize customIconButton;
@synthesize customIndicator;
//@synthesize recordBackButton;
@synthesize recordClearButton;
@synthesize recordRecordButton;
@synthesize recordSaveButton;
@synthesize recordActionView;
@synthesize recordProcessing;
@synthesize progressBarContainer;
@synthesize progressBar;
@synthesize recordLine;
@synthesize playBar;
@synthesize recordingNameField;
@synthesize horizontalAdjustor;


- (id)initWithFrame:(CGRect)frame
{
    
    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    CGRect wholeScreen = CGRectMake(0, 0, x, y);
    
    self = [super initWithFrame:wholeScreen];
    if (self) {
        
        // Black out the rest of the screen:
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        
        // Back button
        [self drawBackButtonWithX:frame.origin.x];
        
        // Init string colours
        colorList = [NSArray arrayWithObjects:
                     [UIColor colorWithRed:239/255.0 green:92/255.0 blue:53/255.0 alpha:1.0],
                     [UIColor colorWithRed:234/255.0 green:154/255.0 blue:41/255.0 alpha:1.0],
                     [UIColor colorWithRed:238/255.0 green:188/255.0 blue:53/255.0 alpha:1.0],
                     [UIColor colorWithRed:43/255.0 green:198/255.0 blue:34/255.0 alpha:1.0],
                     [UIColor colorWithRed:0/255.0 green:141/255.0 blue:218/255.0 alpha:1.0],
                     [UIColor colorWithRed:148/255.0 green:102/255.0 blue:177/255.0 alpha:1.0],
                     nil];
        
        viewFrame = frame;
        
        [self retrieveSampleList];
        
    }
    return self;
}

- (void)checkFirstLaunch
{
    // Check for first launch
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedCustom"]){
        isFirstLaunch = FALSE;
    }else{
        isFirstLaunch = TRUE;
    }
}

- (void)launchSelectorView
{
    
    // draw main window
    [self setBackgroundViewFromNib:@"CustomInstrumentSelector" withFrame:viewFrame andRemove:nil forViewState:VIEW_CUSTOM_INST];
    
    [self initSubtables];
    
    [self checkFirstLaunch];
    
    if(isFirstLaunch){
        [self launchFTUTutorial];
    }
}

- (int)countSampleTree:(NSArray *)tree
{
    int count = 0;
    
    for(NSDictionary * dict in tree){
        if([dict valueForKey:@"Sampleset"] != nil){
            count += [[dict valueForKey:@"Sampleset"] count];
        }else if([dict valueForKey:@"Sectionset"]){
            count += [self countSampleTree:[dict valueForKey:@"Sectionset"]];
        }
    }
    
    return count;
}

- (int)countSamples
{
    return [self countSampleTree:sampleList];
}

- (void)initSubtables
{
    
    // Left sample table
    [sampleTable setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]];
    //[self drawSampleLibraryArrow];
    
    // Right string table
    [stringTable setBackgroundColor:[UIColor colorWithRed:81/255.0 green:81/255.0 blue:81/255.0 alpha:1.0]];
    
    // Next Button
    [self drawNextButtonArrow];
    [self checkIfAllStringsReady];
    
    // Record button
    [self drawRecordCircle];
    [self showHideButton:recordButton isHidden:NO withSelector:@selector(userDidLaunchRecord:)];
    
    // Sample Library Title
    if([sampleStack count] > 0){
        [self setSampleLibraryTitleFromStack];
        [sampleLibraryArrow setHidden:NO];
    }
    
}

#pragma mark - FTU Tutorial

-(void)launchFTUTutorial
{
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    DLog(@" *** Launch FTU Tutorial *** %f %f",x,y);
    
    if(tutorialViewController){
        [tutorialViewController clear];
    }
    
    CGRect tutorialFrame = CGRectMake(0,0,x,y);
    tutorialViewController = [[TutorialViewController alloc] initWithFrame:tutorialFrame andTutorial:@"Custom"];
    tutorialViewController.delegate = self;
    
    [self addSubview:tutorialViewController];
    [tutorialViewController launch];
}

- (void)endTutorialIfOpen
{
    [tutorialViewController end];
}

- (void)notifyTutorialEnded
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedCustom"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Custom Instruments Navigation

- (void)moveFrame:(CGRect)newFrame
{
    backgroundView.frame = newFrame;
}

- (void)userDidBack:(id)sender
{
    [self checkInitCustomSoundRecorder];
    if(![customSoundRecorder isRecording]){
        
        [customSoundRecorder releaseAudio];
        
        // back from save
        if(viewState == VIEW_CUSTOM_NAME){
            // remember instrument name
            instName = nameField.text;
        }
        // else back from record
        
        CGRect newFrame = backgroundView.frame;
        [self setBackgroundViewFromNib:@"CustomInstrumentSelector" withFrame:newFrame andRemove:backgroundView forViewState:VIEW_CUSTOM_INST];
        viewState = VIEW_CUSTOM_INST;
        
        [self initSubtables];
        
        [self loadCellsFromStrings];
    }
    
}

// fit any nib to window
-(void)setBackgroundViewFromNib:(NSString *)nibName withFrame:(CGRect)frame andRemove:(UIView *)removeView forViewState:(int)newViewState
{
    NSArray * nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    backgroundView = nibViews[0];
    backgroundView.frame = frame;
    [self initRoundedCorners];
    //backgroundView.layer.cornerRadius = 5.0;
    
    // TODO: draw corner radii
    
    viewState = newViewState;
    
    if(removeView){
        
        // used to switch between selector and namer
        [UIView animateWithDuration:0.5 animations:^(){
            removeView.alpha = 0.0f;
        } completion:^(BOOL finished){
            [removeView removeFromSuperview];
        }];
        
        backgroundView.alpha = 0.0f;
        [self addSubview:backgroundView];
        
        [UIView animateWithDuration:0.5 animations:^(){
            backgroundView.alpha = 1.0f;
        } completion:^(BOOL finished){
            
        }];
        
    }else{
        [self addSubview:backgroundView];
    }
}

- (void)drawBackButtonWithX:(float)x
{
    CGFloat cancelWidth = 40;
    CGFloat cancelHeight = 50;
    CGFloat insetX = 44;
    CGFloat insetY = 17;
    CGRect cancelFrame = CGRectMake(x-insetX, insetY, cancelWidth, cancelHeight);
    cancelButton = [[UIButton alloc] initWithFrame:cancelFrame];
    
    [cancelButton addTarget:self action:@selector(userDidCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: cancelButton];
    
    CGSize size = CGSizeMake(cancelButton.frame.size.width, cancelButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int buttonWidth = 20;
    int buttonX = cancelButton.frame.size.width-buttonWidth/2-5;
    int buttonY = 9;
    CGFloat buttonHeight = cancelButton.frame.size.height - 2*buttonY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 6.0);
    
    CGContextMoveToPoint(context, buttonX, buttonY);
    CGContextAddLineToPoint(context, buttonX-buttonWidth, buttonY+(buttonHeight/2));
    CGContextAddLineToPoint(context, buttonX, buttonY+buttonHeight);
    
    CGContextStrokePath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [cancelButton addSubview:image];
    
    UIGraphicsEndImageContext();
    
    
}

- (void)showHideButton:(UIButton *)button isHidden:(BOOL)hidden withSelector:(SEL)selector
{
    if(!hidden){
        [button setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }else{
        [button setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3] forState:UIControlStateNormal];
        [button removeTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}

// TODO: clicking on icon can cycle through options, for now all Icon_Custom
- (void)userDidNext:(id)sender
{
    // Save strings
    [self saveStringsFromCells];
    
    // Load nib
    CGRect newFrame = backgroundView.frame;
    [self setBackgroundViewFromNib:@"CustomInstrumentNamer" withFrame:newFrame andRemove:backgroundView forViewState:VIEW_CUSTOM_NAME];
    
    // Draw icon
    [self initCustomIcon];
    
    // Setup text field listener
    nameField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [nameField addTarget:self action:@selector(nameFieldStartEdit:) forControlEvents:UIControlEventEditingDidBegin];
    [nameField addTarget:self action:@selector(nameFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [nameField addTarget:self action:@selector(nameFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    nameField.delegate = self;
    [self resetNameFieldIfBlank];
    
    if(instName != nil){
        nameField.text = instName;
    }
    
    // Save?
    [self checkIfNameReady];
}

#pragma mark - Custom Instruments Save Page

- (void)initCustomIcon
{
    if(!customIconSet){
        customIconSet = [[NSArray alloc] initWithObjects:@"Icon_Custom",@"Icon_Piano",@"Icon_Violin",@"Icon_Vibraphone",@"Icon_Percussion",@"Icon_WubWub",@"Icon_Saxophone",@"Icon_Trombone",@"Icon_Trumpet",nil];
        customIconCounter = 0;
    }
    
    customIndicator.layer.cornerRadius = customIndicator.frame.size.width/2.0;
    
    CGRect imageFrame = CGRectMake(10, 10, customIcon.frame.size.width - 20, customIcon.frame.size.height - 20);
    
    [customIcon setBackgroundColor:[UIColor clearColor]];
    customIcon.layer.cornerRadius = 5.0;
    customIcon.layer.borderWidth = 1.0;
    customIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UIButton * button = [[UIButton alloc] initWithFrame:imageFrame];
    [button setBackgroundColor:[UIColor clearColor]];
    
    [button setImage:[UIImage imageNamed:[customIconSet objectAtIndex:customIconCounter]] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(changeCustomIcon) forControlEvents:UIControlEventTouchUpInside];
    
    customIconButton = button;
    
    [customIcon addSubview:button];
}

- (void)changeCustomIcon
{
    customIconCounter++;
    customIconCounter = customIconCounter % [customIconSet count];
    
    [customIconButton setImage:[UIImage imageNamed:[customIconSet objectAtIndex:customIconCounter]] forState:UIControlStateNormal];
}

- (void)userDidSave:(id)sender
{
    NSString * filename = nameField.text;
    
    [delegate saveCustomInstrumentWithStrings:stringSet andName:filename andStringPaths:stringPaths andIcon:[customIconSet objectAtIndex:customIconCounter]];
}

- (void)userDidCancel:(id)sender
{
    // make sure keyboard is hidden
    [nameField resignFirstResponder];
    
    if(viewState == VIEW_CUSTOM_RECORD || viewState == VIEW_CUSTOM_NAME){
        [self userDidBack:sender];
    }else{
        [delegate closeCustomInstrumentSelectorAndScroll:NO];
    }
}

#pragma mark - Name Field
- (void)nameFieldStartEdit:(id)sender
{
    DLog(@"Name field start edit");
    
    float frameOffset = 35.0;
    CGRect prevIconFrame = customIcon.frame;
    CGRect prevTextFrame = nameField.frame;
    
    CGRect newIconFrame = CGRectMake(prevIconFrame.origin.x,prevIconFrame.origin.y - frameOffset, prevIconFrame.size.width, prevIconFrame.size.height);
    
    CGRect newTextFrame = CGRectMake(prevTextFrame.origin.x,prevTextFrame.origin.y - frameOffset, prevTextFrame.size.width, prevTextFrame.size.height);
    
    // move text field into view
    [UIView animateWithDuration:0.5 animations:^(void){
        customIcon.frame = newIconFrame;
        nameField.frame = newTextFrame;
    }];
    
    // hide default
    // NSString * defaultText = [self generateNextCustomInstrumentName];
    
    if(![nameField.text isEqualToString:@""]){
        [self initAttributedStringForText:nameField];
    }
}

- (void)nameFieldDidChange:(id)sender
{
    int maxLength = 10;
    
    // check length
    if([nameField.text length] > maxLength){
        nameField.text = [nameField.text substringToIndex:maxLength];
    }else if([nameField.text length] == 1){
        [self initAttributedStringForText:nameField];
    }
    
    // enforce uppercase
    nameField.text = [nameField.text uppercaseString];
    
    [self checkIfNameReady];
    
}

-(void)nameFieldDoneEditing:(id)sender
{
    // return icon and name to position
    float frameOffset = 35.0;
    CGRect prevIconFrame = customIcon.frame;
    CGRect prevTextFrame = nameField.frame;
    
    CGRect newIconFrame = CGRectMake(prevIconFrame.origin.x,prevIconFrame.origin.y + frameOffset, prevIconFrame.size.width, prevIconFrame.size.height);
    
    CGRect newTextFrame = CGRectMake(prevTextFrame.origin.x,prevTextFrame.origin.y + frameOffset, prevTextFrame.size.width, prevTextFrame.size.height);
    
    // move text field into view
    [UIView animateWithDuration:0.5 animations:^(void){
        customIcon.frame = newIconFrame;
        nameField.frame = newTextFrame;
    }];
    
    // hide keyboard
    [nameField resignFirstResponder];
    
    if([self checkDuplicateCustomInstrumentName:nameField.text]){
        [self alertDuplicateTrackName];
    }
    
    [self resetNameFieldIfBlank];
    
    // hide styles
    [self clearAttributedStringForText:nameField];
    
}


-(void)resetNameFieldIfBlank
{
    NSString * nameString = nameField.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""] || [self checkDuplicateCustomInstrumentName:nameString]){
        nameField.text = [self generateNextCustomInstrumentName];
        [self checkIfNameReady];
    }
}

#pragma mark - Custom Instrument Naming
- (void)checkIfNameReady
{
    BOOL isReady = YES;
    NSString * nameString = nameField.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""]){
        isReady = NO;
    }else{
        isReady = YES;
    }
    
    if([self checkDuplicateCustomInstrumentName:nameString]){
        isReady = NO;
    }
    
    if(isReady){
        [self showHideButton:saveButton isHidden:NO withSelector:@selector(userDidSave:)];
        [saveButton.imageView setAlpha:1.0];
    }else{
        [self showHideButton:saveButton isHidden:YES withSelector:@selector(userDidSave:)];
        [saveButton.imageView setAlpha:0.3];
    }
}

- (NSString *)generateNextCustomInstrumentName
{
    NSMutableArray * customInstrumentOptions = [delegate getCustomInstrumentOptions];
    int customCount = 0;
    
    for(int i = 0; i < [customInstrumentOptions count]; i++){
        NSString * filename = [[customInstrumentOptions objectAtIndex:i] objectForKey:@"Name"];
        
        if(!([filename rangeOfString:@"TRACK"].location == NSNotFound)){
            
            NSString * customSuffix = [filename stringByReplacingCharactersInRange:[filename rangeOfString:@"TRACK"] withString:@""];
            int numFromSuffix = [customSuffix intValue];
            
            customCount = MAX(customCount,numFromSuffix);
        }
    }
    
    customCount++;
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPaddingCharacter:@"0"];
    [numberFormatter setPaddingPosition:NSNumberFormatterPadBeforePrefix];
    [numberFormatter setMinimumIntegerDigits:2];
    
    NSNumber * number = [NSNumber numberWithInt:customCount];
    
    NSString * numberString = [numberFormatter stringFromNumber:number];
    
    return [@"TRACK" stringByAppendingString:numberString];
}

- (BOOL)checkDuplicateCustomInstrumentName:(NSString *)filename
{
    NSMutableArray * customInstrumentOptions = [delegate getCustomInstrumentOptions];
    
    for(int i = 0; i < [customInstrumentOptions count]; i++){
        NSString * customFilename = [[customInstrumentOptions objectAtIndex:i] objectForKey:@"Name"];
        if([customFilename isEqualToString:filename]){
            return YES;
        }
    }
    
    return NO;
}

-(void)alertDuplicateTrackName
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Track Name" message:@"Cannot override an existing track." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

-(void)alertDuplicateSoundName
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Sound Name" message:@"Cannot override an existing sound." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}


#pragma mark - Recording Name Field
- (void)recordingNameFieldStartEdit:(id)sender
{
    [self initAttributedStringForText:recordingNameField];
}

- (void)initAttributedStringForText:(UITextField *)textField
{
    
    // Create attributed
    UIColor * blueColor = [UIColor colorWithRed:53/255.0 green:194/266.0 blue:241/255.0 alpha:1.0];
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:textField.text];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:40/255.0 green:47/255.0 blue:51/255.0 alpha:1.0] range:NSMakeRange(0, textField.text.length)];
    
    [textField setTextColor:blueColor];
    [textField setAttributedText:str];
}

- (void)clearAttributedStringForText:(UITextField *)textField
{
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:textField.text];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0, textField.text.length)];
    
    [textField setTextColor:[UIColor whiteColor]];
    [textField setAttributedText:str];
}

- (void)recordingNameFieldDidChange:(id)sender
{
    int maxLength = 15;
    
    if([recordingNameField.text length] > maxLength){
        recordingNameField.text = [recordingNameField.text substringToIndex:maxLength];
    }else if([recordingNameField.text length] == 1){
        [self initAttributedStringForText:recordingNameField];
    }
    
    // enforce capitalizing
    recordingNameField.text = [recordingNameField.text capitalizedString];
    
    [self checkIfRecordingNameReady];
}


-(void)recordingNameFieldDoneEditing:(id)sender
{
    // hide keyboard
    [recordingNameField resignFirstResponder];
    
    [self checkIfRecordingNameReady];
    
    if(!isRecordingNameReady){
        
        if([self checkDuplicateRecordingName:recordingNameField.text]){
            [self alertDuplicateSoundName];
        }
        
        [self resetRecordingNameIfBlank];
    }
    
    // hide styles
    [self clearAttributedStringForText:recordingNameField];
    
}

-(void)resetRecordingNameIfBlank
{
    NSString * nameString = recordingNameField.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""] || [self checkDuplicateRecordingName:nameString]){
        [self setRecordDefaultText];
        [self checkIfRecordingNameReady];
    }
}

- (void)setRecordDefaultText
{
    NSArray * tempList = [customSampleList[0] objectForKey:@"Sampleset"];
    
    DLog(@"CustomSampleList is %@",tempList);
    
    int customCount = 0;
    
    // Look through Samples, get the max CustomXXXX name and label +1
    for(NSString * filename in tempList){
        
        if(!([filename rangeOfString:@"Sound"].location == NSNotFound)){
            
            NSString * customSuffix = [filename stringByReplacingCharactersInRange:[filename rangeOfString:@"Sound"] withString:@""];
            int numFromSuffix = [customSuffix intValue];
            
            customCount = MAX(customCount,numFromSuffix);
        }
    }
    
    customCount++;
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPaddingCharacter:@"0"];
    [numberFormatter setPaddingPosition:NSNumberFormatterPadBeforePrefix];
    [numberFormatter setMinimumIntegerDigits:3];
    
    NSNumber * number = [NSNumber numberWithInt:customCount];
    
    NSString * numberString = [numberFormatter stringFromNumber:number];
    
    recordingNameField.text = [@"Sound" stringByAppendingString:numberString];
    
}


#pragma mark - Name Field Shared

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableCharacterSet * allowedCharacters = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowedCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [allowedCharacters formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"_-|"]];
    
    if([string rangeOfCharacterFromSet:allowedCharacters.invertedSet].location == NSNotFound){
        return YES;
    }
    return NO;
}

// single sample audio player
- (void)playAudioForFile:(NSString *)filename withCustomPath:(BOOL)useCustomPath
{
    
    NSString * path;
    
    if(filename == nil){
        DLog(@"Attempting to play nil file");
        return;
    }
    
    filename = [filename stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(useCustomPath){
        
        // different filetype and location
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Samples/" stringByAppendingString:[filename stringByAppendingString:@".m4a"]]];
        
    }else{
        
        path = [[NSBundle mainBundle] pathForResource:filename ofType:@"mp3"];
    }
    
    NSError * error = nil;
    NSURL * url = [NSURL fileURLWithPath:path];
    
    
    DLog(@"Playing URL %@",url);
    
    self.audio = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    [self.audio play];
}

#pragma mark - Record

-(void)checkInitCustomSoundRecorder
{
    if(!customSoundRecorder){
        customSoundRecorder = [[CustomSoundRecorder alloc] init];
        [customSoundRecorder setDelegate:self];
    }
}

-(void)userDidLaunchRecord:(id)sender
{
    // Init recorder
    [self checkInitCustomSoundRecorder];
    
    // Reset progress bar
    [self resetProgressBar];
    [self clearAudioDrawing];
    
    // Save strings
    [self saveStringsFromCells];
    
    // Load record frame
    CGRect newFrame = backgroundView.frame;
    [self setBackgroundViewFromNib:@"CustomInstrumentRecorder" withFrame:newFrame andRemove:backgroundView forViewState:VIEW_CUSTOM_RECORD];
    
    // Load active buttons
    [self drawRecordActionButton];
    [self hideRecordEditingButtons];
    [self changeRecordState:RECORD_STATE_OFF];
    [self showHideButton:recordClearButton isHidden:NO withSelector:@selector(userDidClearRecord)];
    [self showHideButton:recordRecordButton isHidden:NO withSelector:@selector(userDidTapRecord:)];
    [self setRecordDefaultText];
    
    // Setup text field listeners
    recordingNameField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [recordingNameField addTarget:self action:@selector(recordingNameFieldStartEdit:) forControlEvents:UIControlEventEditingDidBegin];
    [recordingNameField addTarget:self action:@selector(recordingNameFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [recordingNameField addTarget:self action:@selector(recordingNameFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    recordingNameField.delegate = self;
    isRecordingNameReady = TRUE;
    [recordingNameField setFont:[UIFont fontWithName:FONT_DEFAULT size:22.0]];
    
    // Init record editing buttons
    [self initRecordEditingButtons];
    
    // Clear any previous recording
    [self userDidClearRecord];
    
    [self checkIfRecordSaveReady];
}

-(void)userDidClearRecord
{
    if(playResetTimer == nil){
        [self changeRecordState:RECORD_STATE_OFF];
        [self hideRecordEditingButtons];
        
        [self resetProgressBar];
        [self resetPlayBar];
        [self clearAudioDrawing];
        
        [customSoundRecorder clearRecord];
        
        // Disable save
        isRecordingReady = FALSE;
        [self checkIfRecordSaveReady];
    }
}

-(void)userDidEndRecord
{
    // End progress bar drawing
    [progressBarTimer invalidate];
    progressBarTimer = nil;
    
    // Re-enable text field
    recordingNameField.enabled = YES;
    
    // End recording
    [recordTimer invalidate];
    recordTimer = nil;
    
    // End record
    [customSoundRecorder stopRecord];
    
    // Reset button
    [self changeRecordState:RECORD_STATE_RECORDED];
    
}

-(void)userDidCompleteRecord
{
    [self userDidEndRecord];
    
    [self showRecordEditingButtons];
    [horizontalAdjustor setBarDefaultWidth:progressBar.frame.size.width minWidth:ADJUSTOR_SIZE/2];
    
    // Init Sampler
    [self showRecordProcessing];
    
    audioLoadTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(initDrawAudio) userInfo:nil repeats:NO];
    
    // Resume playing
    if(pausePlaying){
        [delegate startAllPlaying];
        pausePlaying = NO;
    }
    
    // Enable save
    isRecordingReady = TRUE;
    [self checkIfRecordSaveReady];
}

-(void)initDrawAudio
{
    [self drawAudio];
    //[self performSelectorInBackground:@selector(drawAudio) withObject:nil];
    [self hideRecordProcessing];
}

-(void)drawAudio
{
    DLog(@"Draw audio for sample");
    
    [customSoundRecorder initAudioForSample];
    
    unsigned long int samplesize = [customSoundRecorder fetchAudioBufferSize];
    unsigned long int samplelength = samplesize / sizeof(float);
    float * buffer = [customSoundRecorder fetchAudioBuffer];
    
    float screenWidth = recordLine.frame.size.width;
    float midpointY = recordLine.frame.size.height/2;
    float f = 1.0;
    float scaleY = 200.0;
    
    CGSize size = CGSizeMake(recordLine.frame.size.width, recordLine.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, midpointY);
    
    for(long int x = 0; x <= screenWidth/f; x+=f){
        int n = x * samplelength / screenWidth;
        double point = midpointY-buffer[n]*scaleY;
        
        if(!isnan(point)){
            CGPathAddLineToPoint(path, NULL, ceil(x), point);
        }else{
            DLog(@"Error generating point");
        }
    }
    
    CGContextAddPath(context, path);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor);
    CGContextStrokePath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [recordLine addSubview:image];
    
    UIGraphicsEndImageContext();
    
    [audioLoadTimer invalidate];
    audioLoadTimer = nil;
}

-(void)clearAudioDrawing
{
    for(UIView * v in recordLine.subviews){
        [v removeFromSuperview];
    }
    
    [audioLoadTimer invalidate];
    audioLoadTimer = nil;
}

-(void)checkIfRecordSaveReady
{
    // Ensure both recording name and recording are ready
    if(isRecordingNameReady && isRecordingReady){
        DLog(@"Showing save");
        [self showHideButton:recordSaveButton isHidden:NO withSelector:@selector(userDidSaveRecord:)];
        recordSaveButton.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    }else{
        DLog(@"Hiding save");
        [self showHideButton:recordSaveButton isHidden:YES withSelector:@selector(userDidSaveRecord:)];
        recordSaveButton.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3];
    }
}

- (void)checkIfRecordingNameReady
{
    NSString * nameString = recordingNameField.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""]){
        isRecordingNameReady = NO;
    }else{
        isRecordingNameReady = YES;
    }
    
    if([self checkDuplicateRecordingName:nameString]){
        isRecordingNameReady = NO;
    }
    
    [self checkIfRecordSaveReady];
}

-(BOOL)checkDuplicateRecordingName:(NSString *)filename
{
    NSArray * tempList = [customSampleList[0] objectForKey:@"Sampleset"];
    
    for(int i = 0; i < [tempList count]; i++){
        if([tempList[i] isEqualToString:filename]){
            return YES;
        }
    }
    return NO;
}

-(void)userDidStartRecord
{
    // Pause any playing
    if([delegate checkIsPlaying]){
        if([delegate checkIsRecording]){
            pausePlaying = NO;
        }else{
            pausePlaying = YES;
        }
        
        
        [delegate stopAllPlaying];
    }else{
        pausePlaying = NO;
    }
    
    // Double check
    [self userDidEndRecord];
    [self hideRecordEditingButtons];
    
    // Start record
    [customSoundRecorder startRecord];
    [self changeRecordState:RECORD_STATE_RECORDING];
    
    // Prevent name editing
    recordingNameField.enabled = NO;
    
    // Schedule end of session
    recordTimer = [NSTimer scheduledTimerWithTimeInterval:MAX_RECORD_SECONDS target:self selector:@selector(userDidCompleteRecord) userInfo:nil repeats:NO];
    
    // Reset the progress
    [self resetProgressBar];
    [self clearAudioDrawing];
    
    // Draw progress bar
    progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:RECORD_DRAW_INTERVAL target:self selector:@selector(advanceProgressBar) userInfo:nil repeats:YES];
    
}

- (void)changeRecordState:(int)newState
{
    recordState = newState;
    
    CGSize size;
    CGContextRef context;
    UIImage * newImage;
    
    switch(recordState){
        case RECORD_STATE_OFF:
        {
            // RECORD BUTTON
            [recordRecordButton setBackgroundColor:[UIColor colorWithRed:235/255.0 green:33/255.0 blue:46/255.0 alpha:1.0]];
            [recordActionView setBackgroundColor:[UIColor whiteColor]];
            recordActionView.layer.cornerRadius = 10.0;
            [recordActionView setImage:nil];
            break;
        }
        case RECORD_STATE_RECORDING:
        {
            // STOP BUTTON
            [recordRecordButton setBackgroundColor:[UIColor colorWithRed:235/255.0 green:33/255.0 blue:46/255.0 alpha:1.0]];
            [recordActionView setBackgroundColor:[UIColor whiteColor]];
            recordActionView.layer.cornerRadius = 0.0;
            [recordActionView setImage:nil];
            break;
        }
        case RECORD_STATE_PLAYING:
        {
            // PAUSE BUTTON
            [recordRecordButton setBackgroundColor:[UIColor colorWithRed:244/255.0 green:151/255.0 blue:39/255.0 alpha:1.0]];
            [recordActionView setBackgroundColor:[UIColor clearColor]];
            recordActionView.layer.cornerRadius = 0.0;
            
            // draw pause button
            size = CGSizeMake(recordActionView.frame.size.width, recordActionView.frame.size.height);
            UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
            
            context = UIGraphicsGetCurrentContext();
            
            int pauseWidth = 7;
            
            CGFloat pauseHeight = 20;
            CGRect pauseFrameLeft = CGRectMake(recordActionView.frame.size.width/2 - pauseWidth - 2, 0, pauseWidth, pauseHeight);
            CGRect pauseFrameRight = CGRectMake(pauseFrameLeft.origin.x+pauseWidth+3, 0, pauseWidth, pauseHeight);
            
            CGContextAddRect(context,pauseFrameLeft);
            CGContextAddRect(context,pauseFrameRight);
            CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
            CGContextFillRect(context,pauseFrameLeft);
            CGContextFillRect(context,pauseFrameRight);
            
            newImage = UIGraphicsGetImageFromCurrentImageContext();
            
            [recordActionView setImage:newImage];
            
            UIGraphicsEndImageContext();
            
            break;
        }
        case RECORD_STATE_RECORDED:
        {
            // PLAY BUTTON;
            [recordRecordButton setBackgroundColor:[UIColor colorWithRed:105/255.0 green:214/255.0 blue:90/255.0 alpha:1.0]];
            [recordActionView setBackgroundColor:[UIColor clearColor]];
            recordActionView.layer.cornerRadius = 0.0;
            
            size = CGSizeMake(recordActionView.frame.size.width, recordActionView.frame.size.height);
            UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
            
            context = UIGraphicsGetCurrentContext();
            
            int playWidth = 15;
            int playX = (recordActionView.frame.size.width-playWidth)/2;
            int playY = 0;
            CGFloat playHeight = 20;
            
            CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            
            CGContextSetLineWidth(context, 2.0);
            
            CGContextMoveToPoint(context, playX, playY);
            CGContextAddLineToPoint(context, playX, playY+playHeight);
            CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
            CGContextClosePath(context);
            
            CGContextFillPath(context);
            
            newImage = UIGraphicsGetImageFromCurrentImageContext();
            [recordActionView setImage:newImage];
            
            UIGraphicsEndImageContext();
            
            break;
        }
    }
}

-(void)drawRecordActionButton
{
    int recordActionWidth = 20;
    int recordActionHeight = 20;
    CGRect recordActionButtonFrame = CGRectMake(recordRecordButton.frame.size.width/2-recordActionWidth/2, recordRecordButton.frame.size.height/2-recordActionHeight/2, recordActionWidth, recordActionHeight);
    
    recordActionView = [[UIImageView alloc] initWithFrame:recordActionButtonFrame];
    
    [recordRecordButton addSubview:recordActionView];
}

-(void)userDidTapRecord:(id)sender
{
    switch(recordState)
    {
        case 0: // off -> record
            [self userDidStartRecord];
            break;
            
        case 1: // recording -> recorded
            [self userDidCompleteRecord];
            break;
            
        case 2: // recorded -> playback
            [self userDidStartPlayback];
            break;
            
        case 3: // playing -> pause
            [self userDidPausePlayback];
            break;
    }
}

-(void)userDidSaveRecord:(id)sender
{
    DLog(@"User did save record");
    NSString * filename = recordingNameField.text;
    
    // Rename the file and save in Documents/Samples/ subdirectory
    [customSoundRecorder saveRecordingToFilename:filename];
    //[customSoundRecorder renameRecordingToFilename:filename];
    
    // Add to customSampleList.pList
    [self updateCustomSampleListWithSample:filename];
    
    // Go back
    [self userDidBack:sender];
}

-(BOOL)userDidDeleteRecord:(NSString *)filename
{
    // Remove from customSampleList
    NSArray * customSampleSet = [customSampleList[0] objectForKey:@"Sampleset"];
    for(int i = 0; i < [customSampleSet count]; i++){
        if([[customSampleSet objectAtIndex:i] isEqualToString:filename]){
            [[customSampleList[0] objectForKey:@"Sampleset"] removeObjectAtIndex:i];
        }
    }
    
    // Remove from sampleListSubset
    NSArray * sampleSubset = [sampleListSubset[0] objectForKey:@"Leafsampleset"];
    for(int i = 0; i < [sampleSubset count]; i++){
        if([[sampleSubset objectAtIndex:i] isEqualToString:filename]){
            [[sampleListSubset[0] objectForKey:@"Leafsampleset"] removeObjectAtIndex:i];
        }
    }
    
    // Remove from string list
    for(int i = GTAR_NUM_STRINGS-1; i >= 0; i--){
        
        CustomStringCell * cell = (CustomStringCell *)[stringTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if([cell.sampleFilename isEqualToString:filename]){
            [self deselectString:cell];
            cell.stringLabel.text = @"";
        }
    }
    
    // Remove from sampleList happens by reference
    
    // Remove the sound file
    [self checkInitCustomSoundRecorder];
    [customSoundRecorder deleteRecordingFilename:filename];
    
    // Check if custom sample set is empty
    if([customSampleSet count] == 0){
        
        [self removeCustomSampleList];
        
        [sampleList removeObjectAtIndex:0];
        
        [self reverseSampleStack:nil];
        
        return NO;
        
    }else{
        
        [self saveCustomSampleList];
        
        return YES;
    }
    
}

#pragma mark - Record Editing

-(void)initRecordEditingButtons
{
    horizontalAdjustor = [[HorizontalAdjustor alloc] initWithContainer:progressBarContainer background:backgroundView bar:progressBar];
    
    [horizontalAdjustor setDelegate:self];
    
    [horizontalAdjustor hideControls];
}

-(void)showRecordEditingButtons
{
    [horizontalAdjustor showControlsRelativeToView:progressBar];
}

-(void)hideRecordEditingButtons
{
    [horizontalAdjustor hideControls];
}

-(void)endPanLeft
{
    // Adjust the audio
    float totalLength = recordLine.frame.size.width;
    float lengthRemoved = progressBar.frame.origin.x;
    float sampleLength = [customSoundRecorder getSampleLength];
    float newStart = sampleLength*lengthRemoved/totalLength;
    newStart = MAX(1,newStart);
    
    [customSoundRecorder setSampleStart:newStart];
}

-(void)endPanRight
{
    // Adjust the audio
    float totalLength = recordLine.frame.size.width;
    float newLengthEnd = progressBar.frame.origin.x+progressBar.frame.size.width;
    float sampleLength = [customSoundRecorder getSampleLength];
    float newEnd = sampleLength*newLengthEnd/totalLength;
    newEnd = MIN(newEnd,sampleLength-1);
    
    [customSoundRecorder setSampleEnd:newEnd];
}

- (void)panRight:(float)diff
{
    
}

- (void)panLeft:(float)diff
{
    
}

#pragma mark - Record Processing

-(void)showRecordProcessing
{
    DLog(@"Show record processing");
    
    [recordProcessing setHidden:NO];
    [recordProcessing setText:@""];
    
    /*recordProcessingCounter = 0;
     [self animateRecordProcessing];
     
     if(recordProcessingTimer == nil){
     DLog(@"Init record processing timer");
     recordProcessingCounter = 0;
     [recordProcessing setHidden:NO];
     
     recordProcessingTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(animateRecordProcessing) userInfo:nil repeats:YES];
     }*/
    
}
/*
 -(void)animateRecordProcessing
 {
 
 UIView * recordProcessingInner = [[recordProcessing subviews] firstObject];
 
 recordProcessing.layer.borderWidth = 10.0;
 recordProcessing.layer.cornerRadius = recordProcessing.frame.size.width/2;
 recordProcessing.layer.borderColor = [UIColor whiteColor].CGColor;
 
 recordProcessingInner.layer.borderWidth = 5.0;
 recordProcessingInner.layer.cornerRadius = recordProcessingInner.frame.size.width/2;
 recordProcessingInner.layer.borderColor = [UIColor whiteColor].CGColor;
 
 [recordProcessing setAlpha:1.0];
 [recordProcessingInner setAlpha:0.5];
 
 //DLog(@"Switch on %i",recordProcessingCounter);
 
 switch(recordProcessingCounter){
 case 0:
 [recordProcessing setAlpha:0.0];
 [recordProcessingInner setAlpha:0.5];
 break;
 case 1:
 [recordProcessing setAlpha:0.0];
 [recordProcessingInner setAlpha:1.0];
 break;
 case 2:
 [recordProcessing setAlpha:0.5];
 [recordProcessingInner setAlpha:1.0];
 break;
 case 3:
 [recordProcessing setAlpha:1.0];
 [recordProcessingInner setAlpha:1.0];
 break;
 case 4:
 [recordProcessing setAlpha:0.5];
 [recordProcessingInner setAlpha:1.0];
 break;
 case 5:
 [recordProcessing setAlpha:0.0];
 [recordProcessingInner setAlpha:1.0];
 break;
 case 6:
 [recordProcessing setAlpha:0.0];
 [recordProcessingInner setAlpha:0.5];
 break;
 case 7:
 [recordProcessing setAlpha:0.0];
 [recordProcessingInner setAlpha:0.0];
 break;
 }
 
 DLog(@"Switched");
 
 recordProcessingCounter++;
 recordProcessingCounter %= 8;
 
 }
 */

-(void)hideRecordProcessing
{
    DLog(@"Hide record processing");
    //[recordProcessingTimer invalidate];
    //recordProcessingTimer = nil;
    
    [recordProcessing setHidden:YES];
    [recordProcessing setText:@""];
}

#pragma mark - Playback

-(void)playbackDidEnd
{
    // Make sure playbar goes all the way
    [self animatePlayBarToEnd];
    
    // Change the state
    timePlayed = 0;
    [self changeRecordState:RECORD_STATE_RECORDED];
    [self showRecordEditingButtons];
    [self playbackTimerReset];
    [self playResetTimerReset];
    isPaused = NO;
}

-(void)playbackTimerReset
{
    [playBarTimer invalidate];
    playBarTimer = nil;
}

-(void)playResetTimerReset
{
    [playResetTimer invalidate];
    playResetTimer = nil;
}

-(void)userDidStartPlayback
{
    // Wait for audio loading before allowing playback
    if(audioLoadTimer != nil){
        return;
    }
    
    if(!isPaused){
        [self resetPlayBar];
        
        // Call sound playback
        [customSoundRecorder startPlayback];
        
        // Draw play bar
        [self playbackTimerReset];
        playBarTimer = [NSTimer scheduledTimerWithTimeInterval:RECORD_DRAW_INTERVAL target:self selector:@selector(advancePlayBar) userInfo:nil repeats:YES];
        
    }else{
        
        // Resume playback
        [customSoundRecorder unpausePlayback];
        isPaused = NO;
        
    }
    
    // Change the state
    [self changeRecordState:RECORD_STATE_PLAYING];
    [self hideRecordEditingButtons];
    
    // Add a timeout to ensure recording finished acknowledged
    [self playResetTimerReset];
    float playLength = 1.1*([customSoundRecorder getSampleRelativeLength]/1000.0-timePlayed);
    playResetTimer = [NSTimer scheduledTimerWithTimeInterval:playLength target:self selector:@selector(playbackDidEnd) userInfo:nil repeats:YES];
    
}

-(void)userDidPausePlayback
{
    // Change the state
    [self changeRecordState:RECORD_STATE_RECORDED];
    [self showRecordEditingButtons];
    
    // Pause the recording
    [customSoundRecorder pausePlayback:timePlayed*1000.0];
    [self playResetTimerReset];
    isPaused = YES;
    
}

-(void)resetPlayBar
{
    [playBar setHidden:YES];
    [playBar setAlpha:1.0];
    
    CGRect newFrame = CGRectMake(progressBar.frame.origin.x,0,0,playBar.frame.size.height);
    
    playBar.frame = newFrame;
    
    playBarPercent = 0;
}

-(void)advancePlayBar
{
    if(recordState == RECORD_STATE_PLAYING){
        playBarPercent += RECORD_DRAW_INTERVAL/MAX_RECORD_SECONDS;
        [self movePlayBarToPercent:playBarPercent];
        
        timePlayed += RECORD_DRAW_INTERVAL;
    }
}

-(void)movePlayBarToPercent:(double)percent
{
    if(recordState == RECORD_STATE_PLAYING){
        
        [playBar setHidden:NO];
        
        int playBarX = MAX(progressBarContainer.frame.size.width*percent-playBar.frame.size.width,0);
        playBarX = MIN(playBarX,progressBar.frame.size.width-playBar.frame.size.width);
        
        CGRect newFrame = CGRectMake(progressBar.frame.origin.x+playBarX,0,5,progressBar.frame.size.height);
        
        playBar.frame = newFrame;
        
    }else{
        
        [self resetPlayBar];
        
    }
}

-(void)animatePlayBarToEnd
{
    
    CGRect newFrame = CGRectMake(progressBar.frame.origin.x+progressBar.frame.size.width-playBar.frame.size.width,0,5,progressBar.frame.size.height);
    
    [UIView animateWithDuration:0.3 animations:^(void){
        playBar.frame = newFrame;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.3 animations:^(void){
            [playBar setAlpha:0.0];
        } completion:^(BOOL finished){
            [self resetPlayBar];
        }];
    }];
}

#pragma mark - Progress Bar

-(void)resetProgressBar
{
    CGRect newProgressBarFrame = CGRectMake(0,0,0,progressBar.frame.size.height);
    CGRect newRecordLineFrame = CGRectMake(0,recordLine.frame.origin.y,0,recordLine.frame.size.height);
    
    progressBar.frame = newProgressBarFrame;
    recordLine.frame = newRecordLineFrame;
    
    progressBarPercent = 0;
    
}

-(void)advanceProgressBar
{
    if(recordState == RECORD_STATE_RECORDING){
        
        progressBarPercent += 1.1*(RECORD_DRAW_INTERVAL/MAX_RECORD_SECONDS);
        
        [self fillProgressBarToPercent:progressBarPercent];
        
    }
}

-(void)fillProgressBarToPercent:(double)percent
{
    if(recordState == RECORD_STATE_RECORDING){
        
        int progressBarX = MIN(progressBarContainer.frame.size.width*percent,progressBarContainer.frame.size.width);
        
        CGRect newProgressBarFrame = CGRectMake(0, 0, progressBarX, progressBar.frame.size.height);
        CGRect newRecordLineFrame = CGRectMake(0,recordLine.frame.origin.y,progressBarX,recordLine.frame.size.height);
        
        progressBar.frame = newProgressBarFrame;
        recordLine.frame = newRecordLineFrame;
        
    }
}

#pragma mark - Table View Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(tableView == sampleTable){
        return [self getNumSectionsInSampleTable];
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView == sampleTable){
        return [self getNumRowsForSection:section];
    }else{
        return GTAR_NUM_STRINGS;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == sampleTable){
        float tableHeight = sampleTable.frame.size.height;
        return tableHeight/5.0;
    }else{
        float tableHeight = stringTable.frame.size.height;
        return tableHeight/GTAR_NUM_STRINGS;
    }
}

- (NSString *)getSampleFromIndex:(NSIndexPath *)indexPath
{
    
    if([sampleStack count] == 0){
        
        // check sampleStack
        long sectionindex = indexPath.section;
        long i = indexPath.row;
        
        if(i == 0){
            return [sampleList[sectionindex] objectForKey:@"Section"];
        }
        
        NSArray * section = [sampleList[sectionindex] objectForKey:@"Sampleset"];
        
        return section[i-1];
        
    }else{
        
        NSDictionary * dict = [sampleListSubset objectAtIndex:indexPath.section];
        if([dict objectForKey:@"Sampleset"] || [dict objectForKey:@"Sectionset"]){
            return [dict objectForKey:@"Section"];
        }else{
            return [[dict objectForKey:@"Leafsampleset"] objectAtIndex:indexPath.row];
        }
        
    }
}

- (int)getNumSectionsInSampleTable
{
    if([sampleStack count] == 0){
        
        return [sampleList count];
        
    }else{
        
        int sectionCount = 0;
        
        for(NSDictionary * dict in sampleListSubset){
            if([dict objectForKey:@"Section"]){
                sectionCount++;
            }
        }
        
        return MAX(sectionCount,1);
    }
}

- (int)getNumRowsForSection:(int)sectionIndex
{
    NSDictionary * dict;
    
    if([sampleStack count] == 0){
        dict = [sampleList objectAtIndex:sectionIndex];
    }else{
        dict = [sampleListSubset objectAtIndex:sectionIndex];
    }
    
    if([dict objectForKey:@"Sampleset"] || [dict objectForKey:@"Sectionset"]){
        return 1;
    }else{
        return [[dict objectForKey:@"Leafsampleset"] count];
    }
}

- (void)buildNewSampleSubset
{
    sampleListSubset = [[NSMutableArray alloc] initWithArray:sampleList copyItems:YES];
    
    for(int i = 0; i < [sampleStack count]; i++){
        
        for(int j = 0; j < [sampleListSubset count]; j++){
            
            if([[[sampleListSubset objectAtIndex:j] objectForKey:@"Section"] isEqualToString:[sampleStack objectAtIndex:i]]){
                
                NSMutableArray * newSectionset = [[NSMutableArray alloc] initWithArray:[[sampleListSubset objectAtIndex:j] objectForKey:@"Sectionset"] copyItems:YES];
                
                NSMutableArray * newSampleset = [[NSMutableArray alloc] initWithArray:[[sampleListSubset objectAtIndex:j] objectForKey:@"Sampleset"] copyItems:YES];
                
                [sampleListSubset removeAllObjects];
                [sampleListSubset addObjectsFromArray:newSectionset];
                
                // Leaf of the tree
                if([sampleListSubset count] == 0){
                    [sampleListSubset addObject:[NSMutableDictionary dictionaryWithObject:newSampleset forKey:@"Leafsampleset"]];
                }
            }
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // table init stuff
    if(tableView == stringTable && indexPath.row == 0){
        [stringTable registerNib:[UINib nibWithNibName:@"CustomStringCell" bundle:nil] forCellReuseIdentifier:@"StringCell"];
    }else if(tableView == sampleTable && indexPath.row == 0){
        [sampleTable registerNib:[UINib nibWithNibName:@"CustomSampleCell" bundle:nil] forCellReuseIdentifier:@"SampleCell"];
    }
    
    sampleTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    stringTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    sampleTable.separatorInset = UIEdgeInsetsZero;
    
    // do custom work
    if(tableView == sampleTable){
        
        // init cell
        static NSString * CellIdentifier = @"SampleCell";
        CustomSampleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) cell = [[CustomSampleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.parentCategory = [sampleStack lastObject];
        
        [cell.sampleTitle setText:[self getSampleFromIndex:indexPath]];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        [self clearImagesForCell:cell];
        if(indexPath.row == 0 && [self getNumSectionsInSampleTable] > 1){
            [self drawNextButtonArrowForCell:cell];
            [cell.sampleTitle setFont:[UIFont fontWithName:FONT_BOLD size:16.0]];
        }else{
            [cell.sampleTitle setFont:[UIFont fontWithName:FONT_DEFAULT size:15.0]];
        }
        
        if(selectedSampleCell == cell){
            // TODO: remember if selected on scroll
            [self toggleSampleCellAtIndexPath:indexPath];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setMultipleTouchEnabled:NO];
        
        return cell;
        
    }else{
        
        // init cell
        static NSString * CellIdentifier = @"StringCell";
        CustomStringCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) cell = [[CustomStringCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        // set background
        if(indexPath.row % 2 == 1){
            [cell setBackgroundColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0]];
        }else{
            [cell setBackgroundColor:[UIColor colorWithRed:81/255.0 green:81/255.0 blue:81/255.0 alpha:1.0]];
        }
        
        // customize cells
        cell.index = GTAR_NUM_STRINGS - indexPath.row - 1;
        
        if(cell.sampleFilename!= nil){
            cell.stringLabel.text = cell.sampleFilename;
        }else{
            cell.stringLabel.text = @"";
            cell.defaultFontColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3];
        }
        [cell.stringLabel setTextColor:cell.defaultFontColor];
        
        [cell.stringBox setBackgroundColor:colorList[cell.index]];
        [cell setStringColor:colorList[cell.index]];
        
        if(selectedStringCell == cell){
            [cell notifySelected:YES];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setMultipleTouchEnabled:NO];
        
        return cell;
        
    }
    
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == sampleTable && indexPath.row == 0 && [self getNumSectionsInSampleTable] > 1){
        
        // Sample section
        
        CustomSampleCell * cell = (CustomSampleCell *)[tableView cellForRowAtIndexPath:indexPath];
        NSString * newSection = cell.sampleTitle.text;
        
        [self pushToSampleStack:newSection];
        
        [self buildNewSampleSubset];
        
        [sampleTable reloadData];
        
    }else if(tableView == sampleTable && (indexPath.row > 0 || [self getNumSectionsInSampleTable] == 1)){
        
        // Sample
        
        [self toggleSampleCellAtIndexPath:indexPath];
        
    }else if(tableView == stringTable && indexPath.row < GTAR_NUM_STRINGS){
        
        // String
        
        [self toggleStringCellAtIndexPath:indexPath];
        
    }else{
        
        // Save
        return;
    }
    
    // join sample and string
    if(selectedSampleCell && selectedStringCell){
        
        BOOL useCustomPath = ([self isCustomInstrumentList]) ? TRUE : FALSE;
        
        // pass filename
        NSString * filename = selectedSampleCell.parentCategory;
        filename = [filename stringByAppendingString:@"_"];
        filename = [filename stringByAppendingString:selectedSampleCell.sampleTitle.text];
        [selectedStringCell updateFilename:filename isCustom:useCustomPath];
        
        // turn off sample to avoid reselecting
        [self styleSampleCell:nil turnOff:selectedSampleCell];
        selectedSampleCell = nil;
        
        if(![self checkIfAllStringsReady]){
            [self selectNextString:selectedStringCell];
        }
    }
}

- (void)selectNextString:(CustomStringCell *)cell
{
    int rowIndex = [stringTable indexPathForCell:cell].row;
    int sectionIndex = [stringTable indexPathForCell:cell].section;
    
    [self toggleStringCellAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]];
    
    [self toggleStringCellAtIndexPath:[NSIndexPath indexPathForRow:rowIndex+1 inSection:sectionIndex]];
    
}

- (void)deselectString:(CustomStringCell *)cell
{
    [cell notifySelected:NO];
    [cell updateFilename:nil isCustom:FALSE];
    [self toggleStringCellAtIndexPath:[stringTable indexPathForCell:cell]];
    
    // encapsulate this in cell
    cell.defaultFontColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3];
    [cell.stringLabel setTextColor:cell.defaultFontColor];
    
    [self checkIfAllStringsReady];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: change logic to test if custom sample
    if([self isCustomInstrumentList]){
        return YES;
    }else{
        return NO;
    }
}


- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self deleteCell:indexPath];
    }
}

- (void)deleteCell:(NSIndexPath *)pathToDelete
{
    DLog(@"Delete cell at section %i index %i",pathToDelete.section,pathToDelete.row);
    
    CustomSampleCell * cell = (CustomSampleCell *)[sampleTable cellForRowAtIndexPath:pathToDelete];
    
    NSString * filename = cell.sampleTitle.text;
    
    // Remove the data
    BOOL deleteCell = [self userDidDeleteRecord:filename];
    
    if(deleteCell){
        [sampleTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:pathToDelete] withRowAnimation:UITableViewRowAnimationTop];
    }
    
}

#pragma mark - Sampe Stack
- (void)pushToSampleStack:(NSString *)newSection
{
    //[sampleLibraryTitle setTitle:newSection forState:UIControlStateNormal];
    
    [sampleLibraryArrow setHidden:NO];
    
    [sampleStack addObject:newSection];
    
    [self setSampleLibraryTitleFromStack];
    
}

-(void)popFromSampleStack
{
    if([sampleStack count] > 0){
        
        NSString * oldSection = [sampleStack lastObject];
        [sampleStack removeObject:[sampleStack lastObject]];
        
        DLog(@"Removing current selection %@",oldSection);
    }
    
    if([sampleStack count] > 0){
        [self setSampleLibraryTitleFromStack];
        [sampleLibraryArrow setHidden:NO];
    }else{
        [self resetSampleLibraryTitle];
        [sampleLibraryArrow setHidden:YES];
    }
}

-(void)resetSampleLibraryTitle
{
    [sampleLibraryTitle setTitleEdgeInsets:UIEdgeInsetsMake(0, 14, 0, 0)];
    [sampleLibraryTitle setTitle:@"Sound Library" forState:UIControlStateNormal];
}

-(void)setSampleLibraryTitleFromStack
{
    int penultimateIndex = [sampleStack count] - 2;
    NSString * sampleTitle = @"";
    
    [sampleLibraryTitle setTitleEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
    
    if(penultimateIndex >= 0){
        
        if(penultimateIndex == 0){
            sampleTitle = @"/";
        }else{
            sampleTitle = @"../";
        }
        sampleTitle = [sampleTitle stringByAppendingString:[sampleStack objectAtIndex:penultimateIndex]];
        
    }
    
    sampleTitle = [sampleTitle stringByAppendingString:@"/"];
    sampleTitle = [sampleTitle stringByAppendingString:[sampleStack lastObject]];
    
    [sampleLibraryTitle setTitle:sampleTitle forState:UIControlStateNormal];
}

-(BOOL)isCustomInstrumentList
{
    for(NSString * s in sampleStack){
        if([s isEqualToString:@"Custom"]){
            return YES;
        }
    }
    
    return NO;
}

-(IBAction)reverseSampleStack:(id)sender
{
    DLog(@"Reverse sample stack");
    
    [self popFromSampleStack];
    
    DLog(@"Sample stack count is now %i",[sampleStack count]);
    
    [self buildNewSampleSubset];
    
    [sampleTable reloadData];
}

#pragma mark - Strings
- (void)saveStringsFromCells
{
    stringSet = [NSMutableArray array];
    stringPaths = [NSMutableArray array];
    
    for(int i = GTAR_NUM_STRINGS-1; i >= 0; i--){
        
        CustomStringCell * cell = (CustomStringCell *)[stringTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        if(cell.sampleFilename != nil){
            [stringSet addObject:cell.sampleFilename];
            
            // Determine which directory (and filetype) to use
            if(cell.useCustomPath){
                [stringPaths addObject:@"Custom"];
            }else{
                [stringPaths addObject:@"Default"];
            }
            
        }else{
            [stringSet addObject:@""];
            [stringPaths addObject:@""];
        }
    }
}

- (void)loadCellsFromStrings
{
    [stringTable reloadData];
    
    for(int i=0; i < GTAR_NUM_STRINGS; i++){
        
        CustomStringCell * cell = (CustomStringCell *)[stringTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        //DLog(@"Trying to update string %@ for cell %@",stringSet[GTAR_NUM_STRINGS-i-1],cell);
        
        if(![stringSet[GTAR_NUM_STRINGS-i-1] isEqualToString:@""]){
            
            BOOL useCustomPath = FALSE;
            if([stringPaths[GTAR_NUM_STRINGS-i-1] isEqualToString:@"Custom"]){
                useCustomPath = TRUE;
            }
            
            [cell updateFilename:stringSet[GTAR_NUM_STRINGS-i-1] isCustom:useCustomPath];
        }
    }
    
    [self checkIfAllStringsReady];
}


// determine whether to show Next/Save button
- (BOOL)checkIfAllStringsReady
{
    BOOL isReady = true;
    
    for(int i = 0; i < GTAR_NUM_STRINGS; i++){
        CustomStringCell * cell = (CustomStringCell *)[stringTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        isReady = isReady && [cell isSet];
    }
    
    if(isReady){
        [self showHideButton:nextButton isHidden:NO withSelector:@selector(userDidNext:)];
        [nextButton.imageView setAlpha:1.0];
        [nextButtonArrow setAlpha:1.0];
    }else{
        [self showHideButton:nextButton isHidden:YES withSelector:@selector(userDidNext:)];
        [nextButton.imageView setAlpha:0.3];
        [nextButtonArrow setAlpha:0.3];
    }
    
    return isReady;
}

#pragma mark - Drawing
- (void)initRoundedCorners
{
    UIBezierPath * pathRecord = [UIBezierPath bezierPathWithRoundedRect:backgroundView.bounds byRoundingCorners:(UIRectCornerAllCorners) cornerRadii:CGSizeMake(5.0,5.0)];
    
    [self drawShapedView:backgroundView withBezierPath:pathRecord];
    
}

-(void)drawShapedView:(UIView *)view withBezierPath:(UIBezierPath *)bezierPath
{
    CAShapeLayer * bodyLayer = [CAShapeLayer layer];
    
    [bodyLayer setPath:bezierPath.CGPath];
    view.layer.mask = bodyLayer;
    view.clipsToBounds = YES;
    view.layer.masksToBounds = YES;
    
}

- (void)drawSampleLibraryArrow
{
    CGSize size = CGSizeMake(sampleLibraryTitle.frame.size.width, sampleLibraryTitle.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 8;
    int playX = 23;
    int playY = 14;
    CGFloat playHeight = sampleLibraryTitle.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX-playWidth, playY+(playHeight/2));
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    
    CGContextStrokePath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    sampleLibraryArrow = image;
    
    [sampleLibraryTitle addSubview:image];
    [sampleLibraryArrow setAlpha:0.3];
    [sampleLibraryArrow setHidden:YES];
    
    UIGraphicsEndImageContext();
}

- (void)clearImagesForCell:(CustomSampleCell *)cell
{
    //cell.imageView.image = nil;
    [cell.sampleArrow setImage:nil];
}

- (void)drawNextButtonArrowForCell:(CustomSampleCell *)cell
{
    CGSize size = CGSizeMake(cell.sampleArrow.frame.size.width, cell.sampleArrow.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 8;
    int playX = 3;
    int playY = 14;
    CGFloat playHeight = cell.sampleArrow.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    
    CGContextStrokePath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    [cell.sampleArrow setImage:newImage];
    
    UIGraphicsEndImageContext();
}

- (void)drawNextButtonArrow
{
    
    CGSize size = CGSizeMake(nextButton.frame.size.width, nextButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 10;
    int playX = nextButton.frame.size.width/2 - playWidth/2 + 22;
    int playY = 14;
    CGFloat playHeight = nextButton.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 3.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    
    CGContextStrokePath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [image setAlpha:0.3];
    
    nextButtonArrow = image;
    
    [nextButton addSubview:image];
    
    UIGraphicsEndImageContext();
}

-(void)drawRecordCircle
{
    recordCircle.layer.cornerRadius = 7.5;
}

#pragma mark - Show/Hide/Highlight Sample Cells

- (void)fadeSampleCell
{
    [self styleSampleCell:nil turnOff:selectedSampleCell];
    selectedSampleCell = nil;
}

- (BOOL)toggleSampleCellAtIndexPath:(NSIndexPath *)indexPath
{
    CustomSampleCell * cell = (CustomSampleCell *)[sampleTable cellForRowAtIndexPath:indexPath];
    
    if(selectedSampleCell == cell){
        [self styleSampleCell:nil turnOff:selectedSampleCell];
        selectedSampleCell = nil;
        return NO;
    }else{
        [self styleSampleCell:cell turnOff:selectedSampleCell];
        selectedSampleCell = cell;
        
        BOOL isCustom = ([self isCustomInstrumentList]) ? TRUE : FALSE;
        NSString * filename = [cell.parentCategory stringByAppendingString:@"_"];
        filename = [filename stringByAppendingString:cell.sampleTitle.text];
        [self playAudioForFile:filename withCustomPath:isCustom];
        
        return YES;
    }
}

- (BOOL)toggleStringCellAtIndexPath:(NSIndexPath *)indexPath
{
    
    CustomStringCell * cell = (CustomStringCell *)[stringTable cellForRowAtIndexPath:indexPath];
    
    if(selectedStringCell == cell){
        [cell notifySelected:NO];
        selectedStringCell = nil;
        return NO;
    }else{
        
        [selectedStringCell notifySelected:NO];
        [cell notifySelected:YES];
        
        selectedStringCell = cell;
        return YES;
    }
}

- (void)styleSampleCell:(CustomSampleCell *)cell turnOff:(UITableViewCell *)cellOff
{
    if(cell != nil){
        [cell.sampleTitle setTextColor:[UIColor whiteColor]];
        [cell setBackgroundColor:[UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0]];
        [cell.sampleTitle setBackgroundColor:[UIColor clearColor]];
    }
    if(cellOff != nil){
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(turnOffCellTimer:) userInfo:cellOff repeats:NO];
        
    }
}

- (void)turnOffCellTimer:(NSTimer *)timer
{
    
    CustomSampleCell * cellOff = (CustomSampleCell *)[timer userInfo];
    
    [cellOff.sampleTitle setTextColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0]];
    [cellOff setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0]];
    
}

- (void)retrieveSampleList
{
    
    // Init
    sampleList = [[NSMutableArray alloc] init];
    customSampleList = [[NSMutableArray alloc] init];
    sampleStack = [[NSMutableArray alloc] init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sampleList" ofType:@"plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        DLog(@"The sample plist exists");
    } else {
        DLog(@"The sample plist does not exist");
    }
    
    NSMutableDictionary * plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    // Check for local custom sample list
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    customSampleListPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"customSampleList.plist"];
    
    // Append a second local custom sounds pList to the regular sample list
    if ([fileManager fileExistsAtPath:customSampleListPath]) {
        DLog(@"The custom sample plist exists");
        NSMutableDictionary * customDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:customSampleListPath];
        
        [customSampleList addObjectsFromArray:[customDictionary objectForKey:@"Samples"]];
        
        // First section of the sampleList is the customSampleList
        [sampleList addObjectsFromArray:customSampleList];
        [sampleList addObjectsFromArray:[plistDictionary objectForKey:@"Samples"]];
        
        
    } else {
        DLog(@"The custom sample plist does not exist");
        
        sampleList = [plistDictionary objectForKey:@"Samples"];
        customSampleList = nil;
        
    }
    
}

- (void)removeCustomSampleList
{
    customSampleList = nil;
    
    DLog(@"Deleting custom sample list");
    
    NSError * err = NULL;
    NSFileManager * fm = [[NSFileManager alloc] init];
    
    BOOL result = [fm removeItemAtPath:customSampleListPath error:&err];
    
    if(!result)
        DLog(@"Error deleting");
}

- (void)updateCustomSampleListWithSample:(NSString *)filename
{
    
    DLog(@"Adding %@ to custom sample list",filename);
    
    // Init the custom sample list pList
    if(customSampleList == nil){
        
        NSArray * keys = [[NSArray alloc] initWithObjects:@"Sampleset",@"Section",nil];
        NSArray * objects = [[NSArray alloc] initWithObjects:[[NSMutableArray alloc] initWithObjects:filename,nil],@"Custom",nil];
        
        NSMutableDictionary * sampleDictionary = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];
        customSampleList = [[NSMutableArray alloc] initWithObjects:sampleDictionary, nil];
        
        NSArray * tempSampleList = [[NSArray alloc] initWithArray:sampleList];
        [sampleList removeAllObjects];
        [sampleList addObjectsFromArray:customSampleList];
        [sampleList addObjectsFromArray:tempSampleList];
        
    }else{
        // Beware, this also adds the filename to sampleList
        [[[customSampleList objectAtIndex:0] objectForKey:@"Sampleset"] addObject:filename];
        //[[[sampleList objectAtIndex:0] objectForKey:@"Sampleset"] addObject:filename];
        
    }
    
    // Also update the subset list for viewing if appropriate
    if([self isCustomInstrumentList]){
        [[[sampleListSubset objectAtIndex:0] objectForKey:@"Leafsampleset"] addObject:filename];
    }
    
    [self saveCustomSampleList];
}

- (void)saveCustomSampleList
{
    NSMutableDictionary * wrapperDict = [[NSMutableDictionary alloc] init];
    [wrapperDict setValue:customSampleList forKey:@"Samples"];
    
    DLog(@"Writing custom sample list to path %@",customSampleListPath);
    
    DLog(@"Custom sample list is %@",customSampleList);
    
    BOOL success = [wrapperDict writeToFile:customSampleListPath atomically:YES];
    
    if(success){
        DLog(@"Succeeded");
    }else{
        DLog(@"Failed");
    }
    
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
