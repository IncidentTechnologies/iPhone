//
//  SummaryViewController.h
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextView * summaryView;
@property (nonatomic, strong) IBOutlet UILabel * resultLabel;

- (IBAction)doneButtonClicked:(id)sender;

@end
