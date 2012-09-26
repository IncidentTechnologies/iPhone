//
//  SEQNote.m
//  gTarSequencer
//
//  Created by Ilan Gray on 6/4/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
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
