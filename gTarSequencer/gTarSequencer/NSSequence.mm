//
//  NSSequence.m
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSSequence.h"

@implementation NSSequence

@synthesize m_tracks;
@synthesize m_name;
@synthesize m_tempo;
@synthesize m_volume;
@synthesize m_selectedTrackIndex;

- (id)initWithXMPFilename:(NSString *)filename
{
    if(filename == nil || [filename length] == 0){
        return nil;
    }
    
    self = [super init];
    
    if(self){
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString * sequenceFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Sequences/" stringByAppendingString:[filename stringByAppendingString:@".xml"]]];
        
        char * filepath = (char *)[sequenceFilepath UTF8String];
        
        DLog(@"initWithXMPFilename Sequences/%@.xml",filename);
        
        XMPTree MyTree(filepath);
        
        XMPNode * root = MyTree.GetRootNode()->FindChildByName((char *)"xmp")->FindChildByName((char *)"sequence");
        
        self = [self initWithXMPNode:root];
        
        DLog(@"Finished init?");
        
    }
    
    return self;
}

- (id)initWithXMPNode:(XMPNode *)xmpNode
{
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        XMPObject * sequence = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_name = [[sequence GetChildWithName:@"header"] GetChildTextWithName:@"name"];
        
        [[[sequence GetChildWithName:@"header"] GetChildWithName:@"tempo"] GetAttributeValueWithName:@"value"].GetValueDouble(&m_tempo);
        
        [[[sequence GetChildWithName:@"header"] GetChildWithName:@"volume"] GetAttributeValueWithName:@"value"].GetValueDouble(&m_volume);
        
        m_tracks = [[NSMutableArray alloc] init];
        
        m_selectedTrackIndex = 0;
        
        DLog(@"SEQUENCE");
        
        list<XMPNode *>* t_tracks = xmpNode->FindChildByName((char *)"content")->GetChildren();
        
        for(list<XMPNode *>::iterator it = t_tracks->First(); it != NULL; it++){
            
            NSTrack * track = [[NSTrack alloc] initWithXMPNode:*it];
            
            [self addTrack:track];
        }
        
    }
    
    return self;
}

-(id)initWithName:(NSString *)name tempo:(double)tempo volume:(double)volume
{
	
    self = [super init];
    
	if ( self )
	{
		
		m_tracks = [[NSMutableArray alloc] init];
		
        m_name = name;
        m_tempo = tempo;
        m_volume = volume;
        
        m_selectedTrackIndex = 0;
	}
	
	return self;
}

-(id)initWithName:(NSString *)name tempo:(double)tempo volume:(double)volume instruments:(NSArray *)instruments
{
    self = [super init];
    
	if ( self )
	{
		
		m_tracks = [[NSMutableArray alloc] init];
		
        m_name = name;
        m_tempo = tempo;
        m_volume = volume;
        
        m_selectedTrackIndex = 0;
        
        // TODO: IMPLEMENT
	}
	
	return self;
}

-(XMPNode *)convertToXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"sequence" UTF8String],NULL);
    
    XMPNode *headerNode = new XMPNode((char *)"header", node);
    node->AddChild(headerNode);
    
    XMPNode *contentNode = new XMPNode((char *)"content", node);
    node->AddChild(contentNode);
    
    XMPNode * tempNode = new XMPNode((char *)"name", headerNode);
    tempNode->AppendContentNode((char*)[m_name UTF8String]);
    headerNode->AddChild(tempNode);
    
    tempNode = new XMPNode((char *)"tempo", headerNode);
    tempNode->AddAttribute(new XMPAttribute((char *)"value", m_tempo));
    headerNode->AddChild(tempNode);
    
    tempNode = new XMPNode((char *)"volume", headerNode);
    tempNode->AddAttribute(new XMPAttribute((char *)"value", m_volume));
    headerNode->AddChild(tempNode);
    
    for(NSTrack * track in m_tracks){
        contentNode->AddChild([track convertToXmp]);
    }
    
    return node;
}

-(void)saveToFile:(NSString *)filename
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Sequences"];
    
    NSError * err = NULL;
    [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];
    
    NSString * sequenceFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Sequences/" stringByAppendingString:[filename stringByAppendingString:@".xml"]]];
    
    char * filepath = (char *)[sequenceFilepath UTF8String];
  
    XMPNode *node = NULL;
    node = new XMPNode((char *)[@"xmp" UTF8String],NULL);
    node->AddChild([self convertToXmp]);
    
    XMPTree tree = NULL;
    
    tree.AddChild(node);
    
    tree.SaveXMPToFile(filepath, YES);
    
    DLog(@"Saved to path %s",filepath);
    
}

-(void)addTrack:(NSTrack *)track
{
    [m_tracks addObject:track];
}

-(int)trackCount
{
    return [m_tracks count];
}

@end
