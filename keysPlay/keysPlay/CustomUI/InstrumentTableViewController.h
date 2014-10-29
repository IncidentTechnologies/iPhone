//
//  InstrumentTableViewController.h
//  keysPlay
//
//  Created by Franco on 4/1/13.
//
//

#import "AppCore.h"

//@class AudioController;

@protocol InstrumentSelectionDelegate <NSObject>

- (void)stopAudioEffects;
- (void)didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender;
- (NSInteger)getSelectedInstrumentIndex;
- (NSArray *)getInstrumentList;

@optional
- (void)didLoadInstrument;

@end

@interface InstrumentTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (weak, nonatomic) id <InstrumentSelectionDelegate> delegate;

//- (id)initWithAudioController:(AudioController*)AC;

- (id)init;
- (void)refreshView;

@end
