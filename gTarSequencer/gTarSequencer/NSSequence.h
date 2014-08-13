//
//  NSSequence.h
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "XMPTree.h"
#import "XMPNode.h"
#import <Foundation/Foundation.h>

@interface NSSequence : NSObject

-(id)initWithXMPFilename:(NSString *)filename;
-(id)initWithXMPNode:(XMPNode *)xmpNode;

@end
