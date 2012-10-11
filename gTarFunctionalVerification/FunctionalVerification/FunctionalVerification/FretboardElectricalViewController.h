//
//  FretboardElectricalViewController.h
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/15/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GtarController/GtarController.h>

@interface FretboardElectricalViewController : UIViewController<GtarControllerObserver>

@property (strong, nonatomic) IBOutlet UIView * checkboxesView;

@end
