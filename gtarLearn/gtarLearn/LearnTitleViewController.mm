//
//  ViewController.m
//  gtarLearn
//
//  Created by Idan Beck on 11/10/13.
//  Copyright (c) 2013 Incident Technologies, Inc. All rights reserved.
//

#import "LearnTitleViewController.h"
#import "XMPObjectFactory.h"

@interface LearnTitleViewController () {

}
@end

@implementation LearnTitleViewController


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization on passed parameter observation object
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[OpenGLES2View class];
    
    // Initialize the glView
    _glview = [_glview initWithFrame:_glview.frame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onTestXmpClicked:(id)sender {
    // Button clicked
    
    NSDate *start = [NSDate date];
    XMPObject *tempObj = [XMPObjectFactory MakeXMPObjectFromFilename:@"spaceoddity"];
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    NSLog(@"Execution Time: %f", executionTime);

}

@end
