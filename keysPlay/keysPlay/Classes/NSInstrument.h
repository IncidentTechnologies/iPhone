//
//  NSInstrument.h
//  keysPlay
//
//  Created by Kate Schnippering on 1/6/15.
//
//

#import "AppCore.h"

@class XmlDom;
@class NSSampler;

@interface NSInstrument : NSObject
{
    long m_id;
    long m_xmpid;
    NSString * m_name;
    // NSString * m_iconName;
    bool m_custom;
    
    NSSampler * m_sampler;
}

@property (nonatomic) long m_id;
@property (nonatomic) long m_xmpid;
@property (retain, nonatomic) NSString * m_name;
//@property (retain, nonatomic) NSString * m_iconName;
@property (nonatomic) bool m_custom;

@property (retain, nonatomic) NSSampler * m_sampler;

- (id)initWithXmlDom:(XmlDom *)dom;

-(id)initWithName:(NSString *)name id:(long)index iconName:(NSString *)iconName isCustom:(BOOL)isCustom;

-(id)init;

- (NSString *)getIconName;

-(NSString *)saveToFile:(NSString *)filename saveWithSamples:(BOOL)saveWithSamples;
- (void)deleteFile;

- (void)releaseSounds;


@end
