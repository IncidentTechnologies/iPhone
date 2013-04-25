//
//  SlidingViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/24/13.
//
//

#import <UIKit/UIKit.h>

@interface SlidingViewController : UIViewController

//@property (assign, nonatomic) BOOL isDown;
//@property (assign, nonatomic) BOOL isSliding;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIView *triangleIndicatorImage;

- (void)attachToSuperview:(UIView *)view;
- (void)attachToSuperview:(UIView *)view withFrame:(CGRect)rect;
- (void)toggleView;
- (void)slidingComplete;
- (void)closeView;
- (void)openView;
- (void)setFrame:(CGRect)frame;

@end
