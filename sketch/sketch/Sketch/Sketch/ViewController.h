//
//  ViewController.h
//  Sketch
//
//  Created by Franco on 6/6/13.
//
//

#import <UIKit/UIKit.h>

#import "SongTableViewController.h"
#import <GtarController/GtarController.h>


@interface ViewController : UIViewController <GtarControllerObserver, SongTableViewControllerDelegate>

@end
