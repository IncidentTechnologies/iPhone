//
//  ViewController.m
//  gtarLearn
//
//  Created by Idan Beck on 11/10/13.
//  Copyright (c) 2013 Incident Technologies, Inc. All rights reserved.
//

#import "LearnTitleViewController.h"
#import "XMPLesson.h"

@interface LearnTitleViewController () {

}
@end

@implementation LearnTitleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onTestXmpClicked:(id)sender {
    // Button clicked
    
    XMPLesson *tempLesson = [[XMPLesson alloc] initWithLessonName:@"test_lesson"];
    
}

@end
