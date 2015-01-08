//
//  NSSong.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/16/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "AppCore.h"

@class NSMeasure;
@class XmlDom;

@interface NSSong : NSObject
{
	
    NSMutableArray * m_measures;
    NSMutableArray * m_tracks;
	
	NSString * m_author;
	NSString * m_title;
	NSString * m_description;
    NSString * m_instrument;
    NSInteger m_instrumentXmpId;
	NSUInteger m_id;
	double m_tempo;
	
}

@property (nonatomic, readonly) NSMutableArray * m_measures;
@property (nonatomic, readonly) NSMutableArray * m_markers;
@property (nonatomic, readonly) NSMutableArray * m_tracks;

@property (nonatomic, strong) XmlDom * m_xmlDom;
@property (nonatomic, strong) XmlDom * m_ophoXmlDom;

@property (nonatomic, strong) NSString * m_author;
@property (nonatomic, strong) NSString * m_title;
@property (nonatomic, strong) NSString * m_description;
@property (nonatomic, strong) NSString * m_instrument;
@property (nonatomic, assign) NSInteger m_instrumentXmpId;
@property (nonatomic, assign) NSUInteger m_id;
@property (nonatomic, assign) double m_tempo;

- (id)initWithXmlDom:(XmlDom*)xmlDom ophoXmlDom:(XmlDom*)ophoXmlDom andTrackIndex:(int)trackIndex;

- (id)initWithAuthor:(NSString*)author
			andTitle:(NSString*)title
			 andDesc:(NSString*)desc
			   andId:(NSUInteger)idNum
			andTempo:(double)tempo;

- (void)addMeasure:(NSMeasure*)measure;
- (NSArray*)getSortedNotes;

@end
