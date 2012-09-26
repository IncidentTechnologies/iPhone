//
//  Song.h
//  EtarLearn
//
//  Created by Marty Greenia on 10/4/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Measure.h"

@interface Song : NSObject {

	NSMutableArray * m_measures;
	NSString * m_artist;
	NSString * m_name;
	NSString * m_description;
	NSInteger m_id;
	CGFloat m_tempo;
	
}

@property (nonatomic, retain) NSMutableArray * m_measures;
@property (nonatomic, retain) NSString * m_artist;
@property (nonatomic, retain) NSString * m_name;
@property (nonatomic, retain) NSString * m_description;
@property (nonatomic) NSInteger m_id;
@property (nonatomic) CGFloat m_tempo;

-(id)init;
-(void)dealloc;
-(void)addMeasure:(Measure*)measure;
-(void)sortMeasures;

@end
