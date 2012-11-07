//
//  FileMetadata.h
//  gTarAppCore
//
//  Created by Marty Greenia on 6/18/12.
//  Copyright (c) 2012 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

enum FileType
{
    FileTypeUnknown = 0,
    FileTypeImage,
    FileTypeString
};
    
@interface FileMetadata : NSObject
{
    
    NSDate * m_fileLastUpdate;
    NSString * m_filePath;
    NSURL * m_fileUrl;
    
}

@end
