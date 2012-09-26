//
//  NoteViewController.h
//  AirgTar
//
//  Created by idanbeck on 11/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "gTarState.h"

@interface NoteViewController : UIViewController
{
	int m_ViewHeight;
	gTarState *m_pgTarState;
}

@property (readwrite, assign) int m_ViewHeight;
@property (nonatomic, retain) gTarState *m_pgTarState;


@end
