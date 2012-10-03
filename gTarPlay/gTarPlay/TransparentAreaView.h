//
//  TransparentAreaView.h
//  gTarPlay
//
//  Created by Franco Cedano on 12/13/11.
//  Copyright (c) 2011 Incident. All rights reserved.
//
// Custom UIView class for the FreePlay menu tab that makes
// the area over the effects tab 'tab button' transparent to 
// touch events allowing the touch event to be handled by the
// effects tab view.

#import <UIKit/UIKit.h>

@interface Bounds : NSObject
{
@public
    float xMin;
    float xMax;
    float yMin;
    float yMax;
}
@end

@interface TransparentAreaView : UIView
{
    // array of bounds representing the xMin xMax yMin & yMax of an
    // area that should be transparent' to touche events.
    NSMutableArray *m_tranparentAreas;
}

- (void) addTransparentAreaWithXmin:(float)xMin xMax:(float)xMax yMin:(float)yMin yMax:(float)yMax;

@end
