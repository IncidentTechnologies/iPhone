//
//  SEQNote.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/6/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"

@interface SEQNote : NSObject

@property int string;
@property int fret;

- (id)initWithString:(int)newString andFret:(int)newFret;


@end
