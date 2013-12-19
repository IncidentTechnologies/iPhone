//
//  XMPObject.m
//  gtarLearn
//
//  Created by Idan Beck on 12/18/13.
//  Copyright (c) 2013 Incident Technologies, Inc. All rights reserved.
//

#import "XMPObject.h"
#import "XMPObjectFactory.h"

@implementation XMPObject 

-(id) init {
    RESULT r = R_SUCCESS;
    
    //m_xmpNode = NULL;    
    CPRM((self = [super init]), "initWithParentLesson: Failed to init super");
    
    m_type = XMP_OBJECT_INVALID;
    m_contents = [[NSMutableArray alloc] init];
    m_variables = new list<XMPValue*>();
    
    // Note: This will build the children before the sub-class initialization
    [self BuildChildren];
    
    return self;
Error:
    return NULL;
}

// This will go through the contents and look for an object
// with the given XMP node
-(bool)ContentHasXMPNode:(XMPNode*)xmpNode {
    for (id xmpObj in m_contents) {
        if([xmpObj isMemberOfClass:[XMPObject class]]) {
            XMPObject *tempObj = (XMPObject*)(xmpObj);
            if(tempObj->m_xmpNode == xmpNode)
                return true;
        }
    }
    
    return false;
}

-(RESULT)BuildChildren {
    RESULT r = R_SUCCESS;
    
    
    if(m_xmpNode != NULL) {
        list<XMPNode*> *childrens = m_xmpNode->GetChildren();
        for(list<XMPNode*>::iterator it = childrens->First(); it != NULL; it++) {
            // Check to see this node isn't already present
            if([self ContentHasXMPNode:(*it)] == false) {
                XMPObject *tempObject = [XMPObjectFactory MakeXMPObject:(*it)];
                [m_contents addObject:tempObject];
            }
        }
    }
    
Error:
    return r;
}

-(id) initWithXMPNode:(XMPNode*)xmpNode {
    RESULT r = R_SUCCESS;
    
    CPRM((self = [self init]), "initWithParentLesson: Failed to init");
    m_xmpNode = xmpNode;
    
    return self;
Error:
    return NULL;
}

-(RESULT)AddXmpObject:(XMPObject*)xmpObj {
    [m_contents addObject:xmpObj];
    return R_SUCCESS;
}

-(RESULT)AddXMpVariable:(XMPValue*)xmpVar {
    m_variables->Append(xmpVar);
    return R_SUCCESS;
}

@end
