//
//  Model.h
//  gTar
//
//  Created by wuda on 12/21/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "Texture2D.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface Model : NSObject
{
	
	Texture2D * m_texture;
	
	CGPoint m_center;
	
	GLubyte m_color[16]; // 4 colors x 4 corners
    
}

- (id)initWithCenter:(CGPoint)center andColor:(GLubyte*)color andTexture:(Texture2D*)texture;
- (void)draw;
- (void)drawAt:(CGPoint)point;
- (void)drawWithOffset:(CGPoint)offset;
- (void)changeColor:(GLubyte*)color;
- (void)changeOpacity:(GLubyte)opacity;
- (void)changeCenter:(CGPoint)center;

@property (nonatomic, assign) CGPoint m_center;

@end
