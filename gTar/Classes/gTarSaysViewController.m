//
//  gTarSaysViewController.m
//  gTar
//
//  Created by wuda on 12/6/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "gTarSaysViewController.h"
#import "SaysScoreController.h"
#import "PlayController.h"

@implementation gTarSaysViewController

extern EAGLViewDisplayMode g_eaglDisplayMode;

- (void)playWithXmpBlob:(NSString*)xmpBlob
{
	
	if ( xmpBlob == nil )
	{
		return;
	}
	
	PlayController * playController = [[PlayController alloc] initWithNibName:@"SaysController" bundle:nil];

	playController.m_xmpBlob = xmpBlob;
	g_eaglDisplayMode = DisplayModeES;
	
	if ( m_debugger != nil )
	{
		playController.m_debugger = m_debugger;
	}
	if ( m_clone != nil )
	{
		playController.m_clone = m_clone;
	}
		
	playController.m_returnToController = self;
	
	// Score controller
	SaysScoreController * saysSc = [[SaysScoreController alloc] init];
	saysSc.m_nibName = @"SaysScoreController";
	saysSc.m_returnToController = self;
	
	playController.m_scoreController = saysSc;
	
	[playController changeDisplayMode:PlayControllerModeSays];
	
	// Navigate
	[self.navigationController pushViewController:playController animated:YES];
	
	// All done, release.
	[playController release];
	
}


@end
