//
//  NewsViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/16/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "NewsViewController.h"

#import <CloudController.h>

#import <NewsStory.h>
#import <NewsTicker.h>
#import <CloudResponse.h>

extern CloudController * g_cloudController;

@implementation NewsViewController

@synthesize m_newsTickerView;

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
    
    [m_newsTickerView release];
    
    [m_newsStories release];

    [super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_newsTickerView = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark News Ticker Helpers

- (void)getNewsHeadlines
{
    
    [g_cloudController requestNewsHeadlinesCallbackObj:self andCallbackSel:@selector(requestNewsHeadlinesCallback:)];
    
}

- (void)requestNewsHeadlinesCallback:(CloudResponse*)cloudResponse
{
	
	if ( cloudResponse.m_status == CloudResponseStatusSuccess )
	{
		
		[m_newsStories release];
        
//        m_newsStories = [cloudResponse.m_responseNewsTicker.m_newsArray retain];
                
	}
    
    [self startNewsTicker];
    
}


- (void)startNewsTicker
{
    
    m_currentNewsStory = 0;
    
    m_newsTickerTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(cycleNewsTicker) userInfo:nil repeats:YES];
    
    [self cycleNewsTicker];
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0f];
    
	m_newsTickerView.alpha = 1.0f;
    
	[UIView commitAnimations];
	    
}

- (void)stopNewsTicker
{
    
    [m_newsTickerTimer invalidate];
    
    m_newsTickerTimer = nil;

	m_newsTickerView.alpha = 0.0f;

}

- (void)cycleNewsTicker
{
    
    if ( [m_newsStories count] > m_currentNewsStory )
    {
        NewsStory * newsStory = [m_newsStories objectAtIndex:m_currentNewsStory];
        
        NSString * headline = [newsStory.m_headline stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [m_newsTickerView setTitle:headline forState:UIControlStateNormal];
        
        m_currentNewsStory = (m_currentNewsStory + 1) % [m_newsStories count];
    }
    
}

#pragma -
#pragma News story clicked

- (IBAction)newsStoryClicked:(id)sender
{
    
    NewsStory * newsStory = [m_newsStories objectAtIndex:m_currentNewsStory];
    
    NSString * link =  [newsStory.m_link stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
    
}



@end
