//
//  TelemetryEvents.h
//  gTarAppCore
//
//  Created by Marty Greenia on 2/11/13.
//
//

typedef NSString* TelemetryControllerEvent;

// Internal TC events
TelemetryControllerEvent DroppedTelemetryMessages = @"DroppedTelemetryMessages";

// gTarPlay events
TelemetryControllerEvent GtarPlayAppOpened = @"GtarPlayAppOpened";
TelemetryControllerEvent GtarPlayAppClosed = @"GtarPlayAppClosed";
TelemetryControllerEvent GtarPlayAppMemWarning = @"GtarPlayAppMemWarning";
TelemetryControllerEvent GtarPlayAppLogin = @"GtarPlayAppLogin";
TelemetryControllerEvent GtarPlayAppLogout = @"GtarPlayAppLogout";

TelemetryControllerEvent GtarFirmwareUpdateStatus = @"GtarFirmwareUpdateStatus";

TelemetryControllerEvent GtarPlaySongCompleted = @"GtarPlaySongCompleted";
TelemetryControllerEvent GtarPlaySongRestarted = @"GtarPlaySongRestarted";
TelemetryControllerEvent GtarPlaySongDisconnected = @"GtarPlaySongDisconnected";
TelemetryControllerEvent GtarPlaySongAborted = @"GtarPlaySongAborted";
TelemetryControllerEvent GtarPlaySongShared = @"GtarPlaySongShared";
TelemetryControllerEvent GtarPlayToggleFeature = @"GtarPlayToggleFeature";

TelemetryControllerEvent GtarFreePlayCompleted = @"GtarFreePlayCompleted";
TelemetryControllerEvent GtarFreePlayDisconnected = @"GtarFreePlayDisconnected";
TelemetryControllerEvent GtarFreePlayToggleFeature = @"GtarFreePlayToggleFeature";
TelemetryControllerEvent GtarFreePlayInstrument = @"GtarFreePlayInstrument";
