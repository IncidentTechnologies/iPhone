//
//  NSTrack.m
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSTrack.h"

@implementation NSTrack

@synthesize m_patterns;
@synthesize m_name;
@synthesize m_volume;
@synthesize m_muted;
@synthesize m_instrument;

@synthesize selectedPattern;
@synthesize selectedPatternIndex;
@synthesize selectedPatternDidChange;
@synthesize isSelected;

-(id)initWithXMPNode:(XMPNode *)xmpNode
{
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        XMPObject * track = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_name = [[NSString alloc] initWithUTF8String:[track GetAttributeValueWithName:@"name"].GetPszValue()];
        
        [track GetAttributeValueWithName:@"volume"].GetValueDouble(&m_volume);
        
        [track GetAttributeValueWithName:@"muted"].GetValueBool(&m_muted);
        
        m_instrument = [[NSInstrument alloc] initWithXMPNode:xmpNode->FindChildByName((char *)"instrument")];
        
        list<XMPNode *>* t_patterns = xmpNode->GetChildren();
        
        for(list<XMPNode *>::iterator it = t_patterns->First(); it != NULL; it++){
            
            XMPNode * m_it = *it;
            
            if(strcmp(m_it->GetName(),"pattern") == 0){
                NSPattern * pattern = [[NSPattern alloc] initWithXMPNode:m_it];
                
                [self addPattern:pattern];
            }
        }
        
    }
    
    return self;
}

-(id)initWithName:(NSString *)name volume:(double)volume muted:(bool)muted
{
    
    self = [super init];
    
	if ( self )
    {
        
        m_instrument = [[NSInstrument alloc] init];
        
        m_patterns = [[NSMutableArray alloc] init];
        
        // Add Four Patterns
        NSPattern * patternA = [[NSPattern alloc] initWithName:@"A" on:YES];
        NSPattern * patternB = [[NSPattern alloc] initWithName:@"B" on:NO];
        NSPattern * patternC = [[NSPattern alloc] initWithName:@"C" on:NO];
        NSPattern * patternD = [[NSPattern alloc] initWithName:@"D" on:NO];
        
        [self addPattern:patternA];
        [self addPattern:patternB];
        [self addPattern:patternC];
        [self addPattern:patternD];

        m_name = name;
        m_volume = volume;
        m_muted = muted;
        
        selectedPattern = patternA;
        selectedPatternIndex = 0;
        selectedPatternDidChange = NO;
        
        isSelected = NO;
    }
    
    return self;
    
}

-(XMPNode *)convertToXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"track" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_name UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"volume", m_volume));
    
    node->AddAttribute(new XMPAttribute((char *)"muted", m_muted));
    
    node->AddChild([m_instrument convertToXmp]);
    
    for(NSPattern * pattern in m_patterns){
        node->AddChild([pattern convertToXmp]);
    }
    
    return node;
}

-(void)addPattern:(NSPattern *)pattern
{
    [m_patterns addObject:pattern];
}

#pragma mark Track Actions
- (void)setSelected:(BOOL)selected
{
    isSelected = selected;
    
    if ( selected == YES )
    {
        selectedPattern.selectionChanged = YES;
    }
}

- (BOOL)isSelected
{
    return isSelected;
}

#pragma mark Pattern Actions

- (NSPattern *)selectPattern:(int)newSelection
{
    // -- update flag
    selectedPatternDidChange = YES;
    
    // -- remove playband from old beat seq
    selectedPattern.selectedMeasure.playband = -1;
    
    // -- formally select new beat seq
    selectedPatternIndex = newSelection;
    selectedPattern = [m_patterns objectAtIndex:selectedPatternIndex];
    
    // -- update beat seq's flags
    [selectedPattern turnOnAllFlags];
    
    return selectedPattern;
}

- (void)turnOnAllFlags
{
    selectedPatternDidChange = YES;
    [selectedPattern turnOnAllFlags];
}

- (void)notePlayedAtString:(int)str andFret:(int)fret
{
    [selectedPattern changeNoteAtString:str andFret:fret];
}

#pragma mark Measure Actions

- (NSMeasure *)selectMeasure:(int)newSelection {
    NSMeasure * newlySelectedMeasure = [selectedPattern selectMeasure:newSelection];
    return newlySelectedMeasure;
}

- (void)addMeasure
{
    if ( selectedPattern.measureCount == MAX_BEAT_SEQUENCES )
    {
        return;
    }
    
    // Update data structure:
    [selectedPattern doubleMeasures];
}

- (void)removeMeasure {
    
    if (selectedPattern.measureCount == 1){
        return;
    }
    
    @synchronized(selectedPattern){
        // Remove half the measures:
        [selectedPattern halveMeasures];
    }
}

- (void)clearSelectedMeasure {
    [selectedPattern clearSelectedMeasure];
}

#pragma mark - Playing Notes

// Play audio:
- (void)playFret:(int)fret inRealMeasure:(int)measure withSound:(BOOL)sound withAmplitude:(double)masteramplitude
{
    [m_instrument.audio updateMasterAmplitude:masteramplitude];
    
    if (sound && m_volume > 0)
        [selectedPattern playFret:fret inRealMeasure:measure withInstrument:m_instrument.m_id andAudio:m_instrument.audio withAmplitude:AMPLITUDE_SCALE*m_volume];
    else
        [selectedPattern playFret:fret inRealMeasure:measure withInstrument:-1 andAudio:m_instrument.audio withAmplitude:0.0];
}

- (void)releaseSounds
{
    [m_instrument releaseSounds];
}


- (void)displayAllNotes {
    for (NSMeasure * m in selectedPattern.m_measures)
        [m setUpdateNotesOnMinimap:YES];
}

@end
