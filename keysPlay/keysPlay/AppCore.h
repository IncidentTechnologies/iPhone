/*
 *  AppCore.h
 *  Keys
 *
 *  Created by Kate Schnippering on 10/29/14.
 *  Copyright 2014 IncidentTech. All rights reserved.
 *
 */
#import "KeysController.h"
#import "TestFlight.h"
#import <UIKit/UIKit.h>

#ifdef DEBUG
#define DLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog( s, ... )
#endif

// in microseconds (usleep)
#define KEYS_GUITAR_MESSAGE_DELAY 8000

#define KEYS_GUITAR_NOTE_OFF ((GtarFret)-1)
#define KEYS_GUITAR_FRET_UP (-1)
#define KEYS_KEY_MUTED -1

#define KEYS_GUITAR_STRING_COUNT 6
#define KEYS_GUITAR_FRET_COUNT 16
#define KEYS_GUITAR_LED_COUNT (KEYS_GUITAR_STRING_COUNT * KEYS_GUITAR_FRET_COUNT)

#define KEYS_KEY_COUNT 127

#define KEYS_OCTAVE_COUNT 12
#define KEYS_WHITE_KEY_HARD_COUNT 7
#define KEYS_BLACK_KEY_HARD_COUNT 5
#define KEYS_WHITE_KEY_MED_COUNT 5
#define KEYS_BLACK_KEY_MED_COUNT 3
#define KEYS_WHITE_KEY_EASY_COUNT 3
#define KEYS_BLACK_KEY_EASY_COUNT 2