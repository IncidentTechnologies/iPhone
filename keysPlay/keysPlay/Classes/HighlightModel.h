//
//  HighlightModel.h
//  keysPlay
//
//  Created by Kate Schnippering on 4/24/14.
//
//

#import <gTarAppCore/Model.h>

@interface HighlightModel : Model
{
	
}

// also add shape
- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andShape:(NSString *)shape;

@property (nonatomic, retain) UIImage * highlightImage;

@end