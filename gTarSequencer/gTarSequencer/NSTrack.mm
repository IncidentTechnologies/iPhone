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
@synthesize m_clips;
@synthesize m_name;
@synthesize m_level;
@synthesize m_muted;
@synthesize m_instrument;

@synthesize selectedPattern;
@synthesize selectedPatternIndex;
@synthesize selectedPatternDidChange;
@synthesize isSelected;

@synthesize m_track;

-(id)initWithXMPNode:(XMPNode *)xmpNode
{
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        m_track = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_name = [[NSString alloc] initWithUTF8String:[m_track GetAttributeValueWithName:@"name"].GetPszValue()];
        
        [m_track GetAttributeValueWithName:@"level"].GetValueDouble(&m_level);
        
        [m_track GetAttributeValueWithName:@"muted"].GetValueBool(&m_muted);
        
        m_instrument = [[NSInstrument alloc] initWithXMPNode:xmpNode->FindChildByName((char *)"instrument")];
        
        m_patterns = [[NSMutableArray alloc] init];
        m_clips = [[NSMutableArray alloc] init];
        
        selectedPatternDidChange = NO;
        isSelected = NO;
        
        DLog(@"TRACK %@",m_instrument.m_name);
        
        list<XMPNode *>* t_patterns = xmpNode->GetChildren();
        
        int patternIndex = 0;
        for(list<XMPNode *>::iterator it = t_patterns->First(); it != NULL; it++){
            
            XMPNode * m_it = *it;
            
            if(strcmp(m_it->GetName(),"pattern") == 0){
                
                NSPattern * pattern = [[NSPattern alloc] initWithXMPNode:m_it];
                
                [self addPattern:pattern];
                
                if(pattern.m_on){
                    selectedPattern = pattern;
                    selectedPatternIndex = patternIndex;
                }
                
                patternIndex++;
                
            }else if(strcmp(m_it->GetName(),"clip") == 0){
                
                NSClip * clip = [[NSClip alloc] initWithXMPNode:m_it];
                
                [self addClip:clip];
                
            }
        }
        
    }
    
    return self;
}

-(id)initWithName:(NSString *)name level:(double)level muted:(bool)muted
{
    
    self = [super init];
    
	if ( self )
    {
        
        m_instrument = [[NSInstrument alloc] init];
        
        m_patterns = [[NSMutableArray alloc] init];
        
        m_clips = [[NSMutableArray alloc] init];
        
        // Add Four Patterns
        NSPattern * patternA = [[NSPattern alloc] initWithName:@"-A" on:YES];
        NSPattern * patternB = [[NSPattern alloc] initWithName:@"-B" on:NO];
        NSPattern * patternC = [[NSPattern alloc] initWithName:@"-C" on:NO];
        NSPattern * patternD = [[NSPattern alloc] initWithName:@"-D" on:NO];
        
        [self addPattern:patternA];
        [self addPattern:patternB];
        [self addPattern:patternC];
        [self addPattern:patternD];

        m_name = name;
        m_level = level;
        m_muted = muted;
        
        selectedPattern = patternA;
        selectedPatternIndex = 0;
        selectedPatternDidChange = NO;
        
        isSelected = NO;
    }
    
    return self;
    
}

-(XMPNode *)convertToSequenceXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"track" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_name UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"level", m_level));
    
    node->AddAttribute(new XMPAttribute((char *)"muted", m_muted));
    
    node->AddChild([m_instrument convertToSequenceXmp]);
    
    for(NSPattern * pattern in m_patterns){
        node->AddChild([pattern convertToXmp]);
    }
    
    return node;
}

-(XMPNode *)convertToSongXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"track" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_name UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"level", m_level));
    
    node->AddAttribute(new XMPAttribute((char *)"muted", m_muted));
    
    node->AddChild([m_instrument convertToSongXmp]);
    
    for(NSClip * clip in m_clips){
        node->AddChild([clip convertToSongXmp]);
    }
    
    return node;
}

-(void)addPattern:(NSPattern *)pattern
{
    [m_patterns addObject:pattern];
}

#pragma mark - Clip Actions

-(void)addClip:(NSClip *)clip
{
    [m_clips addObject:clip];
}

-(void)addClip:(NSClip *)clip atIndex:(int)index
{
    if(index >= [m_clips count] || index < 0){
        
        [self addClip:clip];
        
    }else{
        
        NSMutableArray * newClipArray = [[NSMutableArray alloc] init];
        
        for(int i = 0; i <= [m_clips count]; i++){
            
            if(i < index){
                [newClipArray addObject:[m_clips objectAtIndex:i]];
            }else if(i == index){
                [newClipArray addObject:clip];
            }else{
                [newClipArray addObject:[m_clips objectAtIndex:i-1]];
            }
            
        }
        
        m_clips = newClipArray;
        
    }
}

-(NSClip *)firstClip
{
    if([m_clips count] > 0){
        return [m_clips firstObject];
    }
    
    NSClip * newClip = [[NSClip alloc] initWithName:@"clip" startbeat:0 endBeat:0 clipLength:0 clipStart:0 looping:NO loopStart:0 looplength:0 color:@"#FFFFFF" muted:NO];
    
    [self addClip:newClip];
    
    return newClip;
    
}

