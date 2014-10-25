/*
 *  AppCore.h
 *  gTar
 *
 *  Created by Marty Greenia on 10/24/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */
#import "GtarController.h"
#import "KeysController.h"

#define GTAR_GUITAR_STRING_COUNT GtarStringCount
#define GTAR_GUITAR_FRET_COUNT GtarFretCount
#define GTAR_GUITAR_LED_COUNT (GTAR_GUITAR_STRING_COUNT * GTAR_GUITAR_FRET_COUNT)

// in microseconds (usleep)
#define GTAR_GUITAR_MESSAGE_DELAY 8000

#define GTAR_GUITAR_NOTE_OFF ((GtarFret)-1)
#define GTAR_GUITAR_FRET_UP (-1)
#define GTAR_GUITAR_FRET_MUTED ((GtarFret)-2)

#define KEYS_GUITAR_STRING_COUNT GtarStringCount
#define KEYS_GUITAR_FRET_COUNT GtarFretCount
#define KEYS_GUITAR_LED_COUNT (KEYS_GUITAR_STRING_COUNT * KEYS_GUITAR_FRET_COUNT)

// in microseconds (usleep)
#define KEYS_GUITAR_MESSAGE_DELAY 8000

#define KEYS_GUITAR_NOTE_OFF ((GtarFret)-1)
#define KEYS_GUITAR_FRET_UP (-1)
#define KEYS_KEY_MUTED ((GtarFret)-2)

#define KEYS_KEY_COUNT 127