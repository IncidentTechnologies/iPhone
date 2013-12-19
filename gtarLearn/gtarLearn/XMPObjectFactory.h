//
//  XMPObjectFactory.h
//  gtarLearn
//
//  Created by Idan Beck on 12/18/13.
//  Copyright (c) 2013 Incident Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPNode.h"
#import "XMPObject.h"

@interface XMPObjectFactory : NSObject {
    
}

// Will take an XMP node as input and produce an object out of it
+(XMPObject*)MakeXMPObject:(XMPNode*)xmpNode;
+(const unsigned int)str2int:(const char *)str withH:(int)h;

@end
