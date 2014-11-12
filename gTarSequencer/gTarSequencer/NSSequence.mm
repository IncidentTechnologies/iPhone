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
@synthesize m_xmpName;
@synthesize m_tempo;
@synthesize m_volume;
@synthesize m_id;
@synthesize m_selectedTrackIndex;
@synthesize m_originSequenceRoot;

#define DEFAULT_STATE_NAME @"sequenceCurrentState"

// Use to load sequence object with XmlDom
- (id)initWithXMLFilename:(NSString *)filename fromBundle:(BOOL)fromBundle
{
    if(filename == nil || [filename length] == 0){
        return nil;
    }
    
    self = [super init];
    
    if(self){
        
        NSString * sequenceFilepath;
        
        if(fromBundle){
            sequenceFilepath = [[NSBundle mainBundle] pathForResource:filename ofType:@"xml"];
        }else{
            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            sequenceFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Sequences/" stringByAppendingString:[filename stringByAppendingString:@".xml"]]];
        }
        
        DLog(@"initWithXMPFilename %@.xml",filename);
        
        NSString * fileString = [NSString stringWithContentsOfFile:sequenceFilepath encoding:NSUTF8StringEncoding error:nil];
        
        XmlDom * dom = [[XmlDom alloc] initWithXmlString:fileString];
        
        self = [self initWithXmlDom:dom];
        
        DLog(@"Finished XML init");
        
    }
    
    return self;
}

