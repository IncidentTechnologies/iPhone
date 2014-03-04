//
//  CustomInstrumentSelector.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/20/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "CustomInstrumentSelector.h"

#define GTAR_NUM_STRINGS 6
#define MAX_RECORD_SECONDS 4
#define RECORD_DRAW_INTERVAL 0.001
#define ADJUSTOR_SIZE 30.0

#define VIEW_CUSTOM_INST 0
#define VIEW_CUSTOM_NAME 1
#define VIEW_CUSTOM_RECORD 2

#define RECORD_STATE_OFF 0
#define RECORD_STATE_RECORDING 1
#define RECORD_STATE_RECORDED 2
#define RECORD_STATE_PLAYING 3

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
@synthesize nameField;
@synthesize customIcon;
@synthesize customIconButton;
@synthesize customIndicator;
//@synthesize recordBackButton;
@synthesize recordClearButton;
@synthesize recordRecordButton;
@synthesize recordSaveButton;
@synthesize recordActionView;
@synthesize recordProcessingLabel;
@synthesize progressBarContainer;
@synthesize progressBar;
@synthesize recordLine;
@synthesize playBar;
@synthesize recordingNameField;
@synthesize leftAdjustor;
@synthesize rightAdjustor;


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
    
    // Draw icon
    [self initCustomIcon];
    
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

- (void)initCustomIcon
{
    if(!customIconSet){
        customIconSet = [[NSArray alloc] initWithObjects:@"Icon_Music",@"Icon_Piano",@"Icon_Violin",@"Icon_Vibraphone",@"Icon_Percussion",@"Icon_WubWub",@"Icon_Saxophone",@"Icon_Trombone", nil];
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
    }else{
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
    
    [self resetNameFieldIfBlank];
    
    // hide styles
    [self clearAttributedStringForText:nameField];
    
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
    [self initAttributedStringForText:recordingNameField];
}

- (void)initAttributedStringForText:(UITextField *)textField
{
    
    // Create attributed
    UIColor * blueColor = [UIColor colorWithRed:0/255.0 green:161/266.0 blue:222/255.0 alpha:1.0];
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:textField.text];
    [str addAttribute:NSBackgroundColorAttributeName value:blueColor range:NSMakeRange(0, textField.text.length)];
    
    [textField setAttributedText:str];
}

- (void)clearAttributedStringForText:(UITextField *)textField
{
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:textField.text];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0, textField.text.length)];
    
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
    [nameField resignFirstResponder];
    
    [self checkIfRecordingNameReady];
    
    if(!isRecordingNameReady){
        [self resetRecordingNameIfBlank];
    }
    
    // hide styles
    [self clearAttributedStringForText:recordingNameField];
    
}

-(void)resetRecordingNameIfBlank
{
    NSString * nameString = recordingNameField.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""]){
        [self setRecordDefaultText];
    }
}

