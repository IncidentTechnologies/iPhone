//
//  OptionsViewCell.m
//  Sequence
//
//  Created by Kate Schnippering on 2/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "OptionsViewCell.h"
#import "OptionsViewController.h"

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

#define DEFAULT_FILE_TEXT @"Save as"

@implementation OptionsViewCell

@synthesize parent;
@synthesize fileText;
@synthesize fileName;
@synthesize fileLoad;
@synthesize fileDate;
@synthesize activeIndicator;
@synthesize isRenamable;
@synthesize rowid;
@synthesize deleteButton;
@synthesize isNameEditing;
@synthesize scroller;

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
    isEditingMode = NO;
    
    darkGrayColor = [UIColor colorWithRed:50/255.0 green:56/255.0 blue:59/255.0 alpha:1.0];
    blueColor = [UIColor colorWithRed:0/255.0 green:161/255.0 blue:222/255.0 alpha:1.0];
    activeColor = blueColor;
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
    
    // Setup gesture recognizer
    UITapGestureRecognizer * doubletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubletap.numberOfTapsRequired = 2;
    
    [self addGestureRecognizer:doubletap];
    
    // Active indicator
    activeIndicator.layer.cornerRadius = activeIndicator.frame.size.width/2;
    
}

- (void)setAsActiveSequencer
{
    if(!isRenamable){
        isActiveSequencer = YES;
        fileText.textColor = activeColor;
        [self applyBoldFont:YES toLabel:fileText];
        [activeIndicator setBackgroundColor:blueColor];
    }
}

- (void)unsetAsActiveSequencer
{
    isActiveSequencer = NO;
    if(self.isSelected){
        fileText.textColor = [UIColor whiteColor];
    }else{
        fileText.textColor = darkGrayColor;
    }
    [self applyBoldFont:NO toLabel:fileText];
    [activeIndicator setBackgroundColor:[UIColor colorWithRed:201/255.0 green:205/255.0 blue:206/255.0 alpha:1.0]];
}

