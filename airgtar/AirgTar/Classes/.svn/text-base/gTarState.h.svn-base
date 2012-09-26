//
//  gTarState.h
//  AirgTar
//
//  Created by idanbeck on 11/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioController.h"

#import <GameKit/GameKit.h>


typedef enum ChordStates
{
	CHORD_MINOR	 =	0x01,
	CHORD_MAJOR	 =	0x02,
	CHORD_FLAT5	 =	0x04,
	CHORD_SHARP5 =	0x08,
	CHORD_6		 =	0x10,
	CHORD_7		 =	0x20,
	CHORD_9		 =	0x40
} CHORD_STATES;

@interface gTarState : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate>
{	
	int m_RootKey;
	unsigned char m_flags;
	BOOL m_fSharp;
	BOOL m_fFlat;
	
	AudioController *m_ac;
	
	// GK Session for connecting a second iOS device as a pick
	GKSession *m_pgksession;
	
	BOOL m_fPick;
	BOOL m_fPickConnected;
}

@property (nonatomic, readonly) AudioController *m_ac;

@property (nonatomic, retain) GKSession *m_pgksession;

@property (nonatomic, readwrite) int m_RootKey;
@property (nonatomic, readwrite) unsigned char m_flags; 

@property (nonatomic, readwrite) BOOL m_fSharp;
@property (nonatomic, readwrite) BOOL m_fFlat;

@property (nonatomic, readwrite) BOOL m_fPick;
@property (nonatomic, readwrite) BOOL m_fPickConnected;

-(void)TestPluckString:(int)string fret:(int)fret;

-(void)PlayChordState:(float)noteDelay;

-(void)EnableState:(CHORD_STATES)state;
-(void)DisableState:(CHORD_STATES)state;
-(BOOL)CheckState:(CHORD_STATES)state;

// Bluetooth iOS Pick
-(IBAction) ConnectPickiOS:(id)sender;
-(IBAction) ConnectAsPickiOS:(id)sender;

- (void) SendPluck;

@end