- (void)setRecordDefaultText
{
    NSArray * tempList = [customSampleList[0] objectForKey:@"Sampleset"];
    
    NSLog(@"CustomSampleList is %@",tempList);
    
    int customCount = 0;
    
    // Look through Samples, get the max CustomXXXX name and label +1
    for(NSString * filename in tempList){
        
        if(!([filename rangeOfString:@"Custom"].location == NSNotFound)){
            
            NSString * customSuffix = [filename stringByReplacingCharactersInRange:[filename rangeOfString:@"Custom"] withString:@""];
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
    
    recordingNameField.text = [@"Custom" stringByAppendingString:numberString];
    
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
    [recordingNameField setFont:[UIFont systemFontOfSize:22.0]];
    
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
    [self setProgressBarDefaultWidth];
    
    // Init Sampler
    recordProcessingLabel.text = @"PROCESSING";
    audioLoadTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(initDrawAudio) userInfo:nil repeats:NO];
    
    // Enable save
    isRecordingReady = TRUE;
    [self checkIfRecordSaveReady];
}

-(void)initDrawAudio
{
    [self drawAudio];
    recordProcessingLabel.text = @"RECORD NEW";
}

-(void)drawAudio
{
    NSLog(@"Draw audio for sample");
    
    [customSoundRecorder initAudioForSample];
    
    unsigned long int samplesize = [customSoundRecorder fetchAudioBufferSize];
    unsigned long int samplelength = samplesize / sizeof(float);
    float sampleRate = samplelength/[customSoundRecorder fetchSampleRate];
    
    float * buffer = (float *)malloc(samplesize);
    buffer = [customSoundRecorder fetchAudioBuffer];
   
    // Draw sample
    float sampleInterval = 3*sampleRate;
    float midpointY = recordLine.frame.size.height/2;
    float intervalX = sampleInterval*recordLine.frame.size.width/samplelength;
    float scaleY = 1;
    
    // Check the max y
    //float maxY = 0;
    float avgY = 0;
    for(long int x = 0; x < samplelength; x+=sampleInterval){
        //maxY = MAX(maxY,ABS(buffer[x]));
        avgY += ABS(buffer[x]);
    }
    
    avgY /= samplelength;
    scaleY = 2000.0/(1.0-avgY);
    
    CGSize size = CGSizeMake(recordLine.frame.size.width, recordLine.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, midpointY);
    
    for(long int x = 0; x < samplelength; x+=sampleInterval){
        CGPathAddLineToPoint(path, NULL, x*intervalX, midpointY-buffer[x]*scaleY);
    }
    
    CGContextAddPath(context, path);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
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
    
    if([emptyName isEqualToString:@""]){
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
    [self hideRecordEditingButtons];
    
    // Start record
    [customSoundRecorder startRecord];
    [self changeRecordState:RECORD_STATE_RECORDING];
    
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
    NSLog(@"User did save record");
    NSString * filename = recordingNameField.text;
    
    // Rename the file and save in Documents/Samples/ subdirectory
    [customSoundRecorder renameRecordingToFilename:filename];
    
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
            cell.stringLabel.text = @"select a sound";
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
    leftAdjustor = [[UIButton alloc] initWithFrame:CGRectMake(-1*ADJUSTOR_SIZE/2,progressBarContainer.frame.size.height/2-ADJUSTOR_SIZE/2,ADJUSTOR_SIZE,ADJUSTOR_SIZE)];
    rightAdjustor = [[UIButton alloc] initWithFrame:CGRectMake(50,progressBarContainer.frame.size.height/2-ADJUSTOR_SIZE/2,ADJUSTOR_SIZE,ADJUSTOR_SIZE)];
    
    leftAdjustor.backgroundColor = [UIColor whiteColor];
    rightAdjustor.backgroundColor = [UIColor whiteColor];
    
    leftAdjustor.layer.cornerRadius = ADJUSTOR_SIZE/2;
    rightAdjustor.layer.cornerRadius = ADJUSTOR_SIZE/2;
    
    [leftAdjustor setAlpha:0.3];
    [rightAdjustor setAlpha:0.3];
    
    [leftAdjustor setHidden:YES];
    [rightAdjustor setHidden:YES];
    
    [progressBarContainer addSubview:leftAdjustor];
    [progressBarContainer addSubview:rightAdjustor];
    
    // Add gesture recognizers
    UIPanGestureRecognizer * leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecordLeft:)];
    UIPanGestureRecognizer * rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecordRight:)];
    
    [leftAdjustor addGestureRecognizer:leftPan];
    [rightAdjustor addGestureRecognizer:rightPan];
    
}

-(void)showRecordEditingButtons
{
    CGRect newLeftFrame = CGRectMake(progressBar.frame.origin.x-ADJUSTOR_SIZE/2,progressBar.frame.size.height/2-ADJUSTOR_SIZE/2,ADJUSTOR_SIZE,ADJUSTOR_SIZE);
    
    CGRect newRightFrame = CGRectMake(progressBar.frame.origin.x+progressBar.frame.size.width-ADJUSTOR_SIZE/2,progressBar.frame.size.height/2-ADJUSTOR_SIZE/2,ADJUSTOR_SIZE,ADJUSTOR_SIZE);
    
    [leftAdjustor setFrame:newLeftFrame];
    [rightAdjustor setFrame:newRightFrame];
    
    [leftAdjustor setHidden:NO];
    [rightAdjustor setHidden:NO];
}

-(void)hideRecordEditingButtons
{
    [leftAdjustor setHidden:YES];
    [rightAdjustor setHidden:YES];
}

-(void)panRecordLeft:(UIPanGestureRecognizer *)sender
{
    CGPoint newPoint = [sender translationInView:backgroundView];
    
    if([sender state] == UIGestureRecognizerStateBegan){
        leftFirstX = leftAdjustor.frame.origin.x;
        [leftAdjustor setAlpha:0.8];
    }
    
    float minX = 0 - ADJUSTOR_SIZE/2;
    float maxX = rightAdjustor.frame.origin.x - ADJUSTOR_SIZE/2;
    float newX = newPoint.x + leftFirstX;
    
    // wrap to boundary
    if(newX < minX || newX < minX+0.2*ADJUSTOR_SIZE/2){
        newX=minX;
    }
    
    if(newX >= minX && newX <= maxX){
        CGRect newLeftFrame = CGRectMake(newX,progressBar.frame.size.height/2-ADJUSTOR_SIZE/2,ADJUSTOR_SIZE,ADJUSTOR_SIZE);
        
        [leftAdjustor setFrame:newLeftFrame];
        
        CGRect newProgressBarFrame = CGRectMake(newX+ADJUSTOR_SIZE/2, 0, rightAdjustor.frame.origin.x-leftAdjustor.frame.origin.x, progressBar.frame.size.height);
        
        [progressBar setFrame:newProgressBarFrame];
    }
    
    if([sender state] == UIGestureRecognizerStateEnded){
        [leftAdjustor setAlpha:0.3];
        
        // Adjust the audio
        float totalLength = recordLine.frame.size.width;
        float lengthRemoved = progressBar.frame.origin.x;
        float sampleLength = [customSoundRecorder getSampleLength];
        float newStart = sampleLength*lengthRemoved/totalLength;
        newStart = MAX(1,newStart);
        
        [customSoundRecorder setSampleStart:newStart];
    }

}

