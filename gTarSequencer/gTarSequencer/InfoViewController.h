//
//  InfoViewController.h
//  Sequence
//
//  Created by Kate Schnippering on 2/19/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"


@protocol InfoDelegate <NSObject>

@end

extern OphoMaster * g_ophoMaster;

@interface InfoViewController : UIViewController
{
    
    
}

-(IBAction)launchGtarLearnMore:(id)sender;
-(IBAction)launchOphoLogin:(id)sender;

@property (weak, nonatomic) id<InfoDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton * gtarButton;
@property (weak, nonatomic) IBOutlet UIImageView * gtarArrow;

@property (weak, nonatomic) IBOutlet UIButton * ophoButton;
@property (weak, nonatomic) IBOutlet UIImageView * ophoArrow;

@end
