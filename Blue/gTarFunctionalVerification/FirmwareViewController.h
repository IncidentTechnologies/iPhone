//
//  FirmwareViewController.h
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GuitarController.h"

@interface FirmwareViewController : UIViewController <GuitarControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel * firmwareLabel;

@end
