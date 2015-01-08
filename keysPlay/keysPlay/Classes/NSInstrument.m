//
//  NSInstrument.m
//  keysPlay
//
//  Created by Kate Schnippering on 1/6/15.
//
//

#import "NSInstrument.h"
#import "NSSampler.h"
#import "XmlDom.h"

@implementation NSInstrument

@synthesize m_id;
@synthesize m_xmpid;
@synthesize m_name;
//@synthesize m_iconName;
@synthesize m_custom;
@synthesize m_sampler;


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

/*
-(NSString *)saveToFile:(NSString *)filename saveWithSamples:(BOOL)saveWithSamples
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
    
    if(saveWithSamples){
        node->AddChild([self convertToSequenceXmp]);
    }else{
        node->AddChild([self convertToSongXmp]);
    }
    
    XMPTree tree = NULL;
    
    tree.AddChild(node);
    
    tree.SaveXMPToFile(filepath, YES);
    
    DLog(@"Saved to path %s",filepath);
    
    NSString * instrumentFile = [NSString stringWithContentsOfFile:instrumentFilepath encoding:NSASCIIStringEncoding error:nil];
    
    return instrumentFile;
    
}
*/

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
    DLog(@"TODO: Release Sounds");
    //[m_sampler.audio releaseSounds];
}

@end
