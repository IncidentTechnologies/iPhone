//
//  SlidingInstrumentViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/24/13.
//
//

#import <UIKit/UIKit.h>

#import "SlidingViewController.h"
#import <gTarAppCore/InstrumentTableViewController.h>

@interface SlidingInstrumentViewController : SlidingViewController <InstrumentSelectionDelegate>

@property (retain, nonatomic) IBOutlet UIView *innerContentView;

@property (readonly, nonatomic) BOOL loading;

@end
