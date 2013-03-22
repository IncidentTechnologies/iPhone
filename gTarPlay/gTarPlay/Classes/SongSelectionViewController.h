//
//  SongSelectionViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import <UIKit/UIKit.h>

#import "ExpandableSearchBar.h"

@interface SongSelectionViewController : UIViewController <UISearchBarDelegate>

@property (retain, nonatomic) IBOutlet ExpandableSearchBar *searchBar;

- (IBAction)backButtonClicked:(id)sender;

@end
