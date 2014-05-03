//
//  UserRequest.m
//  gTarAppCore
//
//  Created by Marty Greenia on 3/6/12.
//  Copyright (c) 2012 IncidentTech. All rights reserved.
//

#import "UserRequest.h"

@implementation UserRequest

@synthesize m_callbackObject;
@synthesize m_callbackSelector;

- (id)initWithType:(UserRequestType)type
{
    
    self = [super init];
    
	if ( self )
	{
        
        m_type = type;
        
    }
    
    return self;
    
}

- (id)initWithType:(UserRequestType)type andCallbackObject:(id)obj andCallbackSelector:(SEL)sel
{
    
    self = [super init];
    
	if ( self )
	{
        
        m_callbackObject = obj;
		m_callbackSelector = sel;
        m_type = type;
        
    }
    
    return self;
    
}


@end
