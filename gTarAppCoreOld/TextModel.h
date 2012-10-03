//
//  TextModel.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/10/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "Model.h"

@interface TextModel : Model
{

}

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andText:(NSString*)text andHeight:(CGFloat)height;

@end
