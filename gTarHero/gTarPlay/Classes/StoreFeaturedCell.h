//
//  StoreFeaturedCell.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/27/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "StoreSuperclassCell.h"
#import "CustomUserSongCell.h"

@interface StoreFeaturedCell : CustomUserSongCell
{

    IBOutlet UILabel * m_rankingLabel;
    
    IBOutlet UIView * m_rankBackgroundView;

    NSInteger m_rankNumber;
    
}

@property (nonatomic, retain) IBOutlet UILabel * m_rankingLabel;
@property (nonatomic, retain) IBOutlet UIView * m_rankBackgroundView;
@property (nonatomic, assign) NSInteger m_rankNumber;

@end