- (void)applyBoldFont:(BOOL)isBold toLabel:(UILabel *)text
{
    if(isBold){
        [text setFont:[UIFont fontWithName:FONT_BOLD size:18.0]];
    }else{
        [text setFont:[UIFont fontWithName:FONT_DEFAULT size:18.0]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(selected){
        
        NSLog(@"Selecting cell at row %i",rowid);
        
        self.contentView.backgroundColor = darkGrayColor;
        self.backgroundColor = darkGrayColor;
        
        fileText.textColor = (isActiveSequencer && !isRenamable) ? activeColor : [UIColor whiteColor];
        
        [fileLoad setHidden:NO];
        [self setImageForFileLoad:parent.selectMode];
        
        // Modal changes
        if([parent.selectMode isEqualToString:@"SaveCurrent"] && isRenamable){
            
            NSLog(@"Selected cell is Renamable");
            
            [fileText setHidden:YES];
            [fileName setHidden:NO];
            
            // open keyboard
            [self beginNameEditing];
        }else{
            // Save load button
            [self showHideButton:fileLoad isHidden:NO withSelector:@selector(userDidSaveLoad) withAnimation:NO];
        }
        
        [parent deselectAllRowsExcept:self];
        
    }else{
        
        if(!isEditingMode){
            
            if(TESTMODE) NSLog(@"Deselecting cell %i",rowid);
            
            [self endNameEditing];
            
            if([parent.selectMode isEqualToString:@"SaveCurrent"] && isRenamable){
                self.contentView.backgroundColor = [UIColor grayColor];
                self.backgroundColor = [UIColor grayColor];
                
            }else{
                self.contentView.backgroundColor = [UIColor whiteColor];
                self.backgroundColor = [UIColor whiteColor];
            }
            
            fileText.textColor = (isActiveSequencer && !isRenamable) ? activeColor : darkGrayColor;
            [fileLoad setHidden:YES];
            
            [fileText setHidden:NO];
            [fileName setHidden:YES];
        }else{
            
            if(TESTMODE) NSLog(@"*** Not deselecting cell %i",rowid);
        }
        
    }
    
    if(scroller != nil && !isEditingMode){
        [self resetContentOffset];
    }
    
    // Check font for active sequencer
    if(isActiveSequencer && !isRenamable){
        [self applyBoldFont:YES toLabel:fileText];
    }else{
        [self applyBoldFont:NO toLabel:fileText];
    }
    
    // Configure the view for the selected state
}

- (void)userDidSaveLoad
{
    if([parent.selectMode isEqualToString:@"Load"]){
        
        NSLog(@"Load file %@",fileText.text);
        
        // Load
        [parent userDidLoadFile:fileText.text];
        
    }else if([parent.selectMode isEqualToString:@"SaveCurrent"]){
        
        // Save Current
        NSString * emptyName = [fileName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(![fileName.text isEqualToString:fileText.text] && ![emptyName isEqualToString:@""] && ![fileName.text isEqualToString:DEFAULT_FILE_TEXT]){
            fileText.text = fileName.text;
        }
        
        [parent userDidSaveFile:fileText.text];
        
        [self endNameEditing];
        
        [parent deselectAllRows];
    
    }
}

- (void)userDidRename
{
    // Rename
    [parent userDidRenameFile:fileText.text toName:fileName.text];
    fileText.text = fileName.text;
    
    // end name editing happens automatically
    
    [parent deselectAllRows];
    
}

#pragma mark - Editing
-(void)editingDidBegin
{
    NSLog(@"Editing cell mode began");
    isEditingMode = YES;
}

-(void)editingDidEnd
{
    NSLog(@"Editing cell mode ended");
    
    isEditingMode = NO;
}

#pragma mark - Save Field
- (void)saveFieldStartEdit:(id)sender
{
    isNameEditing = YES;
    
    previousNameText = fileName.text;
    
    if([fileName.text isEqualToString:DEFAULT_FILE_TEXT] || [fileName.text isEqualToString:@""]){
        fileName.text = @"";
    }else{
        [self initFileAttributedString];
    }
    
    if(![parent.selectMode isEqualToString:@"Load"]){
        [self checkIfNameReady];
    }
    
    [parent disableScroll];
}

- (void)initFileAttributedString
{
    NSLog(@"Init file attributed string");
    
    if(![fileName.text isEqualToString:DEFAULT_FILE_TEXT] && ![fileName.text isEqualToString:@""]){
        // create attributed string
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:fileName.text];
        [str addAttribute:NSBackgroundColorAttributeName value:blueColor range:NSMakeRange(0, fileName.text.length)];
        
        [fileName setAttributedText:str];
    }
}

- (void)clearFileAttributedString
{
    
    // create attributed string
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:fileName.text];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0, fileName.text.length)];
    
    [fileName setAttributedText:str];
}

- (void)saveFieldDidChange:(id)sender
{
    int maxLength = 30;

    // check length
    if([fileName.text length] > maxLength){
        fileName.text = [fileName.text substringToIndex:maxLength];
    }else if([fileName.text length] == 1){
        [self initFileAttributedString];
    }
    
    // enforce capitalizing
    fileName.text = [fileName.text capitalizedString];
    
    if(![parent.selectMode isEqualToString:@"Load"]){
        [self checkIfNameReady];
    }
}

-(void)saveFieldDoneEditing:(id)sender
{
    isNameEditing = NO;
    
    // save a rename
    if([parent.selectMode isEqualToString:@"Load"] && ![fileName.text isEqualToString:@""]){
        
        // auto rename if duplicate
        if([parent isDuplicateFilename:fileName.text] && ![fileName.text isEqualToString:previousNameText]){
            fileName.text = [parent generateNextSetName];
        }else{
            fileName.text = previousNameText;
        }
        
        // rename
        [self userDidRename];
        
    }else if([fileName.text isEqualToString:@""]){
        [self setSelected:NO animated:NO];
    }
    
    // hide keyboard
    [self endNameEditing];
    [self clearFileAttributedString];
}

- (void)beginNameEditing
{
    isNameEditing = YES;
    
    NSLog(@"Begin name editing");
    
    // This function may be called while already open for editing
    if(![fileName isFirstResponder]){
        [fileName becomeFirstResponder];
        
        if([parent.selectMode isEqualToString:@"Load"]){
            [parent offsetTable:self];
        }
    }
    
    [self checkIfNameReady];
    [parent disableScroll];
}

