//
//  SimpleGuitarController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 8/4/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuitarController.h"

@class GuitarController;
@class AudioController;

@interface SimpleGuitarController : NSObject <GuitarControllerDelegate>
{
    GuitarController * m_guitarController;
    AudioController * m_audioController;
}

@end
