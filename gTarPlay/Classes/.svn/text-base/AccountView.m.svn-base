//
//  AccountView.m
//  gTarPlay
//
//  Created by Marty Greenia on 11/1/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "AccountView.h"

#import "RoundedRectangleView.h"
#import "ExpandingRoundedRectangleView.h"
#import "CustomSegmentedControl.h"

#define SMALL_VIEW_HEIGHT 45
#define HEADING_HEIGHT 23
#define FOOTER_HEIGHT 23
#define PROFILE_BUTTON_WIDTH 100

@implementation AccountView

@synthesize m_loginButton;
@synthesize m_logoutButton;
@synthesize m_profileButton;
@synthesize m_tableView;
@synthesize m_retryCacheLoginButton;
@synthesize m_feedSelector;
@synthesize m_noContentLabel;
@synthesize m_feedActivityIndicator;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        
        //
        // Small view
        //
        m_smallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, SMALL_VIEW_HEIGHT)];
        m_smallView.layer.cornerRadius = 5;
        m_smallView.layer.borderWidth = 1;
        m_smallView.layer.borderColor = [[UIColor grayColor] CGColor];
        m_smallView.clipsToBounds = YES;
        
        UIColor * color1 = [UIColor colorWithRed:0.0f/255.0f green:174.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
        UIColor * color2 = [UIColor colorWithRed:0.0f/255.0f green:137.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
        UIColor * color3 = [UIColor colorWithRed:0.0f/255.0f green:130.0f/255.0f blue:184.0f/255.0f alpha:1.0f];
        UIColor * color4 = [UIColor colorWithRed:0.0f/255.0f green:130.0f/255.0f blue:183.0f/255.0f alpha:1.0f];
        
        CAGradientLayer * gradient = [CAGradientLayer layer];
        gradient.frame = m_smallView.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[color1 CGColor],
                           (id)[color2 CGColor],
                           (id)[color3 CGColor],
                           (id)[color4 CGColor], nil];
        gradient.locations = [NSArray arrayWithObjects:
                              (id)[NSNumber numberWithFloat:0.0f],
                              (id)[NSNumber numberWithFloat:0.2f],
                              (id)[NSNumber numberWithFloat:0.3f],
                              (id)[NSNumber numberWithFloat:1.0f], nil];
        [m_smallView.layer insertSublayer:gradient atIndex:0];
        
        [self addSubview:m_smallView];
        
        //
        // Large view
        //
        m_largeView = [[UIView alloc] initWithFrame:m_smallView.frame];
        m_largeView.layer.cornerRadius = 5;
        m_largeView.layer.borderWidth = 1;
        m_largeView.layer.borderColor = [[UIColor grayColor] CGColor];
        m_largeView.clipsToBounds = YES;
        m_largeView.backgroundColor = [UIColor whiteColor];
        gradient = [CAGradientLayer layer];
        gradient.frame = m_largeView.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[color1 CGColor],
                           (id)[color2 CGColor],
                           (id)[color3 CGColor],
                           (id)[color4 CGColor], nil];
        gradient.locations = [NSArray arrayWithObjects:
                              (id)[NSNumber numberWithFloat:0.0f],
                              (id)[NSNumber numberWithFloat:0.2f],
                              (id)[NSNumber numberWithFloat:0.3f],
                              (id)[NSNumber numberWithFloat:1.0f], nil];
        [m_largeView.layer insertSublayer:gradient atIndex:0];
        
        [self insertSubview:m_largeView belowSubview:m_smallView];
        
        // Stuff for small view
        
        // Normal activity indicator
        m_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        m_activityIndicator.center = m_smallView.center;
        m_activityIndicator.hidesWhenStopped = YES;
        
        [m_smallView addSubview:m_activityIndicator];
        
        // Login view
        m_loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        m_loginButton.frame = CGRectMake(0, 0, 175, 37);
        m_loginButton.center = CGPointMake(m_smallView.frame.size.width/2, m_smallView.frame.size.height/2);
        [m_loginButton setTitle:@"Login to Facebook" forState:UIControlStateNormal];
        [m_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [m_loginButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [m_loginButton setBackgroundColor:[UIColor clearColor]];
        m_loginButton.titleLabel.shadowColor = [UIColor darkGrayColor];
        m_loginButton.titleLabel.shadowOffset = CGSizeMake( 1, 1 );
        
        [m_smallView addSubview:m_loginButton];
        
        // Stuff for large view
        
        // Profile button
        m_profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        m_profileButton.frame = CGRectMake(m_smallView.frame.size.width-PROFILE_BUTTON_WIDTH, 0, PROFILE_BUTTON_WIDTH, m_smallView.frame.size.height);
        [m_profileButton setTitle:@"Profile" forState:UIControlStateNormal];
        [m_profileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [m_profileButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [m_profileButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [m_profileButton setImage:[UIImage imageNamed:@"WhiteBackArrow_RIGHT.png"] forState:UIControlStateNormal];
        [m_profileButton setBackgroundColor:[UIColor clearColor]];
        [m_profileButton setImageEdgeInsets:UIEdgeInsetsMake(18.0, 70.0, 13.0, 15.0)];
        [m_profileButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0, -25.0, 0.0, 25.0)];
        m_profileButton.titleLabel.shadowOffset = CGSizeMake( 1, 1 );
        
        [m_largeView addSubview:m_profileButton];
        
        // Cach login spinner
        m_cacheLoginActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:m_profileButton.frame];
        m_cacheLoginActivityIndicator.hidesWhenStopped = YES;
        
        [m_largeView addSubview:m_cacheLoginActivityIndicator];
        
        // Retry login button
        m_retryCacheLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        m_retryCacheLoginButton.frame = m_profileButton.frame;
        [m_retryCacheLoginButton setTitle:@"Retry" forState:UIControlStateNormal];
        [m_profileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [m_profileButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [m_profileButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        m_profileButton.titleLabel.shadowOffset = CGSizeMake( 1, 1 );
        
        [m_largeView addSubview:m_retryCacheLoginButton];
        
        // Header label
//        m_headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, SMALL_VIEW_HEIGHT, m_smallView.frame.size.width, HEADING_HEIGHT)];
//        m_headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -1, m_smallView.frame.size.width, HEADING_HEIGHT )];
//        m_headerLabel.textAlignment = UITextAlignmentCenter;
//        m_headerLabel.textColor = [UIColor whiteColor];
//        m_headerLabel.backgroundColor = [UIColor clearColor];
//        [m_headerLabel setText:@"Activity Feed"];
//        m_headerLabel.shadowColor = [UIColor grayColor];
//        m_headerLabel.shadowOffset = CGSizeMake( 1, 1 );
//        m_headerLabel.font = [m_headerLabel.font fontWithSize:16.0];
//        
//        m_headerView.layer.borderColor = [[UIColor grayColor] CGColor];
//        m_headerView.layer.borderWidth = 1;
//        
//        [m_headerView addSubview:m_headerLabel];
//        
//        // Draw a background gradient for the header view
//        color1 = [UIColor colorWithRed:205.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
//        color2 = [UIColor colorWithRed:202.0f/255.0f green:202.0f/255.0f blue:202.0f/255.0f alpha:1.0f];
//        color3 = [UIColor colorWithRed:179.0f/255.0f green:179.0f/255.0f blue:179.0f/255.0f alpha:1.0f];
//        color4 = [UIColor colorWithRed:101.0f/255.0f green:101.0f/255.0f blue:101.0f/255.0f alpha:1.0f];
//        gradient = [CAGradientLayer layer];
//        gradient.frame = m_headerView.bounds;
//        gradient.colors = [NSArray arrayWithObjects:
//                           (id)[color1 CGColor],
//                           (id)[color2 CGColor],
//                           (id)[color3 CGColor],
//                           (id)[color4 CGColor], nil];
//        gradient.locations = [NSArray arrayWithObjects:
//                              (id)[NSNumber numberWithFloat:0.05f],
//                              (id)[NSNumber numberWithFloat:0.2f],
//                              (id)[NSNumber numberWithFloat:0.8f],
//                              (id)[NSNumber numberWithFloat:1.0f], nil];
//        [m_headerView.layer insertSublayer:gradient atIndex:0];
        
//        [m_largeView addSubview:m_headerView];
        
        // 
        // This lets use select from between two feeds.
        // The feed selector replaces the header from above.
        //
        m_feedSelector = [[CustomSegmentedControl alloc] initWithFrame:CGRectMake(0, SMALL_VIEW_HEIGHT, m_smallView.frame.size.width, HEADING_HEIGHT)];
        [m_feedSelector changeTitles:[NSArray arrayWithObjects:@"Friends", @"Global", nil]];
        
        [m_feedSelector setFontSize:15];
        
        [m_largeView addSubview:m_feedSelector];
        
        //
        // Welcome user label
        //
        m_welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, m_smallView.frame.size.width-PROFILE_BUTTON_WIDTH-10, m_smallView.frame.size.height)];
        [m_welcomeLabel setText:@"Hi"];
        [m_welcomeLabel setTextColor:[UIColor whiteColor]];
        [m_welcomeLabel setBackgroundColor:[UIColor clearColor]];
        m_welcomeLabel.shadowColor = [UIColor darkGrayColor];
        m_welcomeLabel.shadowOffset = CGSizeMake( 1, 1 );
        
        [m_largeView addSubview:m_welcomeLabel];
        
        // Logout button
//        m_logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        m_logoutButton.frame = CGRectMake(6, 31, 70, 20);
//        [m_logoutButton setTitle:@"Log out" forState:UIControlStateNormal];
//        [m_logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [m_logoutButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
//        [m_logoutButton setImage:[UIImage imageNamed:@"WhiteBackArrow_RIGHT.png"] forState:UIControlStateNormal];
//        [m_logoutButton setBackgroundColor:[UIColor clearColor]];
//        [m_logoutButton setImageEdgeInsets:UIEdgeInsetsMake(6.0, 55.0, 6.0, 8.0)];
//        [m_logoutButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -30.0, 0.0, 20.0)];
//        m_logoutButton.titleLabel.shadowColor = [UIColor darkGrayColor];
//        m_logoutButton.titleLabel.shadowOffset = CGSizeMake( 1, 1 );
//        m_logoutButton.titleLabel.font = [m_logoutButton.titleLabel.font fontWithSize:12.0];
        
//        [m_largeView addSubview:m_logoutButton];
        
        //
        // Create the feed table.
        //
        m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SMALL_VIEW_HEIGHT + HEADING_HEIGHT,
                                                                    m_smallView.frame.size.width - 0,
                                                                    self.frame.size.height - SMALL_VIEW_HEIGHT - HEADING_HEIGHT - 0)];
        m_tableView.clipsToBounds = YES;
        
        [m_largeView addSubview:m_tableView];
        
        //
        // There is no content available.
        // Put this behind the table view so we can hide it when content is available.
        //
        m_noContentLabel = [[UILabel alloc] initWithFrame:m_tableView.frame];
        
        [m_noContentLabel setText:@"No activity found"];
        m_noContentLabel.textColor = [UIColor grayColor];
        m_noContentLabel.shadowColor = [UIColor lightGrayColor];
        m_noContentLabel.shadowOffset = CGSizeMake( 1, 1 );
        m_noContentLabel.textAlignment = UITextAlignmentCenter;
        
        // 
        // We are reloading content.
        // Put this behind the table view so we can hide it when content is available/
        //
        m_feedActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [m_feedActivityIndicator setFrame:m_tableView.frame];
        m_feedActivityIndicator.hidesWhenStopped = YES;
        [m_feedActivityIndicator stopAnimating];
        
        [m_largeView insertSubview:m_noContentLabel belowSubview:m_tableView];
        [m_largeView insertSubview:m_feedActivityIndicator belowSubview:m_tableView];
        
        //
        // This is a nicer looking activity indicator.
        //
        m_footerFeedActivityIndicatorView = [[UITableView alloc] initWithFrame:CGRectMake(0, m_largeView.frame.size.height - FOOTER_HEIGHT,
                                                                                          m_smallView.frame.size.width,
                                                                                          FOOTER_HEIGHT)];
        

    }
    
    return self;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    
    [m_smallView release];
    [m_largeView release];
    
    [m_loginButton release];
    [m_profileButton release];
    [m_activityIndicator release];
    [m_headerLabel release];
    [m_headerView release];
    [m_feedSelector release];
    [m_welcomeLabel release];
    [m_cacheLoginActivityIndicator release];
    [m_retryCacheLoginButton release];
    
    [m_tableView release];
    [m_noContentLabel release];
    [m_feedActivityIndicator release];
    [m_footerFeedActivityIndicatorView release];
    
    [super dealloc];
    
}

