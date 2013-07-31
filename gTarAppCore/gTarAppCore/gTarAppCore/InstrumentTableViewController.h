//
//  InstrumentTableViewController.h
//  gTarPlay
//
//  Created by Franco on 4/1/13.
//
//

#import <UIKit/UIKit.h>

@class AudioController;

@protocol InstrumentSelectionDelegate <NSObject>

@optional
- (void)didSelectInstrument;
- (void)didLoadInstrument;

@end

@interface InstrumentTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UITableView *tableView;
@property (assign, nonatomic) id <InstrumentSelectionDelegate> delegate;

- (id)initWithAudioController:(AudioController*)AC;

@end
