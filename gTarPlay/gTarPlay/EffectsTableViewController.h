//
//  EffectsTableViewController.h
//  gTarPlay
//
//  Created by Franco on 4/8/13.
//
//

#import <UIKit/UIKit.h>

//@class AudioController;

@protocol EffectSelectionDelegate

- (void)didSelectEffectAtIndex:(NSInteger)index;
- (NSString *)getEffectNameAtIndex:(NSInteger)index;
- (NSInteger)getNumEffects;
- (BOOL)isEffectOnAtIndex:(NSInteger)index;
- (void)toggleEffect:(NSInteger)index isOn:(BOOL)on;

@end

@interface EffectsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (weak, nonatomic) id <EffectSelectionDelegate> delegate;

//- (id)initWithAudioController:(AudioController*)AC;
- (id)init;

@end
