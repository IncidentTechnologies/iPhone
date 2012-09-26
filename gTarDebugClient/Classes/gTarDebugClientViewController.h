//
//  gTarDebugClientViewController.h
//  gTarDebugClient
//
//  Created by wuda on 10/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "gTarDebug.h"
#import "GuitarView.h"

@interface gTarDebugClientViewController : UIViewController <UIAlertViewDelegate>
{
	UIAlertView * m_connectionAlert;
	gTarDebug * m_debugger;
	IBOutlet GuitarView * m_gView;
}

@property (nonatomic, retain) UIAlertView * m_connectionAlert;
@property (nonatomic, retain) gTarDebug * m_debugger;
@property (nonatomic, retain) IBOutlet GuitarView * m_gView;

- (IBAction)startServerButtonClicked;
- (IBAction)startClientButtonClicked;

@end

