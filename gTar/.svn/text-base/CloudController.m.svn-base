//
//  CloudController.m
//  gTar
//
//  Created by wuda on 11/10/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "CloudController.h"

@implementation CloudController

@synthesize m_currentRequestType, m_userSongs, m_authenticated;

- (CloudController*)initWithUsername:(NSString*)username andPassword:(NSString*)password andDelegate:(id<CloudControllerDelegate>)delegate
{
	
	if ( self = [super init] )
	{
		
		m_password = password;
		m_username = username;
		
		m_delegate = delegate;
		
		m_servername = @"www.strumhub.com/v0";
		
		m_currentRequestType = RequestTypeNone;
		
		m_authenticated = NO;
		
	}
	
	return self;
	
}

- (void)authenticate
{

	m_currentRequestType = RequestTypeAuthentication;
	
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

	NSString *post = @"data[User][username]=idan&data[User][password]=idan";
	
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  
	
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
	
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	
    [request setURL:[NSURL URLWithString:@"http://www.strumhub.com/v0/users/login"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
	
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
    if (conn)
    {
        m_receivedData = [[NSMutableData data] retain];
    }
    else
    {
        // inform the user that the download could not be made
    }
	
}

- (void)getSongsXml
{

	m_currentRequestType = RequestTypeGetSongsXml;

	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	
    [request setURL:[NSURL URLWithString:@"http://www.strumhub.com/v0/UserSongs/GetSongsXML"]];
    [request setHTTPMethod:@"GET"];
//    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPBody:postData];
	
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
    if (conn)
    {
        m_receivedData = [[NSMutableData data] retain];
    }
    else
    {
        // inform the user that the download could not be made
    }
	
}

- (void)getSongXmp:(UserSong*)userSong
{
	
	m_currentRequestType = RequestTypeGetSongXmp;
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	
	NSString * urlString = [NSString stringWithFormat:@"http://www.strumhub.com/v0/%@", userSong.m_urlPath];
	
    [request setURL:[NSURL URLWithString:urlString]];
	
    [request setHTTPMethod:@"GET"];
	//    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	//    [request setHTTPBody:postData];
	
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
    if (conn)
    {
        m_receivedData = [[NSMutableData data] retain];
    }
    else
    {
        // inform the user that the download could not be made
    }
	
	
}

- (void)getSongXmpWithSongId:(NSInteger)songId
{
	
	UserSong * userSong = [m_userSongs getSongWithSongId:songId];

	[self getSongXmp:userSong];
	
}

- (void)invalidateDelegate
{
	m_delegate = nil;
}

#pragma mark -
#pragma mark Delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response  
{  
    [m_receivedData setLength:0];  
}   

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  
{  
    [m_receivedData appendData:data];  
}  

- (void)connectionDidFinishLoading:(NSURLConnection *)connection  
{  
    // do something with the data  
    // receivedData is declared as a method instance elsewhere  
    //NSLog(@"Succeeded! Received %d bytes of data",[m_receivedData length]);  
    
	NSString * responseStr = [[NSString alloc] initWithData:m_receivedData encoding:NSASCIIStringEncoding];  
    NSLog(responseStr);
	
	// release the connection, and the data object  
    [m_receivedData release];  
		
	m_receivedData = nil;
	
	//NSURL * url = [NSURL URLWithString:@"http://www.strumhub.com/v0"];
	
	//NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
	//NSHTTPCookie * cookie = [cookies objectAtIndex:0];
	
	switch ( m_currentRequestType )
	{
		case RequestTypeAuthentication:
		{

			m_currentRequestType = RequestTypeNone;
			
			m_authenticated = YES;
			
			[m_delegate authenticationSuccess];
			
			//[self getSongsXml];

		} break;

		case RequestTypeGetSongsXml:
		{
			
			m_currentRequestType = RequestTypeNone;
			
			m_songsXml = responseStr;
			
			m_userSongs = [[UserSongs alloc] initWithXml:m_songsXml];
			
			[m_delegate receivedSongsXml:m_userSongs];
			
		} break;
			
		case RequestTypeGetSongXmp:
		{
			
			m_currentRequestType = RequestTypeNone;
						
			[m_delegate receivedSongXmp:responseStr];
			
		} break;
			
		default:
			break;
	}
	
}  

@end
