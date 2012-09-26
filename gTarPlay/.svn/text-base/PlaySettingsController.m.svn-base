//
//  PlaySettingsController.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/2/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "PlaySettingsController.h"

@implementation PlaySettingsController

@synthesize m_username;
@synthesize m_password;
@synthesize m_facebookAccessToken;
@synthesize m_timesRun;

- (void)dealloc
{

	[m_username release];
	[m_password release];
    [m_facebookAccessToken release];
	
	[super dealloc];
	
}

// Encode an object for an archive
- (void)encodeWithCoder:(NSCoder *)coder
{
	
    [coder encodeObject:m_username forKey:@"Username"];
    [coder encodeObject:m_password forKey:@"Password"];
    [coder encodeObject:m_facebookAccessToken forKey:@"FacebookAccessToken"];
	[coder encodeInteger:m_timesRun forKey:@"TimesRun"];
	
	[super encodeWithCoder:coder];
  	
}

// Decode an object from an archive
- (id)initWithCoder:(NSCoder *)coder
{
	
    self = [super initWithCoder:coder];
    
	if ( self )
	{
		
		// use the external SET so it retains automatically
		self.m_username = [coder decodeObjectForKey:@"Username"];
		self.m_password = [coder decodeObjectForKey:@"Password"];
        self.m_facebookAccessToken = [coder decodeObjectForKey:@"FacebookAccessToken"];
		self.m_timesRun = [coder decodeIntegerForKey:@"TimesRun"];
		
	}
	
	return self;
	
}

@end
