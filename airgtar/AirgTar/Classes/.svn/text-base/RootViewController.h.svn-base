//
//  RootViewController.h
//  AirgTar
//
//  Created by idanbeck on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChordViewController.h"
#import "NoteViewController.h"
#import "gTarState.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)


@interface RootViewController : UIViewController <UIAccelerometerDelegate>
{
	UIButton *buttonPlaySongView;
	UIButton *buttonChordView;
	UIButton *buttonSettingsView;
	
	UIButton *buttonConnectAsPick;
	UIButton *buttonConnectPick;
	
	ChordViewController *chordViewController;
	NoteViewController *NoteViewController;
	
	gTarState *m_pgTarState;
	
	UIAccelerometer *m_pAccel;
	
	NSTimer *timerProx;
}

@property (nonatomic, retain) UIAccelerometer *m_pAccel;

@property (nonatomic, retain) IBOutlet UIButton *buttonPlaySongView;
@property (nonatomic, retain) IBOutlet UIButton *buttonChordView;
@property (nonatomic, retain) IBOutlet UIButton *buttonSettingsView;

@property (nonatomic, retain) IBOutlet UIButton *buttonConnectPick;
@property (nonatomic, retain) IBOutlet UIButton *buttonConnectAsPick;

@property (nonatomic, retain) ChordViewController *chordViewController;
@property (nonatomic, retain) NoteViewController *noteViewController;

@property (nonatomic, retain) gTarState *m_pgTarState;

-(IBAction) switchPageToChordView:(id)sender;
-(IBAction) switchPageToNoteView:(id)sender;

-(IBAction) connectPick:(id)sender;
-(IBAction) connectAsPick:(id)sender;

-(void) ProximityChanged:(NSNotification *)notify;

-(void) PreventPxomityScreenLock;

@end
