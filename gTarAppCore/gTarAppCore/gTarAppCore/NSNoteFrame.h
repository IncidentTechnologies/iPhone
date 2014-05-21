//
//  NSNoteFrame.h
//  gTarAppCore
//
//  Created by Marty Greenia on 8/4/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppCore.h"

@class NSNote;

@interface NSNoteFrame : NSObject
{

    double m_absoluteBeatStart;
    double m_duration;
    
    NSMutableArray * m_notes;
    NSMutableArray * m_notesPending;
    NSMutableArray * m_notesHit;
    NSInteger m_notesWrong;
    
}

@property (nonatomic, readonly) double m_absoluteBeatStart;
@property (nonatomic, readonly) double m_duration;
@property (nonatomic, readonly) NSArray * m_notes;
@property (nonatomic, readonly) NSArray * m_notesPending;
@property (nonatomic, readonly) NSArray * m_notesHit;
@property (nonatomic, readonly) NSInteger m_notesWrong;

- (id)initWithStart:(double)absoluteBeatStart andDuration:(double)duration;

- (void)addNote:(NSNote*)note;

- (NSNote*)testString:(GtarString)str andFret:(GtarFret)fret;
- (NSNote*)testString:(GtarString)str;
- (NSNote*)hitTestAndRemoveString:(GtarString)str andFret:(GtarFret)fret;
- (NSNote*)hitTestAndRemoveStringOnly:(GtarString)str;
- (void)removeString:(GtarString)str andFret:(GtarFret)fret;

@end
