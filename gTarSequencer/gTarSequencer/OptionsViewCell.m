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
@synthesize deleteButton;

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
    
    // Setup gesture recognizer
    UITapGestureRecognizer * doubletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubletap.numberOfTapsRequired = 2;
    
    [self addGestureRecognizer:doubletap];
    
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
        [self setImageForFileLoad:parent.selectMode];
        
        // Modal changes
        if([parent.selectMode isEqualToString:@"SaveCurrent"] && isRenamable){
            
            NSLog(@"Selected cell is Renamable");
            
            fileName.text = fileText.text;
            
            [fileText setHidden:YES];
            [fileName setHidden:NO];
            
            // open keyboard
            [self beginNameEditing];
        }
        
    }else{
        
        NSLog(@"Deselecting cell %i",rowid);
        
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
        
        if(![fileName.text isEqualToString:fileText.text] && ![emptyName isEqualToString:@""]){
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

#pragma mark - Save Field
- (void)saveFieldStartEdit:(id)sender
{
    previousNameText = fileName.text;
    
    if([fileName.text isEqualToString:@"Save as"]){
        fileName.text = @"";
    }else{
        [self initFileAttributedString];
    }
    
    [self checkIfNameReady];
}

- (void)initFileAttributedString
{
    // create attributed string
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:fileName.text];
    [str addAttribute:NSBackgroundColorAttributeName value:blueColor range:NSMakeRange(0, fileName.text.length)];
    
    [fileName setAttributedText:str];
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
    
    [self checkIfNameReady];
}

-(void)saveFieldDoneEditing:(id)sender
{
    // save a rename
    if([parent.selectMode isEqualToString:@"Load"]){
        // rename
        [self userDidRename];
    }
    
    // hide keyboard
    [self endNameEditing];
    [self clearFileAttributedString];
}

- (void)beginNameEditing
{
    NSLog(@"Begin name editing");
    if(![fileName isFirstResponder]){
        [fileName becomeFirstResponder];
        
        if([parent.selectMode isEqualToString:@"Load"]){
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
        [parent resetTableOffset:self];
    }
    
    [parent enableScroll];
    [self resetFileNameIfBlank];
}

-(void)resetFileNameIfBlank
{
    
    NSString * nameString = fileName.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""] && previousNameText != nil && ![previousNameText isEqualToString:@""]){
        fileName.text = previousNameText;
    }else if([emptyName isEqualToString:@""]){
        fileName.text = @"Save as";
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
     
     if([emptyName isEqualToString:@""] || [nameString isEqualToString:@"Save as"]){
         isReady = NO;
     }else{
         isReady = YES;
     }
    
    //if([parent isDuplicateFilename:nameString]){
    //    isReady = NO;
    //}
    
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
    static CGFloat targetOffset = 62;
    if(scrollView.contentOffset.x >= targetOffset){
        scrollView.contentOffset = CGPointMake(targetOffset, 0.0);
    }
}

-(NSString *)getNameForFile
{
    return fileText.text;
}

@end
