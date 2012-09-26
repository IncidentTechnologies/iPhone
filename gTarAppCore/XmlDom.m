//
//  XmlDom.m
//  gTarAppCore
//
//  Created by Marty Greenia on 7/13/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "XmlDom.h"
#import "XmlDictionary.h"

@implementation XmlDom

- (id)initWithXmlString:(NSString*)xmlString
{
    
    if ( xmlString == nil )
    {
        [self release];
        return nil;
    }
    
    NSDictionary * xmlDictionary = [[XmlDictionary dictionaryFromXmlBlob:xmlString] retain];
    
    if ( xmlDictionary == nil )
    {
        [self release];
        return nil;
    }
    
    self = [self initWithXmlDictionary:xmlDictionary];
    
    [xmlDictionary release];
    
    if ( self )
    {
        // nothing else to do
    }
    
    return self;
    
}

- (id)initWithXmlData:(NSData*)xmlData
{
    
    if ( xmlData == nil )
    {
        [self release];
        return nil;
    }

    NSDictionary * xmlDictionary = [[XmlDictionary dictionaryFromXmlBlobData:xmlData] retain];
    
    if ( xmlDictionary == nil )
    {
        [self release];
        return nil;
    }
    
    self = [self initWithXmlDictionary:xmlDictionary];
    
    [xmlDictionary release];
    
    if ( self )
    {
        // nothing else to do
    }
    
    return self;

}
 
- (id)initWithXmlDictionary:(NSDictionary*)xmlDictionary
{
    
    if ( xmlDictionary == nil )
    {
        [self release];
        return nil;
    }
    
    if ( [xmlDictionary isKindOfClass:[NSDictionary class]] == NO )
    {
        [self release];
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        // save the dictionary
        [m_backingDictionary release];
        m_backingDictionary = [xmlDictionary retain];

    }
    
    return self;
    
}

- (void)dealloc
{

    [m_backingDictionary release];
    
    [super dealloc];
    
}

#pragma mark - Navigation

- (XmlDom*)getChildWithName:(NSString*)childName
{
    
    if ( childName == nil )
    {
        return nil;
    }
    
    NSDictionary * child = [m_backingDictionary objectForKey:childName];
    
    if ( child == nil )
    {
        return nil;
    }
    
    if ( [child isKindOfClass:[NSString class]] )
    {
        
//        NSLog(@"Child is an attribute string, creating dummy text node");
        
        NSMutableDictionary * tempChild = [[[NSMutableDictionary alloc] init] autorelease];
        
        [tempChild setObject:child forKey:XML_DICTIONARY_TEXT_NODE];
        
        child = tempChild;
        
    }
    else if ( ![child isKindOfClass:[NSDictionary class]] )
    {
        
//        NSLog(@"Child is not a dictionary");
        
        return nil;
        
    }
    
    XmlDom * returnDom = [[[XmlDom alloc] initWithXmlDictionary:child] autorelease];
    
    return returnDom;
    
}

- (NSArray*)getChildArrayWithName:(NSString*)childName
{
    
    if ( childName == nil )
    {
        return nil;
    }
    
    NSArray * child = [m_backingDictionary objectForKey:childName];
    
    if ( child == nil )
    {
        return nil;
    }
    
    if ( [child isKindOfClass:[NSDictionary class]] )
    {
        
//        NSLog(@"Child is a dictionary, creating dummy array");
        
        XmlDom * tempDom = [[[XmlDom alloc] initWithXmlDictionary:(NSDictionary*)child] autorelease];
        
        return [NSArray arrayWithObject:tempDom];
        
    }
    else if ( ![child isKindOfClass:[NSArray class]] )
    {
        
//        NSLog(@"Child is not an array");
        
        return nil;
        
    }
    
    NSMutableArray * domArray = [[NSMutableArray alloc] init];
    
    for ( NSDictionary * dict in child )
    {
        
        XmlDom * dom = [[XmlDom alloc] initWithXmlDictionary:dict];
        
        [domArray addObject:dom];
        
        [dom release];
        
    }

    return [domArray autorelease];

}

#pragma mark - Accessors

- (NSString*)getTextFromChildWithName:(NSString*)childName
{
    
    if ( childName == nil )
    {
        return nil;
    }
    
    XmlDom * childDom = [self getChildWithName:childName];

    NSString * text = [childDom getText];
    
    return text;
    
}

- (NSInteger)getIntegerFromChildWithName:(NSString*)childName
{
    
    if ( childName == nil )
    {
        return nil;
    }
    
    XmlDom * childDom = [self getChildWithName:childName];
    
    NSInteger integer = [childDom getInteger];
    
    return integer;

}

- (NSNumber*)getNumberFromChildWithName:(NSString*)childName
{
    
    if ( childName == nil )
    {
        return nil;
    }
    
    XmlDom * childDom = [self getChildWithName:childName];
    
    NSNumber * number = [childDom getNumber];
    
    return number;

}

- (NSInteger)getDateFromChildWithName:(id)childName
{
    
    if ( childName == nil )
    {
        return nil;
    }
    
    XmlDom * childDom = [self getChildWithName:childName];
    
    NSInteger date = [childDom getDate];
    
    return date;

}

- (NSArray*)getChildrenFromChildWithName:(NSString*)childName
{
    
    if ( childName == nil )
    {
        return nil;
    }
    
    XmlDom * childDom = [self getChildWithName:childName];

    return [childDom getChildren];
    
}

#pragma mark - Helpers
- (NSString*)getText
{
    return [m_backingDictionary objectForKey:XML_DICTIONARY_TEXT_NODE];
}

- (NSInteger)getInteger
{
    NSString * intString = [self getText];
    return [intString integerValue];
}

- (NSNumber*)getNumber
{
    NSString * numString = [self getText];
    return [NSNumber numberWithFloat:[numString floatValue]];
}

- (NSInteger)getDate
{

    NSString * dateString = [self getText];

    NSDateFormatter * dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    return [[dateFormat dateFromString:dateString] timeIntervalSince1970];

}

- (NSArray*)getChildren
{
    
    NSArray * dictArray = [m_backingDictionary allValues];
//    NSArray * keyArray = [m_backingDictionary allKeys];
    
    NSMutableArray * domArray = [[NSMutableArray alloc] init];
    
    // we want to convert all the dictionaries to XmlDoms
    for ( NSDictionary * dict in dictArray )
    {
        
        XmlDom * dom = [[XmlDom alloc] initWithXmlDictionary:dict];
        
        [domArray addObject:dom];
        
        [dom release];
        
    }
    
    return [domArray autorelease];

}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder
{
    
	[coder encodeObject:m_backingDictionary forKey:@"BackingDictionary"];
    
}

// Decode an object from an archive
- (id)initWithCoder:(NSCoder *)coder
{
    //self = [super initWithCoder:coder];
    NSDictionary * backingDictionary = [coder decodeObjectForKey:@"BackingDictionary"];

    self = [self initWithXmlDictionary:backingDictionary];

	return self;
    
}


@end
