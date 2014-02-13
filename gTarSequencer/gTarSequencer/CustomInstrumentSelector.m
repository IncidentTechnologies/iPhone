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

@implementation CustomInstrumentSelector

@synthesize viewFrame;
@synthesize instName;
@synthesize sampleTable;
@synthesize stringTable;
@synthesize cancelButton;
@synthesize delegate;
@synthesize audio;
@synthesize nextButton;
@synthesize recordButton;
@synthesize saveButton;
@synthesize backButton;
@synthesize nameField;
@synthesize customIcon;
@synthesize recordBackButton;
@synthesize recordClearButton;
@synthesize recordRecordButton;
@synthesize recordSaveButton;
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
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        // Cancel button
        [self drawCancelButtonWithX:x];
        
        // Init string colours
        colorList = [NSArray arrayWithObjects:
                     [UIColor colorWithRed:216/255.0 green:64/255.0 blue:64/255.0 alpha:1.0],
                     [UIColor colorWithRed:238/255.0 green:129/255.0 blue:13/255.0 alpha:1.0],
                     [UIColor colorWithRed:245/255.0 green:214/255.0 blue:9/255.0 alpha:1.0],
                     [UIColor colorWithRed:19/255.0 green:133/255.0 blue:4/255.0 alpha:1.0],
                     [UIColor colorWithRed:9/255.0 green:109/255.0 blue:245/255.0 alpha:1.0],
                     [UIColor colorWithRed:150/255.0 green:12/255.0 blue:238/255.0 alpha:1.0],
                     nil];
    
        viewFrame = frame;
        
        [self retrieveSampleList];
        
    }
    return self;
}

- (void)launchSelectorView
{
    
    // draw main window
    [self setBackgroundViewFromNib:@"CustomInstrumentSelector" withFrame:viewFrame andRemove:nil];
    [self initSubtables];
    
}

- (void)userDidBack:(id)sender
{
    // Back from Save screen
    if(sender == backButton){
        // remember instrument name
        instName = nameField.text;
    }
    // Otherwise Back from Record screen
        
    CGRect newFrame = backgroundView.frame;
    [self setBackgroundViewFromNib:@"CustomInstrumentSelector" withFrame:newFrame andRemove:backgroundView];
    
    [self initSubtables];
    
    [self loadCellsFromStrings];
}

// fit any nib to window
-(void)setBackgroundViewFromNib:(NSString *)nibName withFrame:(CGRect)frame andRemove:(UIView *)removeView
{
    
    NSArray * nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    backgroundView = nibViews[0];
    backgroundView.frame = frame;
    backgroundView.layer.cornerRadius = 5.0;
    
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
    CGFloat cancelWidth = 50;
    CGFloat cancelHeight = 50;
    CGFloat inset = 5;
    CGRect cancelFrame = CGRectMake(x - inset - cancelWidth, 0, cancelWidth, cancelHeight);
    cancelButton = [[UIButton alloc] initWithFrame:cancelFrame];
    [cancelButton setTitle:@"X" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:30.0];
    
    [cancelButton addTarget:self action:@selector(userDidCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: cancelButton];
    
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
    [self setBackgroundViewFromNib:@"CustomInstrumentNamer" withFrame:newFrame andRemove:backgroundView];
    
    saveButton.layer.cornerRadius = 5.0;
    backButton.layer.cornerRadius = 5.0;
    
    [backButton addTarget:self action:@selector(userDidBack:) forControlEvents:UIControlEventTouchUpInside];
    
    // Draw icon
    CGRect imageFrame = CGRectMake(10, 10, customIcon.frame.size.width - 20, customIcon.frame.size.height - 20);
    
    [customIcon setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5]];
    customIcon.layer.cornerRadius = 5.0;
    customIcon.layer.borderWidth = 1.0;
    customIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UIButton * button = [[UIButton alloc] initWithFrame:imageFrame];
    [button setBackgroundColor:[UIColor clearColor]];
    
    [button setImage:[UIImage imageNamed:@"Icon_Custom"] forState:UIControlStateNormal];
    //[button setImage:[UIImage imageNamed:@"Icon_Custom"] forState:UIControlStateHighlighted];
    
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
    
    [delegate closeCustomInstrumentSelectorAndScroll:NO];
}

- (void)initSubtables
{
    
    [sampleTable setBackgroundColor:[UIColor colorWithRed:8/255.0 green:135/255.0 blue:166/255.0 alpha:1.0]];
    sampleTable.layer.cornerRadius = 5.0;
    
    [stringTable setBackgroundColor:[UIColor colorWithRed:23/255.0 green:163/255.0 blue:198/255.0 alpha:1.0]];
    nextButton.layer.cornerRadius = 5.0;

    // Fade next button
    [self checkIfAllStringsReady];
    
    // Record button
    [self showHideButton:recordButton isHidden:NO withSelector:@selector(userDidLaunchRecord:)];
    
}