#pragma mark - Animation helpers

- (void)startActivityIndicator
{
    
    [m_loginButton setHidden:YES];
    [m_activityIndicator startAnimating];
    
}

- (void)stopActivityIndicator
{
    
    [m_loginButton setHidden:NO];
    [m_activityIndicator stopAnimating];
    
}

- (void)startCacheLoginActivityIndicator
{
    
    [m_cacheLoginActivityIndicator startAnimating];
    
    [m_retryCacheLoginButton setHidden:YES];
    
    [m_profileButton setHidden:YES];
    
}

- (void)stopCacheLoginActivityIndicator
{

    [m_cacheLoginActivityIndicator stopAnimating];
    
    [m_retryCacheLoginButton setHidden:YES];
    
    [m_profileButton setHidden:NO];
    
}

- (void)failedCacheLoginActivityIndicator
{
    
    [m_cacheLoginActivityIndicator stopAnimating];
    
    [m_retryCacheLoginButton setHidden:NO];
    
    [m_profileButton setHidden:YES];
    
}

- (void)expandAccountView:(BOOL)animated
{
    
    [m_activityIndicator stopAnimating];
    
    if ( animated == YES)
    {
    
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        
        m_smallView.alpha = 0.0f;
        
        [m_largeView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        [UIView commitAnimations];
    }
    else
    {
        m_smallView.alpha = 0.0f;
        
        [m_largeView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }        
    
}

- (void)contractAccountView
{
    
    [m_loginButton setHidden:NO];

    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
    
    m_smallView.alpha = 1.0f;
    
    [m_largeView setFrame:CGRectMake(0, 0, m_smallView.frame.size.width, m_smallView.frame.size.height)];
    
	[UIView commitAnimations];
    
}

@end
