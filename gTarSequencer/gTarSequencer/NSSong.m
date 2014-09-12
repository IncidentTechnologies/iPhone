//
//  NSSong.m
//  Sequence
//
//  Created by Kate Schnippering on 9/10/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSSong.h"

@implementation NSSong

@synthesize m_id;
@synthesize m_title;
@synthesize m_author;
@synthesize m_description;
@synthesize m_tempo;
@synthesize m_tracks;
@synthesize startbeat;
@synthesize duration;
@synthesize m_looping;
@synthesize m_loopstart;
@synthesize m_loopend;
@synthesize m_sequenceName;
@synthesize m_sequenceId;

- (id)initWithXMPFilename:(NSString *)filename
{
    if(filename == nil || [filename length] == 0){
        return nil;
    }
    
    self = [super init];
    
    if(self){
        
        // check mainbundle
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString * sequenceFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Songs/" stringByAppendingString:[filename stringByAppendingString:@".xml"]]];
        
        char * filepath = (char *)[sequenceFilepath UTF8String];
        
        DLog(@"initWithXMPFilename Songs/%@.xml",filename);
        
        XMPTree MyTree(filepath);
        
        XMPNode * root = MyTree.GetRootNode()->FindChildByName((char *)"xmp")->FindChildByName((char *)"song");
        
        self = [self initWithXMPNode:root];
        
        DLog(@"Finished init?");
        
    }
    
    return self;
}

- (id)initWithXMPNode:(XMPNode *)xmpNode
{
    
    if ( xmpNode == nil )
    {
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        XMPObject * m_song = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        [[[m_song GetChildWithName:@"header"] GetChildWithName:@"id"] GetAttributeValueWithName:@"value"].GetValueInt(&m_id);
        
        m_title = [[m_song GetChildWithName:@"header"] GetChildTextWithName:@"title"];
        m_author = [[m_song GetChildWithName:@"header"] GetChildTextWithName:@"author"];
        m_description = [[m_song GetChildWithName:@"header"] GetChildTextWithName:@"description"];
        
        [[[m_song GetChildWithName:@"header"] GetChildWithName:@"tempo"] GetAttributeValueWithName:@"value"].GetValueInt(&m_tempo);
        
        [[[m_song GetChildWithName:@"header"] GetChildWithName:@"loopsettings"] GetAttributeValueWithName:@"looping"].GetValueBool(&m_looping);
        
        [[[m_song GetChildWithName:@"header"] GetChildWithName:@"loopsettings"] GetAttributeValueWithName:@"loopstart"].GetValueInt(&m_loopstart);
        
        [[[m_song GetChildWithName:@"header"] GetChildWithName:@"loopsettings"] GetAttributeValueWithName:@"loopend"].GetValueInt(&m_loopend);
        
        [[[m_song GetChildWithName:@"header"] GetChildWithName:@"sequence"] GetAttributeValueWithName:@"xmpid"].GetValueInt(&m_sequenceId);
        
        m_sequenceName = [[NSString alloc] initWithUTF8String:[[[m_song GetChildWithName:@"header"] GetChildWithName:@"sequence"] GetAttributeValueWithName:@"name"].GetPszValue()];
        
        DLog(@"SONG id | %li",m_id);
        DLog(@"SONG title | %@",m_title);
        DLog(@"SONG author | %@",m_author);
        DLog(@"SONG description | %@",m_description);
        DLog(@"SONG tempo | %li",m_tempo);
        DLog(@"SONG loopsettings looping | %i",m_looping);
        DLog(@"SONG loopsettings loopstart | %li",m_loopstart);
        DLog(@"SONG loopsettings loopend | %li",m_loopend);
        DLog(@"SONG sequence name | %@",m_sequenceName);
        DLog(@"SONG sequence xmpid | %li",m_sequenceId);
        
        // Init the narrative/input children
        m_tracks = [[NSMutableArray alloc] init];
        
        list<XMPNode *>* t_sections = xmpNode->FindChildByName((char *)"content")->GetChildren();
        
        for(list<XMPNode *>::iterator it = t_sections->First(); it != NULL; it++){
            
            XMPNode * m_it = *it;
            
            if(strcmp(m_it->GetName(),"track") == 0){
                
                NSTrack * m_track = [[NSTrack alloc] initWithXMPNode:m_it];
                
                [self addTrack:m_track];
                
            }
        }
        
    }
    
    return self;
    
}

