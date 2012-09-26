//
//  gTarState.m
//  AirgTar
//
//  Created by idanbeck on 11/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "gTarState.h"
#include <list>

int ConvertToRootValue(int root, BOOL sharp, BOOL flat)
{
	int rootval;
	
	rootval = root * 2 - 1;
	
	if(rootval > 5) 
		rootval--;
	
	if(sharp) rootval++;
	if(flat) rootval--;
	
	// make sure flats or sharps didn't switch us to a totally new place
	if(rootval <= 0) 
		rootval += 12;
	if(rootval > 12)
		rootval -= 12;
	
	return rootval;
}

class Pluck
{
public:
	Pluck(unsigned char vel, unsigned char spd) :
		m_vel(vel),
		m_spd(spd),
		m_ID(42)
	{/*empty*/}
	
	~Pluck(){/*empty*/}
	
public:
	unsigned char m_vel;
	unsigned char m_spd;
	unsigned char m_ID;
};

class NotePair
{
public:
	NotePair(int RootValue, int s, int f) :
		str(s),
		fret(f),
		degree(0)
	{		
		int midi = KSObject::GuitarMidiLookup(s, f);
		int absmidi = (midi % 12) + 1;
		int d = absmidi - RootValue + 1;
		if(d < 0)
			d += 12;
		degree = d;
	}
	
	~NotePair(){/*empty*/}
	
public:
	int str;
	int fret;
	int degree;		// this indicates the degree in respect to the tonic
};


@implementation gTarState

@synthesize m_ac;

@synthesize m_RootKey, m_flags;
@synthesize m_fFlat, m_fSharp;
@synthesize m_fPick, m_fPickConnected;

@synthesize m_pgksession;

// Set up the GKPeerPickerController
GKPeerPickerController *g_pGKPeerPickerController;

-(IBAction) ConnectPickiOS:(id)sender
{
	g_pGKPeerPickerController = [[GKPeerPickerController alloc] init];
	g_pGKPeerPickerController.delegate = self;
	g_pGKPeerPickerController.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
	
	m_fPick = false;
	
	[g_pGKPeerPickerController show];
}

-(IBAction) ConnectAsPickiOS:(id)sender
{
	g_pGKPeerPickerController = [[GKPeerPickerController alloc] init];
	g_pGKPeerPickerController.delegate = self;
	g_pGKPeerPickerController.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
	
	m_fPick = true;
	
	[g_pGKPeerPickerController show];
}

- (void) peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
	self.m_pgksession = session;
	session.delegate = self;
	[session setDataReceiveHandler:self withContext:nil];
	picker.delegate = nil;
	
	[picker dismiss];
	[picker autorelease];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    picker.delegate = nil;
    [picker autorelease];
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state 
{
    switch (state)
    {
        case GKPeerStateConnected:
		{
            NSLog(@"connected");
			m_fPickConnected = true;
		} break;
        
		case GKPeerStateDisconnected:
		{
            NSLog(@"disconnected");
            [self.m_pgksession release];
            m_pgksession = nil;
		} break;
    }
}

- (void) SendPluck
{
    Pluck *pTempPluck = new Pluck(127, 127);
	NSData *data = [NSData dataWithBytes:pTempPluck length:sizeof(Pluck)];
	
	if (m_pgksession) 
	{
        [self.m_pgksession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];    
	}
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
	
    //---convert the NSData to NSString---
    NSString* str;
	Pluck *pTempPluck = NULL;
	//[data getBytes:pTempPluck];
	pTempPluck = (Pluck*)data.bytes;
	
    str = [[NSString alloc] initWithFormat:@"Pluck vel:%d spd:%d id:%d", pTempPluck->m_vel, pTempPluck->m_spd, pTempPluck->m_ID];
    
	NSLog(str);
	
	
	
	[self PlayChordState:(0.15f * ((float)(127 - pTempPluck->m_spd) / (float)127))];
}


-(id)init
{
	if(self = [super init])
	{		
		m_ac = NULL;
		
		m_RootKey = 1;
		m_flags = NULL;
		
		// Initialize the audio controller 
		m_ac = [[AudioController alloc] init];
		
		// Set attentuatin to .985
		[m_ac SetAttentuation:0.985f];
		
		// Set up the Audio Controller 
		[m_ac initializeAUGraph:420.f withWaveform:3];
		[m_ac startAUGraph];
		
		m_fFlat = false;
		m_fSharp = false;
		
		m_fPickConnected = false;
		
		//[self EnableState:CHORD_MAJOR];
	}
	
	return self;
}

-(void)TestPluckString:(int)string fret:(int)fret
{
	if(m_ac != NULL)
	{
		[m_ac PluckStringFret:string atFret:fret];
	}
}

