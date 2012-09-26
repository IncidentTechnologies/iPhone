//
//  GuitarEffectCell.m
//  gTarDemo
//
//  Created by Joel Greenia on 11/15/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import "GuitarEffectCell.h"
#import "GuitarEffect.h"
#import "SecondViewController.h"

@implementation GuitarEffectCell

@synthesize m_secondViewController;
@synthesize m_guitarEffect;
@synthesize m_clearFirstLabel;
@synthesize m_colorLabel;
@synthesize m_colorRandomLabel;
@synthesize m_directionLabel;
@synthesize m_directionRandomLabel;
@synthesize m_durationLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self )
    {
        // Initialization code
    }
    
    return self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)upButtonClicked:(id)sender
{
    [m_secondViewController moveEffectUp:m_guitarEffect];
}

- (IBAction)downButtonClicked:(id)sender
{
    [m_secondViewController moveEffectDown:m_guitarEffect];
}

- (IBAction)deleteButtonClicked:(id)sender
{
    [m_secondViewController deleteEffect:m_guitarEffect];
}

- (void)updateCell
{
    
    if ( m_guitarEffect.m_clearFirst == YES )
    {
        [m_clearFirstLabel setText:@"Clear"];
    }
    else
    {
        [m_clearFirstLabel setText:@"NoClear"];
    }
    
    [m_colorLabel setText:[NSString stringWithFormat:@"%u%u%u", m_guitarEffect.m_colorRed, m_guitarEffect.m_colorGreen, m_guitarEffect.m_colorBlue]];
    
    if ( m_guitarEffect.m_colorRandom == YES )
    {
        [m_colorRandomLabel setText:@"Random"];
    }
    else
    {
        [m_colorRandomLabel setText:@"Exact"];
    }
    
    if ( m_guitarEffect.m_direction == 0 )
    {
        [m_directionLabel setText:@"Up"];
    }
    if ( m_guitarEffect.m_direction == 1 )
    {
        [m_directionLabel setText:@"Down"];
    }
    if ( m_guitarEffect.m_direction == 2 )
    {
        [m_directionLabel setText:@"Left"];
    }
    if ( m_guitarEffect.m_direction == 3 )
    {
        [m_directionLabel setText:@"Right"];
    }
    
    if ( m_guitarEffect.m_directionScattering == YES )
    {
        [m_directionRandomLabel setText:@"Scattered"];
    }
    else
    {
        [m_directionRandomLabel setText:@"Exact"];
    }
    
    [m_durationLabel setText:[NSString stringWithFormat:@"%.2f",m_guitarEffect.m_duration]];
    
}

@end
