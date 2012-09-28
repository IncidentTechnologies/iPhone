//
//  FretboardElectricalViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FretboardElectricalViewController.h"

#import "Checklist.h"

extern GuitarController * g_guitarController;

extern Checklist g_checklist;

@interface FretboardElectricalViewController ()
{
    
    char _fretDown[16];
    char _stringDown[6];
    char _noteOn[6];
    
    UIImageView * _imgView[16+6];
    UIImage * _img;
    
    NSInteger _fretDownCount;
    NSInteger _stringDownCount;
    NSInteger _noteOnCount;
    
}

@property (strong, nonatomic) NSString * testType;

@end

@implementation FretboardElectricalViewController

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
    
    [g_guitarController addObserver:self];
    
    UIImage * img = [UIImage imageNamed:@"checkbox_unchecked.png"];
    
    _img = [UIImage imageNamed:@"checkbox_checked.png"];
    
    if ( [_testType isEqualToString:@"PiezoElectrical"] == YES )
    {
        CGFloat height = _checkboxesView.frame.size.height;
        CGFloat width = _checkboxesView.frame.size.width/6.0;
        
        for ( NSInteger str = 0; str < 6; str++ )
        {
            CGRect fr = CGRectMake((5-str)*width, 0, width, height);
            
            UIImageView * imgView = [[UIImageView alloc] initWithFrame:fr];
            
            imgView.image = img;
            
            [_checkboxesView addSubview:imgView];
            
            _imgView[str] = imgView;
        }
    }
    
    if ( [_testType isEqualToString:@"FretElectrical"] == YES )
    {
        CGFloat height = _checkboxesView.frame.size.height/8.0;
        CGFloat width = _checkboxesView.frame.size.width/16.0;
        
        for ( NSInteger str = 0; str < 6; str++ )
        {
            CGRect fr = CGRectMake(0, (5-str)*height, width, height);
            
            UIImageView * imgView = [[UIImageView alloc] initWithFrame:fr];
            
            imgView.image = img;
            
            [_checkboxesView addSubview:imgView];
            
            _imgView[str] = imgView;
        }
        
        for ( NSInteger fret = 0; fret < 16; fret++ )
        {
            CGRect fr = CGRectMake((fret)*width, (7)*height, width, height);
            
            UIImageView * imgView = [[UIImageView alloc] initWithFrame:fr];
            
            imgView.image = img;
            
            [_checkboxesView addSubview:imgView];
            
            _imgView[6 + fret] = imgView;
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

- (void)testComplete
{
    [self performSegueWithIdentifier:@"passSegue" sender:nil];
}

#pragma mark -- GuitarController

- (void)guitarFretDown:(GuitarFret)fret andString:(GuitarString)str
{
    
    if ( [_testType isEqualToString:@"FretElectrical"] == NO )
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
    
    if ( _fretDown[fret] == 0 )
    {
        _fretDown[fret] = 1;

        UIImageView * imgView = _imgView[6 + fret];
        
        [imgView performSelectorOnMainThread:@selector(setImage:) withObject:_img waitUntilDone:YES];
        
        _fretDownCount++;
        
        if ( _fretDownCount == 16 && _stringDownCount == 6 )
        {
            g_checklist.fretElectricalTest = YES;
            
            [self performSelectorOnMainThread:@selector(testComplete) withObject:nil waitUntilDone:NO];
        }
        
    }
    
    if ( _stringDown[str] == 0 )
    {
        _stringDown[str] = 1;

        UIImageView * imgView = _imgView[str];
        
        [imgView performSelectorOnMainThread:@selector(setImage:) withObject:_img waitUntilDone:YES];
        
        _stringDownCount++;
        
        if ( _fretDownCount == 16 && _stringDownCount == 6 )
        {
            g_checklist.fretElectricalTest = YES;
            
            [self performSelectorOnMainThread:@selector(testComplete) withObject:nil waitUntilDone:NO];
        }
        
    }

}

- (void)guitarFretUp:(GuitarFret)fret andString:(GuitarString)str
{
    
    
}

- (void)guitarNotesOnFret:(GuitarFret)fret andString:(GuitarString)str
{
    
    if ( [_testType isEqualToString:@"PiezoElectrical"] == NO )
    {
        return;
    }
    
    // 0-base
    str--;
    
    if ( _noteOn[str] == 0 )
    {
        
        _noteOn[str] = 1;
        
        UIImageView * imgView = _imgView[str];
        
        [imgView performSelectorOnMainThread:@selector(setImage:) withObject:_img waitUntilDone:YES];
        
        _noteOnCount++;
        
        if ( _noteOnCount == 6 )
        {
            g_checklist.piezoElectricalTest = YES;
            
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
