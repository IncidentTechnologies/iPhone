//
//  FourthViewController.m
//  gTarDemo
//
//  Created by Joel Greenia on 11/20/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import "FourthViewController.h"

#import "GuitarController.h"

extern GuitarController * g_guitarController;

@implementation FourthViewController
@synthesize m_redControl;
@synthesize m_greenControl;
@synthesize m_blueControl;
@synthesize m_scrollView;
@synthesize m_buttonView;

#define STRING_COUNT 6
#define FRET_COUNT 16

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Fixed", @"Fixed");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        
        m_stringDict = [[NSMutableDictionary alloc] init];
        m_fretDict = [[NSMutableDictionary alloc] init];
        
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    for ( NSInteger fret = 0; fret < FRET_COUNT; fret++ )
    {
        for ( NSInteger str = 0; str < STRING_COUNT; str++ )
        {
            
//            UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            button.frame = CGRectMake( str * (m_buttonView.frame.size.width / STRING_COUNT), 
                                       fret * (m_buttonView.frame.size.height / FRET_COUNT),
                                       m_buttonView.frame.size.width / STRING_COUNT,
                                       m_buttonView.frame.size.height / FRET_COUNT );
            
            button.backgroundColor = [UIColor blackColor];
            [button setTitle:[NSString stringWithFormat:@"#%u",fret+1] forState:UIControlStateNormal];
            
            [m_buttonView addSubview:button];
            
            [m_stringDict setObject:[NSNumber numberWithInteger:str] forKey:[NSValue valueWithNonretainedObject:button]];
            [m_fretDict setObject:[NSNumber numberWithInteger:fret] forKey:[NSValue valueWithNonretainedObject:button]];
            
            [button addTarget:self action:@selector(individualOnButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    [m_scrollView addSubview:m_buttonView];
    m_scrollView.contentSize = m_buttonView.frame.size;
    
}

- (void)viewDidUnload
{
    [self setM_redControl:nil];
    [self setM_greenControl:nil];
    [self setM_blueControl:nil];
    [self setM_scrollView:nil];
    [self setM_buttonView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    g_guitarController.m_delegate = (id<GuitarControllerDelegate>)self;
    
    [g_guitarController turnOffAllLeds];
    [g_guitarController turnOffAllEffects];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)onButtonClicked:(id)sender
{
    
    NSInteger red = m_redControl.selectedSegmentIndex;
    NSInteger green = m_greenControl.selectedSegmentIndex;
    NSInteger blue = m_blueControl.selectedSegmentIndex;
    
    [g_guitarController turnOnLedAtString:0 andFret:0 withRed:red andGreen:green andBlue:blue];
    
    NSArray * array = [m_fretDict allKeys];
    
    for ( NSValue * value in array )
    {
        UIButton * button = [value nonretainedObjectValue];
        button.backgroundColor = [UIColor colorWithRed:red/3.0 green:green/3.0 blue:blue/3.0 alpha:1.0];
    }
}

- (IBAction)individualOnButtonClicked:(id)sender
{

    NSInteger red = m_redControl.selectedSegmentIndex;
    NSInteger green = m_greenControl.selectedSegmentIndex;
    NSInteger blue = m_blueControl.selectedSegmentIndex;
    
    NSInteger fret = [[m_fretDict objectForKey:[NSValue valueWithNonretainedObject:sender]] integerValue];
    NSInteger str = [[m_stringDict objectForKey:[NSValue valueWithNonretainedObject:sender]] integerValue];
    
    [g_guitarController turnOnLedAtString:str+1
                                  andFret:fret+1
                                  withRed:red
                                 andGreen:green
                                  andBlue:blue];
    
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:red/3.0 green:green/3.0 blue:blue/3.0 alpha:1.0];

}

@end
