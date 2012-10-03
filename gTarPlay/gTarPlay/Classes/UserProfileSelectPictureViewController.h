//
//  UserProfileSelectPictureViewController.h
//  gTarPlay
//
//  Created by Joel Greenia on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <gTarAppCore/PopupViewController.h>

#import "UserProfileNavigationController.h"

@interface UserProfileSelectPictureViewController : PopupViewController
{
    
    UserProfileNavigationController * m_navigationController;
    
}

@property (nonatomic, retain) UserProfileNavigationController * m_navigationController;

- (IBAction)picButtonClicked:(id)sender;
- (IBAction)pic1Clicked:(id)sender;
- (IBAction)pic2Clicked:(id)sender;
- (IBAction)pic3Clicked:(id)sender;
- (IBAction)pic4Clicked:(id)sender;
- (IBAction)pic5Clicked:(id)sender;
- (IBAction)pic6Clicked:(id)sender;

@end