-(void)panRecordRight:(UIPanGestureRecognizer *)sender
{
    CGPoint newPoint = [sender translationInView:backgroundView];
    
    if([sender state] == UIGestureRecognizerStateBegan){
        rightFirstX = rightAdjustor.frame.origin.x;
        [rightAdjustor setAlpha:0.8];
    }
    
    float minX = leftAdjustor.frame.origin.x + ADJUSTOR_SIZE/2;
    float maxX = progressBarDefaultWidth - ADJUSTOR_SIZE/2;
    float newX = newPoint.x + rightFirstX;
    
    // wrap to boundary
    if(newX > maxX || newX > maxX-0.2*ADJUSTOR_SIZE/2){
        newX=maxX;
    }
    
    if(newX >= minX && newX <= maxX){
        CGRect newRightFrame = CGRectMake(newX,progressBar.frame.size.height/2-ADJUSTOR_SIZE/2,ADJUSTOR_SIZE,ADJUSTOR_SIZE);
    
        [rightAdjustor setFrame:newRightFrame];
        
        CGRect newProgressBarFrame = CGRectMake(progressBar.frame.origin.x, 0, rightAdjustor.frame.origin.x-leftAdjustor.frame.origin.x, progressBar.frame.size.height);
        
        [progressBar setFrame:newProgressBarFrame];
    }
    
    if([sender state] == UIGestureRecognizerStateEnded){
        [rightAdjustor setAlpha:0.3];
        
        // Adjust the audio
        float totalLength = recordLine.frame.size.width;
        float newLengthEnd = progressBar.frame.origin.x+progressBar.frame.size.width;
        float sampleLength = [customSoundRecorder getSampleLength];
        float newEnd = sampleLength*newLengthEnd/totalLength;
        newEnd = MIN(newEnd,sampleLength-1);
        
        [customSoundRecorder setSampleEnd:newEnd];
    }
}

- (void)setProgressBarDefaultWidth
{
    progressBarDefaultWidth = progressBar.frame.size.width;
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
        
        progressBarPercent += RECORD_DRAW_INTERVAL/MAX_RECORD_SECONDS;
        
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
        
        [cell.sampleTitle setText:[self getSampleFromIndex:indexPath]];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        [self clearImagesForCell:cell];
        if(indexPath.row == 0 && [self getNumSectionsInSampleTable] > 1){
            [self drawNextButtonArrowForCell:cell];
            [cell.sampleTitle setFont:[UIFont fontWithName:@"Helvetica Bold" size:16.0]];
        }else{
            [cell.sampleTitle setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
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
        [selectedStringCell updateFilename:selectedSampleCell.sampleTitle.text isCustom:useCustomPath];
        
        // turn off sample to avoid reselecting
        [self styleSampleCell:nil turnOff:selectedSampleCell];
        selectedSampleCell = nil;
        
        [self checkIfAllStringsReady];
    }
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
    NSLog(@"Delete cell at section %i index %i",pathToDelete.section,pathToDelete.row);
    
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
    NSLog(@"Reverse sample stack");
    
    [self popFromSampleStack];
    
    NSLog(@"Sample stack count is now %i",[sampleStack count]);
    
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
    int playX = 0;
    int playY = 14;
    CGFloat playHeight = cell.sampleArrow.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    [cell.sampleArrow setImage:newImage];
    
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
    CustomSampleCell * cell = (CustomSampleCell *)[sampleTable cellForRowAtIndexPath:indexPath];
    
    if(selectedSampleCell == cell){
        [self styleSampleCell:nil turnOff:selectedSampleCell];
        selectedSampleCell = nil;
        return NO;
    }else{
        [self styleSampleCell:cell turnOff:selectedSampleCell];
        selectedSampleCell = cell;
        
        NSLog(@"PLAYING FILE ... %@.mp3",cell.sampleTitle.text);
        BOOL isCustom = ([self isCustomInstrumentList]) ? TRUE : FALSE;
        [self playAudioForFile:cell.sampleTitle.text withCustomPath:isCustom];
        
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

- (void)removeCustomSampleList
{
    customSampleList = nil;
    
    NSLog(@"Deleting custom sample list");
    
    NSError * err = NULL;
    NSFileManager * fm = [[NSFileManager alloc] init];
    
    BOOL result = [fm removeItemAtPath:customSampleListPath error:&err];
    
    if(!result)
        NSLog(@"Error deleting");
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
