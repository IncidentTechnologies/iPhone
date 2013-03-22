//
//  ExpandableSearchBar.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import <UIKit/UIKit.h>

@interface ExpandableSearchBar : UISearchBar

@property (retain, nonatomic) IBOutlet UIView *contractedView;
@property (retain, nonatomic) IBOutlet UIView *expandedView;

@end
