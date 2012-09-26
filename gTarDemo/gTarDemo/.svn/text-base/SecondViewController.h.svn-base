//
//  SecondViewController.h
//  gTarDemo
//
//  Created by Joel Greenia on 11/15/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GuitarEffect;
@class ThirdViewController;

@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray * m_effectsList;
}

@property (unsafe_unretained, nonatomic) ThirdViewController * m_thirdViewController;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView * m_table;

- (void)addEffect:(GuitarEffect*)effect;
- (void)moveEffectUp:(GuitarEffect*)effect;
- (void)moveEffectDown:(GuitarEffect*)effect;
- (void)deleteEffect:(GuitarEffect*)effect;

@end
