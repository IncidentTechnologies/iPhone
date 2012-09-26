//
//  VAViewController.m
//  gTarVerificationApp
//
//  Created by Joel Greenia on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VAViewController.h"
#import "VAChecklist.h"

@interface VAViewController ()
{
    
    VAChecklist * m_checklist;
    
    UIImage * m_emptyCheckbox;
    UIImage * m_fullCheckbox;
    
    UIImageView * m_fretboard[6][17];
    
    GtarController * m_gtarController;
    
    UIImageView * m_currentHighlightedImageView;
}

@end

@implementation VAViewController

@synthesize connectedImageView;
@synthesize disconnectedImageView;
@synthesize fretboadView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    m_checklist = [[VAChecklist alloc] init];
    m_fullCheckbox = [UIImage imageNamed:@"checkbox_checked.png"];
    m_emptyCheckbox = [UIImage imageNamed:@"checkbox_unchecked.png"];
    
    CGFloat width = fretboadView.frame.size.width / 17.0;
    CGFloat height = fretboadView.frame.size.height / 6.0;
    
    for ( char str = 0; str < 6; str++ )
    {
        for ( char fret = 0; fret < 17; fret++ )
        {
            
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(fret * width,
                                                                                    (5-str) * height,
                                                                                    width, height)];
            
            [imageView setImage:m_emptyCheckbox];
            
            [fretboadView addSubview:imageView];
            
            m_fretboard[str][fret] = imageView;
            m_checklist->m_noteOn[str][fret] = 0;
        }
    }
    
    [self updateDisplay];
    
    if ( m_gtarController == nil )
    {
        m_gtarController = [[GtarController alloc] init];
        
        [m_gtarController addObserver:self];
    }
}

- (void)viewDidUnload
{
    [self setFretboadView:nil];
    [self setConnectedImageView:nil];
    [self setDisconnectedImageView:nil];
    
    [m_gtarController removeObserver:self];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)updateDisplay
{
    
    if ( m_checklist->m_connected )
    {
        [connectedImageView setImage:m_fullCheckbox];
    }
    else
    {
        [connectedImageView setImage:m_emptyCheckbox];
    }
    
    if ( m_checklist->m_disconnected )
    {
        [disconnectedImageView setImage:m_fullCheckbox];
    }
    else
    {
        [disconnectedImageView setImage:m_emptyCheckbox];
    }
    
    for ( char str = 0; str < 6; str++ )
    {
        for ( char fret = 0; fret < 17; fret++ )
        {
            
            UIImageView * imageView = (UIImageView*)m_fretboard[str][fret];
            
            if ( m_checklist->m_noteOn[str][fret] )
            {
                [imageView setImage:m_fullCheckbox];
            }
            else
            {
                [imageView setImage:m_emptyCheckbox];
            }
            
        }
    }
    
}

- (IBAction)redButtonClicked:(id)sender
{
    
    GtarPosition position = GtarPositionMake(0, 0);
    
    GtarLedColor color = GtarLedColorMake(3, 0, 0);
    
    [m_gtarController turnOnLedAtPosition:position withColor:color];

}

- (IBAction)greenButtonClicked:(id)sender
{
    
    GtarPosition position = GtarPositionMake(0, 0);
    
    GtarLedColor color = GtarLedColorMake(0, 3, 0);

    [m_gtarController turnOnLedAtPosition:position withColor:color];
    
}

- (IBAction)blueButtonClicked:(id)sender
{

    GtarPosition position = GtarPositionMake(0, 0);
    
    GtarLedColor color = GtarLedColorMake(0, 0, 3);
    
    [m_gtarController turnOnLedAtPosition:position withColor:color];

}

- (IBAction)whiteButtonClicked:(id)sender
{

    GtarPosition position = GtarPositionMake(0, 0);
    
    GtarLedColor color = GtarLedColorMake(3, 3, 3);
    
    [m_gtarController turnOnLedAtPosition:position withColor:color];

}

- (IBAction)resetButtonClicked:(id)sender
{
    
    m_checklist = [[VAChecklist alloc] init];
    
    [self updateDisplay];
    
}

#pragma mark - GtarController

- (void)gtarFretDown:(GtarPosition)position
{
    GtarFret fret = position.fret;
    GtarString str = position.string;
    
    UIImageView * imageView = (UIImageView*)m_fretboard[str][fret];
    
    imageView.backgroundColor = [UIColor blueColor];
    
    m_currentHighlightedImageView.backgroundColor = [UIColor clearColor];
    
    m_currentHighlightedImageView = imageView;
    
//    NSLog(@"Fret up: %u %u", fret, str);
}

- (void)gtarFretUp:(GtarPosition)position
{
    GtarFret fret = position.fret;
    GtarString str = position.string;
    
    UIImageView * imageView = (UIImageView*)m_fretboard[str][fret];
    
    imageView.backgroundColor = [UIColor clearColor];
    
    m_currentHighlightedImageView.backgroundColor = [UIColor clearColor];
    
//    NSLog(@"Fret up: %u %u", fret, str);
}

- (void)gtarNoteOn:(GtarPosition)position
{
    GtarFret fret = position.fret;
    GtarString str = position.string;
    
    m_checklist->m_noteOn[str-1][fret] = 1;
    
    [self performSelectorOnMainThread:@selector(updateDisplay) withObject:nil waitUntilDone:YES];
}

- (void)gtarNoteOff:(GtarPosition)position
{
    
}

- (void)gtarConnected
{
    m_checklist->m_connected = YES;
    
    [self performSelectorOnMainThread:@selector(updateDisplay) withObject:nil waitUntilDone:YES];
}

- (void)gtarDisconnected
{
    m_checklist->m_disconnected = YES;
    
    [self performSelectorOnMainThread:@selector(updateDisplay) withObject:nil waitUntilDone:YES];
}

@end
