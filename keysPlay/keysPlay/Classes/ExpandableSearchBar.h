//
//  ExpandableSearchBar.h
//  keysPlay
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

@property (retain, nonatomic) IBOutlet id<ExpandableSearchBarDelegate> delegate;
@property (retain, nonatomic) NSString *searchString;

- (void)endSearch;
- (void)beginSearch;
- (void)minimizeKeyboard;
- (void)startActivityAnimation;
- (void)stopActivityAnimation;

@end
