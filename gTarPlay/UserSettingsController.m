//
//  UserSettingsController.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/25/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "UserSettingsController.h"

#import <UserProfile.h>

@implementation UserSettingsController

@synthesize m_timesLoggedin;
@synthesize m_userProfile;

- (void)dealloc
{

    [m_userProfile release];
    
	[super dealloc];
	
}

// Encode an object for an archive
- (void)encodeWithCoder:(NSCoder *)coder
{
	
	[coder encodeInteger:m_timesLoggedin forKey:@"TimesLoggedin"];
	[coder encodeObject:m_userProfile forKey:@"UserProfile"];

	[super encodeWithCoder:coder];
  	
}

// Decode an object from an archive
- (id)initWithCoder:(NSCoder *)coder
{
	
    self = [super initWithCoder:coder];
    
	if ( self )
	{
		
		self.m_timesLoggedin = [coder decodeIntegerForKey:@"TimesLoggedin"];
		self.m_userProfile = [coder decodeObjectForKey:@"UserProfile"];
		
	}
	
	return self;
	
}


@end
