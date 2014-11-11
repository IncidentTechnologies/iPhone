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
@synthesize m_xmpName;
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

@synthesize m_song;

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
        
        // First check it's a valid filepath
        
        if([[NSFileManager defaultManager] fileExistsAtPath:sequenceFilepath]){
        
            DLog(@"initWithXMPFilename Songs/%@.xml",filename);
            
            XMPTree MyTree(filepath);
            
            XMPNode * rootNode = MyTree.GetRootNode()->FindChildByName((char *)"xmp")->FindChildByName((char *)"song");
            
            self = [self initWithXMPNode:rootNode];
            
            DLog(@"Finished init?");
            
        }else{
            
            DLog(@"ERROR: Attempting to load Song XMP that does not exist.");
            
            return nil;
            
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
        XmlDom * header = [[dom getChildWithName:@"song"] getChildWithName:@"header"];
        XmlDom * content = [[dom getChildWithName:@"song"] getChildWithName:@"content"];
        
        m_title = [header getTextFromChildWithName:@"title"];
        m_author = [header getTextFromChildWithName:@"author"];
        m_description = [header getTextFromChildWithName:@"description"];
        m_id = [[header getValueFromChildWithName:@"id"] intValue];
        m_tempo = [[header getValueFromChildWithName:@"tempo"] intValue];
        
        m_looping = [[header getAttribute:@"looping" fromChildWithName:@"loopsettings"] boolValue];
        
        m_loopstart = [[header getAttribute:@"loopstart" fromChildWithName:@"loopsettings"] intValue];
        
        m_loopend = [[header getAttribute:@"loopend" fromChildWithName:@"loopsettings"] intValue];
        
        m_sequenceId = [[header getAttribute:@"xmpid" fromChildWithName:@"sequence"] intValue];
        
        m_sequenceName = [header getAttribute:@"name" fromChildWithName:@"sequence"];
        
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
        
        // Init the track children
        m_tracks = [[NSMutableArray alloc] init];
        
        NSArray * children = [content getChildArrayWithName:@"track"];
        
        for(XmlDom * child in children){
            
            NSTrack * m_track = [[NSTrack alloc] initWithXmlDom:child];
            
            [self addTrack:m_track];
            
        }
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
        m_song = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        [[[m_song GetChildWithName:@"header"] GetChildWithName:@"id"] GetAttributeValueWithName:@"value"].GetValueInt(&m_id);
        
        m_title = [[m_song GetChildWithName:@"header"] GetChildTextWithName:@"title"];
        m_xmpName = m_title;
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
        
        DLog(@"SONG is %@",m_song);
        
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
    if(m_description != nil){
        tempNode->AppendContentNode((char*)[m_description UTF8String]);
    }else{
        tempNode->AppendContentNode((char*)[@"" UTF8String]);
    }
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
    if(m_sequenceName != nil){
        tempNode->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_sequenceName UTF8String]));
    }
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

- (NSString *)saveToFile:(NSString *)filename
{
    if(filename == nil){
        DLog(@"ERROR: trying to save song to nil filename");
        return nil;
    }
    
    m_title = filename;
    
    DLog(@"Name to %@",m_title);
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:TYPE_SONG];
    
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
    
    //NSData * songFile = [NSData dataWithContentsOfFile:songFilepath];
    NSString * songFile = [NSString stringWithContentsOfFile:songFilepath encoding:NSASCIIStringEncoding error:nil];
    
    return songFile;

}

- (void)deleteFile
{
    if(m_title == nil){
        DLog(@"ERROR: attempting to delete nil file");
        return;
    }
    
    
    NSString * filename = m_title;
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * songFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Songs/" stringByAppendingString:[filename stringByAppendingString:@".xml"]]];
    
    NSError * error = NULL;
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:songFilepath error:&error];
    
    if(!result)
        DLog(@"Error deleting");
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
        m_xmpName = m_title;
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

- (NSTrack *)trackWithName:(NSString *)name
{
    
    if(name == nil || [name length] == 0){
        return nil;
    }
    
    for(NSTrack * track in m_tracks){
        if([track.m_name isEqualToString:name]){
            return track;
        }
    }
    
    return nil;
}

- (NSTrack *)trackWithName:(NSString *)name level:(double)level mute:(bool)mute instrument:(NSInstrument *)inst
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
    NSTrack * newTrack = [[NSTrack alloc] initWithName:name level:level muted:mute];
    newTrack.m_instrument.m_id = inst.m_id;
    newTrack.m_instrument.m_name = inst.m_name;
    
    [self addTrack:newTrack];
    
    return newTrack;
}

- (void)finishTracks
{
    // Get the last beat and set as endbeat for all
    double lastBeat = 0.0;
    
    for(NSTrack * track in m_tracks){
        for(NSClip * clip in track.m_clips){
            for(NSNote * note in clip.m_notes){
                lastBeat = MAX(lastBeat,clip.m_startbeat + note.m_beatstart + note.m_duration);
            }
        }
    }
    
    // Set the endbeat for all the last tracks
    for(NSTrack * track in m_tracks){
        [[track.m_clips lastObject] setEndbeat:lastBeat];
    }
}

- (void)renameToName:(NSString *)name andDescription:(NSString *)description
{
    m_title = name;
    m_xmpName = name;
    m_description = description;
}


- (void)setSongSequence:(NSSequence *)sequence
{
    m_sequenceName = sequence.m_name;
    m_sequenceId = sequence.m_id;
}

- (BOOL)doesSongMatchSequence:(NSSequence *)sequence
{
    int matchingTracksCount = 0;
    
    for(NSTrack * track in sequence.m_tracks){
        
        for(NSTrack * songTrack in m_tracks){
            
            if(track.m_instrument.m_id == songTrack.m_instrument.m_id){
                matchingTracksCount++;
            }
            
        }
    }
    
    DLog(@"Does song match sequence? Matching tracks: %i",matchingTracksCount);
    
    return (matchingTracksCount > 0);
    
}

- (NSSequence *)generateSequenceFromSong
{
    // Generate sequence from song if sequence does not match
    NSSequence * sequence = [[NSSequence alloc] initWithName:[g_ophoMaster generateNextSequenceName] tempo:self.m_tempo volume:1.0];
    
    // Get the IDs for all the instruments
    for(NSTrack * track in self.m_tracks){
        
        NSTrack * sequenceTrack = [[NSTrack alloc] initWithName:track.m_name level:track.m_level muted:track.m_muted];
        
        sequenceTrack.m_instrument = [[NSInstrument alloc] initWithName:track.m_name id:track.m_instrument.m_xmpid iconName:[track.m_instrument getIconName] isCustom:track.m_instrument.m_custom];
        
        [sequence addTrack:sequenceTrack];
        
    }
    
    // Rename song's patterns to custom so they don't get cleared
    
    for(NSTrack * track in m_tracks){
        for(NSClip * clip in track.m_clips){
            if([clip.m_name isEqualToString:OPHO_PATTERN_OFF] || [clip.m_name isEqualToString:PATTERN_OFF]){
                [clip setMute:YES];
            }else{
                [clip changePattern:PATTERN_E];
            }
        }
    }
    
    return sequence;
}

@end
