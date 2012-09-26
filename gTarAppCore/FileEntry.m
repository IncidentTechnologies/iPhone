//
//  FileEntry.m
//  gTarAppCore
//
//  Created by Marty Greenia on 11/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "FileEntry.h"


@implementation FileEntry

@synthesize m_fileId;
@synthesize m_mimeType;
@synthesize m_fileType;

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_mimeType release];
    
    [super dealloc];
    
}

@end
