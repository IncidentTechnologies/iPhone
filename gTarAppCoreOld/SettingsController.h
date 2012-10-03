//
//  SettingsController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 4/2/11.
//  Copyright 2011 IncidentTech All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingsController : NSObject <NSCoding>
{
	NSString * m_name;
}

- (id)initWithName:(NSString*)name;
+ (SettingsController*)settingsWithName:(NSString*)name;
- (BOOL)saveArchive;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

@end
