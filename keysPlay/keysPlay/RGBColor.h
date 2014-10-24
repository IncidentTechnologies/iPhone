//
//  RGBColor.h
//  keysPlay
//
//  Created by Franco Cedano on 3/30/12.
//  Copyright (c) 2012 Incident. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RGBColor : NSObject

@property int R;
@property int G;
@property int B;

- (id) initWithRed:(int)red Green:(int)green Blue:(int)blue;

@end	
