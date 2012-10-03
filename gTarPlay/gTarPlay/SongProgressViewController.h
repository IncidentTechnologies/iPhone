//
//  SongProgressViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 8/10/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSSongModel;
@class SongProgressView;
@class SongPreviewView;

@interface SongProgressViewController : UIViewController
{
    
    NSSongModel * m_songModel;
    
    IBOutlet UIView * m_progressView;
    
    SongPreviewView * m_songPreviewView;
    
    UIView * m_progressIndicator;

}

@property (nonatomic, retain) NSSongModel * m_songModel;
@property (nonatomic, retain) IBOutlet UIView * m_progressView;
@property (nonatomic, retain) IBOutlet UIView * m_progressIndicator;

- (void)attachToSuperview:(UIView*)superview;
- (void)hideProgressView;
- (void)showProgressView;
- (void)updateView;
- (void)resetView;

@end
