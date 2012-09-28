//
//  FretboardElectricalViewController.h
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GuitarController.h"

@interface FretboardElectricalViewController : UIViewController<GuitarControllerObserver>

@property (strong, nonatomic) IBOutlet UIView * checkboxesView;

@end
