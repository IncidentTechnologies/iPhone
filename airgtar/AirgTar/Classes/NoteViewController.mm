//
//  NoteViewController.m
//  AirgTar
//
//  Created by idanbeck on 11/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NoteViewController.h"


@implementation NoteViewController

@synthesize m_ViewHeight;
@synthesize m_pgTarState;

/*
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}
 */

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, m_ViewHeight);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
