//
//  LineOutViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/22/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "LineOutViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "Checklist.h"

extern Checklist g_checklist;

@interface LineOutViewController ()
{
    AVAudioPlayer * _audioPlayer;
}

@end

@implementation LineOutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSString * soundFilePath = [[NSBundle mainBundle] pathForResource:@"sth" ofType:@"mp3"];
    NSURL * newURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    
    NSError * error;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:newURL error:&error];
    _audioPlayer.numberOfLoops = -1;

    // Registers this class as the delegate of the audio session.
	[[AVAudioSession sharedInstance] setDelegate: self];
    
    // Initialize the AVAudioSession here.
	if ( ![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error] )
    {
        // Handle the error here.
		NSLog(@"Audio Session error %@, %@", error, [error userInfo] );
    }
              
    
    [_audioPlayer play];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [_audioPlayer stop];
    
    [super viewWillDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [segue.identifier isEqualToString:@"passSegue"] == YES )
    {
        g_checklist.lineOutTest = YES;
    }
    else
    {
        g_checklist.lineOutTest = NO;
    }
}

@end
