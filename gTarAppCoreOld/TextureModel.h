//
//  TextureModel.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/23/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TextureModel : Model
{

}

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andImageName:(NSString*)image;

@end
