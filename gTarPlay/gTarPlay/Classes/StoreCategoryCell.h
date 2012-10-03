//
//  StoreCategoryCell.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/27/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "StoreSuperclassCell.h"
#import "CustomUserSongCell.h"

@interface StoreCategoryCell : CustomUserSongCell
{
    
    IBOutlet UILabel * m_categoryNameLabel;
    IBOutlet UIButton * m_backButton;
    NSString * m_categoryName;
    
}

@property (nonatomic, retain) IBOutlet UILabel * m_categoryNameLabel;
@property (nonatomic, retain) IBOutlet UIButton * m_backButton;

@property (nonatomic, retain) NSString * m_categoryName;

@end
