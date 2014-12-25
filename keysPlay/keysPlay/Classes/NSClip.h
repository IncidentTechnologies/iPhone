//
//  NSClip.h
//  keysPlay
//
//  Created by Kate Schnippering on 12/24/14.
//
//

#import "AppCore.h"
#import "NSNote.h"

@class XmlDom;

@interface NSClip : NSObject
{
    NSString * m_name;
    
    double m_startbeat;
    double m_endbeat;
    double m_cliplength;
    double m_clipstart;
    bool m_looping;
    double m_loopstart;
    double m_looplength;
    bool m_muted;
    
    NSString * m_color;
    
    NSMutableArray * m_notes;
}

@property (nonatomic, readonly) NSString * m_name;
@property (nonatomic, readonly) NSString * m_color;
@property (nonatomic, readonly) NSMutableArray * m_notes;

@property (nonatomic, assign) double m_startbeat;
@property (nonatomic, assign) double m_endbeat;
@property (nonatomic, assign) double m_cliplength;
@property (nonatomic, assign) double m_clipstart;
@property (nonatomic, assign) bool m_looping;
@property (nonatomic, assign) double m_loopstart;
@property (nonatomic, assign) double m_looplength;
@property (nonatomic, assign) bool m_muted;

- (id)initWithXmlDom:(XmlDom *)dom;

@end
