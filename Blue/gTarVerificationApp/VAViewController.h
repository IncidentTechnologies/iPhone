//
//  VAViewController.h
//  gTarVerificationApp
//
//  Created by Joel Greenia on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GtarController/GtarController.h>

@interface VAViewController : UIViewController <GtarControllerObserver>

@property (weak, nonatomic) IBOutlet UIImageView * connectedImageView;
@property (weak, nonatomic) IBOutlet UIImageView * disconnectedImageView;
@property (weak, nonatomic) IBOutlet UIView * fretboadView;

- (IBAction)redButtonClicked:(id)sender;
- (IBAction)greenButtonClicked:(id)sender;
- (IBAction)blueButtonClicked:(id)sender;
- (IBAction)whiteButtonClicked:(id)sender;

- (IBAction)resetButtonClicked:(id)sender;
@end
