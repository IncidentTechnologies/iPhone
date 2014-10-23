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
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIButton *triangleIndicatorImage;

- (void)attachToSuperview:(UIView *)view withFrame:(CGRect)rect;
- (void)toggleView:(BOOL)animated;
- (void)slidingComplete;
- (void)closeView:(BOOL)animated;
- (void)openView:(BOOL)animated;
- (void)setFrame:(CGRect)frame;
- (void)colorTriangleIndicator:(UIColor *)color;
- (void)invertTriangleIndicator;
- (void)invertView:(BOOL)invert;

@end
