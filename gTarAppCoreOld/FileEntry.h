//
//  FileEntry.h
//  gTarAppCore
//
//  Created by Marty Greenia on 11/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

enum FileEntryType
{
    FileEntryTypeUnknown = 0,
    FileEntryTypeImage,
    FileEntryTypeXmp
};

@interface FileEntry : NSObject
{
    
    NSInteger m_fileId;
    NSString * m_mimeType;
    FileEntryType * m_fileType;
    
}

@property (nonatomic, assign) NSInteger m_fileId;
@property (nonatomic, retain) NSString * m_mimeType;
@property (nonatomic, assign) FileEntryType * m_fileType;

@end
