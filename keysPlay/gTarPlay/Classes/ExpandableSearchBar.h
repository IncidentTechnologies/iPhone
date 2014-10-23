//
//  ExpandableSearchBar.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import <UIKit/UIKit.h>

@class ExpandableSearchBar;

@protocol ExpandableSearchBarDelegate <NSObject>

- (void)searchBarDidBeginEditing:(ExpandableSearchBar *)searchBar;
- (void)searchBarSearch:(ExpandableSearchBar *)searchBar;
- (void)searchBarCancel:(ExpandableSearchBar *)searchBar;

@end

@interface ExpandableSearchBar : UIView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet id<ExpandableSearchBarDelegate> delegate;
@property (weak, readonly, nonatomic) NSString *searchString;

- (void)endSearch;
- (void)beginSearch;
- (void)minimizeKeyboard;
- (void)startActivityAnimation;
- (void)stopActivityAnimation;

@end
