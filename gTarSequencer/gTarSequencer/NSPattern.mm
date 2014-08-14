//
//  NSPattern.m
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSPattern.h"

@implementation NSPattern

@synthesize m_name;
@synthesize m_on;
@synthesize m_notes;
@synthesize m_measures;

@synthesize selectedMeasure;
@synthesize selectedMeasureIndex;
@synthesize measureCount;
@synthesize countChanged;
@synthesize selectionChanged;

-(id)initWithXMPNode:(XMPNode *)xmpNode
{
    
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        XMPObject * pattern = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_name = [[NSString alloc] initWithUTF8String:[pattern GetAttributeValueWithName:@"name"].GetPszValue()];
        
        [pattern GetAttributeValueWithName:@"on"].GetValueBool(&m_on);
        
        list<XMPNode *>* t_notes = xmpNode->GetChildren();
        
        for(list<XMPNode *>::iterator it = t_notes->First(); it != NULL; it++){
            
            NSNote * note = [[NSNote alloc] initWithXMPNode:*it];
            
            [self addNote:note];
        }
        
    }
    
    return self;
}

-(id)initWithName:(NSString *)name on:(bool)on
{
    self = [super init];
    
	if ( self )
    {
        m_name = name;
        m_on = on;
        
        m_notes = [[NSMutableArray alloc] init];
        m_measures = [[NSMutableArray alloc] init];
        
        // Add First Measure
        NSMeasure * measure1 = [[NSMeasure alloc] init];
        
        [self addMeasure:measure1];
        
        selectedMeasure = measure1;
        selectedMeasureIndex = 0;
        measureCount = [m_measures count];
        
        selectionChanged = YES;
        countChanged = YES;
        
    }
    
    return self;
}

-(XMPNode *)convertToXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"pattern" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_name UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"on", m_on));
    
    return node;
}

-(void)addMeasure:(NSMeasure *)measure
{
    [m_measures addObject:measure];
}

-(void)addNote:(NSNote *)note
{
    [m_notes addObject:note];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        m_measures = [aDecoder decodeObjectForKey:@"Measures List"];
        measureCount = [m_measures count];
        
        selectedMeasureIndex = [aDecoder decodeIntForKey:@"Selected Measure Index"];
        selectedMeasure = [m_measures objectAtIndex:selectedMeasureIndex];
        
        selectionChanged = YES;
        countChanged = YES;
    }
    return self;
}

- (void)setMeasureCount:(int)newMeasureCount
{
    measureCount = newMeasureCount;
    countChanged = YES;
}

- (void)setSelectedMeasureIndex:(int)newSelectedMeasureIndex
{
    selectedMeasureIndex = newSelectedMeasureIndex;
    selectionChanged = YES;
}

- (void)setSelectedMeasure:(NSMeasure *)newSelectedMeasure
{
    selectedMeasure = newSelectedMeasure;
    selectionChanged = YES;
}

#pragma mark Play/pause

- (void)playFret:(int)whichFret inRealMeasure:(int)realMeasure withInstrument:(int)instrumentIndex andAudio:(SoundMaker *)audioSource withAmplitude:(double)amplitude
{
    // Remove old playband:
    for (NSMeasure * m in m_measures)
    {
        [m setPlayband:-1];
    }
    
    // Add new one:
    [[m_measures objectAtIndex:realMeasure] playNotesAtFret:whichFret withInstrument:instrumentIndex andAudio:audioSource withAmplitudeWeight:amplitude];
}

- (int)computeRealMeasureFromAbsolute:(int)absoluteMeasure
{
    if ( [m_measures count] == 4 )
    {
        return absoluteMeasure;
    }
    else if ( [m_measures count] == 2 )
    {
        if ( (absoluteMeasure + 1) % 2 == 0 )     // if absoluteMeasure is even
        {
            return 1;
        }
        else {                              // else, its odd
            return 0;
        }
    }
    else if ( [m_measures count] == 1 )
    {
        return 0;
    }
    else {
        DLog(@"GIVEN BAD ABSOLUTE MEASURE TO PLAY");
        return -1;
    }
}

#pragma mark Change Note

- (void)changeNoteAtString:(int)str andFret:(int)fret
{
    [selectedMeasure changeNoteAtString:str andFret:fret];
}

- (BOOL)isNoteOnAtString:(int)str andFret:(int)fret
{
    return [selectedMeasure isNoteOnAtString:str andFret:fret];
}

#pragma mark Add/Remove Measures

- (void)doubleMeasures
{
    DLog(@"Doubling measures");
    
    countChanged = YES;
    
    int previousCount = measureCount;
    measureCount *= 2;
    
    for (int i=0;i<previousCount;i++)
    {
        NSMeasure * oldMeasure = [m_measures objectAtIndex:i];
        [oldMeasure setUpdateNotesOnMinimap:YES];
        
        NSMeasure * newMeasure = [[NSMeasure alloc] initWithMeasure:oldMeasure];
        [m_measures addObject:newMeasure];
    }
    
    [self selectMeasure:selectedMeasureIndex+1];
}

- (void)halveMeasures
{
    DLog(@"halving measures");
    
    countChanged = YES;
    
    int previousCount = measureCount;
    measureCount /= 2;
    
    int difference = previousCount - measureCount;
    
    for (int i=0;i<difference;i++){
        [m_measures removeLastObject];
    }
    
    if (selectedMeasureIndex >= [m_measures count]){
        [self selectMeasure:[m_measures count] - 1];
    }
    
    // Redraw the old measures
    for(int i=0; i<measureCount;i++){
        NSMeasure * oldMeasure = [m_measures objectAtIndex:i];
        [oldMeasure setUpdateNotesOnMinimap:YES];
    }
}

#pragma mark Clearing Measures

- (void)clearSelectedMeasure
{
    [selectedMeasure clearNotes];
}

#pragma mark Selecting Measures

- (NSMeasure *)selectMeasure:(NSUInteger)newSelection
{
    selectedMeasureIndex = newSelection;
    selectedMeasure = [m_measures objectAtIndex:newSelection];
    
    [selectedMeasure turnOnAllFlags];
    selectionChanged = YES;
    
    return selectedMeasure;
}

- (void)turnOnAllFlags
{
    countChanged = YES;
    selectionChanged = YES;
    
    for (NSMeasure * m in m_measures)
    {
        [m turnOnAllFlags];
    }
}

#pragma mark Archiving
/*
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:m_measures forKey:@"Measures List"];
    [aCoder encodeInt:selectedMeasureIndex forKey:@"Selected Measure Index"];
}
*/

@end
