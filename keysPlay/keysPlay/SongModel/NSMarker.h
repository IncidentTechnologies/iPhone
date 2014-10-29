//
//  NSMarker.h
//  gTarAppCore
//
//  Created by Kate Schnippering on 5/12/14.
//
//

#import "AppCore.h"

@class XmlDom;

@interface NSMarker : NSObject
{
	double m_startBeat;
}

@property (nonatomic, assign) double m_startBeat;
@property (nonatomic, assign) NSString * m_name;

- (id)initWithXmlDom:(XmlDom*)xmlDom;

- (id)initWithStartBeat:(double)startBeat
		   andName:(NSString *)name;

@end
