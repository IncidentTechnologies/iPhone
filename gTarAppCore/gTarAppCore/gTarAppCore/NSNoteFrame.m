//
//  NSNoteFrame.m
//  gTarAppCore
//
//  Created by Marty Greenia on 8/4/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "NSNoteFrame.h"
#import "NSNote.h"

#import "AppCore.h"

@implementation NSNoteFrame

@synthesize m_absoluteBeatStart;
@synthesize m_duration;
@synthesize m_notes;
@synthesize m_notesPending;
@synthesize m_notesHit;
@synthesize m_notesWrong;

- (id)init
{
    
    self = [super init];
    
    if ( self )
    {
        
        m_notes = [[NSMutableArray alloc] init];
        m_notesPending = [[NSMutableArray alloc] init];
        m_notesHit = [[NSMutableArray alloc] init];
        m_notesWrong = 0;

    }
    
    return self;
    
}

- (id)initWithStart:(double)absoluteBeatStart andDuration:(double)duration
{

    self = [super init];
    
    if ( self )
    {
        
        m_absoluteBeatStart = absoluteBeatStart;
        m_duration = duration;
        
        m_notes = [[NSMutableArray alloc] init];
        m_notesPending = [[NSMutableArray alloc] init];
        m_notesHit = [[NSMutableArray alloc] init];
        m_notesWrong = 0;

    }
    
    return self;

}

- (void)dealloc
{
    
    [m_notes release];
    [m_notesPending release];
    [m_notesHit release];
    
    [super dealloc];
    
}

- (void)addNote:(NSNote*)note
{
    
    [m_notes addObject:note];
    [m_notesPending addObject:note];
    
}

- (NSNote*)testString:(GtarString)str andFret:(GtarFret)fret
{
    
    NSNote * foundNote = nil;
    
    for ( NSNote * testNote in m_notesPending )
    {
        
        if ( testNote.m_string == str &&
            testNote.m_fret == fret )
        {
            foundNote = testNote;
            break;
        }
        
        if ( testNote.m_string == str &&
            testNote.m_fret == GTAR_GUITAR_FRET_MUTED &&
            fret == 0 )
        {
            foundNote = testNote;
            break;
        }
        
    }
    
    return foundNote;
    
}

- (NSNote*)testString:(GtarString)str
{
    
    NSNote * foundNote = nil;
    
    for ( NSNote * testNote in m_notesPending )
    {
        if ( testNote.m_string == str )
        {
            
            foundNote = testNote;
            break;
            
        }
    }
    
    return foundNote;
    
}

- (void)removeString:(GtarString)str andFret:(GtarFret)fret
{
    NSNote * foundNote = nil;
    
    
    for ( NSNote * testNote in m_notesPending )
    {
        
        if ( testNote.m_string == str &&
            testNote.m_fret == fret )
        {
            foundNote = testNote;
            break;
        }
        
        if ( testNote.m_string == str &&
            testNote.m_fret == GTAR_GUITAR_FRET_MUTED &&
            fret == 0 )
        {
            foundNote = testNote;
            break;
        }
        
    }
    
    if ( foundNote != nil )
    {
        [m_notesPending removeObject:foundNote];
        [m_notesHit addObject:foundNote];
    }
}

- (NSNote*)hitTestAndRemoveString:(GtarString)str andFret:(GtarFret)fret
{
    
    NSNote * foundNote = nil;
    
    for ( NSNote * testNote in m_notesPending )
    {
        
        if ( testNote.m_string == str && 
             testNote.m_fret == fret )
        {
            foundNote = testNote;
            break;
        }
        
        if ( testNote.m_string == str &&
             testNote.m_fret == GTAR_GUITAR_FRET_MUTED &&
             fret == 0 )
        {
            foundNote = testNote;
            break;
        }
        
    }
    
    if ( foundNote != nil )
    {
        [m_notesPending removeObject:foundNote];
        [m_notesHit addObject:foundNote];
        
        return foundNote;
    }
    else
    {
        m_notesWrong++;
        
        return nil;
    }

}

- (NSNote*)hitTestAndRemoveStringOnly:(GtarString)str
{
    
    NSNote * foundNote = nil;
    
    for ( NSNote * testNote in m_notesPending )
    {
        if ( testNote.m_string == str )
        {
            
            foundNote = testNote;
            break;
            
        }
    }
    
    if ( foundNote != nil )
    {
        [m_notesPending removeObject:foundNote];
        [m_notesHit addObject:foundNote];
        
        return foundNote;
    }
    else
    {
        m_notesWrong++;
        
        return nil;
    }
    
}


@end
