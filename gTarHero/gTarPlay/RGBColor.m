//
//  RGBColor.m
//  gTarPlay
//
//  Created by Franco Cedano on 3/30/12.
//  Copyright (c) 2012 Incident. All rights reserved.
//

#import "RGBColor.h"

@implementation RGBColor

@synthesize R;
@synthesize G;
@synthesize B;

- (id) initWithRed:(int)red Green:(int)green Blue:(int)blue
{
    self = [super init];
    if (self)
    {
        R = red;
        G = green;
        B = blue;
    }
    
    return self;
}

@end
