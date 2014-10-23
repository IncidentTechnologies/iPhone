//
//  FretViewController.m
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/8/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "FretViewController.h"

#import "Checklist.h"

extern GtarController * g_gtarController;

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
    
    CGFloat height = _checkboxesView.frame.size.height/6.0;
    CGFloat width = _checkboxesView.frame.size.width/16.0;
    
    _img = [UIImage imageNamed:@"checkbox_checked.png"];
    
    for ( NSInteger str = 0; str < 6; str++ )
    {
        for ( NSInteger fret = 0; fret < 16; fret++ )
        {
            CGRect fr = CGRectMake(fret*width, (5-str)*height, width, height);
            
            UIImageView * imgView = [[UIImageView alloc] initWithFrame:fr];
            
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

- (void)viewDidAppear:(BOOL)animated
{
    
    [g_gtarController addObserver:self];
    
    UIImage * img = [UIImage imageNamed:@"checkbox_unchecked.png"];
        
    for ( NSInteger str = 0; str < 6; str++ )
    {
        for ( NSInteger fret = 0; fret < 16; fret++ )
        {
            
            UIImageView * imgView = _imgView[str*16 + fret];
            
            imgView.image = img;
            
            _fretUp[str*16 + fret] = 0;
            _fretDown[str*16 + fret] = 0;
            _noteOn[str*16 + fret] = 0;
        }
    }
    
    // init tests
    if ( [_testType isEqualToString:@"FretUpDown"] == YES )
    {
        g_checklist.fretUpTest = NO;
        g_checklist.fretDownTest = NO;
    }
    if ( [_testType isEqualToString:@"NoteOn"] == YES )
    {
        g_checklist.noteOnTest = NO;
    }
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [g_gtarController removeObserver:self];
    
    [super viewWillDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    [g_gtarController turnOffAllLeds];
    
}

#pragma mark - GtarController

- (void)testComplete
{
    [self performSegueWithIdentifier:@"passSegue" sender:nil];
}

#pragma mark -- GtarController

- (void)gtarFretDown:(GtarPosition)position
{
    
    GtarFret fret = position.fret;
    GtarString str = position.string;
    
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
            
            [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret+1, str+1)
                                        withColor:GtarLedColorMake(0, 3, 0)];
        }
        else
        {
            [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret+1, str+1)
                                        withColor:GtarLedColorMake(3, 0, 0)];
        }
        
        _fretDownCount++;
        
        if ( _fretDownCount == (16*6) )
        {
            g_checklist.fretDownTest = YES;
            
            if ( g_checklist.fretUpTest == YES )
            {
                [g_gtarController turnOffAllLeds];
                
                [self performSelectorOnMainThread:@selector(testComplete) withObject:nil waitUntilDone:NO];
            }

        }
        
    }

}

- (void)gtarFretUp:(GtarPosition)position
{
    
    GtarFret fret = position.fret;
    GtarString str = position.string;
    
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

            [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret+1, str+1)
                                        withColor:GtarLedColorMake(0, 3, 0)];
        }
        else
        {
            [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret+1, str+1)
                                        withColor:GtarLedColorMake(3, 0, 0)];
        }
        
        _fretUpCount++;
        
        if ( _fretUpCount == (16*6) )
        {
            g_checklist.fretUpTest = YES;
            
            if ( g_checklist.fretDownTest == YES )
            {
                [g_gtarController turnOffAllLeds];
                
                [self performSelectorOnMainThread:@selector(testComplete) withObject:nil waitUntilDone:NO];
            }
        }
        
    }

}

- (void)gtarNoteOn:(GtarPluck)pluck
{
    GtarFret fret = pluck.position.fret;
    GtarString str = pluck.position.string;
    
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
        [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret+1, str+1) 
                                    withColor:GtarLedColorMake(0, 3, 0)];
        
        _noteOn[str * 16 + fret] = 1;
        
        UIImageView * imgView = _imgView[str * 16 + fret];
        
        [imgView performSelectorOnMainThread:@selector(setImage:) withObject:_img waitUntilDone:YES];
        
        _noteOnCount++;
        
        if ( _noteOnCount == (16*6) )
        {
            g_checklist.noteOnTest = YES;
            
            [g_gtarController turnOffAllLeds];
            
            [self performSelectorOnMainThread:@selector(testComplete) withObject:nil waitUntilDone:NO];
            
        }
    }

}

@end
