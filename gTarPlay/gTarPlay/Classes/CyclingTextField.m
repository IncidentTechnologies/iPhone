//
//  CyclingTextField.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/14/13.
//
//

#import "CyclingTextField.h"

@implementation CyclingTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [_nextTextField release];
    [_submitButton release];
    
    [super dealloc];
}


@end
