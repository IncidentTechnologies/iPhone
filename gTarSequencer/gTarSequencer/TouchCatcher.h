//
//  TouchCatcher.h
//  gTarSequencer
//
//  Created by Ilan Gray on 7/30/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TouchCatcherDelegate <NSObject>

-(void)touchWasCaught:(CGPoint)touchCaught;

@end

@class InstrumentCell;

// TouchCatcher's job is to plant itself covering the entire screen
//      and pass word to its delegate of all touches that occur
//      outside its area to ignore. The areaToIgnore is given along with
//      its parentView so that this class can convert to local coords.
@interface TouchCatcher : UIControl
{
    CGRect areaToIgnore;
}

- (void)setAreaToIgnore:(CGRect)area inParentView:(UIView *)fromView;

@property (weak, nonatomic) id <TouchCatcherDelegate> delegate;

@end
