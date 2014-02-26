//
//  CustomInstrumentSelector.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/20/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "CustomInstrumentSelector.h"

#define GTAR_NUM_STRINGS 6
#define MAX_RECORD_SECONDS 5
#define RECORD_DRAW_INTERVAL 0.01

#define VIEW_CUSTOM_INST 0
#define VIEW_CUSTOM_NAME 1
#define VIEW_CUSTOM_RECORD 2

#define RECORD_STATE_OFF 0
#define RECORD_STATE_RECORDING 1
#define RECORD_STATE_RECORDED 2
#define RECORD_STATE_PLAYING 3

#define RECORD_DEFAULT_TEXT @"New Recording"
#define INST_NAME_DEFAULT_TEXT @"NAME"

@implementation CustomInstrumentSelector

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
@synthesize backButton;
@synthesize nameField;
@synthesize customIcon;
//@synthesize recordBackButton;
@synthesize recordClearButton;
@synthesize recordRecordButton;
@synthesize recordSaveButton;
@synthesize recordActionView;
@synthesize progressBarContainer;
@synthesize progressBar;
@synthesize playBar;
@synthesize recordingNameField;


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
        
        // Cancel button
        [self drawCancelButtonWithX:x];
        
        // Init string colours
        colorList = [NSArray arrayWithObjects:
                     [UIColor colorWithRed:238/255.0 green:28/255.0 blue:36/255.0 alpha:1.0],
                     [UIColor colorWithRed:234/255.0 green:154/255.0 blue:0/255.0 alpha:1.0],
                     [UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0],
                     [UIColor colorWithRed:5/255.0 green:195/255.0 blue:77/255.0 alpha:1.0],
                     [UIColor colorWithRed:30/255.0 green:108/255.0 blue:213/255.0 alpha:1.0],
                     [UIColor colorWithRed:170/255.0 green:114/255.0 blue:233/255.0 alpha:1.0],
                     nil];
    
        viewFrame = frame;
        
        [self retrieveSampleList];
        
    }
    return self;
}

- (void)launchSelectorView
{
    
    // draw main window
    [self setBackgroundViewFromNib:@"CustomInstrumentSelector" withFrame:viewFrame andRemove:nil forViewState:VIEW_CUSTOM_INST];
    [self initSubtables];
    
}

- (void)userDidBack:(id)sender
{
    // Back from Save screen
    if(viewState == VIEW_CUSTOM_NAME){
        // remember instrument name
        instName = nameField.text;
    }
    // Otherwise Back from Record screen
        
    CGRect newFrame = backgroundView.frame;
    [self setBackgroundViewFromNib:@"CustomInstrumentSelector" withFrame:newFrame andRemove:backgroundView forViewState:VIEW_CUSTOM_INST];
    viewState = VIEW_CUSTOM_INST;
    
    [self initSubtables];
    
    [self loadCellsFromStrings];
}

