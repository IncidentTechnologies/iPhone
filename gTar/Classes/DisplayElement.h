//
//  DisplayElement.h
//  EtarLearn
//
//  Created by Marty Greenia on 10/4/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

enum DisplayElementType {
	TypeInvalid = 0,
	TypeHorizontalLine,
	TypeVerticalLine,
	TypeNote
};

@interface DisplayElement : NSObject {

	DisplayElementType m_type;
	CGFloat m_color[4];
	CGFloat m_textColor[4];
	CGPoint m_start;
	CGFloat m_length;
	NSString * m_text;
	
	
}

@property (nonatomic) DisplayElementType m_type;
//@property (nonatomic) CGFloat color[4];
@property (nonatomic) CGPoint m_start;
@property (nonatomic) CGFloat m_length;
@property (nonatomic, retain) NSString * m_text;

- (void)setColor:(CGFloat*)color;
- (CGFloat*)getColor;

- (void)setTextColor:(CGFloat*)color;
- (CGFloat*)getTextColor;

@end
