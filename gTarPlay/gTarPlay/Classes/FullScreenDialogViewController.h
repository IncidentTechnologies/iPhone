//
//  FullScreenDialogViewController.h
//  gTarPlay
//
//  Created by Joel Greenia on 3/2/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface FullScreenDialogViewController : UIViewController
{
    FullScreenDialogViewController * m_previousDialog;
    RootViewController * m_rootViewController;
}

@property (nonatomic, assign) FullScreenDialogViewController * m_previousDialog;
@property (nonatomic, assign) RootViewController * m_rootViewController;

- (void)attachToSuperview:(UIView*)view;
- (void)detachFromSuperview;

@end
