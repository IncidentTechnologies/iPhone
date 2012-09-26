//
//  FileController.m
//  gTarAppCore
//
//  Created by Marty Greenia on 11/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "FileController.h"

#import "CloudController.h"
#import "CloudRequest.h"
#import "CloudResponse.h"
#import "FileRequest.h"

@implementation FileController

@synthesize m_cloudController;

- (id)initWithCloudController:(CloudController*)cloudController
{
    
    self = [super init];
    
    if ( self )
    {
        
        m_cloudController = [cloudController retain];
        
        m_fileCacheMap = [[NSMutableDictionary alloc] init];
        
        m_pendingFileRequests = [[NSMutableDictionary alloc] init];
        
        //
        // Scan the hdd for files that have been caches
        //
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString * cacheDirectory = [paths objectAtIndex:0];
        NSString * cachePath = [cacheDirectory stringByAppendingPathComponent:@"File"];
        
        NSError * error = nil;
        
        if ( [[NSFileManager defaultManager] fileExistsAtPath:cachePath] == NO )
        {
            
            // Cache is empty, create it
            [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
            
            if ( error != nil )
            {
                NSLog(@"Error: '%@' creating File cache path: '%@'", [error localizedDescription], cachePath);
                
                [self release];
                
                return nil;
            }
            
        }
        else
        {
            
            NSArray * cacheContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:&error];
            
            if ( error != nil )
            {
                NSLog(@"Error: '%@' enumerating File cache path: '%@'", [error localizedDescription], cachePath);
                
                [self release];
                
                return nil;
            }
            
            for ( NSString * fileName in cacheContents )
            {
                
                NSArray * components = [fileName componentsSeparatedByString:@"."];
                
                NSString * keyStr = [components objectAtIndex:0];
                
                NSNumber * key = [NSNumber numberWithInteger:[keyStr integerValue]];
                
                NSString * filePath = [cachePath stringByAppendingPathComponent:fileName];
                
                if ( filePath == nil || key == nil )
                {
                    NSLog(@"Failed to map %@ to %@", key, filePath);
                }
                else
                {
                    [m_fileCacheMap setObject:filePath forKey:key];
                    
//                    NSLog(@"Mapped %@ to %@", key, filePath);
                }
                
            }
            
        }
        
    }
    
    return self;
    
}

- (void)dealloc
{
    [m_cloudController release];
    
    [m_pendingFileRequests release];
    
    [m_fileCacheMap release];
    
    [super dealloc];
}

