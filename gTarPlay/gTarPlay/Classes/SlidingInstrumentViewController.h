//
//  SlidingInstrumentViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/24/13.
//
//

#import <UIKit/UIKit.h>

#import "SlidingViewController.h"
#import "InstrumentTableViewController.h"

@protocol SlidingInstrumentDelegate <NSObject>

- (void)stopAudioEffects;
- (NSInteger)getSelectedInstrumentIndex;
- (NSArray *)getInstrumentList;
- (void)didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender;

@end

@interface SlidingInstrumentViewController : SlidingViewController <InstrumentSelectionDelegate>

@property (weak, nonatomic) id <SlidingInstrumentDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *innerContentView;

@property (readonly, nonatomic) BOOL loading;

@end
