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
    
    long m_startbeat;
    long m_endbeat;
    long m_cliplength;
    long m_clipstart;
    bool m_looping;
    long m_loopstart;
    long m_looplength;
    
    NSString * m_color;
    
    NSMutableArray * m_notes;
}

@property (nonatomic, readonly) NSString * m_name;
@property (nonatomic, readonly) NSString * m_color;
@property (nonatomic, readonly) NSMutableArray * m_notes;

@property (nonatomic, assign) long m_startbeat;
@property (nonatomic, assign) long m_endbeat;
@property (nonatomic, assign) long m_cliplength;
@property (nonatomic, assign) long m_clipstart;
@property (nonatomic, assign) bool m_looping;
@property (nonatomic, assign) long m_loopstart;
@property (nonatomic, assign) long m_looplength;

-(id)initWithXMPNode:(XMPNode *)xmpNode;

- (id)initWithName:(NSString *)name
         startbeat:(long)startbeat
           endBeat:(long)endbeat
        clipLength:(long)cliplength
         clipStart:(long)clipstart
           looping:(bool)looping
         loopStart:(long)loopstart
        looplength:(long)looplength
             color:(NSString *)color;

-(XMPNode *)convertToSongXmp;

-(void)addNote:(NSNote *)note;

@end
