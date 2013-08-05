//
//  MenuViewController.m
//  Sketch
//
//  Created by Franco on 8/3/13.
//
//

#import "MenuViewController.h"

#import <gTarAppCore/UserController.h>

@interface MenuViewController ()

@end

@implementation MenuViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender
{
    [[UserController sharedSingleton] requestLogoutUserCallbackObj:nil andCallbackSel:nil];
    
    // TODO: get facebook instance/singleton to logout
    //[_facebook logout];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