-(void)endNameEditing
{
    isNameEditing = NO;
    
    NSLog(@"End name editing");
    
    // hide keyboard
    if([fileName isFirstResponder]){
        
        [fileName resignFirstResponder];
        [parent resetTableOffset:self];
        [parent enableScroll];
    }
    
    [self resetFileNameIfBlank];
}

-(void)resetFileNameIfBlank
{
    if(TESTMODE) NSLog(@"Reset filename if blank");
    
    NSString * nameString = fileName.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""] && previousNameText != nil && ![previousNameText isEqualToString:@""]){
        fileName.text = previousNameText;
    }else if([emptyName isEqualToString:@""]){
        fileName.text = DEFAULT_FILE_TEXT;
    }else if([parent isDuplicateFilename:nameString]){
        fileName.text = [parent generateNextSetName];
        [self checkIfNameReady];
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
    NSLog(@"Check if name ready");
    
     BOOL isReady = YES;
     NSString * nameString = fileName.text;
     NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
     
     if([emptyName isEqualToString:@""] || [nameString isEqualToString:DEFAULT_FILE_TEXT]){
         isReady = NO;
     }else{
         isReady = YES;
     }
    
    if([parent isDuplicateFilename:nameString]){
        isReady = NO;
    }
    
    if(isReady){
        [self showHideButton:fileLoad isHidden:NO withSelector:@selector(userDidSaveLoad) withAnimation:YES];
    }else{
        [self showHideButton:fileLoad isHidden:YES withSelector:@selector(userDidSaveLoad) withAnimation:NO];
    }
}

- (void)showHideButton:(UIButton *)button isHidden:(BOOL)hidden withSelector:(SEL)selector withAnimation:(BOOL)animate
{
    if(!hidden){
        [button setAlpha:1.0];
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }else{
        [button setAlpha:0.2];
        [button removeTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)setImageForFileLoad:(NSString *)mode
{
    if([mode isEqualToString:@"Load"]){
        
        CGSize size = CGSizeMake(fileLoad.frame.size.width, fileLoad.frame.size.height);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        int loadArrowWidth = 20;
        int loadArrowHeight = 17;
        int loadArrowX = 10;
        int loadArrowY = 16;
        int topOfArrow = 8;
        
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        
        CGContextSetLineWidth(context, 2.0);
        
        CGContextMoveToPoint(context, loadArrowX, loadArrowY);
        CGContextAddLineToPoint(context, loadArrowX+loadArrowWidth, loadArrowY);
        CGContextAddLineToPoint(context, loadArrowX+loadArrowWidth/2, loadArrowY+loadArrowHeight);
        CGContextClosePath(context);
        CGContextFillPath(context);
        
        CGContextSetLineWidth(context, 10.0);
        CGContextMoveToPoint(context, loadArrowX+loadArrowWidth/2, topOfArrow);
        CGContextAddLineToPoint(context, loadArrowX+loadArrowWidth/2, loadArrowY);
        CGContextStrokePath(context);
    
        UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        [fileLoad setImage:newImage forState:UIControlStateNormal];

        UIGraphicsEndImageContext();
        
        [fileLoad setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

    }else{
        [fileLoad setImage:[UIImage imageNamed:@"Save_Icon"] forState:UIControlStateNormal];
        [fileLoad setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
}

#pragma mark - Double tap
-(void)handleDoubleTap:(UITapGestureRecognizer *)sender
{
    // ensure selected
    if(!self.isSelected){
        NSLog(@"****** force select");
        [self setSelected:YES animated:NO];
    }
    
    if([parent.selectMode isEqualToString:@"Load"]){
        
        fileName.text = fileText.text;
        
        [fileText setHidden:YES];
        [fileName setHidden:NO];
        
        // open keyboard
        [self beginNameEditing];
    }
}

#pragma mark - Deleting
// Prevent bouncing
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scroller = scrollView;
    
    static CGFloat targetOffset = 62;
    if(scrollView.contentOffset.x >= targetOffset){
        scrollView.contentOffset = CGPointMake(targetOffset, 0.0);
    }
}

-(void)resetContentOffset
{
    scroller.contentOffset = CGPointMake(0,0);
}

-(NSString *)getNameForFile
{
    return fileText.text;
}

@end
