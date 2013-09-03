//
//  StoreViewController.h
//  gTarPlay
//
//  Created by Franco on 8/28/13.
//
//

#import <UIKit/UIKit.h>
#import "PaginatedPullToUpdateTableView.h"

@interface StoreViewController : UIViewController <PullToUpdateTableViewDelegate> {

}

@property (retain, nonatomic) IBOutlet UIButton *buttonGetProductList;
@property (retain, nonatomic) IBOutlet PullToUpdateTableView *pullToUpdateSongList;
@property (retain, nonatomic) IBOutlet UIButton *buttonGetServerSongList;


- (IBAction)getProductList:(id)sender;
- (IBAction)onGetServerSongListTouchUpInside:(id)sender;
- (void)refreshDisplayedStoreSongList;

- (void)refreshSongList;

@end
