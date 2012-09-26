//
//  GuitarView.m
//  gTarSequencer
//
//  Created by Ilan Gray on 6/26/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
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
        
        guitar = [[GuitarController alloc] init];
        
        [self clearData];
    }
    return self;
}

- (void)observeGtar
{
    [guitar addObserver:self];
}

- (void)update
{
    if ( measure == nil )
    {
        [guitar turnOffAllLeds];
        return;
    }
    
    // update notes
    if ( [measure shouldUpdateNotesOnGuitar] )
    {
        [self displayMeasure];
        [measure setUpdateNotesOnGuitar:NO];
    }
    
    // update playband:
    if ( [measure shouldUpdatePlaybandOnGuitar] )
    {
        [self displayPlayBandAtFret:measure.playband];
        [measure setUpdatePlaybandOnGuitar:NO];
    }
}

- (void)setMeasure:(Measure *)newMeasure
{
    measure = newMeasure;
    
    // i would like to get rid of this line
    //      because it doesnt follow MVC
    [measure setUpdateNotesOnGuitar:YES];
}

- (void)displayMeasure
{
    for (int s = 0; s < STRINGS_ON_GTAR; s++)
    {
        for (int f = 0; f < FRETS_ON_GTAR; f++)
        {
            if ( [measure isNoteOnAtString:s andFret:f] && !notesOn[s][f] ) 
            {
                notesOn[s][f] = YES;
                [guitar turnOnLedWithColorMappingAtString:s+1 andFret:f+1];
            }
            else if ( ![measure isNoteOnAtString:s andFret:f] && notesOn[s][f] )
            {
                notesOn[s][f] = NO;
                [guitar turnOffLedAtString:s+1 andFret:f+1];
            }
            
            if ( playband == f )
            {
                [guitar turnOnLedAtString:s+1 andFret:f+1 withRed:3 andGreen:3 andBlue:3];
            }
        }
    }
}

- (void)displayPlayBandAtFret:(int)whichFret
{
    [self removePlayBand];
    
    if ( whichFret >= 0 )
    {
        playband = whichFret;
        
        [guitar turnOnLedAtString:0 andFret:whichFret+1 withRed:3 andGreen:3 andBlue:3];
    }
}

- (void)removePlayBand
{
    if ( playband >= 0 )
    {
        [self resetLightsAtFret:playband];
        playband = -1;
    }
}

- (void)resetLightsAtFret:(int)whichFret
{
    for (int i=0;i<STRINGS_ON_GTAR;i++)
    {
        if ( [measure isNoteOnAtString:i andFret:whichFret] )
            [guitar turnOnLedWithColorMappingAtString:i+1 andFret:whichFret+1];
        else
            [guitar turnOffLedAtString:i+1 andFret:whichFret+1];
    }
}

- (void)clearData
{
    for (int s=0;s<STRINGS_ON_GTAR;s++)
    {
        for (int f=0;f<FRETS_ON_GTAR;f++)
        {
            notesOn[s][f] = NO;
        }
    }
}

#pragma mark - Guitar Observer

- (void)guitarNotesOnFret:(GuitarFret)fr andString:(GuitarString)str
{
    NSLog(@"Note played");
    
    [delegate notePlayedAtString:str andFret:fr];
}

- (void)guitarConnected
{
    NSLog(@"Guitar connected");
    
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
    [guitar setStringColorMapping:0 toRed:3 andGreen:0 andBlue:0];
    [guitar setStringColorMapping:1 toRed:0 andGreen:3 andBlue:0];
    [guitar setStringColorMapping:2 toRed:0 andGreen:0 andBlue:3];
    [guitar setStringColorMapping:3 toRed:3 andGreen:3 andBlue:0];
    [guitar setStringColorMapping:4 toRed:0 andGreen:3 andBlue:3];
    [guitar setStringColorMapping:5 toRed:3 andGreen:0 andBlue:3];
    
    [delegate guitarConnected];
    
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

- (void)guitarDisconnected
{
    NSLog(@"Guitar disconnected");
    
    [delegate guitarDisconnected];
}

- (void)guitarFretDown:(GuitarFret)fret andString:(GuitarString)str
{
}

- (void)guitarFretUp:(GuitarFret)fret andString:(GuitarString)str
{
}

- (void)guitarNotesOffFret:(GuitarFret)fret andString:(GuitarString)str
{
}


@end
