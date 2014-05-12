//
//  NSSong.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/16/11.
//  Copyright 2011 Msft. All rights reserved.
//

@class NSMeasure;
@class XmlDom;

@interface NSSong : NSObject
{
	
	NSMutableArray * m_measures;
	
	NSString * m_author;
	NSString * m_title;
	NSString * m_description;
    NSString * m_instrument;
	NSUInteger m_id;
	double m_tempo;
	
}

@property (nonatomic, readonly) NSMutableArray * m_measures;
@property (nonatomic, readonly) NSMutableArray * m_markers;

@property (nonatomic, strong) NSString * m_author;
@property (nonatomic, strong) NSString * m_title;
@property (nonatomic, strong) NSString * m_description;
@property (nonatomic, strong) NSString * m_instrument;
@property (nonatomic, assign) NSUInteger m_id;
@property (nonatomic, assign) double m_tempo;

- (id)initWithXmlDom:(XmlDom*)xmlDom;

- (id)initWithAuthor:(NSString*)author
			andTitle:(NSString*)title
			 andDesc:(NSString*)desc
			   andId:(NSUInteger)idNum
			andTempo:(double)tempo;

- (void)addMeasure:(NSMeasure*)measure;
- (NSArray*)getSortedNotes;

@end
