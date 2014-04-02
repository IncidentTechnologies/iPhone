//
//  LightsViewController.h
//  gTarPlay
//
//  Created by Franco on 3/28/13.
//
//

#import <GtarController/GtarController.h>

#import <UIKit/UIKit.h>

@interface LightsViewController : UIViewController <GtarControllerObserver> {
    
}

@property (nonatomic, retain) IBOutlet UILabel *allLabel;

- (void)localizeViews;

@end
