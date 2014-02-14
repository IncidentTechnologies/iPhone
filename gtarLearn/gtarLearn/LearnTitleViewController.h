//
//  ViewController.h
//  gtarLearn
//
//  Created by Idan Beck on 11/10/13.
//  Copyright (c) 2013 Incident Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OpenGLES2View.h"

@interface LearnTitleViewController : UIViewController{
    OpenGLES2View *_glview;
}

@property (nonatomic, retain) IBOutlet UIButton *m_buttonTestXMP;
@property (nonatomic, retain) IBOutlet OpenGLES2View *glview;

-(IBAction) onTestXmpClicked:(id)sender;

@end
