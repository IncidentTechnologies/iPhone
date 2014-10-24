//
//  LineModel.h
//  keysPlay
//
//  Created by Marty Greenia on 3/10/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import <gTarAppCore/Model.h>

@interface LineModel : Model
{
    CGSize m_size;
}


- (CGPoint)getCenter;
- (CGSize)getSize;
- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color;
- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andImage:(UIImage*)image;

@end
