//
//  KeyBoardManager.h
//  AutoRepair
//
//  Created by Gaurav Goyal on 2/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IQKeyBoardManager : NSObject
{
    //TextField or TextView object.
    UIView *textFieldView;
    
    CGFloat animationDuration;
    
    // Added
    NSNotification* lastKeyboardNotification;
}

//Call it on your AppDelegate;
+(void)installKeyboardManager;


@end



/*Additional Function*/
@interface IQKeyBoardManager(ToolbarOnKeyboard)

//Helper functions to add Done button on keyboard.
+(void)addDoneButtonOnKeyboard:(UITextField*)textField target:(id)target action:(SEL)action;

//Helper function to add SegmentedNextPrevious and Done button on keyboard.
+(void)addPreviousNextDoneButtonOnKeyboard:(UITextField*)textField target:(id)target previousAction:(SEL)previousAction nextAction:(SEL)nextAction doneAction:(SEL)doneAction;

@end