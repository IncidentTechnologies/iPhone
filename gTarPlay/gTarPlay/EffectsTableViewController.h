//
//  EffectsTableViewController.h
//  gTarPlay
//
//  Created by Franco on 4/8/13.
//
//

#import <UIKit/UIKit.h>

@class AudioController;

@interface EffectsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UITableView *tableView;

- (id)initWithAudioController:(AudioController*)AC;

@end