- (XMPNode *)convertToXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"song" UTF8String],NULL);
    
    XMPNode *headerNode = new XMPNode((char *)"header", node);
    node->AddChild(headerNode);
    
    XMPNode *contentNode = new XMPNode((char *)"content", node);
    node->AddChild(contentNode);
    
    XMPNode *tempNode = new XMPNode((char *)"id", headerNode);
    tempNode->AddAttribute(new XMPAttribute((char *)"value", m_id));
    headerNode->AddChild(tempNode);
    
    tempNode = new XMPNode((char *)"title", headerNode);
    tempNode->AppendContentNode((char*)[m_title UTF8String]);
    headerNode->AddChild(tempNode);
    
    tempNode = new XMPNode((char *)"author", headerNode);
    tempNode->AppendContentNode((char*)[m_author UTF8String]);
    headerNode->AddChild(tempNode);
    
    tempNode = new XMPNode((char *)"description", headerNode);
    tempNode->AppendContentNode((char*)[m_description UTF8String]);
    headerNode->AddChild(tempNode);
    
    tempNode = new XMPNode((char *)"tempo", headerNode);
    tempNode->AddAttribute(new XMPAttribute((char *)"value", m_tempo));
    headerNode->AddChild(tempNode);
    
    tempNode = new XMPNode((char *)"loopsettings", headerNode);
    tempNode->AddAttribute(new XMPAttribute((char *)"looping", m_looping));
    tempNode->AddAttribute(new XMPAttribute((char *)"loopstart", m_loopstart));
    tempNode->AddAttribute(new XMPAttribute((char *)"loopend", m_loopend));
    headerNode->AddChild(tempNode);
    
    tempNode = new XMPNode((char *)"sequence", headerNode);
    tempNode->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_sequenceName UTF8String]));
    tempNode->AddAttribute(new XMPAttribute((char *)"xmpid", m_sequenceId));
    headerNode->AddChild(tempNode);
    
    for(NSTrack * track in m_tracks){
        contentNode->AddChild([track convertToSongXmp]);
    }
    
    return node;
}

- (void)printTree
{
    XMPTree tree = NULL;
    
    tree.AddChild([self convertToXmp]);
    
    tree.PrintXMPTree();
}

- (void)saveToFile:(NSString *)filename
{
    m_title = filename;
    
    DLog(@"Name to %@",m_title);
    
    filename = [@"usr_" stringByAppendingString:filename];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Songs"];
    
    NSError * err = NULL;
    [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];
    
    NSString * songFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Songs/" stringByAppendingString:[filename stringByAppendingString:@".xml"]]];
    
    char * filepath = (char *)[songFilepath UTF8String];
    
    XMPNode *node = NULL;
    node = new XMPNode((char *)[@"xmp" UTF8String],NULL);
    node->AddChild([self convertToXmp]);
    
    XMPTree tree = NULL;
    
    tree.AddChild(node);
    
    tree.SaveXMPToFile(filepath, YES);
    
    DLog(@"Saved to path %s",filepath);

}

- (id)initWithTitle:(NSString *)title author:(NSString *)author description:(NSString *)description tempo:(long)tempo looping:(bool)looping loopstart:(long)loopstart loopend:(long)loopend sequenceName:(NSString *)sequenceName sequenceId:(long)sequenceId
{
	
    self = [super init];
    
	if ( self )
	{
		
		m_tracks = [[NSMutableArray alloc] init];
		
        // TODO: get from server
        m_id = 0;
        
        m_title = title;
        m_author = author;
        m_description = description;
        m_tempo = tempo;
        m_looping = looping;
        m_loopstart = loopstart;
        m_loopend = loopend;
        
        m_sequenceName = sequenceName;
        m_sequenceId = sequenceId;
	}
	
	return self;
}


- (void)addTrack:(NSTrack *)track
{
    [m_tracks addObject:track];
}

- (NSTrack *)trackWithName:(NSString *)name volume:(double)volume mute:(bool)mute instrument:(NSInstrument *)inst
{
    if(name == nil || [name length] == 0){
        return nil;
    }
    
    for(NSTrack * track in m_tracks){
        if([track.m_name isEqualToString:name]){
            return track;
        }
    }
    
    // not found, create
    NSTrack * newTrack = [[NSTrack alloc] initWithName:name volume:volume muted:mute];
    newTrack.m_instrument.m_id = inst.m_id;
    newTrack.m_instrument.m_name = inst.m_name;
    
    [self addTrack:newTrack];
    
    return newTrack;
}

- (void)renameToName:(NSString *)name andDescription:(NSString *)description
{
    m_title = name;
    m_description = description;
}

@end
