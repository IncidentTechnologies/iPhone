//
//  NSPattern.h
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "XMPNode.h"
#import "XMPObject.h"
#import "NSNote.h"

@interface NSPattern : NSObject
{
    NSString * m_name;
    bool m_on;
    
    NSMutableArray * m_notes;
}

@property (nonatomic, retain) NSString * m_name;
@property (nonatomic) bool m_on;
@property (nonatomic, retain) NSMutableArray * m_notes;

-(id)initWithXMPNode:(XMPNode *)xmpNode;

-(id)initWithName:(NSString *)name on:(bool)on;

-(XMPNode *)convertToXmp;

-(void)addNote:(NSNote *)note;

@end
