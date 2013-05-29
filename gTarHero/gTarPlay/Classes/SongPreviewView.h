//
//  SongPreviewView.h
//  gTarPlay
//
//  Created by Marty Greenia on 10/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSSongModel;

@interface SongPreviewView : UIView
{
    
    UIImageView * m_contentView;
    UIImageView * m_foregroundView;
    
    UIImageView * m_gradientLeft;
    UIImageView * m_gradientRight;
    
    CGSize m_contentSize;
    
    NSSongModel * m_songModel;
    
}
- (id)initWithFrame:(CGRect)frame andSongModel:(NSSongModel*)songModel;
- (UIImage*)drawContentImage;
- (UIImage*)drawForegroundImage;
- (void)updateView;
- (CGFloat)convertToStringCoords:(char)str;
- (CGFloat)convertToBeatCoords:(CGFloat)beat;
- (void)toggleGradients;
@end
