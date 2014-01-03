//
//  InstrumentTableCell.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "InstrumentTableViewCell.h"
#import "InstrumentTableViewController.h"

@implementation InstrumentTableViewCell

@synthesize parent;
@synthesize instrumentIconView;
@synthesize instrumentIconBorder;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)userDidTapInstrumentIcon:(id)sender
{
    if ( deleteMode )
    {
        [self disableDeleteMode];
        
        [parent deleteCell:self];
    }
    else {
        [self enableDeleteMode];
    }
}

- (void)enableDeleteMode
{
    
    //UIColor * customRed = [UIColor redColor];
    UIColor * customRed = [UIColor colorWithRed:131/255.0 green:12/255.0 blue:54/255.0 alpha:1];
    deleteMode = YES;
    
    instrumentIconView.backgroundColor = customRed;
    instrumentIconBorder.backgroundColor = customRed;
    
    self.instrumentIconView.image = [UIImage imageNamed:@"Icon_Trash"];
    
    // touch catcher:
    //[self updateTouchCatcher];
    //[touchCatcher setHidden:NO];
}

- (void)disableDeleteMode
{
    
    UIColor * customBlue = [UIColor colorWithRed:22/255.0 green:41/255.0 blue:68/255.0 alpha:1];
    
    deleteMode = NO;
    
    instrumentIconView.backgroundColor = customBlue;
    instrumentIconBorder.backgroundColor = customBlue;
    
    self.instrumentIconView.image = self.instrumentIcon;
    
    // touch catcher:
    // [touchCatcher setHidden:YES];
}

@end
