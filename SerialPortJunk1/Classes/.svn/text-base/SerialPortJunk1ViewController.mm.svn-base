//
//  SerialPortJunk1ViewController.m
//  SerialPortJunk1
//
//  Created by Idan Beck on 10/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SerialPortJunk1ViewController.h"

@implementation SerialPortJunk1ViewController

@synthesize readButton, writeButton;

@synthesize rxTextView;

@synthesize rxTimer;



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void) checkRx
{
	char *pBuffer;
	int bytes_n = m_psp->ReadSerialPort(pBuffer);
	
	if(bytes_n > 0)
	{
		NSString *pAppendString = [[NSString alloc] initWithFormat:@"%s", pBuffer];
		rxTextView.text = [rxTextView.text stringByAppendingString:pAppendString];
		if(pBuffer != NULL)
		{
			delete [] pBuffer;
			pBuffer = NULL;
		}
	}
}

- (IBAction) ReadButtonTouchUpInside:(id)sender
{
	[self checkRx];
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (IBAction) WriteButtonTouchUpInside:(id)sender
{
	int strLen = writeTextField.text.length;
	char *pString = new char[strLen + 1];		// add one for the null byte
	[writeTextField.text getCString:pString];
	m_psp->WriteSerialPort(pString, strLen);
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    m_psp = new SerialPort();
	
	rxTextView.text = [[NSString alloc] initWithString:@""];
	rxTextView.font = [UIFont fontWithName:@"courier" size:14];
	
	rxTimer = [NSTimer scheduledTimerWithTimeInterval:0.002 target:self selector:@selector(checkRx) userInfo:nil repeats:YES];
	
	[super viewDidLoad];
}




/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[rxTextView release];
	[readButton release];
	[writeTextField release];
	[writeButton release];
    [super dealloc];
}

@end
