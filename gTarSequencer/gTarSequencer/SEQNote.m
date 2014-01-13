//
//  SEQNote.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/6/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "SEQNote.h"

@implementation SEQNote

@synthesize string;
@synthesize fret;

- (id)initWithString:(int)newString andFret:(int)newFret
{
    self = [super init];
    if (self)
    {
        string = newString;
        fret = newFret;
    }
    return self;
}

@end
