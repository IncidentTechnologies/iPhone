//
//  SongProgressViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 8/10/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SongProgressViewController.h"
#import "SongProgressView.h"
#import "SongPreviewView.h"

#import <NSSongModel.h>
#import <NSSong.h>
#import <NSMeasure.h>
#import <NSNote.h>


@implementation SongProgressViewController

@synthesize m_songModel;
@synthesize m_progressView;
@synthesize m_progressIndicator;

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
    [m_songModel release];
    [m_progressView release];
    [m_progressIndicator release];
    
//    [m_songPreviewView removeFromSuperview];
//    [m_songPreviewView release];

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
    
    self.m_progressView = nil;
    self.m_progressIndicator = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma Attach and animate

- (void)attachToSuperview:(UIView*)superview
{
    
    self.view.center = CGPointMake( superview.center.x, self.view.frame.size.height / 2 );
    
    [superview addSubview:self.view];
    
    m_progressIndicator.transform = CGAffineTransformMakeTranslation( -m_progressIndicator.frame.size.width, 0);

//    m_songPreviewView = [[SongPreviewView alloc] initWithFrame:m_progressView.frame andSongModel:m_songModel];
//    
//    m_songPreviewView.center = m_progressView.center;
//    
//    [m_progressView addSubview:m_songPreviewView];
    
}

- (void)hideProgressView
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];

    self.view.transform = CGAffineTransformMakeTranslation( 0 , -self.view.frame.size.height );
    
    [UIView commitAnimations];

}

- (void)showProgressView
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    self.view.transform = CGAffineTransformIdentity;
    
    [UIView commitAnimations];

}

- (void)updateView
{
    
//    [m_songPreviewView updateView];
    
    m_progressIndicator.transform = CGAffineTransformMakeTranslation( -m_progressIndicator.frame.size.width*(1.0-m_songModel.m_percentageComplete), 0);
    
}

- (void)resetView;
{

    m_progressIndicator.transform = CGAffineTransformMakeTranslation( -m_progressIndicator.frame.size.width, 0);
    
//    [m_songPreviewView removeFromSuperview];
//    [m_songPreviewView release];
//    
//    m_songPreviewView = [[SongPreviewView alloc] initWithFrame:m_progressView.frame andSongModel:m_songModel];
//    
//    [self.view addSubview:m_songPreviewView];
    
}

@end
