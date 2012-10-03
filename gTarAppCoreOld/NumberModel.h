//
//  NumberModel.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/10/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "Model.h"

#define NUMBER_MODEL_MAX_NUMBER 19

@interface NumberModel : Model
{
	NSInteger m_value;
}

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andValue:(NSInteger)value;

@end
