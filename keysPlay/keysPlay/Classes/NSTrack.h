//
//  NSTrack.h
//  keysPlay
//
//  Created by Kate Schnippering on 12/24/14.
//
//

#import "AppCore.h"
#import "NSClip.h"

@class XmlDom;

@interface NSTrack : NSObject
{
    NSString * m_name;
    double m_level;
    bool m_muted;
    
    //NSInstrument * m_instrument;
    NSMutableArray * m_clips;
}

@property (retain, nonatomic) NSString * m_name;
//@property (retain, nonatomic) NSInstrument * m_instrument;
@property (retain, nonatomic) NSMutableArray * m_clips;

- (id)initWithXmlDom:(XmlDom *)dom;

- (NSArray *)convertClipsToMeasures;

@end
