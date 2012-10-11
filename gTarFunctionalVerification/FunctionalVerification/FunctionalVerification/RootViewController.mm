//
//  MasterViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/8/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "RootViewController.h"

#import <GtarController/GtarControllerInternal.h>

#import "Checklist.h"

GtarController * g_gtarController;

Checklist g_checklist;

@interface RootViewController ()
{
    NSMutableArray *_objects;
}

@end

@implementation RootViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if ( g_gtarController == nil )
    {
        
        g_gtarController = [[GtarController alloc] init];
        
        [g_gtarController sendRequestCertDownload];
        
        [g_gtarController addObserver:self];
        
    }

}
- (void)debugGo
{
    
//    int i=0;
//    unsigned int mc = 0;
//    Method * mlist = class_copyMethodList(object_getClass(g_guitarController), &mc);
//    NSLog(@"%d methods", mc);
//    for(i=0;i<mc;i++)
//    {
//        NSLog(@"Method no #%d: %s", i, sel_getName(method_getName(mlist[i])));
//    }
    
//    [g_gtarController notifyObserversGtarConnectedM:nil];
//    
//    [g_gtarController debugSpoofConnected];
    
    [g_gtarController debugSpoofConnected];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
//    if ([[segue identifier] isEqualToString:@"startSegue"])
    {
        
        // zero out our checklist structure to init it
        memset(&g_checklist, 0, sizeof(g_checklist));
        
    }
    
}

#pragma mark -- GuitarController

@end
