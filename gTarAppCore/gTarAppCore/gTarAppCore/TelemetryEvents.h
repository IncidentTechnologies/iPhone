//
//  TelemetryEvents.h
//  gTarAppCore
//
//  Created by Marty Greenia on 2/11/13.
//
//

#ifndef gTarAppCore_TelemetryEvents_h
#define gTarAppCore_TelemetryEvents_h

typedef NSString* TelemetryControllerEvent;

// Internal TC events
#define DroppedTelemetryMessages ((TelemetryControllerEvent)@"DroppedTelemetryMessages")

// gTarPlay events
#define GtarPlayAppOpened ((TelemetryControllerEvent)@"GtarPlayAppOpened")
#define GtarPlayAppClosed ((TelemetryControllerEvent)@"GtarPlayAppClosed")
#define GtarPlayAppMemWarning ((TelemetryControllerEvent)@"GtarPlayAppMemWarning")
#define GtarPlayAppLogin ((TelemetryControllerEvent)@"GtarPlayAppLogin")
#define GtarPlayAppLogout ((TelemetryControllerEvent)@"GtarPlayAppLogout")

#define GtarFirmwareUpdateStatus ((TelemetryControllerEvent)@"GtarFirmwareUpdateStatus")

#define GtarPlaySongCompleted ((TelemetryControllerEvent)@"GtarPlaySongCompleted")
#define GtarPlaySongRestarted ((TelemetryControllerEvent)@"GtarPlaySongRestarted")
#define GtarPlaySongDisconnected ((TelemetryControllerEvent)@"GtarPlaySongDisconnected")
#define GtarPlaySongAborted ((TelemetryControllerEvent)@"GtarPlaySongAborted")
#define GtarPlaySongShared ((TelemetryControllerEvent)@"GtarPlaySongShared")
#define GtarPlayToggleFeature ((TelemetryControllerEvent)@"GtarPlayToggleFeature")

#define GtarFreePlayCompleted ((TelemetryControllerEvent)@"GtarFreePlayCompleted")
#define GtarFreePlayDisconnected ((TelemetryControllerEvent)@"GtarFreePlayDisconnected")
#define GtarFreePlayToggleFeature ((TelemetryControllerEvent)@"GtarFreePlayToggleFeature")
#define GtarFreePlayInstrument ((TelemetryControllerEvent)@"GtarFreePlayInstrument")

#endif
