//
//  InfoViewController.h
//  Sequence
//
//  Created by Kate Schnippering on 2/19/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol InfoDelegate <NSObject>

@end

@interface InfoViewController : UIViewController
{
    
    
}

-(IBAction)launchLearnMore:(id)sender;

@property (weak, nonatomic) id<InfoDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton * infoButton;
@property (weak, nonatomic) IBOutlet UIImageView * infoArrow;

@end
