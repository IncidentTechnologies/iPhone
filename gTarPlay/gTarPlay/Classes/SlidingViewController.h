//
//  SlidingViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/24/13.
//
//

#import <UIKit/UIKit.h>

@interface SlidingViewController : UIViewController

@property (assign, nonatomic) BOOL isDown;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIView *triangleIndicatorImage;

- (void)attachToSuperview:(UIView *)view withFrame:(CGRect)rect;
- (void)toggleView:(BOOL)animated;
- (void)slidingComplete;
- (void)closeView:(BOOL)animated;
- (void)openView:(BOOL)animated;
- (void)setFrame:(CGRect)frame;

@end
