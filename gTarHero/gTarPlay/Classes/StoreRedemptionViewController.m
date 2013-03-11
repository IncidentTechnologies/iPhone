//
//  StoreRedemptionViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 8/19/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StoreRedemptionViewController.h"

#import "StoreNavigationViewController.h"

@implementation StoreRedemptionViewController

@synthesize m_textField;
@synthesize m_buttonView;
@synthesize m_activityIndicator;
@synthesize m_statusLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_textField release];
    [m_buttonView release];
    [m_activityIndicator release];
    [m_previousText release];
    [m_statusLabel release];
    
    [super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_textField = nil;
    self.m_buttonView = nil;
    self.m_activityIndicator = nil;
    self.m_statusLabel = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [m_textField becomeFirstResponder];
    [m_statusLabel setHidden:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [m_textField resignFirstResponder];
}

#pragma mark - Button clicked handler

- (IBAction)redeemButtonClicked:(id)sender
{
    
    NSString * currentText = [m_textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];

    if ( [currentText length] == 16 )
    {
        [m_buttonView setHidden:YES];
        
        [m_activityIndicator startAnimating];
        
        [(StoreNavigationViewController*)m_navigationController redeemCreditCode:currentText];
    }
    
}

#pragma mark - UITextFielDelegate

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string
{
    // is this addition going in at the end?
    if ( range.location == [textField.text length] )
    {
        m_intraStringEditing = NO;
    }
    else
    {
        m_intraStringEditing = YES;
    }
    
    // remove exising '-' chars
    NSString * currentText = [m_textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];

    // count the new chars, discount the replaced chars
    NSUInteger newLength = [currentText length] + [string length] - range.length;

    if ( newLength > 16 )
    {
        return NO;
    }
    else
    {
        return YES;
    }

}


- (IBAction)textFieldDidChange:(id)sender
{

    // break infinite recursions
    if ( [m_textField.text isEqualToString:m_previousText] == YES )
    {
        return;
    }

    // dont mess with the '-' if they are correcting something in the middle
    if ( m_intraStringEditing == YES )
    {
        return;
    }
    
    // remove exising '-' chars
    NSString * currentText = [m_textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    
    NSString * newText = @"";
    
    for ( NSInteger location = 0; location < 16; location += 4 )
    {
        
        NSInteger remainingLength = [currentText length] - location;
        
        NSRange range;
        range.location = location;
        
        if ( remainingLength < 4 )
        {
            
            range.length = remainingLength;
            
            NSString * substring = [currentText substringWithRange:range];
            
            newText = [NSString stringWithFormat:@"%@%@",newText, substring];
            
            break;
            
        }
        else
        {
            range.length = 4;

            NSString * substring = [currentText substringWithRange:range];
            
            if ( remainingLength == 4 )
            {
                newText = [NSString stringWithFormat:@"%@%@",newText, substring];
            }
            else
            {
                newText = [NSString stringWithFormat:@"%@%@-",newText, substring];
            }
        }
        
    }
        
    [m_previousText release];
    
    m_previousText = [newText retain];
    
    [m_textField setText:newText];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [self redeemButtonClicked:textField];
    
    return YES;
    
}

#pragma mark - Misc

- (void)redeemSucceeded
{
    
    [m_activityIndicator stopAnimating];
    
    [m_buttonView setHidden:NO];
    
    [m_statusLabel setText:@"Success!"];
    
    [m_statusLabel setHidden:NO];

}

- (void)redeemFailed:(NSString*)reason
{

    [m_activityIndicator stopAnimating];

    [m_buttonView setHidden:NO];

    [m_statusLabel setText:reason];
    
    [m_statusLabel setHidden:NO];

}

@end
