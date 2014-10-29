//
//  ESRenderer.m
//  gTar
//
//  Created by Marty Greenia on 10/18/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "ViewRenderer.h"

@implementation ViewRenderer

- (void)render
{
	// virtual
}

- (void)renderWithHighlights:(BOOL)highlight
{
    // virtual
}

- (void)renderWithHighlights:(BOOL)highlight fretOne:(BOOL)fretOne fretTwo:(BOOL)fretTwo fretThree:(BOOL)fretThree
{
    [self renderWithHighlights:highlight];
}

- (BOOL)resizeFromLayer:(CALayer *)layer
{
	// virtual
	return false;
}
@end
