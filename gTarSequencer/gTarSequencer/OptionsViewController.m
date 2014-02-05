//
//  SaveLoadSelector.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/28/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "OptionsViewController.h"

@implementation OptionsViewController

@synthesize delegate;
@synthesize saveField;
@synthesize saveWarning;
@synthesize filePicker;
@synthesize noFilesLabel;
@synthesize saveLoadButton;
@synthesize saveSaveButton;
@synthesize loadLoadButton;
@synthesize loadSaveButton;
@synthesize activeSequencer;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self userDidSaveSequence];
    }
    return self;
}

- (void)initSave
{
    
    saveSaveButton.layer.cornerRadius = 5.0;
    saveLoadButton.layer.cornerRadius = 5.0;
    
    if(activeSequencer != nil){
        saveField.text = activeSequencer;
        [saveWarning setHidden:NO];
    }else{
        [saveWarning setHidden:YES];
    }
    
    saveField.delegate = self;
    
    // Setup text field listener
    [saveField addTarget:self action:@selector(saveFieldStartEdit:) forControlEvents:UIControlEventEditingDidBegin];
    [saveField addTarget:self action:@selector(saveFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [saveField addTarget:self action:@selector(saveFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self showHideButton:saveSaveButton isHidden:NO withSelector:@selector(userDidSaveFromSave:)];

}

- (void)initLoad
{
    
    [self fetchFilesFromDocumentDir];
    
    loadSaveButton.layer.cornerRadius = 5.0;
    loadLoadButton.layer.cornerRadius = 5.0;
    
    if([fileLoadSet count] > 0){
        
        [noFilesLabel setHidden:YES];
        [filePicker setHidden:NO];
        
        filePicker.delegate = self;
        filePicker.dataSource = self;
        
        [filePicker reloadAllComponents];
        
        // default select the active file
        if(activeSequencer != nil){
            for(int i = 0; i < [fileLoadSet count]; i++){
                if([fileLoadSet[i] isEqualToString:activeSequencer]){
                    [filePicker selectRow:i inComponent:0 animated:YES];
                }
            }
        }
        
    }else{
        [noFilesLabel setHidden:NO];
        [filePicker setHidden:YES];
    }
    
    
}

- (void)fetchFilesFromDocumentDir
{
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSError * error;
    fileLoadSet = (NSMutableArray *)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[paths objectAtIndex:0] error:&error];
    
    // Exclude two default files: instrument set and sequencer state
    for(int i = 0; i < [fileLoadSet count]; i++){
        if([fileLoadSet[i] isEqualToString:@"sequencerInstruments.plist"] || [fileLoadSet[i] isEqualToString:@"sequencerCurrentState"]){
            [fileLoadSet removeObjectAtIndex:i--];
        }else{
            // remove usr_ prefix
            fileLoadSet[i] = [fileLoadSet[i] stringByReplacingCharactersInRange:[fileLoadSet[i] rangeOfString:@"usr_"] withString:@""];
        }
    }
}

- (void)userDidSaveSequence
{
    [self initSave];
}

- (void)userDidLoadSequence
{
    [self initLoad];
}

- (void)userDidSaveFromSave:(id)sender
{
    NSString * filename = saveField.text;
    
    activeSequencer = filename;
    [delegate saveWithName:filename];
}

- (IBAction)userDidLoadFromLoad:(id)sender
{
    NSString * filename = [fileLoadSet objectAtIndex:[filePicker selectedRowInComponent:0]];
    
    activeSequencer = filename;
    [delegate loadFromName:filename];
}

#pragma mark - Save Field
- (void)saveFieldStartEdit:(id)sender
{
    // hide default
    NSString * defaultText = @"my_sequencer";
    
    if([saveField.text isEqualToString:defaultText]){
        saveField.text = @"";
    }
}
- (void)saveFieldDidChange:(id)sender
{
    int maxLength = 30;
    
    // check length
    if([saveField.text length] > maxLength){
        saveField.text = [saveField.text substringToIndex:maxLength];
    }
    
    [self checkIfNameReady];
}

-(void)saveFieldDoneEditing:(id)sender
{
    // hide keyboard
    [saveField resignFirstResponder];
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

- (void)checkIfNameReady
{
    BOOL isReady = YES;
    NSString * nameString = saveField.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""]){
        isReady = NO;
    }else{
        isReady = YES;
    }
    
    if(isReady){
        [self showHideButton:saveSaveButton isHidden:NO withSelector:@selector(userDidSaveFromSave:)];
    }else{
        [self showHideButton:saveSaveButton isHidden:YES withSelector:@selector(userDidSaveFromSave:)];
    }
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

#pragma mark - File Picker
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 25;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [fileLoadSet count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString * title = fileLoadSet[row];
    NSAttributedString * styledString;
    
    if([title isEqualToString:activeSequencer]){
        styledString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}];
    }else{
       styledString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:29/255.0 green:88/255.0 blue:103/255.0 alpha:1.0]}];
    }
    
    
    return styledString;
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
