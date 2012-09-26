//
//  GtarController.h
//  GtarController
//
//  Created by Marty Greenia on 5/24/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GTAR_CONTROLLER_STRING_COUNT 6
#define GTAR_CONTROLLER_FRET_COUNT 16
#define GTAR_CONTROLLER_LED_COUNT (GTAR_CONTROLLER_STRING_COUNT * GTAR_CONTROLLER_FRET_COUNT)

#define GTAR_CONTROLLER_NOTE_OFF (-1)
#define GTAR_CONTROLLER_FRET_UP (-1)

typedef unsigned char GtarString;
typedef unsigned char GtarFret;

@protocol GtarControllerObserver <NSObject>
- (void)gtarFretDown:(GtarFret)fret andString:(GtarString)str;
- (void)gtarFretUp:(GtarFret)fret andString:(GtarString)str;
- (void)gtarNoteOnFret:(GtarFret)fret andString:(GtarString)str;
- (void)gtarNoteOffFret:(GtarFret)fret andString:(GtarString)str;
- (void)gtarConnected;
- (void)gtarDisconnected;
@end

typedef enum GTAR_CONTROLLER_EFFECT
{
	GtarControllerEffectNone = 0,
	GtarControllerEffectFretFollow,
	GtarControllerEffectNoteActive,
	GtarControllerEffectFretFollowNoteActive
} GtarControllerEffect;

typedef enum GTAR_CONTROLLER_LOG_LEVEL
{
    GtarControllerLogLevelAll = 0,
    GtarControllerLogLevelInfo,
    GtarControllerLogLevelWarn,
    GtarControllerLogLevelError,
    GtarControllerLogLevelOff
} GtarControllerLogLevel;

@interface GtarController : NSObject

// Is the gtar connected?
- (BOOL)isConnected;

// Set the logging level
- (void)setLogLevel:(GtarControllerLogLevel)level;

// These functions put the GuitarController into a spoofed 'connected' state, primarily for
// testing functionality in the Simulator. 
- (void)debugSpoofConnected;
- (void)debugSpoofDisconnected;

// Register an object to receive updates from the GuitarController.
// Observers are NOT retained when added, and are therefore not release
// after they have been removed. The observer cannot be nil, naturally.
- (void)addObserver:(id<GtarControllerObserver>)observer;
- (void)removeObserver:(id<GtarControllerObserver>)observer;

- (void)turnOffAllLeds;
- (void)turnOffLedAtFret:(GtarFret)fret andString:(GtarString)str;
- (void)turnOnLedAtFret:(GtarFret)fret andString:(GtarString)str withRed:(char)red andGreen:(char)green andBlue:(char)blue;

- (void)turnOnLedWithColorMappingAtFret:(GtarFret)fret andString:(GtarString)str;
- (void)setStringsColorMapping:(char**)colorMap;
- (void)setStringColorMapping:(GtarString)str toRed:(char)red andGreen:(char)green andBlue:(char)blue;

- (void)setMinimumInterarrivalTime:(double)time;

- (void)turnOffAllEffects;
- (void)setEffectColor:(GtarControllerEffect)effect toRed:(char)red andGreen:(char)green andBlue:(char)blue;

@end
