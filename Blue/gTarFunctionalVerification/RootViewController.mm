//
//  MasterViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

//#import <GtarController/GtarController.h>

//#import <objc/runtime.h>

#import "GuitarController.h"

#import "Checklist.h"

//GtarController * g_gtarController;
GuitarController * g_guitarController;

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
    
    if ( g_guitarController == nil )
    {
        
//        g_gtarController = [[GtarController alloc] init];
//        
//        [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, 0) withColor:GtarLedColorMake(3, 3, 3)];
//        
//        [g_gtarController addObserver:self];
//        
//        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(debugGo) userInfo:nil repeats:NO];
        
        g_guitarController = [[GuitarController alloc] init];
        
//        [g_guitarController addObserver:self];
        
//        [g_guitarController turnOnLedAtString:0 andFret:0 withRed:0 andGreen:0 andBlue:3];
        
//        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(debugGo) userInfo:nil repeats:NO];

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
    
    [g_guitarController debugSpoofConnected];

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

- (void)guitarFretDown:(GuitarFret)fret andString:(GuitarString)str
{
}
- (void)guitarFretUp:(GuitarFret)fret andString:(GuitarString)str
{
}
- (void)guitarNotesOnFret:(GuitarFret)fret andString:(GuitarString)str
{
}
- (void)guitarNotesOffFret:(GuitarFret)fret andString:(GuitarString)str
{
}
- (void)guitarConnected
{
//    [g_guitarController turnOnLedAtString:0 andFret:0 withRed:3 andGreen:0 andBlue:0];
}
- (void)guitarDisconnected
{
}


@end
