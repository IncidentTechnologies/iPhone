//
//  RecordShareViewController.h
//  Sequence
//
//  Created by Kate Schnippering on 3/25/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordShareDelegate <NSObject>

- (void) viewSeqSetWithAnimation:(BOOL)animate;

@end

@interface RecordShareViewController : UIViewController
{
    
    
}

@property (weak, nonatomic) id<RecordShareDelegate> delegate;

@end
