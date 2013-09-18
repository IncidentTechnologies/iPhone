//
//  StoreListBuyButtonView.h
//  gTarPlay
//
//  Created by Idan Beck on 8/31/13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    BUY_BUTTON_PRICE,
    BUY_BUTTON_FREE,
    BUY_BUTTON_CONFIRM,
    BUY_BUTTON_PROCESSING,
    BUY_BUTTON_PURCHASED,
    BUY_BUTTON_INVALID
} BUY_BUTTON_STATE;

@interface StoreListBuyButtonView : UIView

-(void)updateBuyButtonState:(BUY_BUTTON_STATE)state;

@end
