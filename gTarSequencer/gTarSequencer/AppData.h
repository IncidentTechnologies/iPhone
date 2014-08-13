//
//  AppData.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/14/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TestFlightSDK3.0.0/TestFlight.h"

#ifdef DEBUG
#define DLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog( s, ... )
#endif

#define TESTMODE 0
#define CUSTOMINSTRUMENT 1

#define XBASE_LG 568
#define XBASE_SM 480
#define XBASE 480
#define YBASE 320
#define BOTTOMBAR_HEIGHT 55

#define DEFAULT_VOLUME 0.2
#define MAX_VOLUME 0.4
#define MIN_VOLUME 0.001
#define AMPLITUDE_SCALE 1.8

#define VISIBLE 1.0
#define NOT_VISIBLE 0.0

#define STRINGS_ON_GTAR 6
#define FRETS_ON_GTAR 16
#define MAX_NOTES 96

#define NUM_PATTERNS 4
#define NUM_MEASURES 4