//
//  ChordViewController.h
//  AirgTar
//
//  Created by idanbeck on 11/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "gTarState.h"


@interface ChordViewController : UIViewController 
{
	UIButton **m_ppbuttonKeys;

	IBOutlet UIButton *m_pbuttonC;
	IBOutlet UIButton *m_pbuttonD;
	IBOutlet UIButton *m_pbuttonE;
	IBOutlet UIButton *m_pbuttonF;
	IBOutlet UIButton *m_pbuttonG;	
	IBOutlet UIButton *m_pbuttonA;
	IBOutlet UIButton *m_pbuttonB;
	
	IBOutlet UIButton *m_pbuttonFlat;
	IBOutlet UIButton *m_pbuttonSharp;
	IBOutlet UIButton *m_pbuttonMinor;
	IBOutlet UIButton *m_pbuttonMajor;
	
	IBOutlet UIButton *m_pbutton6;
	IBOutlet UIButton *m_pbutton7;
	IBOutlet UIButton *m_pbutton9;
	
	UIButton **m_ppbuttonModifiers;
	
	int m_ViewHeight;
	gTarState *m_pgTarState;
}

@property (readwrite, assign) int m_ViewHeight;

@property (nonatomic, retain) gTarState *m_pgTarState;

-(IBAction)KeyButtonDown:(id)sender;

-(IBAction)FlatButtonDown:(id)sender;

-(IBAction)SharpButtonDown:(id)sender;

-(IBAction)MinorButtonDown:(id)sender;

-(IBAction)MajorButtonDown:(id)sender;

-(IBAction)ModifierButtonDown:(id)sender;

@end
