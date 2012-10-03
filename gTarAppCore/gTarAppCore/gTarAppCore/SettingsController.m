//
//  SettingsController.m
//  gTarAppCore
//
//  Created by Marty Greenia on 4/2/11.
//  Copyright 2011 IncidentTech All rights reserved.
//

#import "SettingsController.h"


@implementation SettingsController


#pragma mark Archiver coder

- (id)initWithName:(NSString*)name
{

    self = [super init];
    
	if ( self )
	{
		
		m_name = [name retain];
		
	}
	
	return self;

}

+ (SettingsController*)settingsWithName:(NSString*)name
{

	if ( name == nil )
	{
		return nil;
	}
	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
	NSString * archiveName = [NSString stringWithFormat:@"%@.archive", name];
	NSString * archivePath = [documentsDirectory stringByAppendingPathComponent:archiveName];

	// If this setting controller already exists, unarchive it
	SettingsController * sc = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
	
	// Otherwise get a new one.
	if ( sc == nil )
	{
		sc = [[self alloc] initWithName:name];
		[sc autorelease];
	}

	return sc;

}

- (void)dealloc
{
	
	[m_name release];
	
	[super dealloc];
	
}

- (BOOL)saveArchive
{
	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
	NSString * archiveName = [NSString stringWithFormat:@"%@.archive", m_name];
	NSString * archivePath = [documentsDirectory stringByAppendingPathComponent:archiveName];
	
	return [NSKeyedArchiver archiveRootObject:self toFile:archivePath];
	
}


#pragma mark -
#pragma mark NSCoder functions

// Encode an object for an archive
- (void)encodeWithCoder:(NSCoder *)coder
{
	
    [coder encodeObject:m_name forKey:@"Name"];
  	
}

// Decode an object from an archive
- (id)initWithCoder:(NSCoder *)coder
{
	
    self = [super init];
    
	if ( self )
	{
		
		m_name = [[coder decodeObjectForKey:@"Name"] retain];
		
	}
	
	return self;
	
}

@end
