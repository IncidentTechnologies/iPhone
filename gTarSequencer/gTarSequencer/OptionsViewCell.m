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
@synthesize rowid;

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
    isActiveSequencer = NO;
    
    activeColor = [UIColor colorWithRed:0/255.0 green:161/255.0 blue:222/255.0 alpha:1.0];
    darkGrayColor = [UIColor colorWithRed:50/255.0 green:56/255.0 blue:59/255.0 alpha:1.0];
    blueColor = [UIColor colorWithRed:0/255.0 green:161/255.0 blue:222/255.0 alpha:1.0];
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

- (void)setAsActiveSequencer
{
    if(!isRenamable){
        isActiveSequencer = YES;
        fileText.textColor = activeColor;
    }
}

- (void)unsetAsActiveSequencer
{
    isActiveSequencer = NO;
    if(self.selected){
        fileText.textColor = [UIColor whiteColor];
    }else{
        fileText.textColor = [UIColor colorWithRed:50/255.0 green:56/255.0 blue:59/255.0 alpha:1.0];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
    [super setSelected:selected animated:animated];
    
    // Save load button
    [self showHideButton:fileLoad isHidden:NO withSelector:@selector(userDidSaveLoad)];
    
    if(selected){
        
        NSLog(@"Selecting cell at row %i",rowid);
        
        self.contentView.backgroundColor = darkGrayColor;
        self.backgroundColor = darkGrayColor;
        
        fileText.textColor = (isActiveSequencer && !isRenamable) ? activeColor : [UIColor whiteColor];
        [fileLoad setHidden:NO];
        
        // Modal changes
        if([parent.selectMode isEqualToString:@"Rename"] || (![parent.selectMode isEqualToString:@"Load"] && isRenamable)){
            
            NSLog(@"Selected cell is Renamable");
            
            fileName.text = fileText.text;
            
            // create attributed string
            NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:fileName.text];
            [str addAttribute:NSBackgroundColorAttributeName value:blueColor range:NSMakeRange(0, fileName.text.length)];
            
            [fileName setAttributedText:str];
            
            [fileText setHidden:YES];
            [fileName setHidden:NO];
            
            // open keyboard
            [self beginNameEditing];
        }
        
    }else{
        
        NSLog(@"Deselecting cell %i",rowid);
        
        if(![parent.selectMode isEqualToString:@"Load"] && isRenamable){
            self.contentView.backgroundColor = [UIColor grayColor];
            self.backgroundColor = [UIColor grayColor];
            
            [self endNameEditing];
            
        }else{
            self.contentView.backgroundColor = [UIColor whiteColor];
            self.backgroundColor = [UIColor whiteColor];
        }
        
        fileText.textColor = (isActiveSequencer && !isRenamable) ? activeColor : darkGrayColor;
        [fileLoad setHidden:YES];
        
        [fileText setHidden:NO];
        [fileName setHidden:YES];
        
    }

    // Configure the view for the selected state
}

- (void)userDidSaveLoad
{
    if([parent.selectMode isEqualToString:@"Load"]){
        
        // Load
        [parent userDidLoadFile:fileText.text];
        
    }else if([parent.selectMode isEqualToString:@"Rename"]){
        
        // Rename
        [parent userDidRenameFile:fileText.text toName:fileName.text];
        fileText.text = fileName.text;
        
        [self endNameEditing];
        
        [parent deselectAllRows];
        
    }else if([parent.selectMode isEqualToString:@"CreateNew"]){
    
        NSLog(@"FileName Text is %@ and FileText Text is %@",fileName.text,fileText.text);
        
        NSString * emptyName = [fileName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // Create New
        if(![fileName.text isEqualToString:fileText.text] && ![emptyName isEqualToString:@""]){
            fileText.text = fileName.text;
        }
        
        NSLog(@"Creating new with name %@",fileText.text);
        
        [parent userDidCreateNewFile:fileText.text];
        
        [self endNameEditing];
        
        [parent deselectAllRows];
        
        
    }else if([parent.selectMode isEqualToString:@"SaveCurrent"]){
        
        // Save Current
        
        NSLog(@"FileName Text is %@ and FileText Text is %@",fileName.text,fileText.text);
        
        
        NSString * emptyName = [fileName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(![fileName.text isEqualToString:fileText.text] && ![emptyName isEqualToString:@""]){
            fileText.text = fileName.text;
        }
        
        [parent userDidSaveFile:fileText.text];
        
        [self endNameEditing];
        
        [parent deselectAllRows];
    
    }
}

#pragma mark - Save Field
- (void)saveFieldStartEdit:(id)sender
{
    
    // hide default
    NSString * defaultText = @"New set";
    
    if([fileName.text isEqualToString:defaultText]){
        fileName.text = @"";
    }
    
    [self checkIfNameReady];
}

- (void)saveFieldDidChange:(id)sender
{
    int maxLength = 30;

    // check length
    if([fileName.text length] > maxLength){
        fileName.text = [fileName.text substringToIndex:maxLength];
    }
    
    // enforce capitalizing
    fileName.text = [fileName.text capitalizedString];
    
    [self checkIfNameReady];
}

-(void)saveFieldDoneEditing:(id)sender
{
    // hide keyboard
    [self endNameEditing];
}

- (void)beginNameEditing
{
    NSLog(@"Begin name editing");
    if(![fileName isFirstResponder]){
        [fileName becomeFirstResponder];
        [fileName selectAll:self];
        
        if([parent.selectMode isEqualToString:@"Rename"]){
            [parent offsetTable:self];
        }else{
            [parent disableScroll];
        }
    }
}

-(void)endNameEditing
{
    NSLog(@"End name editing");
    // hide keyboard
    if([fileName isFirstResponder]){
        
        [fileName resignFirstResponder];
        [parent enableScroll];
        [parent resetTableOffset:self];    
    }
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