// Use to load Sequence object with XmpNode
- (id)initWithXMPFilename:(NSString *)filename fromBundle:(BOOL)fromBundle
{
    if(filename == nil || [filename length] == 0){
        return nil;
    }
    
    self = [super init];
    
    if(self){
        
        NSString * sequenceFilepath;
        
        if(fromBundle){
            sequenceFilepath = [[NSBundle mainBundle] pathForResource:filename ofType:@"xml"];
        }else{
            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            sequenceFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Sequences/" stringByAppendingString:[filename stringByAppendingString:@".xml"]]];
        }
        
        char * filepath = (char *)[sequenceFilepath UTF8String];
        
        DLog(@"initWithXMPFilename %@.xml",filename);
        
        XMPTree MyTree(filepath);
        
        XMPNode * root = MyTree.GetRootNode()->FindChildByName((char *)"xmp")->FindChildByName((char *)"custom")->FindChildByName((char *)"sequence");
        
        self = [self initWithXMPNode:root];
        
        DLog(@"Finished XMP init");
        
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
        m_xmpName = m_name;
        
        [[[sequence GetChildWithName:@"header"] GetChildWithName:@"tempo"] GetAttributeValueWithName:@"value"].GetValueDouble(&m_tempo);
        
        [[[sequence GetChildWithName:@"header"] GetChildWithName:@"volume"] GetAttributeValueWithName:@"value"].GetValueDouble(&m_volume);
        
        [[[sequence GetChildWithName:@"header"] GetChildWithName:@"id"] GetAttributeValueWithName:@"value"].GetValueInt(&m_id);
        
        [[[sequence GetChildWithName:@"header"] GetChildWithName:@"origin-sequence-root"] GetAttributeValueWithName:@"value"].GetValueBool(&m_originSequenceRoot);
        
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


- (id)initWithXmlDom:(XmlDom *)dom
{
    if(dom == nil){
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        XmlDom * header = [[[dom getChildWithName:@"custom"]  getChildWithName:@"sequence"] getChildWithName:@"header"];
        XmlDom * content = [[[dom getChildWithName:@"custom"]  getChildWithName:@"sequence"] getChildWithName:@"content"];
        
        m_name = [header getTextFromChildWithName:@"name"];
        m_xmpName = m_name;
        m_id = [[header getValueFromChildWithName:@"id"] intValue];
        m_tempo = [[header getValueFromChildWithName:@"tempo"] floatValue];
        m_volume = [[header getValueFromChildWithName:@"volume"] floatValue];
        m_originSequenceRoot = [[header getValueFromChildWithName:@"origin-sequence-root"] boolValue];
        
        DLog(@"SEQUENCE id | %li",m_id);
        DLog(@"SEQUENCE name | %@",m_name);
        DLog(@"SEQUENCE tempo | %f",m_tempo);
        DLog(@"SEQUENCE volume | %f",m_volume);
        
        // Init the track children
        m_tracks = [[NSMutableArray alloc] init];
        
        m_selectedTrackIndex = 0;
        
        NSArray * children = [content getChildArrayWithName:@"track"];
        
        for(XmlDom * child in children){
            
            NSTrack * m_track = [[NSTrack alloc] initWithXmlDom:child];
            
            [self addTrack:m_track];
            
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
        m_xmpName = name;
        m_tempo = tempo;
        m_volume = volume;
        m_originSequenceRoot = false;
        
        // TODO: get from server
        m_id = 0;
        
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
        m_xmpName = name;
        m_tempo = tempo;
        m_volume = volume;
        m_originSequenceRoot = false;
        
        m_selectedTrackIndex = 0;
        
        // TODO: IMPLEMENT
	}
	
	return self;
}

-(XMPNode *)convertToXmp:(BOOL)saveWithSamples
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
    
    tempNode = new XMPNode((char *)"id", headerNode);
    tempNode->AddAttribute(new XMPAttribute((char *)"value", m_id));
    headerNode->AddChild(tempNode);
    
    tempNode = new XMPNode((char *)"origin-sequence-root", headerNode);
    tempNode->AddAttribute(new XMPAttribute((char *)"value", m_originSequenceRoot));
    headerNode->AddChild(tempNode);
    
    for(NSTrack * track in m_tracks){
        contentNode->AddChild([track convertToSequenceXmp:saveWithSamples]);
    }
    
    return node;
}

-(NSString *)saveToFile:(NSString *)filename saveWithSamples:(BOOL)saveWithSamples
{
    /*if([m_tracks count] == 0 || [[m_tracks firstObject] m_instrument] == nil){
        DLog(@"ERROR Trying to save incomplete Sequence");
        return nil;
    }*/
    
    // First change the name
    if([filename rangeOfString:DEFAULT_STATE_NAME].location == NSNotFound){
        
        m_name = filename;
        m_xmpName = filename;
        
        DLog(@"Name to %@",filename);
    }
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:TYPE_SEQUENCE];
    
    NSError * err = NULL;
    [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];
    
    NSString * sequenceFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Sequences/" stringByAppendingString:[filename stringByAppendingString:@".xml"]]];
    
    char * filepath = (char *)[sequenceFilepath UTF8String];
  
    XMPNode *node = NULL;
    XMPNode *custom = NULL;
    node = new XMPNode((char *)[@"xmp" UTF8String],NULL);
    custom = new XMPNode((char *)[@"custom" UTF8String],NULL);
    node->AddChild(custom);
    custom->AddChild([self convertToXmp:saveWithSamples]);
    
    XMPTree tree = NULL;
    
    tree.AddChild(node);
    
    tree.SaveXMPToFile(filepath, YES);
    
    DLog(@"Saved to path %s",filepath);
    
   // NSData * sequenceFile = [[NSData alloc] initWithContentsOfFile:sequenceFilepath];
    NSString * sequenceFile = [NSString stringWithContentsOfFile:sequenceFilepath encoding:NSASCIIStringEncoding error:nil];
    
    return sequenceFile;
    
}

- (void)deleteFile
{
    NSString * filename = m_name;
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * sequenceFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Sequences/" stringByAppendingString:[filename stringByAppendingString:@".xml"]]];
    
    NSError * error = NULL;
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:sequenceFilepath error:&error];
    
    if(!result)
        DLog(@"Error deleting");
}

-(void)addTrack:(NSTrack *)track
{
    [m_tracks addObject:track];
}

-(int)trackCount
{
    return [m_tracks count];
}

- (void)renameToName:(NSString *)newName
{
    m_name = newName;
    m_xmpName = newName;
    
    
}

- (void)giveAppOwnership
{
    m_originSequenceRoot = YES;
}

- (void)giveUserOwnership
{
    m_originSequenceRoot = NO;
}

@end
