//
//  SerialPortJunk1ViewController.h
//  SerialPortJunk1
//
//  Created by Idan Beck on 10/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SerialPort.h"

@interface SerialPortJunk1ViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
	SerialPort *m_psp;
	IBOutlet UIButton *readButton;
	
	IBOutlet UIButton *writeButton;
	IBOutlet UITextField *writeTextField;
	
	IBOutlet UITextView *rxTextView;
	
	NSTimer *rxTimer;
}

@property (nonatomic, retain) UIButton *readButton;

@property (nonatomic, retain) UIButton *writeButton;
@property (nonatomic, retain) UIButton *writeTextField;

@property (nonatomic, retain) UITextView *rxTextView;

@property (nonatomic, retain) NSTimer *rxTimer;

- (IBAction) ReadButtonTouchUpInside:(id)sender;

- (IBAction) WriteButtonTouchUpInside:(id)sender;

- (void) checkRx;

@end