- (void)moveFrame:(CGRect)newFrame
{
    backgroundView.frame = newFrame;
}

#pragma mark - Name Field / Recording Name Field
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
    NSString * defaultText = @"NAME";
    
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
}

- (void)recordingNameFieldStartEdit:(id)sender
{
    // hide default
    NSString * defaultText = @"New Recording";
    
    if([recordingNameField.text isEqualToString:defaultText]){
        recordingNameField.text = @"";
    }
}

- (void)recordingNameFieldDidChange:(id)sender
{
    int maxLength = 15;
    
    if([recordingNameField.text length] > maxLength){
        recordingNameField.text = [recordingNameField.text substringToIndex:maxLength];
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
}

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
    [self setBackgroundViewFromNib:@"CustomInstrumentRecorder" withFrame:newFrame andRemove:backgroundView];

    // Load active buttons
    [self showHideButton:recordBackButton isHidden:NO withSelector:@selector(userDidBack:)];
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
    
    recordState = 0;
    [recordRecordButton setTitle:@"RECORD" forState:UIControlStateNormal];
    
    [self resetProgressBar];
    [self resetPlayBar];
    
    // Disable save
    isRecordingReady = FALSE;
    [self showHideButton:recordSaveButton isHidden:YES withSelector:@selector(userDidSaveRecord:)];
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
    [recordRecordButton setTitle:@"PLAY" forState:UIControlStateNormal];
    recordState = 2;
    
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
    }else{
        NSLog(@"Hiding save");
        [self showHideButton:recordSaveButton isHidden:YES withSelector:@selector(userDidSaveRecord:)];
    }
}

- (void)checkIfRecordingNameReady
{
    NSString * nameString = recordingNameField.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([nameString isEqualToString:@"New Recording"] || [emptyName isEqualToString:@""]){
        isRecordingNameReady = FALSE;
    }else{
        isRecordingNameReady = TRUE;
    }
    
    [self checkIfRecordSaveReady];
}


-(void)userDidStartRecord
{
    
    // Start record
    [customSoundRecorder startRecord];
    [recordRecordButton setTitle:@"STOP" forState:UIControlStateNormal];
    recordState = 1;
    
    // Schedule end of session
    recordTimer = [NSTimer scheduledTimerWithTimeInterval:MAX_RECORD_SECONDS target:self selector:@selector(userDidEndRecord) userInfo:nil repeats:NO];
    
    // Reset the progress
    [self resetProgressBar];
    
    // Draw progress bar
    progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:RECORD_DRAW_INTERVAL target:self selector:@selector(advanceProgressBar) userInfo:nil repeats:YES];
    
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
    [playBarTimer invalidate];
    playBarTimer = nil;
}

-(void)userDidStartPlayback
{
    [self resetPlayBar];
    
    // Call sound playback
    [customSoundRecorder startPlayback];
    
    // Reset timer
    [playBarTimer invalidate];
    playBarTimer = nil;
    
    // Draw play bar
    playBarTimer = [NSTimer scheduledTimerWithTimeInterval:RECORD_DRAW_INTERVAL target:self selector:@selector(advancePlayBar) userInfo:nil repeats:YES];
}

-(void)resetPlayBar
{
    CGRect newFrame = CGRectMake(0,0,0,playBar.frame.size.height);
    
    playBar.frame = newFrame;
    
    playBarPercent = 0;
}

-(void)advancePlayBar
{
    playBarPercent += RECORD_DRAW_INTERVAL/MAX_RECORD_SECONDS;
    
    [self movePlayBarToPercent:playBarPercent];
}

-(void)movePlayBarToPercent:(double)percent
{
    CGRect newFrame = CGRectMake(progressBarContainer.frame.size.width*percent,0,10,progressBar.frame.size.height);
    
    playBar.frame = newFrame;
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
    progressBarPercent += RECORD_DRAW_INTERVAL/MAX_RECORD_SECONDS;
    
    [self fillProgressBarToPercent:progressBarPercent];
}

-(void)fillProgressBarToPercent:(double)percent
{
    CGRect newFrame = CGRectMake(0, 0, progressBarContainer.frame.size.width*percent, progressBar.frame.size.height);
    
    progressBar.frame = newFrame;
}

