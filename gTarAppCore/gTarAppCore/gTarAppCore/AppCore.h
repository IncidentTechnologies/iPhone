/*
 *  AppCore.h
 *  gTar
 *
 *  Created by Marty Greenia on 10/24/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */
#import <GtarController/Gtar.h>

#define GTAR_GUITAR_STRING_COUNT GtarStringCount
#define GTAR_GUITAR_FRET_COUNT GtarFretCount
#define GTAR_GUITAR_LED_COUNT (GTAR_GUITAR_STRING_COUNT * GTAR_GUITAR_FRET_COUNT)

// in microseconds (usleep)
#define GTAR_GUITAR_MESSAGE_DELAY 8000

#define GTAR_GUITAR_NOTE_OFF ((GtarFret)-1)
#define GTAR_GUITAR_FRET_UP (-1)
#define GTAR_GUITAR_FRET_MUTED ((GtarFret)-2)