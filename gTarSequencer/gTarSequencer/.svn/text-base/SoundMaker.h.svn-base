//
//  SoundMaker.h
//  gTarSequencer
//
//  Created by Ilan Gray on 7/30/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import <Foundation/Foundation.h>

@class AudioController;

// Serves as a wrapper class for the AudioController, because 
//      whoever #imports the AC (or a file that #imports the AC)
//      needs to be a .mm file. This prevents refactoring, which
//      I find to be a useful tool, so i made this dummy class.
@interface SoundMaker : NSObject
{
    AudioController * audioController;
}

- (void)PluckStringFret:(int)str atFret:(int)fret;

@end