-(void)DisableState:(CHORD_STATES)state
{
	m_flags &= ~((unsigned char)(state));
}

-(void)EnableState:(CHORD_STATES)state
{
	// Set state
	m_flags |= ((unsigned char)(state));

	if(state == CHORD_MINOR)
		[self DisableState:CHORD_MAJOR];
	else if(state == CHORD_MAJOR)
		[self DisableState:CHORD_MINOR];
	else if(state == CHORD_7)
		[self DisableState:CHORD_6];
	else if(state == CHORD_6)
		[self DisableState:CHORD_7];
	else if(state == CHORD_FLAT5)
		[self DisableState:CHORD_SHARP5];
	else if(state == CHORD_SHARP5)
		[self DisableState:CHORD_FLAT5];
}

-(BOOL)CheckState:(CHORD_STATES)state
{
	unsigned char status = m_flags & (unsigned char)(state);
	if(status != 0)
		return TRUE;
	else 
		return FALSE;
}

-(void)PlayChordState:(float)noteDelay
{
	std::list<NotePair*> ChordNotes;
	
	int RootVal = ConvertToRootValue(m_RootKey, m_fFlat, m_fSharp);
	
	
	// All chord forms should be in MAJOR so that modifiers can take place later
	switch (m_RootKey) 
	{
		// C 
		case 1:
		{			
			ChordNotes.push_back(new NotePair(RootVal, 1, 3));
			ChordNotes.push_back(new NotePair(RootVal, 2, 2));
			
			if([self CheckState:CHORD_7])
				ChordNotes.push_back(new NotePair(RootVal, 3, 4)); // Add the major 7th
			else if([self CheckState:CHORD_6])
				ChordNotes.push_back(new NotePair(RootVal, 3, 2)); // Add the major 6th
			else 
				ChordNotes.push_back(new NotePair(RootVal, 3, 0));
			
			if([self CheckState:CHORD_9])
				ChordNotes.push_back(new NotePair(RootVal, 4, 3)); // Add the major 9th	
			else
				ChordNotes.push_back(new NotePair(RootVal, 4, 1));
			
			ChordNotes.push_back(new NotePair(RootVal, 5, 0));		
			
		} break;
			
		// D
		case 2:
		{
			if([self CheckState:(CHORD_STATES)(CHORD_7 | CHORD_9)])			
				ChordNotes.push_back(new NotePair(RootVal, 0, 2));	
			
			ChordNotes.push_back(new NotePair(RootVal, 1, 0));
			ChordNotes.push_back(new NotePair(RootVal, 2, 0));
			ChordNotes.push_back(new NotePair(RootVal, 3, 2));

			if([self CheckState:(CHORD_STATES)(CHORD_7 | CHORD_9)])
				ChordNotes.push_back(new NotePair(RootVal, 4, 1));	// Add the Major 7th
			else if([self CheckState:CHORD_6])
				ChordNotes.push_back(new NotePair(RootVal, 4, 0)); // Add the major 6th
			else 
				ChordNotes.push_back(new NotePair(RootVal, 4, 3));	
			
			if([self CheckState:CHORD_9])
				ChordNotes.push_back(new NotePair(RootVal, 5, 0)); // Add the major 9th	
			else
				ChordNotes.push_back(new NotePair(RootVal, 5, 2));	
			
		} break;
			
		// E
		case 3:
		{			
			ChordNotes.push_back(new NotePair(RootVal, 0, 0));
			ChordNotes.push_back(new NotePair(RootVal, 1, 2));
			
			if([self CheckState:CHORD_7])
				ChordNotes.push_back(new NotePair(RootVal, 2, 1));
			else
				ChordNotes.push_back(new NotePair(RootVal, 2, 2));
				
			ChordNotes.push_back(new NotePair(RootVal, 3, 1));
			
			if([self CheckState:CHORD_6])
				ChordNotes.push_back(new NotePair(RootVal, 4, 2)); // Add the major 6th
			else
				ChordNotes.push_back(new NotePair(RootVal, 4, 0));
			
			if([self CheckState:CHORD_9])
				ChordNotes.push_back(new NotePair(RootVal, 5, 2)); // Add the major 9th		
			else
				ChordNotes.push_back(new NotePair(RootVal, 5, 0));			
		} break;
			
		// F
		case 4:
		{
			ChordNotes.push_back(new NotePair(RootVal, 0, 1));
			ChordNotes.push_back(new NotePair(RootVal, 2, 3));
			ChordNotes.push_back(new NotePair(RootVal, 3, 2));
			
			if([self CheckState:CHORD_6])
				ChordNotes.push_back(new NotePair(RootVal, 4, 3)); // Add the major 6th
			else
				ChordNotes.push_back(new NotePair(RootVal, 4, 1));
			
			if([self CheckState:CHORD_7])
				ChordNotes.push_back(new NotePair(RootVal, 5, 0));
			else if([self CheckState:CHORD_9])
				ChordNotes.push_back(new NotePair(RootVal, 5, 3)); // Add the major 9th	
			else
				ChordNotes.push_back(new NotePair(RootVal, 5, 1));
		} break;
			
		// G
		case 5:
		{
			ChordNotes.push_back(new NotePair(RootVal, 0, 3));
			
			if([self CheckState:CHORD_9])
				ChordNotes.push_back(new NotePair(RootVal, 1, 0)); // Add the major 9th	
			else
				ChordNotes.push_back(new NotePair(RootVal, 1, 2));
			
			ChordNotes.push_back(new NotePair(RootVal, 2, 0));
			ChordNotes.push_back(new NotePair(RootVal, 3, 0));
			
			if([self CheckState:CHORD_6])
				ChordNotes.push_back(new NotePair(RootVal, 4, 3)); // Add the major 6th
			else
				ChordNotes.push_back(new NotePair(RootVal, 4, 0));
			
			if([self CheckState:CHORD_7])
				ChordNotes.push_back(new NotePair(RootVal, 5, 2));
			else if([self CheckState:CHORD_6])
				ChordNotes.push_back(new NotePair(RootVal, 5, 0)); // Add the major 6th
			else
				ChordNotes.push_back(new NotePair(RootVal, 5, 3));
		} break;
			
		// A
		case 6:
		{
			ChordNotes.push_back(new NotePair(RootVal, 0, 0));
			ChordNotes.push_back(new NotePair(RootVal, 1, 0));
			ChordNotes.push_back(new NotePair(RootVal, 2, 2));
			
			if([self CheckState:CHORD_7])
				ChordNotes.push_back(new NotePair(RootVal, 3, 1));
			else if([self CheckState:CHORD_9])
				ChordNotes.push_back(new NotePair(RootVal, 3, 4)); // Add the major 9th	
			else
				ChordNotes.push_back(new NotePair(RootVal, 3, 2));
			
			ChordNotes.push_back(new NotePair(RootVal, 4, 2));
			
			if([self CheckState:CHORD_6])
				ChordNotes.push_back(new NotePair(RootVal, 5, 2)); // Add the major 6th
			else if([self CheckState:CHORD_9])
				ChordNotes.push_back(new NotePair(RootVal, 5, 3)); // Add the major 9th	
			else
				ChordNotes.push_back(new NotePair(RootVal, 5, 0));
		} break;
			
			
			
		// B
		case 7:
		{
			ChordNotes.push_back(new NotePair(RootVal, 0, 2));
			ChordNotes.push_back(new NotePair(RootVal, 1, 2));
			ChordNotes.push_back(new NotePair(RootVal, 2, 4));
			
			if([self CheckState:CHORD_7])
				ChordNotes.push_back(new NotePair(RootVal, 3, 3));
			else
				ChordNotes.push_back(new NotePair(RootVal, 3, 4));
			
			if([self CheckState:CHORD_9])
				ChordNotes.push_back(new NotePair(RootVal, 4, 2)); // Add the major 9th	
			else
				ChordNotes.push_back(new NotePair(RootVal, 4, 4));
			
			if([self CheckState:CHORD_6])
				ChordNotes.push_back(new NotePair(RootVal, 5, 4)); // Add the major 6th
			else
				ChordNotes.push_back(new NotePair(RootVal, 5, 2));
		} break;
			
	}
	
	for(std::list<NotePair*>::iterator it = ChordNotes.begin(); it != ChordNotes.end(); it++)
	{
		int tempFret = (*it)->fret;
				
		if([self CheckState:CHORD_MINOR])
		{
			// Flat the third
			if((*it)->degree == 5)
				tempFret--;
			
			// Flat the seventh
			if((*it)->degree == 12)
				tempFret--;
		}
		else if([self CheckState:CHORD_MAJOR]) 
		{
			// Major 3rd
			if((*it)->degree == 4)
				tempFret++;
		}
		else 
		{
			// If neither then we need to flat the 7th since it's added as a major
			if((*it)->degree == 12)
				tempFret--;
		}
		
		if([self CheckState:CHORD_FLAT5] && (*it)->degree == 8)
			tempFret--;
		
		if([self CheckState:CHORD_SHARP5] && (*it)->degree == 8)
			tempFret++;
		
		// Shift only after modifiers have been spoken for as to 
		// not mess up the note relations
		if(m_fFlat)
			tempFret--;
		
		if(m_fSharp)
			tempFret++;
		
		[m_ac PluckStringFret:(*it)->str atFret:tempFret];
		[NSThread sleepForTimeInterval:noteDelay];
	}
}

@end
