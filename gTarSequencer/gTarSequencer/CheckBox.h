//
//  CheckBox.h
//  gTarSequencer
//
//  Created by Ilan Gray on 6/21/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@protocol CheckBoxDelegate <NSObject>

- (void)stateDidChange:(BOOL)newState;

@end

#define ON 1
#define OFF 0


@interface CheckBox : UIView
{
    BOOL checked;
    
    UIImageView * checkmarkView;
    UIImage * checkmark;
}

- (void)setToState:(BOOL)state;

@property (weak, nonatomic) id <CheckBoxDelegate> delegate;

@end
