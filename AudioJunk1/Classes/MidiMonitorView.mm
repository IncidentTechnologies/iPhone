//
//  MidiMonitorView.m
//  AudioJunk1
//
//  Created by idanbeck on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MidiMonitorView.h"

@implementation MidiMonitorView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) writeText:(NSString *)pstrText
{
    m_pTextView.text = [[NSString alloc] initWithString:pstrText];
}

- (void) writeLine:(NSString *)pstrLine
{
    NSString *pstrCur = [[NSString alloc] initWithString:m_pTextView.text];
    NSString *pstrNew = [[NSString alloc] initWithFormat:@"%@%@\n", pstrCur, pstrLine];

    SEL writeTextSelector = @selector(writeText:);
    [self performSelectorOnMainThread:writeTextSelector withObject:pstrNew waitUntilDone:true];
    
    [pstrNew release];
    [pstrCur release];
}

void MidiMonitorWriteLine(void *self, NSString *pstrLine)
{
    [(id)self writeLine:pstrLine];
}

- (void) writeString:(NSString *)pstrString
{
    NSString *pstrCur = [[NSString alloc] initWithString:m_pTextView.text];
    NSString *pstrNew = [[NSString alloc] initWithFormat:@"%@%@", pstrCur, pstrString];

    SEL writeTextSelector = @selector(writeText:);
    [self performSelectorOnMainThread:writeTextSelector withObject:pstrNew waitUntilDone:true];
    
    [pstrNew release];
    [pstrCur release];
}

void MidiMonitorWriteString(void *self, NSString *pstrString)
{
    [(id)self writeLine:pstrString];
}

- (id) initWithTabBar
{
    if([self init])
    {
        // Tab Title
        self.title = @"Midi";
        //self.tabBarItem.image = [UIImage imageNamed:@"name_gray.png"];
        
        // set the long name shown in the navigation bar at the top
        self.navigationController.title = @"Midi";
        
        // Set up the text view
        CGRect textRect = CGRectMake(25, 25, 300, 350);
        m_pTextView = [[UITextView alloc] initWithFrame:textRect];
        m_pTextView.delegate = self;
        
        // Also set text view to non-editable
        m_pTextView.editable = false;        
        m_pTextView.text = [[NSString alloc] initWithString:@"Midi Monitor:\n"];
        
        [self.view addSubview:m_pTextView];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
