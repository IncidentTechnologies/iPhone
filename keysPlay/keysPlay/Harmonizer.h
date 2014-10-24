//
//  Harmonizer.h
//  keysPlay
//
//  Created by Franco Cedano on 6/19/12.
//  Copyright (c) 2012 Incident. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Harmonizer : NSObject
{
    int m_HarmonizerArray[25];
}

@property (assign, nonatomic) NSInteger m_harmonizerType;

- (void) setHarmonizerType:(NSInteger)index;
- (NSDictionary*) getHarmonizedValuesForString:(NSInteger)string andFret:(NSInteger)fret;

@end