- (NSClip *)lastClipComparePattern:(NSString *)pattern andMuted:(BOOL)muted atBeat:(double)beat
{
    if([m_clips count] == 0){
        
        NSClip * newClip = [[NSClip alloc] initWithName:pattern startbeat:0 endBeat:0 clipLength:0 clipStart:0 looping:NO loopStart:0 looplength:0 color:@"#FFFFFF" muted:muted];
    
        [self addClip:newClip];
        
        return newClip;
        
    }else{
        
        NSClip * currentClip = [m_clips lastObject];
        
        if(currentClip.m_muted != muted || ![currentClip.m_name isEqualToString:pattern]){
            
            currentClip.m_endbeat = beat;
            currentClip.m_cliplength = currentClip.m_endbeat - currentClip.m_startbeat;
            
            NSClip * newClip = [[NSClip alloc] initWithName:pattern startbeat:beat endBeat:0 clipLength:0 clipStart:0 looping:NO loopStart:0 looplength:0 color:@"#FFFFFF" muted:muted];
    
            [self addClip:newClip];
            
            return newClip;
        }
        
        return currentClip;
    }
}

- (double)roundBeatDownToMeasure:(double)beat
{
    double numMeasures = ceil(beat / 4.0) - 1.0;
    return numMeasures * 4.0;
}

- (double)roundBeatUpToMeasure:(double)beat
{
    double numMeasures = ceil(beat / 4.0);
    return numMeasures * 4.0;
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
    // -- clear the old one
    selectedPattern.m_on = NO;
    
    // -- update flag
    selectedPatternDidChange = YES;
    
    // -- remove playband from old beat seq
    selectedPattern.selectedMeasure.playband = -1;
    
    // -- formally select new beat seq
    selectedPatternIndex = newSelection;
    selectedPattern = [m_patterns objectAtIndex:selectedPatternIndex];
    selectedPattern.m_on = YES;
    
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
    [selectedPattern changeNoteAtString:str andFret:fret forMeasure:selectedPattern.selectedMeasure];
}

- (int)getPatternLengthByName:(NSString *)patternname
{
    for(NSPattern * pattern in m_patterns){
        if([pattern.m_name isEqualToString:patternname]){
            return [pattern.m_measures count];
        }
    }
    
    return 0;
}

- (NSPattern *)getPatternByName:(NSString *)patternname
{
    for(NSPattern * pattern in m_patterns){
        if([pattern.m_name isEqualToString:patternname]){
            return pattern;
        }
    }
    
    return nil;
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
    [selectedPattern doubleMeasures:YES];
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
    [m_instrument.m_sampler.audio updateMasterAmplitude:masteramplitude];
    
    if (sound && m_level > 0)
        [selectedPattern playFret:fret inRealMeasure:measure withInstrument:m_instrument.m_id andAudio:m_instrument.m_sampler.audio withAmplitude:AMPLITUDE_SCALE*m_level];
    else
        [selectedPattern playFret:fret inRealMeasure:measure withInstrument:-1 andAudio:m_instrument.m_sampler.audio withAmplitude:0.0];
}

- (void)releaseSounds
{
    [m_instrument releaseSounds];
}


- (void)displayAllNotes {
    for (NSMeasure * m in selectedPattern.m_measures)
        [m setUpdateNotesOnMinimap:YES];
}

#pragma mark - Regenerate Song Data

- (void)regenerateSongWithInstrumentTrack:(NSTrack *)instTrack
{
    
    for(NSClip * clip in self.m_clips){
        
        [clip clearNotes];
        
        // Get the pattern data
        NSPattern * clipPattern;
        float patternLength = 0;
        
        for(NSPattern * p in instTrack.m_patterns){
            if([clip.m_name isEqualToString:p.m_name]){
                clipPattern = p;
                patternLength = (float)[instTrack getPatternLengthByName:p.m_name];
            }
        }
        
        patternLength *= 4.0; // count beats instead of measures
        float patternStartbeat = floor(clip.m_startbeat/patternLength) * patternLength;
        float patternEndbeat = ceil(clip.m_endbeat/patternLength) * patternLength;
        float patternBeat = patternStartbeat;
        
        DLog(@"Pattern Startbeat to Endbeat is %f to %f with length %f",patternStartbeat,patternEndbeat,patternLength);
        
        // Cycle through the pattern for the duration of the clip, but offset the start
        for(patternBeat = patternStartbeat; patternBeat < patternEndbeat; patternBeat += patternLength){
            
            // Generate the notes and add them
            for(NSNote * n in clipPattern.m_notes){
                
                float noteStartbeat = patternBeat + (n.m_beatstart/4.0); // Use beat rather than 1-16 value
                
                if(noteStartbeat >= clip.m_startbeat && noteStartbeat <= clip.m_endbeat){
                    
                    NSNote * clipNote = [[NSNote alloc] initWithValue:n.m_value beatstart:noteStartbeat duration:n.m_duration];
                    [clip addNote:clipNote];
                    
                }
                
            }
        }
        
        //DLog(@"Pattern %@ from beat %f to %f",clip.m_name,clip.m_startbeat,clip.m_endbeat);
        
    }
    
    //DLog(@"Track is now %@",self);
    
}


@end
