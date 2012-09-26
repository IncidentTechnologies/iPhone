//
//  FretButton.h
//  AudioJunk1
//
//  Created by Idan Beck on 10/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface FretButton : UIButton
{
	int m_string;
	int m_fret;
}

@property (assign) int m_string;
@property (assign) int m_fret;

@end
