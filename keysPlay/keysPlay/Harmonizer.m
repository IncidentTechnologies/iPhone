//
//  Harmonizer.m
//  keysPlay
//
//  Created by Franco Cedano on 6/19/12.
//  Copyright (c) 2012 Incident. All rights reserved.
//

#import "Harmonizer.h"

@implementation Harmonizer

@synthesize m_harmonizerType;

- (id)init
{
    self = [super init];
    if (self)
    {
        m_HarmonizerArray[0] = 0;
        m_HarmonizerArray[1] = 2;
        m_HarmonizerArray[2] = 5;
        m_HarmonizerArray[3] = 7;
        m_HarmonizerArray[4] = 10;
        m_HarmonizerArray[5] = 12;
        m_HarmonizerArray[6] = 14;
        m_HarmonizerArray[7] = 17;
        m_HarmonizerArray[8] = 19;
        m_HarmonizerArray[9] = 22;
        m_HarmonizerArray[10] = 24;
        m_HarmonizerArray[11] = 26;
        m_HarmonizerArray[12] = 29;
        m_HarmonizerArray[13] = 31;
        m_HarmonizerArray[14] = 34;
        m_HarmonizerArray[15] = 36;
        m_HarmonizerArray[16] = 38;
        m_HarmonizerArray[17] = 41;
    }
    
    return self;
}

- (void) setHarmonizerType:(NSInteger)type
{
    m_harmonizerType = type;
    if (1 == type)
    {
        m_HarmonizerArray[0] = 0;
        m_HarmonizerArray[1] = 2;
        m_HarmonizerArray[2] = 5;
        m_HarmonizerArray[3] = 7;
        m_HarmonizerArray[4] = 10;
        m_HarmonizerArray[5] = 12;
        m_HarmonizerArray[6] = 14;
        m_HarmonizerArray[7] = 17;
        m_HarmonizerArray[8] = 19;
        m_HarmonizerArray[9] = 22;
        m_HarmonizerArray[10] = 24;
        m_HarmonizerArray[11] = 26;
        m_HarmonizerArray[12] = 29;
        m_HarmonizerArray[13] = 31;
        m_HarmonizerArray[14] = 34;
        m_HarmonizerArray[15] = 36;
        m_HarmonizerArray[16] = 38;
        m_HarmonizerArray[17] = 41;
    }
    else if (2 == type)
    {
        m_HarmonizerArray[0] = 0;
        m_HarmonizerArray[1] = 2;
        m_HarmonizerArray[2] = 4;
        m_HarmonizerArray[3] = 5;
        m_HarmonizerArray[4] = 7;
        m_HarmonizerArray[5] = 9;
        m_HarmonizerArray[6] = 11;
        m_HarmonizerArray[7] = 12;
        m_HarmonizerArray[8] = 14;
        m_HarmonizerArray[9] = 16;
        m_HarmonizerArray[10] = 17;
        m_HarmonizerArray[11] = 19;
        m_HarmonizerArray[12] = 21;
        m_HarmonizerArray[13] = 23;
        m_HarmonizerArray[14] = 24;
        m_HarmonizerArray[15] = 26;
        m_HarmonizerArray[16] = 28;
        m_HarmonizerArray[17] = 29;
        m_HarmonizerArray[18] = 31;
        m_HarmonizerArray[19] = 33;
        m_HarmonizerArray[20] = 35;
        m_HarmonizerArray[21] = 36;
        m_HarmonizerArray[22] = 38;
        m_HarmonizerArray[23] = 40;
        m_HarmonizerArray[24] = 41;
    }
}

// Takes the string and fret values as input and maps them to the current harmonizer
// map/array to find the harmonized string and fret values. returns an NSDictionary
// with the harmonized string and fret values under keys "String" and "Fret". returns
// nil on error.
// string and fret should be 0 based
- (NSDictionary*) getHarmonizedValuesForString:(NSInteger)string andFret:(NSInteger)fret
{
    if (0 !=  m_harmonizerType)
    {
        // offset each string by 2 note positions to avoid one fret up and one 
        // fret over from sounding the same
        fret = m_HarmonizerArray[fret + string * 2];
        string = 0;
        
        if (fret > 41)
            return nil; //?? should return nil on this error?
        
        while (fret > 16)
        {
            if (++string == 4)
            {
                fret -= 4;
            }
            else
            {
                fret -= 5;
            }
        }
    }

    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:string], @"String",[NSNumber numberWithInt:fret], @"Fret", nil];    
}

@end
