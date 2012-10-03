//
//  NoteAnimation.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/23/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "Animation.h"


@interface NoteAnimation : Animation
{
	Model * m_overlay;
	CGPoint m_center;
}

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andOverlay:(Model*)overlay;

@end
