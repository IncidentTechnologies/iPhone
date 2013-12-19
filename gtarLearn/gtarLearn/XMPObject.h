//
//  XMPObject.h
//  gtarLearn
//
//  Created by Idan Beck on 12/18/13.
//  Copyright (c) 2013 Incident Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dss_list.h"
#import "EHM.h"
#import "XMPValue.h"
#import "XMPNode.h"

using namespace dss;

// XMP Values are types of values that can be put into the XML file format
typedef enum XMPObjectTypes
{
    XMP_OBJECT_TEXT,
    XMP_OBJECT_LEDEVENT,
    XMP_OBJECT_LOOP,
    XMP_OBJECT_GTARNOTE,
    XMP_OBJECT_INPUT,
    XMP_OBJECT_LESSON,
    XMP_OBJECT_CHAPTER,
    XMP_OBJECT_SONG,
    XMP_OBJECT_INVALID
} XMP_OBJECT_TYPE;

@interface XMPObject : NSObject {
    int m_id;
    
    NSMutableArray *m_contents;
    list<XMPValue*>* m_variables;
    
    XMP_OBJECT_TYPE m_type;
    
    XMPNode *m_xmpNode;
}

-(id) initWithXMPNode:(XMPNode*)xmpNode;

-(RESULT)AddXmpObject:(XMPObject*)xmpObj;
-(RESULT)AddXMpVariable:(XMPValue*)xmpVar;
-(RESULT)BuildChildren;

-(bool)ContentHasXMPNode:(XMPNode*)xmpNode;

@end
