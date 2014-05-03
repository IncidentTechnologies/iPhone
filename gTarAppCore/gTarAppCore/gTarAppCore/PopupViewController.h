//
//  PopupViewController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 6/15/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class RoundedRectangleView;
@class PopupViewController;

@protocol PopupViewControllerDelegate <NSObject>
- (void)popupClosed:(PopupViewController*)popup;
@end

@interface PopupViewController : UIViewController
{

    id<PopupViewControllerDelegate> __weak m_popupDelegate;

//    RoundedRectangleView * m_backgroundView;
    
    UIButton * m_closeButton;
    
    UIImage * m_closeButtonImage;
    
    UIButton * m_fullScreenButton;
    
    UIView * m_blackBackgroundView;
    
    NSString * m_popupTitle;
//    UILabel * m_popupTitleLabel;
    UIView * m_popupTitleView;
    
    BOOL m_attaching;
    BOOL m_attached;
    
}

@property (nonatomic, weak) id<PopupViewControllerDelegate> m_popupDelegate;
//@property (nonatomic, retain) RoundedRectangleView * m_backgroundView;
@property (nonatomic, strong) UIImage * m_closeButtonImage;
@property (nonatomic, strong) NSString * m_popupTitle;

- (void)attachToSuperView:(UIView*)superview;
- (void)attachToSuperViewWithBlackBackground:(UIView *)superview;
- (void)sharedAttachToSuperView:(UIView*)superview;
- (void)attachFinalize;
- (void)detachFromSuperView;
- (void)detachFinalize;

- (IBAction)fullScreenButtonClicked:(id)sender;
- (IBAction)closeButtonClicked:(id)sender;

@end
