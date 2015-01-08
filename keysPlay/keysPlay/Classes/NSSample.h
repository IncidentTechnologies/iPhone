//
//  NSSample.h
//  keysPlay
//
//  Created by Kate Schnippering on 1/6/15.
//
//

#import "AppCore.h"

@class XmlDom;

@interface NSSample : NSObject
{
    NSString * m_name;
    NSString * m_value;
    bool m_custom;
    
    NSString * m_externalId;
    long m_xmpFileId;
    
    NSString * m_sampleData;
}

@property (retain, nonatomic) NSString * m_name;
@property (retain, nonatomic) NSString * m_value;
@property (nonatomic) bool m_custom;
@property (nonatomic, assign) long m_xmpFileId;
@property (nonatomic, retain) NSString * m_externalId;
@property (nonatomic, retain) NSString * m_sampleData;

- (id)initWithXmlDom:(XmlDom *)dom;

- (id)initWithName:(NSString *)name custom:(bool)custom value:(NSString *)value externalId:(NSString *)externalId xmpFileId:(long)xmpFileId;

//- (void)saveToFile;

@end