- (void)clearCache
{
    
    NSLog(@"Clearing the File cache!");
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * cacheDirectory = [paths objectAtIndex:0];
    NSString * cachePath = [cacheDirectory stringByAppendingPathComponent:@"File"];
    
    NSError * error = nil;
    
    BOOL result;
    
    // Delete the old cache folder
    result = [[NSFileManager defaultManager] removeItemAtPath:cachePath error:&error];
    
    if ( result == NO || error != nil )
    {
        NSLog(@"Failed to delete File cache");
        
        return;
    }
    
    // Now that all the files are deleted, clear the mapping to them.
    [m_fileCacheMap release];
    
    m_fileCacheMap = [[NSMutableDictionary alloc] init];
    
    // Create a new cache folder
    result = [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
    
    if ( result == NO || error != nil )
    {
        NSLog(@"Error creating File cache path: %@", cachePath);
        
        return;
    }
    
}

#pragma mark General

- (BOOL)fileExists:(NSInteger)fileId
{
    
    NSNumber * key = [NSNumber numberWithInteger:fileId];
    
    NSString * filePath = [m_fileCacheMap objectForKey:key];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
}

- (id)loadFile:(NSInteger)fileId
{
    
    NSNumber * key = [NSNumber numberWithInteger:fileId];
    
    NSString * filePath = [m_fileCacheMap objectForKey:key];
    
    if ( filePath == nil )
    {
        return nil;
    }
    
    if ( [filePath hasSuffix:@".png"] == YES )
    {
        
        UIImage * img = [UIImage imageWithContentsOfFile:filePath];
        
        return img;
        
    }
    else if ( [filePath hasSuffix:@".xmp"] == YES )
    {
        
        NSString * str = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
        
        return str;
        
    }
    else
    {
        
        NSLog(@"Failed loading invalid file type");
        
        return nil;
        
    }

    return nil;
    
}

- (BOOL)saveFilePath:(NSString*)filePath withFileId:(NSInteger)fileId
{
    
    if ( filePath == nil )
    {
        return NO;
    }
    
    id file = nil;
    
    if ( [filePath hasSuffix:@".png"] == YES ||
         [filePath hasSuffix:@".jpg"] == YES ||
         [filePath hasSuffix:@".jpeg"] == YES )
    {
        
        UIImage * img = [UIImage imageWithContentsOfFile:filePath];
        
        file = img;
        
    }
    else if ( [filePath hasSuffix:@".xmp"] == YES )
    {
        
        NSString * str = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
        
        file = str;
        
    }
    else
    {
        
        NSLog(@"Failed loading invalid file type before saving");
        
        return NO;
    }
        
    return [self saveFile:file withFileId:fileId];
    
}

- (BOOL)saveFile:(id)file withFileId:(NSInteger)fileId
{
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * cacheDirectory = [paths objectAtIndex:0];
    NSString * cachePath = [cacheDirectory stringByAppendingPathComponent:@"File"];
    
    NSString * fileName = nil;
    NSData * fileContents = nil;
    
    if ( [file isKindOfClass:[UIImage class]] == YES )
    {
        
        UIImage * img = (UIImage*)file;
        
        fileName = [NSString stringWithFormat:@"%u.png", fileId];
        fileContents = UIImagePNGRepresentation(img);
        
    }
    else if ( [file isKindOfClass:[NSString class]] == YES )
    {
        
        NSString * str = (NSString*)file;
        
        fileName = [NSString stringWithFormat:@"%u.xmp", fileId];
        fileContents = [str dataUsingEncoding:NSASCIIStringEncoding];
        
    }
    else
    {
        NSLog(@"Failed to save invalid file type");
        
        return NO;
    }
    
    NSString * filePath = [cachePath stringByAppendingPathComponent:fileName];

    BOOL success = [fileContents writeToFile:filePath atomically:YES];
    
    if ( success == NO )
    {
        return NO;
    }
    
    NSNumber * key = [NSNumber numberWithInteger:fileId];
    
//    NSLog(@"Saved %@ to %@", key, filePath);
    
    [m_fileCacheMap setObject:filePath forKey:key];
    
    // Don't backup this file
    [self addSkipBackupAttributeToFileId:fileId];
    
    return YES;
    
}

- (id)getFileOrReturnNil:(NSInteger)fileId
{
    // nil is ok
    return [self loadFile:fileId];
}

- (id)getFileOrDownloadSync:(NSInteger)fileId
{
    
    // FileId of zero is an invalid id
    if ( fileId == 0 )
    {
        return nil;
    }
    
    id file = [self loadFile:fileId];
    
    if ( file == nil )
    {
        
        CloudRequest * cloudRequest = [m_cloudController requestFile:fileId andCallbackObj:nil andCallbackSel:nil];
        
        CloudResponse * cloudResponse = cloudRequest.m_cloudResponse;
        
        file = [self receivedFileResponse:cloudResponse];
        
    }
    
    return file;

}

- (void)getFileOrDownloadAsync:(NSInteger)fileId callbackObject:(id)obj callbackSelector:(SEL)sel
{
    
    // FileId of zero is an invalid id
    if ( fileId == 0 )
    {
        [obj performSelector:sel withObject:nil];
        return;
    }
    
    id file = [self loadFile:fileId];
    
    if ( file == nil )
    {
        [self downloadFile:fileId callbackObject:obj callbackSelector:sel];
    }
    else
    {
        [obj performSelector:sel withObject:file];
    }
    
}

- (void)precacheFile:(NSInteger)fileId
{
    
    // FileId of zero is an invalid id
    if ( fileId == 0 )
    {
        return;
    }
    
    // We only cache the object if we don't have it already.
    NSNumber * key = [NSNumber numberWithInteger:fileId];
    
    if ( [m_fileCacheMap objectForKey:key] != nil )
    {
        return;
    }
    
    // download a file for the first time
    FileRequest * fileRequest = [m_pendingFileRequests objectForKey:key];
    
    // see if there is already a request pending
    if ( fileRequest == nil )
    {
        
        fileRequest = [[[FileRequest alloc] initWithFileId:fileId] autorelease];
        [m_pendingFileRequests setObject:fileRequest forKey:key];

        // send it to the cloud
        [m_cloudController requestFile:fileId andCallbackObj:self andCallbackSel:@selector(downloadFileCallback:)];

    }
    
}

- (void)downloadFile:(NSInteger)fileId callbackObject:(id)obj callbackSelector:(SEL)sel
{
    
    NSNumber * key = [NSNumber numberWithInteger:fileId];
    
    FileRequest * fileRequest = [m_pendingFileRequests objectForKey:key];
    
    // see if there is another request pending
    if ( fileRequest == nil )
    {
        // send off the request
        fileRequest = [[[FileRequest alloc] initWithFileId:fileId andCallbackObject:obj andSelector:sel] autorelease];
        [m_pendingFileRequests setObject:fileRequest forKey:key];
    }
    else
    {
        // If this request is already going, just add ourselves to the list of waiting objects
        [fileRequest addCallbackObject:obj andSelector:sel];
    }
    
    // send it to the cloud
    [m_cloudController requestFile:fileId andCallbackObj:self andCallbackSel:@selector(downloadFileCallback:)];
    
}

- (void)downloadFileCallback:(CloudResponse*)cloudResponse
{
    
    id file = [self receivedFileResponse:cloudResponse];
    
    NSNumber * key = [NSNumber numberWithInteger:cloudResponse.m_responseFileId];

    FileRequest * fileRequest = [m_pendingFileRequests objectForKey:key];
    
    if ( fileRequest != nil )
    {
        // send the file to the original caller(s)
        [fileRequest returnResponse:file];
        
        [m_pendingFileRequests removeObjectForKey:key];
    }
    
}

- (id)receivedFileResponse:(CloudResponse*)cloudResponse
{
    
    NSData * fileData = cloudResponse.m_receivedData;
    
    NSString * fileType = cloudResponse.m_mimeType;
    
    id file = [self createFile:fileData fromMimeType:fileType];
    
    NSNumber * key = [NSNumber numberWithInteger:cloudResponse.m_responseFileId];
    
    if ( file != nil )
    {
        [self saveFile:file withFileId:cloudResponse.m_responseFileId];
    }
    
    FileRequest * fileRequest = [m_pendingFileRequests objectForKey:key];
    
    if ( fileRequest != nil )
    {
        [fileRequest returnResponse:file];
    }
    
    return file;
    
}

- (id)createFile:(NSData*)data fromMimeType:(NSString*)mimeType
{
    
    if ( [mimeType isEqualToString:@"text/xml"] == YES )
    {
        NSString * xmpBlob = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
        
        return xmpBlob;
    }
    
    if ( ([mimeType isEqualToString:@"image/png"] == YES) ||
         ([mimeType isEqualToString:@"image/jpeg"] == YES) ||
         ([mimeType isEqualToString:@"image/jpg"] == YES) )
    {
        UIImage * image = [[[UIImage alloc] initWithData:data] autorelease];
        
        return image;
    }
    
    return nil;
    
}

#pragma mark - Permissions setting

// This changes a file's attributes so they aren't backed-up
- (BOOL)addSkipBackupAttributeToFileId:(NSInteger)fileId
{
    
    NSNumber * key = [NSNumber numberWithInteger:fileId];
    
    NSString * filePath = [m_fileCacheMap objectForKey:key];
    
    if ( filePath == nil )
    {
        return NO;
    }
    
    return [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:filePath]];
    
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:[URL path]] == NO )
    {
        NSLog(@"File does not exist, cannot set attributes.");
        return NO;
    }
    
    NSError * error = nil;
    
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
    
    if ( success == NO )
    {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    
    return success;
    
}


@end
