//
//  NSInstrument.m
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSInstrument.h"

@implementation NSInstrument

@synthesize m_id;
@synthesize m_xmpid;
@synthesize m_name;
//@synthesize m_iconName;
@synthesize m_custom;
@synthesize m_sampler;

-(id)initWithXMPNode:(XMPNode *)xmpNode
{
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        XMPObject * instrument = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_name = [[NSString alloc] initWithUTF8String:[instrument GetAttributeValueWithName:@"name"].GetPszValue()];
        
        //m_iconName = [[NSString alloc] initWithUTF8String:[instrument GetAttributeValueWithName:@"iconname"].GetPszValue()];
        
        [instrument GetAttributeValueWithName:@"index"].GetValueInt(&m_id);
        
        if(m_id <= 0){
            [instrument GetAttributeValueWithName:@"xmpid"].GetValueInt(&m_xmpid);
            m_id = m_xmpid;
        }
        
        [instrument GetAttributeValueWithName:@"custom"].GetValueBool(&m_custom);
        
        if(xmpNode->HasChild((char *)"gain")){
            m_sampler = [[NSSampler alloc] initWithXMPNode:xmpNode->FindChildByName((char *)"gain")->FindChildByName((char *)"sampler")];
        }else{
            m_sampler = nil;
        }
    }
    
    return self;
}

-(id)initWithXmlDom:(XmlDom *)dom
{
    if(dom == nil){
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        
        m_name = [dom getTextFromChildWithName:@"name"];
        
        //m_iconName = [dom getTextFromChildWithName:@"iconname"];
        
        m_id = [dom getIntegerFromChildWithName:@"index"];
        
        if(m_id <= 0){
            m_xmpid = [dom getIntegerFromChildWithName:@"xmpid"];
            m_id = m_xmpid;
        }
        
        m_custom = [[dom getTextFromChildWithName:@"custom"] boolValue];
        
        m_sampler = [[NSSampler alloc] initWithXmlDom:[[dom getChildWithName:@"gain"] getChildWithName:@"sampler"]];
        
        DLog(@"INSTRUMENT name | %@",m_name);
        
        DLog(@"INSTRUMENT id | %i",m_id);
    }
    
    return self;
}


-(id)init
{
    self = [super init];
    
	if ( self )
    {
        m_name = @"";
        m_id = -1;
        m_xmpid = -1;
        //m_iconName = @"";
        m_custom = NO;
        
        m_sampler = [[NSSampler alloc] init];
    }
    
    return self;
}

-(id)initWithName:(NSString *)name id:(long)index iconName:(NSString *)iconName isCustom:(BOOL)isCustom
{
    
    self = [super init];
    
	if ( self )
    {
        m_name = name;
        m_id = index;
        m_xmpid = m_id;
        //m_iconName = iconName;
        m_custom = isCustom;
        
        m_sampler = [[NSSampler alloc] init];
    }
    
    return self;
}

-(XMPNode *)convertToSequenceXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"instrument" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_name UTF8String]));
    
    //node->AddAttribute(new XMPAttribute((char *)"iconname", (char *)[m_iconName UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"index", m_id));
    
    node->AddAttribute(new XMPAttribute((char *)"custom", m_custom));
    
    XMPNode * header = NULL;
    header = new XMPNode((char *)[@"header" UTF8String],NULL);
    node->AddChild(header);
    
    if(m_sampler != nil){
        
        // Add display XMP for Gears
        XMPNode * display = NULL;
        display = new XMPNode((char *)[@"display" UTF8String],NULL);
        header->AddChild(display);
        
        XMPNode * view = NULL;
        view = new XMPNode((char *)[@"view" UTF8String],NULL);
        view->AddAttribute(new XMPAttribute((char *)"width",(char *)"200px"));
        display->AddChild(view);
        
        XMPNode * label = NULL;
        label = new XMPNode((char *)[@"label" UTF8String],NULL);
        label->AddAttribute(new XMPAttribute((char *)"top",(char *)"10px"));
        label->AddAttribute(new XMPAttribute((char *)"left",(char *)"15px"));
        label->AppendContentNode((char*)[m_name UTF8String]);
        view->AddChild(label);
        
        int sampleIndex = 0;
        for(NSSample * sample in m_sampler.m_samples){
            
            int topPx = 35+30*sampleIndex;
            NSString * topPxString = [NSString stringWithFormat:@"%ipx",topPx];
            
            XMPNode * button = NULL;
            button = new XMPNode((char *)[@"button" UTF8String],NULL);
            button->AddAttribute(new XMPAttribute((char *)"top",(char *)[topPxString UTF8String]));
            button->AddAttribute(new XMPAttribute((char *)"left",(char *)"15px"));
            button->AddAttribute(new XMPAttribute((char *)"target",(char *)[sample.m_externalId UTF8String]));
            button->AddAttribute(new XMPAttribute((char *)"param",(char *)"trigger"));
            button->AddAttribute(new XMPAttribute((char *)"type",(char *)"momentary"));
            button->AddAttribute(new XMPAttribute((char *)"value",(char *)"0"));
            button->AppendContentNode((char*)[sample.m_name UTF8String]);
            view->AddChild(button);
            
            sampleIndex++;
        }
        
        XMPNode * gain = NULL;
        gain = new XMPNode((char *)[@"gain" UTF8String],NULL);
        gain->AddAttribute(new XMPAttribute((char *)"value",1.0));
        node->AddChild(gain);
        
        gain->AddChild([m_sampler convertToXmp]);
    }
    
    return node;
}

