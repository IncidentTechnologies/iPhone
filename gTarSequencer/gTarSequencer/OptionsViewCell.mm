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

//#define DEFAULT_SET_NAME @"Tutorial"
#define DEFAULT_FILE_TEXT @"Save as"
#define TABLE_SETS @"Sequences"
#define TABLE_SONGS @"Songs"

@implementation OptionsViewCell

@synthesize parent;
@synthesize fileText;
@synthesize fileName;
@synthesize fileLoad;
@synthesize fileDate;
@synthesize activeIndicator;
@synthesize isRenamable;
@synthesize rowid;
@synthesize isNameEditing;
@synthesize setButton;
@synthesize songButton;
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

- (void)awakeFromNib
{
    [super awakeFromNib];

    // Adjust layout to phone size
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    float x = [frameGenerator getFullscreenWidth];
    
    [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.y,x,self.frame.size.height)];
    
    _setButtonWidth.constant = x/2.0;
    _songButtonWidth.constant = x/2.0;
    _songButtonLeftConstraint.constant = x/2.0;
    
    // Add swipe recognizer for deleting
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
    self.panRecognizer.delegate = self;
    
    [self.container addGestureRecognizer:self.panRecognizer];
}


- (void)sharedInit
{
    isActiveSequencer = NO;
    isActiveSong = NO;
    isEditingMode = NO;
    
    darkGrayColor = [UIColor colorWithRed:50/255.0 green:56/255.0 blue:59/255.0 alpha:1.0];
    blueColor = [UIColor colorWithRed:23/255.0 green:163/255.0 blue:198/255.0 alpha:1.0];
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
    
    if(![fileText.text isEqualToString:DEFAULT_SET_NAME]){
        
        // Setup text field listener
        [fileName addTarget:self action:@selector(saveFieldStartEdit:) forControlEvents:UIControlEventEditingDidBegin];
        [fileName addTarget:self action:@selector(saveFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [fileName addTarget:self action:@selector(saveFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        // Setup gesture recognizer
        UITapGestureRecognizer * doubletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubletap.numberOfTapsRequired = 2;
        
        [self addGestureRecognizer:doubletap];
    }
    
    // Active indicator
    activeIndicator.layer.cornerRadius = activeIndicator.frame.size.width/2;
    
}

- (void)setAsActiveSequencer
{
    if(!isRenamable){
        isActiveSequencer = YES;
        [self setActive];
    }
}

- (void)unsetAsActiveSequencer
{
    isActiveSequencer = NO;
    [self unsetActive];
}

- (void)setAsActiveSong
{
    if(!isRenamable){
        isActiveSong = YES;
        [self setActive];
    }
}

- (void)unsetAsActiveSong
{
    isActiveSong = NO;
    [self unsetActive];
}

- (void)setActive
{
    fileText.textColor = activeColor;
    [self applyBoldFont:YES toLabel:fileText];
    [activeIndicator setBackgroundColor:blueColor];
}

- (void)unsetActive
{
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
        
        DLog(@"Selecting cell at row %i",rowid);
        
        self.container.backgroundColor = darkGrayColor;
        
        fileText.textColor = ((isActiveSequencer || isActiveSong) && !isRenamable) ? activeColor : [UIColor whiteColor];
        
        [fileLoad setHidden:NO];
        [self setImageForFileLoad:parent.selectMode];
        
        // Modal changes
        if([parent.selectMode isEqualToString:@"SaveCurrent"] && isRenamable){
            
            DLog(@"Selected cell is Renamable");
            
            [fileText setHidden:YES];
            [fileName setHidden:NO];
            
            // open keyboard
            [self beginNameEditing];
        }else{
            // Save load button
            [self showHideButton:fileLoad isHidden:NO withSelector:@selector(userDidSaveLoad) withAnimation:NO];
        }
        
        //[parent deselectAllRowsExcept:self];
        
    }else{
        
        //if(!isEditingMode){
            
            DLog(@"Deselecting cell %i",rowid);
            
            [self endNameEditing];
            
            if([parent.selectMode isEqualToString:@"SaveCurrent"] && isRenamable){
                self.container.backgroundColor = [UIColor grayColor];
            }else{
                self.container.backgroundColor = [UIColor whiteColor];
            }
            
            fileText.textColor = ((isActiveSequencer || isActiveSong) && !isRenamable) ? activeColor : darkGrayColor;
            [fileLoad setHidden:YES];
            
            [fileText setHidden:NO];
            [fileName setHidden:YES];
        //}else{
            
        //    DLog(@"*** Not deselecting cell %i",rowid);
        //}
        
    }
    
    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
    
    // Check font for active sequencer
    if((isActiveSequencer || isActiveSong) && !isRenamable){
        [self applyBoldFont:YES toLabel:fileText];
    }else{
        [self applyBoldFont:NO toLabel:fileText];
    }
    
    // Configure the view for the selected state
}

- (void)userDidSaveLoad
{
    if([parent.selectMode isEqualToString:@"Load"]){
        
        DLog(@"Load file %@",fileText.text);
        
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
    DLog(@"Editing cell mode began");
    isEditingMode = YES;
}

-(void)editingDidEnd
{
    DLog(@"Editing cell mode ended");
    
    isEditingMode = NO;
}

#pragma mark - Save Field
- (void)saveFieldStartEdit:(id)sender
{
    isNameEditing = YES;
    
    previousNameText = fileName.text;
    
    if([fileName.text isEqualToString:DEFAULT_FILE_TEXT] || [fileName.text isEqualToString:@""] || [fileName.text isEqualToString:DEFAULT_SET_NAME]){
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
    DLog(@"Init file attributed string");
    
    if(![fileName.text isEqualToString:DEFAULT_FILE_TEXT] && ![fileName.text isEqualToString:@""]){
        // create attributed string
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:fileName.text];
        [str addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:40/255.0 green:47/255.0 blue:51/255.0 alpha:1.0] range:NSMakeRange(0, fileName.text.length)];
        [str addAttribute:NSForegroundColorAttributeName value:blueColor range:NSMakeRange(0,fileName.text.length)];
        
        [fileName setAttributedText:str];
    }
}

- (void)clearFileAttributedString
{
    
    // create attributed string
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:fileName.text];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0, fileName.text.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,fileName.text.length)];
    
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
    
    // hide keyboard
    if([fileName isFirstResponder]){
        
        [fileName resignFirstResponder];
        [parent resetTableOffset:self];
        [parent enableScroll];
    }
    
    // save a rename
    if([parent.selectMode isEqualToString:@"Load"] && ![fileName.text isEqualToString:@""] && ![fileName.text isEqualToString:DEFAULT_SET_NAME]){
        
        // auto rename if duplicate
        if([parent isDuplicateFilename:fileName.text] && ![fileName.text isEqualToString:previousNameText]){
            //fileName.text = [parent generateNextSetName];
            fileName.text = previousNameText;
            [parent alertDuplicateFilename];
        }else if([parent isDuplicateFilename:fileName.text]){
            fileName.text = previousNameText;
        }
        
        // rename
        [self userDidRename];
        
    }else if([fileName.text isEqualToString:@""] || [fileName.text isEqualToString:DEFAULT_SET_NAME]){
        [self setSelected:NO animated:NO];
    }
    
    [self endNameEditing];
    [self clearFileAttributedString];
}

