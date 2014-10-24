//
//  SelectorControl.h
//  keysPlay
//
//  Created by Marty Greenia on 3/14/13.
//
//

#import <UIKit/UIKit.h>

@interface SelectorControl : UIControl

@property (nonatomic, assign) NSUInteger selectedIndex;

- (void)setTitles:(NSArray*)titleArray;
- (void)setTitle:(NSString*)title forIndex:(NSUInteger)index;

- (void)setFontSize:(CGFloat)size;
- (void)setFontSize:(CGFloat)size forIndex:(NSUInteger)index;

@end
