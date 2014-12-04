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

#define KEYS_DEFAULT_NOTE_DURATION 1.0

#define KEYS_KEY_COUNT 127

#define TOUCH_HIT_EASY_CORRECT 0.85
#define TOUCH_HIT_EASY_NEAR 0.65
#define TOUCH_HIT_EASY_INCORRECT 0.0

#define TOUCH_HIT_MEDIUM_CORRECT 0.9
#define TOUCH_HIT_MEDIUM_NEAR 0.8
#define TOUCH_HIT_MEDIUM_INCORRECT 0.0

#define TOUCH_HIT_HARD_CORRECT 0.95
#define TOUCH_HIT_HARD_NEAR 0.85
#define TOUCH_HIT_HARD_INCORRECT 0.0