#pragma mark - Table View Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(tableView == sampleTable){
        return [sampleList count];
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView == sampleTable){
        return [[sampleList[section] objectForKey:@"Sampleset"] count]+1;
    }else{
        return GTAR_NUM_STRINGS;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == sampleTable){
        float tableHeight = sampleTable.frame.size.height;
        return tableHeight/9.0;
    }else{
        float tableHeight = stringTable.frame.size.height;
        return tableHeight/GTAR_NUM_STRINGS;
    }
}

- (NSString *)getSampleFromIndex:(NSIndexPath *)indexPath
{
    
    long sectionindex = indexPath.section;
    long i = indexPath.row;
    
    if(i == 0){
        return [sampleList[sectionindex] objectForKey:@"Section"];
    }
    
    NSArray * section = [sampleList[sectionindex] objectForKey:@"Sampleset"];
    
    return section[i-1];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // table init stuff
    if(tableView == stringTable && indexPath.row == 0){
        [self.stringTable registerNib:[UINib nibWithNibName:@"CustomStringCell" bundle:nil] forCellReuseIdentifier:@"StringCell"];
    }
    
    self.sampleTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.stringTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // do custom work
    if(tableView == sampleTable){
        
        // init cell
        static NSString * CellIdentifier = @"SampleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        // do custom work
        [cell.textLabel setText:[self getSampleFromIndex:indexPath]];
        
        [cell.textLabel setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8]];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
        
        if(indexPath.row == 0){
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
        
        // do custom work
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.index = GTAR_NUM_STRINGS - indexPath.row - 1;
        
        if(cell.sampleFilename!= nil){
            cell.stringLabel.text = cell.sampleFilename;
        }else{
            cell.stringLabel.text = @"select a sound";
            cell.defaultFontColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3];
        }
        [cell.stringLabel setTextColor:cell.defaultFontColor];
        
        [cell.stringBox setBackgroundColor:colorList[cell.index]];
        
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
    if(tableView == sampleTable && indexPath.row > 0){
        
        [self toggleSampleCellAtIndexPath:indexPath];
        
    }else if(tableView == stringTable && indexPath.row < GTAR_NUM_STRINGS){
        
        [self toggleStringCellAtIndexPath:indexPath];

    }else{
        // save
        return;
    }
    
    // join sample and string
    if(selectedSampleCell && selectedStringCell){
        
        BOOL useCustomPath = (indexPath.section == 0 && customSampleList != nil) ? TRUE : FALSE;
        
        // pass filename
        [selectedStringCell updateFilename:selectedSampleCell.textLabel.text isCustom:useCustomPath];
        
        // turn off sample to avoid reselecting
        [self styleSampleCell:nil turnOff:selectedSampleCell];
        selectedSampleCell = nil;
        
        [self checkIfAllStringsReady];
    }
}

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
    }else{
        [self showHideButton:nextButton isHidden:YES withSelector:@selector(userDidNext:)];
    }
}

- (void)checkIfNameReady
{
    BOOL isReady = YES;
    NSString * nameString = nameField.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([nameString isEqualToString:@"NAME"] || [emptyName isEqualToString:@""]){
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
        BOOL isCustom = (indexPath.section == 0 && customSampleList != nil) ? TRUE : FALSE;
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
        [cell setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2]];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    }
    if(cellOff != nil){
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(turnOffCellTimer:) userInfo:cellOff repeats:NO];
        
    }
}

- (void)turnOffCellTimer:(NSTimer *)timer
{
    
    UITableViewCell * cellOff = (UITableViewCell *)[timer userInfo];
    
    [cellOff.textLabel setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8]];
    [cellOff setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0]];
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


- (void)retrieveSampleList
{
    
    // Init
    sampleList = [[NSMutableArray alloc] init];
    customSampleList = [[NSMutableArray alloc] init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sampleList" ofType:@"plist"];
    
    // Check for local custom sample list
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    customSampleListPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"customSampleList.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSLog(@"The sample plist exists");
    } else {
        NSLog(@"The sample plist does not exist");
    }
    
    NSMutableDictionary * plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    // Append a second local custom sounds pList
    if ([fileManager fileExistsAtPath:customSampleListPath]) {
        NSLog(@"The custom sample plist exists");
        NSMutableDictionary * customDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:customSampleListPath];
        [plistDictionary addEntriesFromDictionary:customDictionary];
        
        [customSampleList addObjectsFromArray:[customDictionary objectForKey:@"Samples"]];
        
        // First section of the sampleList is the customSampleList
        sampleList = customSampleList;
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
    
    }else{
        [[customSampleList[0] objectForKey:@"Sampleset"] addObject:filename];
    }
    
    // First section of the sampleList is the customSampleList
    NSArray * tempSampleList = sampleList;
    sampleList = customSampleList;
    [sampleList addObjectsFromArray:tempSampleList];

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