// fit any nib to window
-(void)setBackgroundViewFromNib:(NSString *)nibName withFrame:(CGRect)frame andRemove:(UIView *)removeView forViewState:(int)newViewState
{
    NSArray * nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    backgroundView = nibViews[0];
    backgroundView.frame = frame;
    
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

// single sample audio player
- (void)playAudioForFile:(NSString *)filename withCustomPath:(BOOL)useCustomPath
{
    
    NSString * path;
    
    if(filename == nil){
        NSLog(@"Attempting to play nil file");
        return;        
    }
    
    if(useCustomPath){
        
        // different filetype and location
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Samples/" stringByAppendingString:[filename stringByAppendingString:@".m4a"]]];
        
    }else{
        
        path = [[NSBundle mainBundle] pathForResource:filename ofType:@"mp3"];
    }
    
    NSError * error = nil;
    NSURL * url = [NSURL fileURLWithPath:path];

    
    NSLog(@"Playing URL %@",url);
    
    self.audio = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    [self.audio play];
}

- (void)drawCancelButtonWithX:(float)x
{
    CGFloat cancelWidth = 35;
    CGFloat cancelHeight = 50;
    CGFloat inset = 5;
    CGRect cancelFrame = CGRectMake(x - inset - cancelWidth, 0, cancelWidth, cancelHeight);
    cancelButton = [[UIButton alloc] initWithFrame:cancelFrame];
    //[cancelButton setTitle:@"X" forState:UIControlStateNormal];
    //[cancelButton setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8] forState:UIControlStateNormal];
    //[cancelButton setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    //cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:30.0];
    
    [cancelButton addTarget:self action:@selector(userDidCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: cancelButton];
    
    CGSize size = CGSizeMake(cancelButton.frame.size.width, cancelButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 20;
    int playX = cancelButton.frame.size.width-playWidth/2-5;
    int playY = 10;
    CGFloat playHeight = cancelButton.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    CGContextAddLineToPoint(context, playX-playWidth, playY+(playHeight/2));
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
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
    
    [backButton addTarget:self action:@selector(userDidBack:) forControlEvents:UIControlEventTouchUpInside];
    [self drawBackButtonArrow];
    
    // Draw icon
    CGRect imageFrame = CGRectMake(10, 10, customIcon.frame.size.width - 20, customIcon.frame.size.height - 20);
    
    [customIcon setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5]];
    customIcon.layer.cornerRadius = 5.0;
    customIcon.layer.borderWidth = 1.0;
    customIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UIButton * button = [[UIButton alloc] initWithFrame:imageFrame];
    [button setBackgroundColor:[UIColor clearColor]];
    
    [button setImage:[UIImage imageNamed:@"Icon_Custom"] forState:UIControlStateNormal];
    
    [customIcon addSubview:button];
    
    // Setup text field listener
    nameField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [nameField addTarget:self action:@selector(nameFieldStartEdit:) forControlEvents:UIControlEventEditingDidBegin];
    [nameField addTarget:self action:@selector(nameFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [nameField addTarget:self action:@selector(nameFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    nameField.delegate = self;
    
    if(instName != nil){
        nameField.text = instName;
    }
    
    // Save?
    [self checkIfNameReady];
}

- (void)userDidSave:(id)sender
{
    NSString * filename = nameField.text;

    [delegate saveCustomInstrumentWithStrings:stringSet andName:filename andStringPaths:stringPaths];
}

- (void)userDidCancel:(id)sender
{
    // make sure keyboard is hidden
    [nameField resignFirstResponder];
    
    if(viewState == VIEW_CUSTOM_RECORD){
        [self userDidBack:sender];
    }else{
        [delegate closeCustomInstrumentSelectorAndScroll:NO];
    }
}

- (void)initSubtables
{
    
    // Left sample table
    [sampleTable setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]];
    [self drawSampleLibraryArrow];
    
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
        [sampleLibraryTitle setTitle:[sampleStack lastObject] forState:UIControlStateNormal];
        [sampleLibraryArrow setHidden:NO];
    }
    
}

- (void)moveFrame:(CGRect)newFrame
{
    backgroundView.frame = newFrame;
}

#pragma mark - Name Field
- (void)nameFieldStartEdit:(id)sender
{
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
    NSString * defaultText = INST_NAME_DEFAULT_TEXT;
    
    if([nameField.text isEqualToString:defaultText]){
        nameField.text = @"";
    }
}
- (void)nameFieldDidChange:(id)sender
{
    int maxLength = 10;
    
    // check length
    if([nameField.text length] > maxLength){
        nameField.text = [nameField.text substringToIndex:maxLength];
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
    
    [self resetNameFieldIfBlank];
}


-(void)resetNameFieldIfBlank
{
    NSString * nameString = nameField.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""]){
        nameField.text = INST_NAME_DEFAULT_TEXT;
    }
}


#pragma mark - Recording Name Field
- (void)recordingNameFieldStartEdit:(id)sender
{
    // hide default
    NSString * defaultText = RECORD_DEFAULT_TEXT;
    
    if([recordingNameField.text isEqualToString:defaultText]){
        recordingNameField.text = @"";
    }else{
        [self initRecordingNameAttributedString];
    }
    
}

- (void)initRecordingNameAttributedString
{
    
    // Create attributed
    UIColor * blueColor = [UIColor colorWithRed:0/255.0 green:161/266.0 blue:222/255.0 alpha:1.0];
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:recordingNameField.text];
    [str addAttribute:NSBackgroundColorAttributeName value:blueColor range:NSMakeRange(0, recordingNameField.text.length)];
    
    [recordingNameField setAttributedText:str];
}

- (void)clearRecordingNameAttributedString
{
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:recordingNameField.text];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0, recordingNameField.text.length)];
    
    [recordingNameField setAttributedText:str];
}