- (void)beginNameEditing
{
    isNameEditing = YES;
    
    DLog(@"Begin name editing");
    
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
    
    DLog(@"End name editing");
    
    // hide keyboard
    if([fileName isFirstResponder]){
        
        [fileName resignFirstResponder];
        [parent resetTableOffset:self];
        [parent enableScroll];
    }
    
    [self resetFileNameIfBlank];
    [parent enableScroll];
}

-(void)resetFileNameIfBlank
{
    DLog(@"Reset filename if blank");
    
    NSString * nameString = fileName.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""] && previousNameText != nil && ![previousNameText isEqualToString:@""]){
        fileName.text = previousNameText;
    }else if([emptyName isEqualToString:@""]){
        fileName.text = DEFAULT_FILE_TEXT;
    }/*else if([parent isDuplicateFilename:nameString]){
        fileName.text = [parent generateNextSetName];
        [self checkIfNameReady];
    }*/
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
    DLog(@"Check if name ready");
    
    BOOL isReady = YES;
    NSString * nameString = fileName.text;
    NSString * emptyName = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([emptyName isEqualToString:@""] || [nameString isEqualToString:DEFAULT_FILE_TEXT] || [nameString isEqualToString:DEFAULT_SET_NAME]){
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
        DLog(@"****** force select");
        [self setSelected:YES animated:NO];
    }
    
    if([parent.selectMode isEqualToString:@"Load"]){
        
        if(![fileText.text isEqualToString:DEFAULT_SET_NAME] && [setButton isHidden]){
            fileName.text = fileText.text;
            
            [fileText setHidden:YES];
            [fileName setHidden:NO];
            
            // open keyboard
            [self beginNameEditing];
        }
    }
}


