//
//  NSClip.h
//  Sequence
//
//  Created by Kate Schnippering on 9/10/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "XMPNode.h"
#import "XMPObject.h"
#import "NSNote.h"

@interface NSClip : NSObject
{
    NSString * m_name;
    
    double m_startbeat;
    double m_endbeat;
    double m_cliplength;
    double m_clipstart;
    bool m_looping;
    double m_loopstart;
    double m_looplength;
    bool m_muted;
    
    NSString * m_color;
    
    NSMutableArray * m_notes;
}

@property (nonatomic) XMPObject * m_clip;

@property (nonatomic, readonly) NSString * m_name;
@property (nonatomic, readonly) NSString * m_color;
@property (nonatomic, readonly) NSMutableArray * m_notes;

@property (nonatomic, assign) double m_startbeat;
@property (nonatomic, assign) double m_endbeat;
@property (nonatomic, assign) double m_cliplength;
@property (nonatomic, assign) double m_clipstart;
@property (nonatomic, assign) bool m_looping;
@property (nonatomic, assign) double m_loopstart;
@property (nonatomic, assign) double m_looplength;
@property (nonatomic, assign) bool m_muted;

-(id)initWithXMPNode:(XMPNode *)xmpNode;
- (id)initWithXmlDom:(XmlDom *)dom;

- (id)initWithName:(NSString *)name
         startbeat:(double)startbeat
           endBeat:(double)endbeat
        clipLength:(double)cliplength
         clipStart:(double)clipstart
           looping:(bool)looping
         loopStart:(double)loopstart
        looplength:(double)looplength
             color:(NSString *)color
             muted:(bool)muted;

-(XMPNode *)convertToSongXmp;

- (void)addNoteWithValue:(NSString *)value beatStart:(double)beatStart duration:(double)duration;
- (void)addNote:(NSNote *)note;

- (void)removeNoteAtBeat:(float)beat atValue:(long)value;

- (void)clearNotes;

- (void)setMute:(bool)muted;

- (void)setTempStartbeat:(double)startbeat tempEndbeat:(double)endbeat;

- (void)setEndbeat:(double)beat;

- (double)getMeasureForBeat:(double)beat;

- (double)getDownMeasureForBeat:(double)beat;

- (void)changePattern:(NSString *)newPattern;

@end
