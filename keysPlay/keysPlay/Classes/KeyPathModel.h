//
//  KeyPathModel.h
//  gTarAppCore
//
//  Created by Kate Schnippering on 10/27/14.
//  Copyright 2014 Msft. All rights reserved.
//

#import <gTarAppCore/Model.h>

@interface KeyPathModel : Model
{

}

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color;
- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andImage:(UIImage*)image;

@end
