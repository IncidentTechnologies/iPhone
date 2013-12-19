//
//  XMPObjectFactory.m
//  gtarLearn
//
//  Created by Idan Beck on 12/18/13.
//  Copyright (c) 2013 Incident Technologies, Inc. All rights reserved.
//

#import "XMPObjectFactory.h"
#import "XMPText.h"
#import "XMPGtarNote.h"
#import "XMPLEDEvent.h"
#import "XMPLoop.h"
#import "XMPInput.h"

@implementation XMPObjectFactory

/*
+(const unsigned int)str2int:(const char *)str withH:(int)h {
    return !str[h] ? 5381 : ([XMPObjectFactory str2int:str withH:(h+1)]*33) ^ str[h];
}
*/


// Will take an XMP node as input and produce an object out of it
// This function can recurse
+(XMPObject*)MakeXMPObject:(XMPNode*)xmpNode {
    char *pszName = xmpNode->GetName();
    XMPObject *retObj = NULL;
    
    if(strcmp(pszName, (char*)"text")) {
        retObj = [[XMPText alloc] initWithXMPNode:xmpNode];
    }
    else if(strcmp(pszName, (char*)"guitarposition")) {
        retObj = [[XMPGtarNote alloc] initWithXMPNode:xmpNode];
    }
    else if(strcmp(pszName, (char*)"loop")) {
        retObj = [[XMPLoop alloc] initWithXMPNode:xmpNode];
    }
    else if(strcmp(pszName, (char*)"ledout")) {
        retObj = [[XMPLEDEvent alloc] initWithXMPNode:xmpNode];
    }
    else if(strcmp(pszName, (char*)"input")) {
        retObj = [[XMPInput alloc] initWithXMPNode:xmpNode];
    }
    /*
    else if(strcmp(pszName, (char*)"lesson")) {
        
    }
    else if(strcmp(pszName, (char*)"chapter")) {
        
    }
    else if(strcmp(pszName, (char*)"song")) {
        
    }
    */
    
    return retObj;
}

@end
