//
//  NSSample.m
//  keysPlay
//
//  Created by Kate Schnippering on 1/6/15.
//
//

#import "NSSample.h"
#import "XmlDom.h"

@implementation NSSample

@synthesize m_name;
@synthesize m_value;
@synthesize m_custom;
@synthesize m_xmpFileId;
@synthesize m_externalId;
@synthesize m_sampleData;


-(id)initWithXmlDom:(XmlDom *)dom
{
    if(dom == nil){
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        
        m_name = [dom getTextFromChildWithName:@"name"];
        
        m_value = [dom getTextFromChildWithName:@"value"];
        
        m_custom = [[dom getTextFromChildWithName:@"custom"] boolValue];
        
        m_xmpFileId = [[dom getTextFromChildWithName:@"xmpid"] intValue];
        
        m_externalId = [dom getTextFromChildWithName:@"id"];
        
        m_sampleData = [dom getText];
        
        DLog(@"SAMPLE %@",m_name);
        
    }
    
    return self;
}

-(id)initWithName:(NSString *)name custom:(bool)custom value:(NSString *)value externalId:(NSString *)externalId xmpFileId:(long)xmpFileId
{
    self = [super init];
    
    if ( self )
    {
        m_name = name;
        m_value = value;
        m_custom = custom;
        m_xmpFileId = xmpFileId;
        m_externalId = externalId;
        m_sampleData = nil;
    }
    
    return self;
}

/*
- (void)saveToFile
{
    NSString * filename = m_name;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Samples"];
    
    NSError * err = NULL;
    [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];
    
    NSString * sequenceFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Samples/" stringByAppendingString:[filename stringByAppendingString:@".xml"]]];
    
    char * filepath = (char *)[sequenceFilepath UTF8String];
    
    XMPNode *node = NULL;
    node = new XMPNode((char *)[@"xmp" UTF8String],NULL);
    node->AddChild([self convertToXmp]);
    
    XMPTree tree = NULL;
    
    tree.AddChild(node);
    
    tree.SaveXMPToFile(filepath, YES);
    
    DLog(@"Saved SAMPLE to path %s",filepath);
    
}
*/

@end
