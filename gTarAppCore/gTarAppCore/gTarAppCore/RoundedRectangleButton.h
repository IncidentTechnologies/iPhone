//
//  RoundedRectangleButton.h
//  gTarAppCore
//
//  Created by Marty Greenia on 7/28/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "RoundedRectangleView.h"
@class RoundedRectangleView;

@interface RoundedRectangleButton : UIButton
{

    RoundedRectangleView * m_backgroundView;
    
}

@property (nonatomic, readonly) RoundedRectangleView * m_backgroundView;

@end
