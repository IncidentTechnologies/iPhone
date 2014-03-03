//
//  SoundMaker.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/27/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"

@class AudioController;

// Serves as a wrapper class for the AudioController, because
//      whoever #imports the AC (or a file that #imports the AC)
//      needs to be a .mm file. This prevents refactoring, which
//      I find to be a useful tool, so i made this dummy class.
@interface SoundMaker : NSObject
{
    int instIndex;
}


- (id)initWithStringSet:(NSArray *)stringSet andStringPaths:(NSArray *)stringPaths andIndex:(int)index;
- (void)PluckStringFret:(int)str atFret:(int)fret withAmplitude:(double)amplitude;

@end
