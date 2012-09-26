//
//  gTarRootViewController.h
//  EtarLearn
//
//  Created by Marty Greenia on 9/30/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LedMarquee.h"

@class EAGLView;


@interface gTarRootViewController : UIViewController
{
	IBOutlet UILabel * versionDate;
	IBOutlet UILabel * versionTime;
	IBOutlet EAGLView *glView;
	
	LedMarquee * m_ledMarquee;

}

@property (nonatomic, retain) UILabel * versionDate;
@property (nonatomic, retain) UILabel * versionTime;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

- (IBAction)learnButtonClicked:(id)sender;
- (IBAction)jamButtonClicked:(id)sender;
- (IBAction)playButtonClicked:(id)sender;
- (IBAction)saysButtonClicked:(id)sender;
- (IBAction)accountButtonClicked:(id)sender;
- (IBAction)testButtonClicked:(id)sender;

@end
