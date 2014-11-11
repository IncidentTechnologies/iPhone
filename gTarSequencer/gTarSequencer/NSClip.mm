//
//  NSClip.m
//  Sequence
//
//  Created by Kate Schnippering on 9/10/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSClip.h"


@implementation NSClip

@synthesize m_notes;
@synthesize m_name;
@synthesize m_color;
@synthesize m_startbeat;
@synthesize m_endbeat;
@synthesize m_cliplength;
@synthesize m_clipstart;
@synthesize m_looping;
@synthesize m_loopstart;
@synthesize m_looplength;
@synthesize m_muted;

@synthesize m_clip;


- (id)initWithXMPNode:(XMPNode *)xmpNode
{
    
    if ( xmpNode == nil )
    {
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        m_clip = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_name = [self getPatternNameFromOphoName:[[NSString alloc] initWithUTF8String:[m_clip GetAttributeValueWithName:@"name"].GetPszValue()]];
        
        m_color = [[NSString alloc] initWithUTF8String:[m_clip GetAttributeValueWithName:@"color"].GetPszValue()];
        
        [m_clip GetAttributeValueWithName:@"startbeat"].GetValueDouble(&m_startbeat);
        
        [m_clip GetAttributeValueWithName:@"endbeat"].GetValueDouble(&m_endbeat);
        
        [m_clip GetAttributeValueWithName:@"cliplength"].GetValueDouble(&m_cliplength);
        
        [m_clip GetAttributeValueWithName:@"clipstart"].GetValueDouble(&m_clipstart);
        
        [m_clip GetAttributeValueWithName:@"looping"].GetValueBool(&m_looping);
        
        [m_clip GetAttributeValueWithName:@"loopstart"].GetValueDouble(&m_loopstart);
        
        [m_clip GetAttributeValueWithName:@"looplength"].GetValueDouble(&m_looplength);
        
        [m_clip GetAttributeValueWithName:@"muted"].GetValueBool(&m_muted);
        
        DLog(@"CLIP name | %@",m_name);
        DLog(@"CLIP color | %@",m_color);
        DLog(@"CLIP startbeat | %f",m_startbeat);
        DLog(@"CLIP endbeat | %f",m_endbeat);
        DLog(@"CLIP cliplength | %f",m_cliplength);
        DLog(@"CLIP clipstart | %f",m_clipstart);
        DLog(@"CLIP looping | %i",m_looping);
        DLog(@"CLIP loopstart | %f",m_loopstart);
        DLog(@"CLIP looplength | %f",m_looplength);
        DLog(@"CLIP muted | %i",m_muted);
        
        m_notes = [[NSMutableArray alloc] init];
        
        list<XMPNode *>* t_sections = xmpNode->GetChildren();
        
        for(list<XMPNode *>::iterator it = t_sections->First(); it != NULL; it++){
            
            NSNote * m_note = [[NSNote alloc] initWithXMPNode:*it];
            
            [self addNote:m_note];
    
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
        DLog(@"CLIP");
        
        m_name = [self getPatternNameFromOphoName:[dom getTextFromChildWithName:@"name"]];
        
        m_color = [dom getTextFromChildWithName:@"color"];
        
        m_startbeat = [[dom getTextFromChildWithName:@"startbeat"] doubleValue];
        
        m_endbeat = [[dom getTextFromChildWithName:@"endbeat"] doubleValue];
        
        m_cliplength = [[dom getTextFromChildWithName:@"cliplength"] doubleValue];
        
        m_clipstart = [[dom getTextFromChildWithName:@"clipstart"] doubleValue];
        
        m_looping = [[dom getTextFromChildWithName:@"looping"] boolValue];
        
        m_loopstart = [[dom getTextFromChildWithName:@"loopstart"] doubleValue];
        
        m_looplength = [[dom getTextFromChildWithName:@"looplength"] doubleValue];
        
        m_muted = [[dom getTextFromChildWithName:@"muted"] boolValue];
        
        DLog(@"CLIP name | %@",m_name);
        DLog(@"CLIP color | %@",m_color);
        DLog(@"CLIP startbeat | %f",m_startbeat);
        DLog(@"CLIP endbeat | %f",m_endbeat);
        DLog(@"CLIP cliplength | %f",m_cliplength);
        DLog(@"CLIP clipstart | %f",m_clipstart);
        DLog(@"CLIP looping | %i",m_looping);
        DLog(@"CLIP loopstart | %f",m_loopstart);
        DLog(@"CLIP looplength | %f",m_looplength);
        DLog(@"CLIP muted | %i",m_muted);
        
        m_notes = [[NSMutableArray alloc] init];
        
        NSArray * notechildren = [dom getChildArrayWithName:@"note"];
        
        for(XmlDom * child in notechildren){
            
            NSNote * note = [[NSNote alloc] initWithXmlDom:child];
            
            [self addNote:note];
        }
    }
    
    return self;
}

- (id)initWithName:(NSString *)name startbeat:(double)startbeat endBeat:(double)endbeat clipLength:(double)cliplength clipStart:(double)clipstart looping:(bool)looping loopStart:(double)loopstart looplength:(double)looplength color:(NSString *)color muted:(bool)muted
{
	
    self = [super init];
    
	if ( self )
	{
		
		m_notes = [[NSMutableArray alloc] init];
		
		m_name = name;
        m_startbeat = startbeat;
        m_endbeat = endbeat;
        m_cliplength = cliplength;
        m_clipstart = clipstart;
        m_looping = looping;
        m_loopstart = loopstart;
        m_looplength = looplength;
        m_muted = muted;
        
        m_color = color;
        
	}
	
	return self;
}

- (XMPNode *)convertToSongXmp
{
    // Set some details for OPHO
    NSArray * colorOptions = [NSArray arrayWithObjects:@"#82B3BE",@"#7EBDCD",@"#79B2C7",@"#A9C8D0",@"#79AAC5",@"#636363", nil];
    
    NSString * ophoName = [self getOphoNameFromPatternName:m_name isMute:m_muted];
    NSString * ophoColor;
    
    if([ophoName isEqualToString:OPHO_PATTERN_A]){
        ophoColor = colorOptions[0];
    }else if([ophoName isEqualToString:OPHO_PATTERN_B]){
        ophoColor = colorOptions[1];
    }else if([ophoName isEqualToString:OPHO_PATTERN_C]){
        ophoColor = colorOptions[2];
    }else if([ophoName isEqualToString:OPHO_PATTERN_D]){
        ophoColor = colorOptions[3];
    }else if([ophoName isEqualToString:OPHO_PATTERN_E]){
        ophoColor = colorOptions[4];
    }else{
        ophoColor = colorOptions[5];
    }
    
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"clip" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[ophoName UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"startbeat", m_startbeat));
    
    node->AddAttribute(new XMPAttribute((char *)"endbeat", m_endbeat));
    
    node->AddAttribute(new XMPAttribute((char *)"cliplength", m_cliplength));
    
    node->AddAttribute(new XMPAttribute((char *)"clipstart", m_clipstart));
    
    node->AddAttribute(new XMPAttribute((char *)"looping", m_looping));
    
    node->AddAttribute(new XMPAttribute((char *)"loopstart", m_loopstart));
    
    node->AddAttribute(new XMPAttribute((char *)"looplength", m_looplength));
    
    node->AddAttribute(new XMPAttribute((char *)"color", (char *)[ophoColor UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"muted", m_muted));
    
    for(NSNote * note in m_notes){
        node->AddChild([note convertToSongXmp]);
    }
    
    return node;
}

- (NSString *)getOphoNameFromPatternName:(NSString *)patternName isMute:(BOOL)mute
{
    if(mute){
        return OPHO_PATTERN_OFF;
    }else if([patternName isEqualToString:PATTERN_A]){
        return OPHO_PATTERN_A;
    }else if([patternName isEqualToString:PATTERN_B]){
        return OPHO_PATTERN_B;
    }else if([patternName isEqualToString:PATTERN_C]){
        return OPHO_PATTERN_C;
    }else if([patternName isEqualToString:PATTERN_D]){
        return OPHO_PATTERN_D;
    }else{
        return OPHO_PATTERN_E;
    }
}

- (NSString *)getPatternNameFromOphoName:(NSString *)ophoName
{
    if([ophoName isEqualToString:OPHO_PATTERN_A]){
        return PATTERN_A;
    }else if([ophoName isEqualToString:OPHO_PATTERN_B]){
        return PATTERN_B;
    }else if([ophoName isEqualToString:OPHO_PATTERN_C]){
        return PATTERN_C;
    }else if([ophoName isEqualToString:OPHO_PATTERN_D]){
        return PATTERN_D;
    }else if([ophoName isEqualToString:OPHO_PATTERN_E]){
        return PATTERN_E;
    }else{
        return PATTERN_OFF;
    }
}

- (void)addNote:(NSNote *)note
{
    [m_notes addObject:note];
}

- (void)removeNoteAtBeat:(float)beat atValue:(long)value
{
    
    float relativeBeat = beat - self.m_startbeat;
    
    NSMutableArray * notesToRemove = [[NSMutableArray alloc] init];
    
    for(NSNote * note in m_notes){
        
        if(note.m_beatstart - 0.20 < relativeBeat && note.m_beatstart + 0.20 > relativeBeat && note.m_stringvalue == value){
            [notesToRemove addObject:note];
        }
    }
    
    DLog(@"%li notes found for removal",[notesToRemove count]);
    
    // In guessing which note we're removing we need to avoid duplicates
    
    if([notesToRemove count] > 1){
        // Choose the closest
        NSNote * minDiffNote = [notesToRemove firstObject];
        
        for(NSNote * n in notesToRemove){
            if(fabs(n.m_beatstart-relativeBeat) < fabs(minDiffNote.m_beatstart-relativeBeat)){
                minDiffNote = n;
            }
        }
        
        [m_notes removeObject:minDiffNote];
    }else{
        [m_notes removeObjectsInArray:notesToRemove];
    }
    
    
}

- (void)clearNotes
{
    [m_notes removeAllObjects];
}

- (void)setMute:(bool)muted
{
    m_muted = muted;
}

- (void)setTempStartbeat:(double)startbeat tempEndbeat:(double)endbeat
{
    m_startbeat = startbeat;
    m_endbeat = endbeat;
}

- (void)setEndbeat:(double)beat
{
    m_endbeat = [self roundBeatUpToMeasure:beat];
}

- (double)roundBeatUpToMeasure:(double)beat
{
    double numMeasures = ceil(beat / 4.0);
    return numMeasures * 4.0;
}

- (double)getMeasureForBeat:(double)beat
{
    double numMeasures = ceil(beat / 4.0);
    return numMeasures;
}

- (double)getDownMeasureForBeat:(double)beat
{
    double numMeasures = floor(beat / 4.0);
    return numMeasures;
}

- (void)changePattern:(NSString *)newPattern
{
    m_name = newPattern;
}

@end
