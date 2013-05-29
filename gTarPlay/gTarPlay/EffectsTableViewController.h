//
//  EffectsTableViewController.h
//  gTarPlay
//
//  Created by Franco on 4/8/13.
//
//

#import <UIKit/UIKit.h>

@class AudioController;

@protocol EffectSelectionDelegate
-(void) didSelectEffectAtIndex:(NSInteger)index;
@end

@interface EffectsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UITableView *tableView;
@property (assign, nonatomic) id <EffectSelectionDelegate> delegate;

- (id)initWithAudioController:(AudioController*)AC;

@end
