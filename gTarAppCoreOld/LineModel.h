//
//  LineModel.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/10/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "Model.h"

@interface LineModel : Model
{

}

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color;
- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andImage:(UIImage*)image;
//- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andNil:(UIImage*)image;

@end