- (void)recordingNameFieldDidChange:(id)sender
{
    int maxLength = 15;
    
    if([recordingNameField.text length] > maxLength){
        recordingNameField.text = [recordingNameField.text substringToIndex:maxLength];
    }else if([recordingNameField.text length] == 1){
        [self initRecordingNameAttributedString];
    }
    
    // enforce capitalizing
    recordingNameField.text = [recordingNameField.text capitalizedString];
    
    [self checkIfRecordingNameReady];
}


-(void)recordingNameFieldDoneEditing:(id)sender
{
    // hide keyboard
    [nameField resignFirstResponder];
    
    [self checkIfRecordingNameReady];
    
    if(!isRecordingNameReady){
        [self resetRecordingNameIfBlank];
    }
    
    // hide styles
    [self clearRecordingNameAttributedString];
    
}

-(void)resetRecordingNameIfBlank
{
    NSString * nameString = recordingNameField.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""]){
        recordingNameField.text = RECORD_DEFAULT_TEXT;
    }
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

#pragma mark - Record

-(void)userDidLaunchRecord:(id)sender
{
    
    // Init recorder
    if(!customSoundRecorder){
        customSoundRecorder = [[CustomSoundRecorder alloc] init];
        [customSoundRecorder setDelegate:self];
    }
    
    // Reset progress bar
    [self resetProgressBar];
    
    // Save strings
    [self saveStringsFromCells];
    
    // Load record frame
    CGRect newFrame = backgroundView.frame;
    [self setBackgroundViewFromNib:@"CustomInstrumentRecorder" withFrame:newFrame andRemove:backgroundView forViewState:VIEW_CUSTOM_RECORD];

    // Load active buttons
    [self drawRecordActionButton];
    [self changeRecordState:RECORD_STATE_OFF];
    [self showHideButton:recordClearButton isHidden:NO withSelector:@selector(userDidClearRecord)];
    [self showHideButton:recordRecordButton isHidden:NO withSelector:@selector(userDidTapRecord:)];
    
    // Setup text field listeners
    recordingNameField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [recordingNameField addTarget:self action:@selector(recordingNameFieldStartEdit:) forControlEvents:UIControlEventEditingDidBegin];
    [recordingNameField addTarget:self action:@selector(recordingNameFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [recordingNameField addTarget:self action:@selector(recordingNameFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    recordingNameField.delegate = self;
    isRecordingNameReady = FALSE;
    
    
    // Clear any previous recording
    [self userDidClearRecord];
    
    [self checkIfRecordSaveReady];
}

-(void)userDidClearRecord
{
    NSLog(@"Clear recording");
    
    [self changeRecordState:RECORD_STATE_OFF];
    
    [self resetProgressBar];
    [self resetPlayBar];
    
    // Disable save
    isRecordingReady = FALSE;
    [self checkIfRecordSaveReady];
}

-(void)userDidEndRecord
{
    // End progress bar drawing
    [progressBarTimer invalidate];
    progressBarTimer = nil;
    
    // End recording
    [recordTimer invalidate];
    recordTimer = nil;
    
    // End record
    [customSoundRecorder stopRecord];
    
    // Reset button
    [self changeRecordState:RECORD_STATE_RECORDED];
    
    // Enable save
    isRecordingReady = TRUE;
    [self checkIfRecordSaveReady];
}

-(void)checkIfRecordSaveReady
{
    // Ensure both recording name and recording are ready
    if(isRecordingNameReady && isRecordingReady){
        NSLog(@"Showing save");
        [self showHideButton:recordSaveButton isHidden:NO withSelector:@selector(userDidSaveRecord:)];
        recordSaveButton.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    }else{
        NSLog(@"Hiding save");
        [self showHideButton:recordSaveButton isHidden:YES withSelector:@selector(userDidSaveRecord:)];
        recordSaveButton.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3];
    }
}

- (void)checkIfRecordingNameReady
{
    NSString * nameString = recordingNameField.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([nameString isEqualToString:RECORD_DEFAULT_TEXT] || [emptyName isEqualToString:@""]){
        isRecordingNameReady = FALSE;
    }else{
        isRecordingNameReady = TRUE;
    }
    
    [self checkIfRecordSaveReady];
}


-(void)userDidStartRecord
{
    
    // Double check
    [self userDidEndRecord];
    
    // Start record
    [customSoundRecorder startRecord];
    [self changeRecordState:RECORD_STATE_RECORDING];
    
    // Schedule end of session
    recordTimer = [NSTimer scheduledTimerWithTimeInterval:MAX_RECORD_SECONDS target:self selector:@selector(userDidEndRecord) userInfo:nil repeats:NO];
    
    // Reset the progress
    [self resetProgressBar];
    
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
            // RECORD BUTTON
            [recordRecordButton setBackgroundColor:[UIColor colorWithRed:235/255.0 green:33/255.0 blue:46/255.0 alpha:1.0]];
            [recordActionView setBackgroundColor:[UIColor whiteColor]];
            recordActionView.layer.cornerRadius = 10.0;
            [recordActionView setImage:nil];
            break;
        case RECORD_STATE_RECORDING:
            // STOP BUTTON
            [recordRecordButton setBackgroundColor:[UIColor colorWithRed:235/255.0 green:33/255.0 blue:46/255.0 alpha:1.0]];
            [recordActionView setBackgroundColor:[UIColor whiteColor]];
            recordActionView.layer.cornerRadius = 0.0;
            [recordActionView setImage:nil];
            break;
        case RECORD_STATE_PLAYING:
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
            
        case RECORD_STATE_RECORDED:
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
            [self userDidEndRecord];
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
    NSLog(@"User did save record");
    NSString * filename = recordingNameField.text;
    
    // Rename the file and save in Documents/Samples/ subdirectory
    [customSoundRecorder renameRecordingToFilename:filename];
    
    // Add to customSampleList.pList
    [self updateCustomSampleListWithSample:filename];
    
    // Go back
    [self userDidBack:sender];
}

#pragma mark - Playback

-(void)playbackDidEnd
{
    // Make sure playbar goes all the way
    [self animatePlayBarToEnd];
    
    // Change the state
    [self changeRecordState:RECORD_STATE_RECORDED];
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
    
    // Add a timeout to ensure recording finished acknowledged
    [self playResetTimerReset];
    playResetTimer = [NSTimer scheduledTimerWithTimeInterval:MAX_RECORD_SECONDS target:self selector:@selector(playbackDidEnd) userInfo:nil repeats:YES];
    
}

-(void)userDidPausePlayback
{
    // Change the state
    [self changeRecordState:RECORD_STATE_RECORDED];
    
    // Pause the recording
    [customSoundRecorder pausePlayback];
    [self playResetTimerReset];
    isPaused = YES;
    
}

-(void)resetPlayBar
{
    [playBar setHidden:YES];
    
    CGRect newFrame = CGRectMake(0,0,0,playBar.frame.size.height);
    
    playBar.frame = newFrame;
    
    playBarPercent = 0;
}

-(void)advancePlayBar
{
    if(recordState == RECORD_STATE_PLAYING){
        playBarPercent += RECORD_DRAW_INTERVAL/MAX_RECORD_SECONDS;
        [self movePlayBarToPercent:playBarPercent];
    }
}

-(void)movePlayBarToPercent:(double)percent
{
    if(recordState == RECORD_STATE_PLAYING){
        
        [playBar setHidden:NO];
        
        int playBarX = MAX(progressBarContainer.frame.size.width*percent-playBar.frame.size.width+10,0);
        playBarX = MIN(playBarX,progressBar.frame.size.width-playBar.frame.size.width);
        
        CGRect newFrame = CGRectMake(playBarX,0,10,progressBar.frame.size.height);
        
        playBar.frame = newFrame;
        
    }else{

        [self resetPlayBar];
        
    }
}

-(void)animatePlayBarToEnd
{
    
    CGRect newFrame = CGRectMake(progressBar.frame.size.width-playBar.frame.size.width,0,10,progressBar.frame.size.height);
    
    [UIView animateWithDuration:0.3 animations:^(void){
        playBar.frame = newFrame;
    }];
}

#pragma mark - Progress Bar

-(void)resetProgressBar
{
    CGRect newFrame = CGRectMake(0,0,0,progressBar.frame.size.height);
    
    progressBar.frame = newFrame;
    
    progressBarPercent = 0;
    
}

-(void)advanceProgressBar
{
    if(recordState == RECORD_STATE_RECORDING){
        
        progressBarPercent += RECORD_DRAW_INTERVAL/MAX_RECORD_SECONDS;
        
        [self fillProgressBarToPercent:progressBarPercent];
        
    }
}

-(void)fillProgressBarToPercent:(double)percent
{
    if(recordState == RECORD_STATE_RECORDING){
        
        int progressBarX = MIN(progressBarContainer.frame.size.width*percent,progressBarContainer.frame.size.width);
        
        CGRect newFrame = CGRectMake(0, 0, progressBarX, progressBar.frame.size.height);
        
        progressBar.frame = newFrame;
        
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
    }
    
    sampleTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    stringTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    sampleTable.separatorInset = UIEdgeInsetsZero;
    
    // do custom work
    if(tableView == sampleTable){
        
        // init cell
        static NSString * CellIdentifier = @"SampleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        [cell.textLabel setText:[self getSampleFromIndex:indexPath]];
        
        [cell.textLabel setTextColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0]];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
        
        [self clearImagesForCell:cell];
        if(indexPath.row == 0 && [self getNumSectionsInSampleTable] > 1){
            [self drawNextButtonArrowForCell:cell];
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Bold" size:16.0]];
        }else{
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
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
            cell.stringLabel.text = @"select a sound";
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
        
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString * newSection = cell.textLabel.text;
        
        [self pushToSampleStack:newSection];
        
        [self buildNewSampleSubset];
        
        [sampleTable reloadData];
        
    }else if(tableView == sampleTable && (indexPath.row > 0 || [self getNumSectionsInSampleTable] == 1)){
        
        // TODO: check table type
        [self toggleSampleCellAtIndexPath:indexPath];
        
    }else if(tableView == stringTable && indexPath.row < GTAR_NUM_STRINGS){
        
        [self toggleStringCellAtIndexPath:indexPath];

    }else{
        // save
        return;
    }
    
    // join sample and string
    if(selectedSampleCell && selectedStringCell){
        
        BOOL useCustomPath = ([self isCustomInstrumentList]) ? TRUE : FALSE;
        
        // pass filename
        [selectedStringCell updateFilename:selectedSampleCell.textLabel.text isCustom:useCustomPath];
        
        // turn off sample to avoid reselecting
        [self styleSampleCell:nil turnOff:selectedSampleCell];
        selectedSampleCell = nil;
        
        [self checkIfAllStringsReady];
    }
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
    NSLog(@"Delete cell at section %i index %i",pathToDelete.section,pathToDelete.row);
    // Remove from the data structure
    
    // Remove the data
    
    // Reload table
    //[sampleTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:pathToDelete] withRowAnimation:UITableViewRowAnimationTop];
    
}

#pragma mark - Sampe Stack
- (void)pushToSampleStack:(NSString *)newSection
{
    [sampleLibraryTitle setTitle:newSection forState:UIControlStateNormal];
    
    [sampleLibraryArrow setHidden:NO];
    
    [sampleStack addObject:newSection];
    
}

-(void)popFromSampleStack
{
    if([sampleStack count] > 0){
        
        NSString * oldSection = [sampleStack lastObject];
        [sampleStack removeObject:[sampleStack lastObject]];
        
        NSLog(@"Removing current selection %@",oldSection);
    }
    
    if([sampleStack count] > 0){
        [sampleLibraryTitle setTitle:[sampleStack lastObject] forState:UIControlStateNormal];
        [sampleLibraryArrow setHidden:NO];
    }else{
        [sampleLibraryTitle setTitle:@"Sample Library" forState:UIControlStateNormal];
        [sampleLibraryArrow setHidden:YES];
    }
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
    NSLog(@"reverse sample stack");
    
    [self popFromSampleStack];
    
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
        
        //NSLog(@"Trying to update string %@ for cell %@",stringSet[GTAR_NUM_STRINGS-i-1],cell);
        
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
- (void)checkIfAllStringsReady
{
    BOOL isReady = true;
    
    for(int i = 0; i < GTAR_NUM_STRINGS; i++){
        CustomStringCell * cell = (CustomStringCell *)[stringTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        isReady = isReady && [cell isSet];
    }
    
    if(isReady){
        [self showHideButton:nextButton isHidden:NO withSelector:@selector(userDidNext:)];
        [nextButtonArrow setAlpha:1.0];
    }else{
        [self showHideButton:nextButton isHidden:YES withSelector:@selector(userDidNext:)];
        [nextButtonArrow setAlpha:0.3];
    }
}

#pragma mark - Drawing
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
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    CGContextAddLineToPoint(context, playX-playWidth, playY+(playHeight/2));
    CGContextClosePath(context);
    
    
    CGContextFillPath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    sampleLibraryArrow = image;
    
    [sampleLibraryTitle addSubview:image];
    [sampleLibraryArrow setAlpha:0.7];
    [sampleLibraryArrow setHidden:YES];
    
    UIGraphicsEndImageContext();
}

- (void)clearImagesForCell:(UITableViewCell *)cell
{
    cell.imageView.image = nil;
}

- (void)drawNextButtonArrowForCell:(UITableViewCell *)cell
{
    NSLog(@"Draw next button arrow for cell");
    
    CGSize size = CGSizeMake(10, cell.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 8;
    int playX = 0;
    int playY = 14;
    CGFloat playHeight = cell.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    cell.imageView.image = newImage;
    
    //[cell addSubview:image];
    
    UIGraphicsEndImageContext();
}

- (void)drawNextButtonArrow
{
    
    CGSize size = CGSizeMake(nextButton.frame.size.width, nextButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 8;
    int playX = nextButton.frame.size.width/2 - playWidth/2 + 28;
    int playY = 14;
    CGFloat playHeight = nextButton.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [image setAlpha:0.3];
    
    nextButtonArrow = image;
    
    [nextButton addSubview:image];
    
    UIGraphicsEndImageContext();
}

- (void)drawBackButtonArrow
{
    
    CGSize size = CGSizeMake(backButton.frame.size.width, backButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 8;
    int playX = backButton.frame.size.width/2 - playWidth/2 - 20;
    int playY = 14;
    CGFloat playHeight = backButton.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    CGContextAddLineToPoint(context, playX-playWidth, playY+(playHeight/2));
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [backButton addSubview:image];
    
    UIGraphicsEndImageContext();
}

-(void)drawRecordCircle
{
    recordCircle.layer.cornerRadius = 7.5;
}

- (void)checkIfNameReady
{
    BOOL isReady = YES;
    NSString * nameString = nameField.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([nameString isEqualToString:INST_NAME_DEFAULT_TEXT] || [emptyName isEqualToString:@""]){
        isReady = NO;
    }else{
        isReady = YES;
    }
    
    if(isReady){
        [self showHideButton:saveButton isHidden:NO withSelector:@selector(userDidSave:)];
    }else{
        [self showHideButton:saveButton isHidden:YES withSelector:@selector(userDidSave:)];
    }
}

- (void)fadeSampleCell
{
    [self styleSampleCell:nil turnOff:selectedSampleCell];
    selectedSampleCell = nil;
}

- (BOOL)toggleSampleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [sampleTable cellForRowAtIndexPath:indexPath];
    
    if(selectedSampleCell == cell){
        [self styleSampleCell:nil turnOff:selectedSampleCell];
        selectedSampleCell = nil;
        return NO;
    }else{
        [self styleSampleCell:cell turnOff:selectedSampleCell];
        selectedSampleCell = cell;
        
        NSLog(@"PLAYING FILE ... %@.mp3",cell.textLabel.text);
        BOOL isCustom = ([self isCustomInstrumentList]) ? TRUE : FALSE;
        [self playAudioForFile:cell.textLabel.text withCustomPath:isCustom];
        
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

- (void)styleSampleCell:(UITableViewCell *)cell turnOff:(UITableViewCell *)cellOff
{
    if(cell != nil){
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell setBackgroundColor:[UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0]];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    }
    if(cellOff != nil){
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(turnOffCellTimer:) userInfo:cellOff repeats:NO];
        
    }
}

- (void)turnOffCellTimer:(NSTimer *)timer
{
    
    UITableViewCell * cellOff = (UITableViewCell *)[timer userInfo];
    
    [cellOff.textLabel setTextColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0]];
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
        NSLog(@"The sample plist exists");
    } else {
        NSLog(@"The sample plist does not exist");
    }
    
    NSMutableDictionary * plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    // Check for local custom sample list
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    customSampleListPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"customSampleList.plist"];
    
    // Append a second local custom sounds pList to the regular sample list
    if ([fileManager fileExistsAtPath:customSampleListPath]) {
        NSLog(@"The custom sample plist exists");
        NSMutableDictionary * customDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:customSampleListPath];
        
        [customSampleList addObjectsFromArray:[customDictionary objectForKey:@"Samples"]];
        
        // First section of the sampleList is the customSampleList
        [sampleList addObjectsFromArray:customSampleList];
        [sampleList addObjectsFromArray:[plistDictionary objectForKey:@"Samples"]];
        
        
    } else {
        NSLog(@"The custom sample plist does not exist");
        
        sampleList = [plistDictionary objectForKey:@"Samples"];
        customSampleList = nil;

    }
    
}

- (void)updateCustomSampleListWithSample:(NSString *)filename
{
    
    NSLog(@"Adding %@ to custom sample list",filename);
    
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

    [self saveCustomSampleList];
}

- (void)saveCustomSampleList
{
    NSMutableDictionary * wrapperDict = [[NSMutableDictionary alloc] init];
    [wrapperDict setValue:customSampleList forKey:@"Samples"];
    
    NSLog(@"Writing custom sample list to path %@",customSampleListPath);
    
    BOOL success = [wrapperDict writeToFile:customSampleListPath atomically:YES];
    
    if(success){
        NSLog(@"Succeeded");
    }else{
        NSLog(@"Failed");
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
