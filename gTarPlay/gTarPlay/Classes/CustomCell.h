//
//  CustomCell.h
//  gTarPlay
//
//  Created by Marty Greenia on 9/22/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomCell : UITableViewCell
{
    
    BOOL m_initialized;
    
}

+ (CGFloat)cellHeight;
- (void)updateCell;

@end
