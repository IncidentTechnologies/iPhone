//
//  ViewController.m
//  gtarLearn
//
//  Created by Idan Beck on 11/10/13.
//  Copyright (c) 2013 Incident Technologies, Inc. All rights reserved.
//

#import "LearnTitleViewController.h"
#import "XMPTree.h"

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
    NSError *pError = NULL;
    NSString *pTempFilePath = [[NSBundle mainBundle] pathForResource:@"test_lesson" ofType:@"xmp"];
    //NSString *pTempFileContent = [NSString stringWithContentsOfFile:pTempFileContent encoding:NSUTF8StringEncoding error:&pError];
    XMPTree *pTempTree = new XMPTree((char *)[pTempFilePath UTF8String]);
    pTempTree->PrintXMPTree();
    
    
}

@end
