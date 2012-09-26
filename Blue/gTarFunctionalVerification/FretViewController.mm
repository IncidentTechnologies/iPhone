//
//  FretViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FretViewController.h"

//#import <GtarController/GtarController.h>

#import "Checklist.h"

//extern GtarController * g_gtarController;
extern GuitarController * g_guitarController;

extern Checklist g_checklist;

@interface FretViewController ()
{
    char _fretUp[16*6];
    char _fretDown[16*6];
    char _noteOn[16*6];
    
    UIImageView * _imgView[16*6];
    UIImage * _img;
    
    NSInteger _fretUpCount;
    NSInteger _fretDownCount;
    NSInteger _noteOnCount;
}

@property (strong, nonatomic) NSString * testType;

@end

@implementation FretViewController

@synthesize checkboxesView = _checkboxesView;
@synthesize testType = _testType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    [g_gtarController addObserver:self];
    [g_guitarController addObserver:self];
    
    CGFloat height = _checkboxesView.frame.size.height/6.0;
    CGFloat width = _checkboxesView.frame.size.width/16.0;
    
    UIImage * img = [UIImage imageNamed:@"checkbox_unchecked.png"];
    
    _img = [UIImage imageNamed:@"checkbox_checked.png"];
    
    for ( NSInteger str = 0; str < 6; str++ )
    {
        for ( NSInteger fret = 0; fret < 16; fret++ )
        {
            CGRect fr = CGRectMake(fret*width, (5-str)*height, width, height);
            
            UIImageView * imgView = [[UIImageView alloc] initWithFrame:fr];
            
            imgView.image = img;
            
            [_checkboxesView addSubview:imgView];
            
            _imgView[str*16 + fret] = imgView;
        }
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [g_guitarController removeObserver:self];
    
    [super viewWillDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - GtarController

//- (void)gtarFretDown:(GtarPosition)position
//{
//    
//    if ( _fretDown[position.string * 16 + position.fret] == 0 )
//    {
//        _fretDown[position.string * 16 + position.fret] = 1;
//        
//        _fretDownCount++;
//        
//        if ( _fretDownCount == (16*6) )
//        {
////            g_checklist.fretTest
//        }
//        
//    }
//        
//}
//
//- (void)gtarFretUp:(GtarPosition)position
//{
//    
//    if ( _fretUp[position.string * 16 + position.fret] == 0 )
//    {
//        _fretUp[position.string * 16 + position.fret] = 1;
//        
//        _fretUpCount++;
//        
//        if ( _fretUpCount == (16*6) )
//        {
////            g_checklist.fretTest
//        }
//        
//    }
//    
//}
//
//- (void)gtarNoteOn:(GtarPosition)position
//{
//    
//    if ( _noteOn[position.string * 16 + position.fret] == 0 )
//    {
//        _noteOn[position.string * 16 + position.fret] = 1;
//        
//        UIImageView * imgView = _imgView[position.string * 16 + position.fret];
//        
//        UIImage * img = [UIImage imageNamed:@"checkbox_checked.png"];
//
//        imgView.image = img;
//    
//        _noteOnCount++;
//        
//        if ( _noteOnCount == (16*6) )
//        {
//            g_checklist.fretTest = YES;
//        }
//    }
//}
//
//- (void)gtarNoteOff:(GtarPosition)position
//{
////    _fretDown[position.string * 16 + position.fret] = 1;
//}

- (void)testComplete
{
    [self performSegueWithIdentifier:@"passSegue" sender:nil];
}

#pragma mark -- GuitarController

- (void)guitarFretDown:(GuitarFret)fret andString:(GuitarString)str
{
    
    if ( [_testType isEqualToString:@"FretUpDown"] == NO )
    {
        return;
    }
    
    if ( fret == 0 )
    {
        return;
    }

    // 0-base
    str--;
    fret--;
    
    if ( _fretDown[str * 16 + fret] == 0 )
    {
        _fretDown[str * 16 + fret] = 1;
        
        if ( _fretUp[str * 16 + fret] == 1 )
        {
            UIImageView * imgView = _imgView[str * 16 + fret];
            
            [imgView performSelectorOnMainThread:@selector(setImage:) withObject:_img waitUntilDone:YES];
            
            [g_guitarController turnOnLedAtString:str+1 andFret:fret+1 withRed:0 andGreen:3 andBlue:0];
        }
        else
        {
            [g_guitarController turnOnLedAtString:str+1 andFret:fret+1 withRed:3 andGreen:0 andBlue:0];
        }
        
        _fretDownCount++;
        
        if ( _fretDownCount == (16*6) )
        {
            g_checklist.fretDownTest = YES;
            
            if ( g_checklist.fretUpTest == YES )
            {
                [g_guitarController turnOffAllLeds];
                
                [self performSelectorOnMainThread:@selector(testComplete) withObject:nil waitUntilDone:NO];
            }

        }
        
    }

}

- (void)guitarFretUp:(GuitarFret)fret andString:(GuitarString)str
{
    
    if ( [_testType isEqualToString:@"FretUpDown"] == NO )
    {
        return;
    }
    
    if ( fret == 0 )
    {
        return;
    }

    // 0-base
    str--;
    fret--;
    
    if ( _fretUp[str * 16 + fret] == 0 )
    {
        _fretUp[str * 16 + fret] = 1;
        
        if ( _fretDown[str * 16 + fret] == 1 )
        {
            
            UIImageView * imgView = _imgView[str * 16 + fret];
            
            [imgView performSelectorOnMainThread:@selector(setImage:) withObject:_img waitUntilDone:YES];

            [g_guitarController turnOnLedAtString:str+1 andFret:fret+1 withRed:0 andGreen:3 andBlue:0];
        }
        else
        {
            [g_guitarController turnOnLedAtString:str+1 andFret:fret+1 withRed:3 andGreen:0 andBlue:0];
        }
        
        _fretUpCount++;
        
        if ( _fretUpCount == (16*6) )
        {
            g_checklist.fretUpTest = YES;
            
            if ( g_checklist.fretDownTest == YES )
            {
                [g_guitarController turnOffAllLeds];
                
                [self performSelectorOnMainThread:@selector(testComplete) withObject:nil waitUntilDone:NO];
            }
        }
        
    }

}

- (void)guitarNotesOnFret:(GuitarFret)fret andString:(GuitarString)str
{
    
    if ( [_testType isEqualToString:@"NoteOn"] == NO )
    {
        return;
    }
    
    if ( fret == 0 )
    {
        return;
    }
    
    // 0-base
    str--;
    fret--;
    
    if ( _noteOn[str * 16 + fret] == 0 )
    {
        
        [g_guitarController turnOnLedAtString:str+1 andFret:fret+1 withRed:0 andGreen:3 andBlue:0];
        
        _noteOn[str * 16 + fret] = 1;
        
        UIImageView * imgView = _imgView[str * 16 + fret];
        
        [imgView performSelectorOnMainThread:@selector(setImage:) withObject:_img waitUntilDone:YES];
        
        _noteOnCount++;
        
        if ( _noteOnCount == (16*6) )
        {
            g_checklist.noteOnTest = YES;
            
            [g_guitarController turnOffAllLeds];
            
            [self performSelectorOnMainThread:@selector(testComplete) withObject:nil waitUntilDone:NO];
            
        }
    }

}

- (void)guitarNotesOffFret:(GuitarFret)fret andString:(GuitarString)str
{
}
- (void)guitarConnected
{
}
- (void)guitarDisconnected
{
}

@end
