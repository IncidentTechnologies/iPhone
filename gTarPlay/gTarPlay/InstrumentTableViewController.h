//
//  InstrumentTableViewController.h
//  gTarPlay
//
//  Created by Franco on 4/1/13.
//
//

#import <UIKit/UIKit.h>

@class AudioController;

@interface InstrumentTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (id)initWithAudioController:(AudioController*)AC;

@end
