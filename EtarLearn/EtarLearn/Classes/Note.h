//
//  Note.h
//  EtarLearn
//
//  Created by Marty Greenia on 10/4/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Note : NSObject <NSCopying> {
	
	CGFloat m_duration;
	NSString *m_value;

	// The beat within the measure where this note starts.
	// Although relative to the start of the measure,
	// it is actually one-indexed.
	CGFloat m_measureStart;

	// Absolute beat start (relative to the begining of the song, beat 0)
	CGFloat m_absoluteBeatStart;
	
	// Attributes of the 'guitarposition' element, stored in this note for simplicity
	NSInteger m_string; // 1-6
	NSInteger m_fret;

}

@property (nonatomic) CGFloat m_duration;
@property (nonatomic, retain) NSString *m_value;
@property (nonatomic) CGFloat m_measureStart;
@property (nonatomic) CGFloat m_absoluteBeatStart;
@property (nonatomic) NSInteger m_string;
@property (nonatomic) NSInteger m_fret;

- (id)init;
- (void)dealloc;
- (NSComparisonResult)compare:(Note*)note;
- (id)copyWithZone:(NSZone *)zone;
- (id)mutableCopy;

@end