-(XMPNode *)convertToSongXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"instrument" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_name UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"xmpid", m_id));
    
    node->AddAttribute(new XMPAttribute((char *)"custom", m_custom));
    
    return node;
}


-(NSString *)saveToFile:(NSString *)filename
{
    m_name = filename;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:TYPE_INSTRUMENT];
    
    NSError * err = NULL;
    [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];
    
    NSString * instrumentFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Instruments/" stringByAppendingString:[filename stringByAppendingString:@".xml"]]];
    
    char * filepath = (char *)[instrumentFilepath UTF8String];
    
    XMPNode *node = NULL;
    //XMPNode *custom = NULL;
    node = new XMPNode((char *)[@"xmp" UTF8String],NULL);
    //custom = new XMPNode((char *)[@"custom" UTF8String],NULL);
    //node->AddChild(custom);
    node->AddChild([self convertToSequenceXmp]);
    
    XMPTree tree = NULL;
    
    tree.AddChild(node);
    
    tree.SaveXMPToFile(filepath, YES);
    
    DLog(@"Saved to path %s",filepath);
    
    NSString * instrumentFile = [NSString stringWithContentsOfFile:instrumentFilepath encoding:NSASCIIStringEncoding error:nil];
    
    return instrumentFile;
    
}


- (void)deleteFile
{
    NSString * filename = m_name;
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * sequenceFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Instruments/" stringByAppendingString:[filename stringByAppendingString:@".xml"]]];
    
    NSError * error = NULL;
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:sequenceFilepath error:&error];
    
    if(!result)
        DLog(@"Error deleting");
}

- (NSString *)getIconName
{
    NSString * filePath = [[NSBundle mainBundle] pathForResource:[@"Icon_" stringByAppendingString:m_name] ofType:@"png"];
    NSString * iconName = @"Icon_Custom";
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        iconName = [@"Icon_" stringByAppendingString:m_name];
    }
    
    return iconName;
}


-(void)releaseSounds
{
    [m_sampler.audio releaseSounds];
}

/*
 
 #pragma mark Saving To Disk
 
 - (void)encodeWithCoder:(NSCoder *)aCoder
 {
 [aCoder encodeObject:patterns forKey:@"Patterns"];
 [aCoder encodeInt:instrument forKey:@"Instrument"];
 [aCoder encodeInt:selectedPatternIndex forKey:@"Selected Pattern Index"];
 [aCoder encodeObject:instrumentName forKey:@"Instrument Name"];
 [aCoder encodeObject:iconName forKey:@"Icon Name"];
 [aCoder encodeBool:isSelected forKey:@"Is Selected"];
 [aCoder encodeObject:stringSet forKey:@"Strings"];
 [aCoder encodeBool:isMuted forKey:@"Is Muted"];
 [aCoder encodeObject:isCustom forKey:@"Custom"];
 [aCoder encodeDouble:amplitude forKey:@"Amplitude"];
 
 }
 
 */

@end
