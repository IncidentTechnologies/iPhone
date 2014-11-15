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
        
        DLog(@"PATTERN");
        
        [self initFirstMeasure];
        
        list<XMPNode *>* t_notes = xmpNode->GetChildren();
        
        for(list<XMPNode *>::iterator it = t_notes->First(); it != NULL; it++){
            
            NSNote * note = [[NSNote alloc] initWithXMPNode:*it];
            
            [self addNote:note];
        }
        
    }
    
    return self;
}

-(id)initWithXmlDom:(XmlDom *)dom
{
    if(dom == nil){
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
    
        m_name = [dom getTextFromChildWithName:@"name"];
        
        m_on = [[dom getTextFromChildWithName:@"on"] boolValue];
        
        DLog(@"PATTERN %@",m_name);
        
        [self initFirstMeasure];
        
        NSArray * notechildren = [dom getChildArrayWithName:@"note"];
        
        for(XmlDom * child in notechildren){
            
            NSNote * note = [[NSNote alloc] initWithXmlDom:child];
            
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
        
        [self initFirstMeasure];
    }
    
    return self;
}

-(void)initFirstMeasure
{
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

-(XMPNode *)convertToXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"pattern" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_name UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"on", m_on));
    
    for(NSNote * note in m_notes){
        node->AddChild([note convertToSequenceXmp]);
    }
    
    return node;
}

-(void)addMeasure:(NSMeasure *)measure
{
    [m_measures addObject:measure];
}

-(void)addNote:(NSNote *)note
{
    [self addNoteObject:note];
    
    NSMeasure * m;
    int numMeasures = [m_measures count];
    int fret = floor(note.m_beatstart);
    int string = note.m_stringvalue;
    int measureIndex = 0;
    
    if(note.m_beatstart < FRETS_ON_GTAR){
        
        // Add to first measure
        measureIndex = 0;
        
    }else if(note.m_beatstart < 2*FRETS_ON_GTAR){
        
        if(numMeasures < 2){
            [self doubleMeasures:NO];
        }
        
        // Add to second measure
        measureIndex = 1;
        
    }else if(note.m_beatstart < 3*FRETS_ON_GTAR){
        
        if(numMeasures < 3){
            [self doubleMeasures:NO];
        }
        
        // Add to third measure
        measureIndex = 2;
        
    }else if(note.m_beatstart < 4*FRETS_ON_GTAR){
        
        if(numMeasures < 3){
            [self doubleMeasures:NO];
        }
        
        // Add to fourth measure
        measureIndex = 3;
        
    }
    
    if(measureIndex < 0 || measureIndex >= [m_measures count]){
        return;
    }
    
    m = [m_measures objectAtIndex:measureIndex];
    [[m_measures objectAtIndex:measureIndex] setActivated:true];
    
    fret -= FRETS_ON_GTAR*measureIndex;
    
    if(![m isNoteOnAtString:string andFret:fret]){
        [m changeNoteAtString:string andFret:fret];
    }
    
}

-(void)addNoteObject:(NSNote *)note
{
    [m_notes addObject:note];
    
    NSArray * sortedArray = [m_notes sortedArrayUsingComparator:^NSComparisonResult(NSNote *n1, NSNote *n2){
        if(n1.m_beatstart > n2.m_beatstart) return NSOrderedDescending;
        else if(n1.m_beatstart < n2.m_beatstart) return NSOrderedAscending;
        else return NSOrderedSame;
    }];
    
    m_notes = [NSMutableArray arrayWithArray:sortedArray];
}

- (void)changeNoteAtString:(int)str andFret:(int)fret forMeasure:(NSMeasure *)measure
{
    int measureIndex = [m_measures indexOfObject:measure];
    int measureOffset = FRETS_ON_GTAR*measureIndex;
    
    NSMutableArray * notesToRemove = [[NSMutableArray alloc] init];
    
    if([measure isNoteOnAtString:str andFret:fret]){
        
        // Remove from note array
        for(NSNote * note in m_notes){
            if(note.m_stringvalue == str && (floor(note.m_beatstart)-measureOffset) == fret){
                [notesToRemove addObject:note];
            }
        }
        
    }else{
        
        // Add to note array
        NSNote * note = [[NSNote alloc] initWithValue:[NSString stringWithFormat:@"%i",str] beatstart:fret+measureOffset];
        
        [self addNoteObject:note];
    }
    
    [m_notes removeObjectsInArray:notesToRemove];
    
    [measure changeNoteAtString:str andFret:fret];
    
}

- (void)removeAllInvalidNotes:(int)maxMeasure
{
    NSMutableArray * notesToRemove = [[NSMutableArray alloc] init];
    
    for(NSNote * note in m_notes){
        if(note.m_beatstart > FRETS_ON_GTAR*maxMeasure-1){
            [notesToRemove addObject:note];
        }
    }
    
    [m_notes removeObjectsInArray:notesToRemove];
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

#pragma mark Add/Remove Measures

- (void)doubleMeasures:(BOOL)duplicate
{
    DLog(@"Doubling measures");
    
    countChanged = YES;
    
    int previousCount = measureCount;
    measureCount *= 2;
    
    for (int i=0;i<previousCount;i++)
    {
        if(duplicate){
            
            NSMeasure * oldMeasure = [m_measures objectAtIndex:i];
            [oldMeasure setUpdateNotesOnMinimap:YES];
            
            NSMeasure * newMeasure = [[NSMeasure alloc] initWithMeasure:oldMeasure];
            [m_measures addObject:newMeasure];
            
            // Add notes that get turned on
            int newMeasureIndex = [m_measures indexOfObject:newMeasure];
            int newMeasureOffset = FRETS_ON_GTAR*newMeasureIndex;
            
            for(int s = 0; s < STRINGS_ON_GTAR; s++){
                for(int f = 0; f < FRETS_ON_GTAR; f++){
                    if([oldMeasure isNoteOnAtString:s andFret:f]){
                        NSNote * note = [[NSNote alloc] initWithValue:[NSString stringWithFormat:@"%i",s] beatstart:f+newMeasureOffset];
                        
                        [self addNoteObject:note];
                    }
                }
            }
                
        }else{
            
            NSMeasure * newMeasure = [[NSMeasure alloc] init];
            [m_measures addObject:newMeasure];
        }
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
    
    [self removeAllInvalidNotes:measureCount];
    
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
