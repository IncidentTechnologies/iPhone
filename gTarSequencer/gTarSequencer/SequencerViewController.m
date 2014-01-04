//
//  SequencerViewController.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "SequencerViewController.h"

#define MAX_SEQUENCES 15
#define LAST_FRET 15
#define LAST_MEASURE 3
#define XBASE 480
#define YBASE 320

@implementation SequencerViewController

@synthesize instrumentTableViewController;
@synthesize bottomBarViewController;
@synthesize gTarLogoImageView;
@synthesize gTarConnectedText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubviews];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    //[self setPlayNotesButton:nil];
    
    // Release any retained subviews of the main view
    self.instrumentTableViewController = nil;
    self.bottomBarViewController = nil;
    
}

- (void)initSubviews
{
    
    
    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    // Gtar delegate and connection spoof
    NSLog(@"Setup and connect gTar");
    isConnected = NO;
    //isPlaying = NO;
    
    guitarView = [[GuitarView alloc] init];
    guitarView.delegate = self;
    [guitarView observeGtar];
    
    string = 0;
    fret = 0;
    
    // Instrument table
    NSLog(@"Start to build instrument table");
    
    instrumentTableViewController = [[InstrumentTableViewController alloc] initWithNibName:@"InstrumentTableView" bundle:nil];
    [instrumentTableViewController.view setFrame:CGRectMake(0, 0, XBASE, 255)];
    
    [self.view addSubview:instrumentTableViewController.view];
    
    // Tempo slider and play/pause
    NSLog(@"Start to build the bottom bar");
    bottomBarViewController = [[BottomBarViewController alloc] initWithNibName:@"BottomBar" bundle:nil];
    [bottomBarViewController.view setFrame:CGRectMake(0,251,XBASE,YBASE-252)];
    
    [self.view addSubview:bottomBarViewController.view];
    
}

#pragma mark - Guitar Observer

- (void)notePlayedAtString:(int)str andFret:(int)fr
{
  /*  if ( !isConnected || fr == 0 )
    {
        return;
    }
    
    if ( selectedInstrumentIndex < 0 || [instruments count] == 0 )
    {
        NSLog(@"No instruments opened, or selected instrument index < 0");
        return;
    }
    NSLog(@"Valid selection & valid data, so playing");
    
    SEQNote * note = [[SEQNote alloc] initWithString:str-1 andFret:fr-1];
    [self performSelectorOnMainThread:@selector(notePlayed:) withObject:note waitUntilDone:YES];*/
    
    NSLog(@"notePlayedAtString");
}

/*- (void)notePlayed:(SEQNote *)note
{
    NSLog(@"gTarSeq received note played message");
    
    // Pass note-played message onto the selected instrument
    Instrument * selectedInst = [instruments objectAtIndex:selectedInstrumentIndex];
    [selectedInst notePlayedAtString:note.string andFret:note.fret];
    
    [self updateAllVisibleCells];
    
    [guitarView update];
    
    [self save];
}*/

- (void)guitarConnected
{
    NSLog(@"Guitar connected");
    
    isConnected = YES;
    
    [self updateConnectedImages];
}

- (void)guitarDisconnected
{
    NSLog(@"Guitar disconnected");
    
    isConnected = NO;
    
    [self updateConnectedImages];
}

- (void)updateConnectedImages
{
    if (isConnected)
    {
        NSLog(@"update images connected");
        
        [self.gTarLogoImageView setImage:[UIImage imageNamed: @"gTarConnectedLogo"]];
        
        [self.gTarConnectedText setText:@"Connected"];
        
    }
    else {
        
        NSLog(@"update images not connected");
        
        [self.gTarLogoImageView setImage:[UIImage imageNamed: @"gTarNotConnectedLogo"]];
        
        [self.gTarConnectedText setText:@"Not Connected"];
    }
    
}


@end
