//
//  GuitarView.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/23/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "GuitarView.h"

@implementation GuitarView

@synthesize measure;
@synthesize delegate;
@synthesize guitar;

- (id)init
{
    self = [super init];
    if ( self )
    {
        measure = nil;
        guitar = [[GtarController alloc] init];
        [guitar addObserver:self];
        
        [self clearData];
    }
    return self;
}

- (void)observeGtar
{
    [guitar addObserver:self];
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:guitar selector:@selector(debugSpoofConnected) userInfo:nil repeats:NO];
}


- (void)update
{
    if (measure == nil)
    {
        if(guitar.connected){
            [guitar turnOffAllLeds];
        }
        return;
    }
    
    // update notes
    if ([measure shouldUpdateNotesOnGuitar]){
        [self displayMeasure];
        [measure setUpdateNotesOnGuitar:NO];
    }
    
    // update playband:
    if ([measure shouldUpdatePlaybandOnGuitar]){
        [self displayPlayBandAtFret:measure.playband];
        [measure setUpdatePlaybandOnGuitar:NO];
    }
    
    if(TESTMODE) DLog(@"gv update");
}

- (void)setMeasure:(Measure *)newMeasure
{
    measure = newMeasure;
    
    // TODO: this doesn't follow MVC
    [measure setUpdateNotesOnGuitar:YES];
}

- (void)displayMeasure
{
    
    for (int s = 0; s < STRINGS_ON_GTAR; s++){
        for (int f = 0; f < FRETS_ON_GTAR; f++){
            
            if ([measure isNoteOnAtString:s andFret:f] && !notesOn[s][f]){
                notesOn[s][f] = YES;
                if(guitar.connected){
                    [guitar turnOnLedAtPositionWithColorMap:GtarPositionMake(f+1, s+1)];
                }
                
            }else if (![measure isNoteOnAtString:s andFret:f] && notesOn[s][f]){
                notesOn[s][f] = NO;
                if(guitar.connected){
                    [guitar turnOffLedAtPosition:GtarPositionMake(f+1, s+1)];
                }
            }
            
            if (playband == f){
                if(guitar.connected){
                    [guitar turnOnLedAtPosition:GtarPositionMake(f+1, s+1)
                                  withColor:GtarLedColorMake(3, 3, 3)];
                }
            }
        }
    }
}

- (void)displayPlayBandAtFret:(int)whichFret
{
    [self removePlayBand];
    
    if (whichFret >= 0){
        playband = whichFret;
        
        if(guitar.connected){
            [guitar turnOnLedAtPosition:GtarPositionMake(whichFret+1, 0)
                          withColor:GtarLedColorMake(3, 3, 3)];
        }
    }
}

- (void)removePlayBand
{
    if (playband >= 0){
        [self resetLightsAtFret:playband];
        playband = -1;
    }
}

- (void)resetLightsAtFret:(int)whichFret
{
    for (int i=0;i<STRINGS_ON_GTAR;i++){
        
        if ([measure isNoteOnAtString:i andFret:whichFret]){
            if(guitar.connected){
                [guitar turnOnLedAtPositionWithColorMap:GtarPositionMake(whichFret+1, i+1)];
            }
            
        }else{
            if(guitar.connected){
                [guitar turnOffLedAtPosition:GtarPositionMake(whichFret+1, i+1)];
            }
        }
    }
}

- (void)clearData
{
    for (int s=0;s<STRINGS_ON_GTAR;s++){
        for (int f=0;f<FRETS_ON_GTAR;f++){
            notesOn[s][f] = NO;
        }
    }
}

#pragma mark - Gtar Observer

- (void)gtarNoteOn:(GtarPluck)pluck
{
    DLog(@"Note played");
    
    
    [delegate notePlayedAtString:pluck.position.string andFret:pluck.position.fret];
}

- (void)gtarConnected
{
    DLog(@"Guitar connected");
    
    
    // Turn off effects & LEDs
    [guitar turnOffAllLeds];
    [self turnOffEffects];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
    
    // Set color mapping
    //    [guitar setStringColorMapping:0 toRed:3 andGreen:0 andBlue:0];
    //    [guitar setStringColorMapping:1 toRed:0 andGreen:3 andBlue:0];
    //    [guitar setStringColorMapping:2 toRed:0 andGreen:0 andBlue:3];
    //    [guitar setStringColorMapping:3 toRed:3 andGreen:3 andBlue:0];
    //    [guitar setStringColorMapping:4 toRed:0 andGreen:3 andBlue:3];
    //    [guitar setStringColorMapping:5 toRed:3 andGreen:0 andBlue:3];
    
    GtarLedColorMap map;
    
    map.stringColor[0] = GtarLedColorMake(3, 0, 0);
    map.stringColor[1] = GtarLedColorMake(3, 1.5, 0);
    map.stringColor[2] = GtarLedColorMake(3, 3, 0);
    map.stringColor[3] = GtarLedColorMake(0, 3, 0);
    map.stringColor[4] = GtarLedColorMake(0, 0, 3);
    map.stringColor[5] = GtarLedColorMake(1.5, 0, 1.5);
    
    [guitar setColorMap:map];
    
    [delegate gtarConnected:YES];
    
    // Refresh guitarview (delaying a bit so that hopefully the gtar effects will be turned off)
    [self performSelector:@selector(refreshGuitarView) withObject:nil afterDelay:0.6];
}

- (void)refreshGuitarView
{
    [self clearData];
    [self update];
}

- (void)turnOffEffects
{
    [guitar turnOffAllEffects];
}

- (void)gtarDisconnected
{
    [delegate gtarConnected:NO];
}

- (BOOL)isGtarConnected
{
    return guitar.connected;
}

@end
