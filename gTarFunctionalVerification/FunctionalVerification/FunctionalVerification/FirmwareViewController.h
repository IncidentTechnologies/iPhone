//
//  FirmwareViewController.h
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/14/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GtarControllerInternal.h>

@interface FirmwareViewController : UIViewController <GtarControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel * firmwareLabel;

@end