-(NSString *)getNameForFile
{
    return fileText.text;
}

#pragma mark - Set and Song toggle

- (IBAction)userDidSelectSetButton:(id)sender
{
    [self highlightSetButton];
    
    [parent loadTableWith:TABLE_SETS];
}

- (IBAction)userDidSelectSongButton:(id)sender
{
    [self highlightSongButton];
    
    [parent loadTableWith:TABLE_SONGS];
    
}

- (void)highlightSetButton
{
    [setButton setBackgroundColor:darkGrayColor];
    [setButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[setButton titleLabel] setFont:[UIFont fontWithName:@"Avenir Next" size:22.0]];
    
    [songButton setBackgroundColor:[UIColor whiteColor]];
    [songButton setTitleColor:darkGrayColor forState:UIControlStateNormal];
    [[songButton titleLabel] setFont:[UIFont fontWithName:@"Avenir Next" size:18.0]];
}

- (void)highlightSongButton
{
    [songButton setBackgroundColor:darkGrayColor];
    [songButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[songButton titleLabel] setFont:[UIFont fontWithName:@"Avenir Next" size:22.0]];
    
    [setButton setBackgroundColor:[UIColor whiteColor]];
    [setButton setTitleColor:darkGrayColor forState:UIControlStateNormal];
    [[setButton titleLabel] setFont:[UIFont fontWithName:@"Avenir Next" size:18.0]];
    
}

#pragma mark - Editing

// Allow the table to scroll vertically
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if(!isEditingMode){
        return YES;
    }else{
        return NO;
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO];
}

- (void)panCell:(UIPanGestureRecognizer *)recognizer
{
    if(![setButton isHidden] || [fileText.text isEqualToString:DEFAULT_SET_NAME] || [parent isLeftNavOpen]){
        return;
    }
    
    switch (recognizer.state) {
            
        case UIGestureRecognizerStateBegan:
        {
            self.panStartPoint = [recognizer translationInView:self.container];
            self.startingLeftConstraint = self.leftConstraint.constant;
            DLog(@"Pan Began at %@", NSStringFromCGPoint(self.panStartPoint));
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            
            CGPoint currentPoint = [recognizer translationInView:self.container];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            
            DLog(@"Pan Moved %f", deltaX);
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {
                panningLeft = YES;
            }
            
            if (!panningLeft) {
                
                // Close the cell
                
                CGFloat constant = deltaX;
                if (constant > 0) {
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                } else {
                    self.leftConstraint.constant = constant;
                    self.rightConstraint.constant = -1 * [self buttonTotalWidth] - constant;
                }
            } else if (fabs(self.leftConstraint.constant) < [self buttonTotalWidth]){
                
                // Open the cell
                
                CGFloat constant = deltaX;
                
                [self editingDidBegin];
                
                if (constant <= -1 * [self buttonTotalWidth]) {
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                } else {
                    self.leftConstraint.constant = constant;
                    self.rightConstraint.constant = -1 * [self buttonTotalWidth] - constant;
                }
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
            
            if (self.leftConstraint.constant < 0) {
                //Cell was opening
                CGFloat halfButton = -1 * [self buttonTotalWidth] / 2.0;
                if (self.leftConstraint.constant < halfButton) {
                    //Open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Re-close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            }else{
                // Re-close
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
            }
            
            DLog(@"Pan Ended");
            break;
            
        case UIGestureRecognizerStateCancelled:
            
            if (self.startingLeftConstraint == 0) {
                //Cell was closed - reset everything to 0
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
            } else {
                //Cell was open - reset to the open state
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            DLog(@"Pan Cancelled");
            break;
            
        default:
            break;
    }
}


- (CGFloat)buttonTotalWidth {
    return deleteButton.frame.size.width;
}

- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing
{
    self.leftConstraint.constant = 0.0;
    self.rightConstraint.constant = -1 * [self buttonTotalWidth];
    
    if(endEditing){
        [self editingDidEnd];
    }
}

- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
    self.leftConstraint.constant = -1 * [self buttonTotalWidth];
    self.rightConstraint.constant = 0.0;
}

- (IBAction)userDidSelectDeleteButton:(id)sender
{
    DLog(@"Delete cell");
    
    [parent deleteCell:self];
    
    [self editingDidEnd];
}


@end
