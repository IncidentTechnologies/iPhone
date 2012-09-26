//
//  gTarLearnViewController.h
//  gTar
//
//  Created by wuda on 10/24/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "gTarDebug.h"
#import "Lesson.h"

@interface gTarLearnViewController : UIViewController <gTarDebugServer, UITableViewDelegate, UITableViewDataSource>
{
	// Table 
	IBOutlet UITableView * m_lessonTableView;
	IBOutlet UITableView * m_chapterTableView;
	
	
	NSMutableArray * m_lessons;
	Lesson * m_selectedLesson;
	
	// Debug related
	IBOutlet UIButton * m_debugStatus;
	BOOL m_debug;
	gTarDebug * m_debugger;
}

// Table 
@property (nonatomic, retain) IBOutlet UITableView * m_lessonTableView;
@property (nonatomic, retain) IBOutlet UITableView * m_chapterTableView;

@property (nonatomic, retain) IBOutlet UIButton * m_debugStatus;

-(IBAction)stopButtonClicked:(id)sender;
-(IBAction)lessonButtonClicked:(id)sender;
-(IBAction)debugButtonClicked:(id)sender;

@end
