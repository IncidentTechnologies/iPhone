//
//  OptionsViewCell.m
//  Sequence
//
//  Created by Kate Schnippering on 2/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "OptionsViewCell.h"
#import "OptionsViewController.h"

@implementation OptionsViewCell

@synthesize parent;
@synthesize fileText;
@synthesize fileName;
@synthesize fileLoad;
@synthesize fileDate;
@synthesize isRenamable;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if ( self )
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    
}

- (void)layoutSubviews
{
    [self setUserInteractionEnabled:YES];
    
    // Draw file load icon
    fileLoad.layer.borderColor = [UIColor whiteColor].CGColor;
    fileLoad.layer.borderWidth = 2.0f;
    fileLoad.layer.cornerRadius = 20;

    // Style and setup fileName field
    [fileName setHidden:YES];
    fileName.delegate = self;
    fileName.backgroundColor = [UIColor colorWithRed:50/255.0 green:56/255.0 blue:59/255.0 alpha:1.0];
    fileName.textColor = [UIColor whiteColor];
    fileName.borderStyle = UITextBorderStyleNone;
    
    // Setup text field listener
    [fileName addTarget:self action:@selector(saveFieldStartEdit:) forControlEvents:UIControlEventEditingDidBegin];
    [fileName addTarget:self action:@selector(saveFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [fileName addTarget:self action:@selector(saveFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    UIColor * darkGrayColor = [UIColor colorWithRed:50/255.0 green:56/255.0 blue:59/255.0 alpha:1.0];
    UIColor * blueColor = [UIColor colorWithRed:0/255.0 green:161/255.0 blue:222/255.0 alpha:1.0];
    
    // Save load button
    [self showHideButton:fileLoad isHidden:NO withSelector:@selector(userDidSaveLoad)];
    
    if(selected){
        
        self.contentView.backgroundColor = darkGrayColor;
        self.backgroundColor = darkGrayColor;
        
        fileText.textColor = [UIColor whiteColor];
        [fileLoad setHidden:NO];
        
        // Modal changes
        if([parent.selectMode isEqualToString:@"Rename"] || (![parent.selectMode isEqualToString:@"Load"] && isRenamable)){
            
            self.fileName.text = self.fileText.text;
            
            // create attributed string
            NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:fileName.text];
            [str addAttribute:NSBackgroundColorAttributeName value:blueColor range:NSMakeRange(0, fileName.text.length)];
            
            [fileName setAttributedText:str];
            
            [self.fileText setHidden:YES];
            [self.fileName setHidden:NO];
            
            // open keyboard
            [self beginNameEditing];
            
        }
        
    }else{
        
        if(![parent.selectMode isEqualToString:@"Load"] && isRenamable){
            self.contentView.backgroundColor = [UIColor grayColor];
            self.backgroundColor = [UIColor grayColor];
        }else{
            self.contentView.backgroundColor = [UIColor whiteColor];
            self.backgroundColor = [UIColor whiteColor];
        }
        
        fileText.textColor = darkGrayColor;
        [fileLoad setHidden:YES];
        
        [self.fileText setHidden:NO];
        [self.fileName setHidden:YES];
        
        [self endNameEditing];
        
    }

    // Configure the view for the selected state
}

- (void)userDidSaveLoad
{
    if([parent.selectMode isEqualToString:@"Load"]){
        
        // Load
        [parent userDidLoadFile:self.fileText.text];
        
    }else if([parent.selectMode isEqualToString:@"Rename"]){
        
        // Rename
        [parent userDidRenameFile:self.fileText.text toName:self.fileName.text];
        self.fileText.text = self.fileName.text;
        
        [self endNameEditing];
        
        [parent deselectAllRows];
        
    }else if([parent.selectMode isEqualToString:@"CreateNew"]){
    
        // Create New
        if(![self.fileName.text isEqualToString:self.fileText.text]){
            self.fileText.text = self.fileName.text;
        }
        
        [parent userDidCreateNewFile:self.fileText.text];
        
        [self endNameEditing];
        
        [parent deselectAllRows];
        
        
    }else if([parent.selectMode isEqualToString:@"SaveCurrent"]){
        
        // Save Current
        
        if(![self.fileName.text isEqualToString:self.fileText.text]){
            self.fileText.text = self.fileName.text;
        }
        
        [parent userDidSaveFile:self.fileText.text];
        
        [self endNameEditing];
        
        [parent deselectAllRows];
    
    }
}

#pragma mark - Save Field
- (void)saveFieldStartEdit:(id)sender
{
    [self checkIfNameReady];
}

- (void)saveFieldDidChange:(id)sender
{
    int maxLength = 30;

    // check length
    if([fileName.text length] > maxLength){
     fileName.text = [fileName.text substringToIndex:maxLength];
    }
    
    [self checkIfNameReady];
}

-(void)saveFieldDoneEditing:(id)sender
{
    // hide keyboard
    [self endNameEditing];
}

- (void)beginNameEditing
{
    [fileName becomeFirstResponder];
}

-(void)endNameEditing
{
    // hide keyboard
    [fileName resignFirstResponder];
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
     NSString * nameString = fileName.text;
     NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
     
     if([emptyName isEqualToString:@""]){
         isReady = NO;
     }else{
         isReady = YES;
     }
    
    if([parent isDuplicateFilename:nameString]){
        isReady = NO;
    }
    
    if(isReady){
        [self showHideButton:fileLoad isHidden:NO withSelector:@selector(userDidSaveLoad)];
    }else{
        [self showHideButton:fileLoad isHidden:YES withSelector:@selector(userDidSaveLoad)];
    }
}

- (void)showHideButton:(UIButton *)button isHidden:(BOOL)hidden withSelector:(SEL)selector
{
    if(!hidden){
        [button setAlpha:1.0];
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }else{
        [button setAlpha:0.2];
        [button removeTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}


@end
