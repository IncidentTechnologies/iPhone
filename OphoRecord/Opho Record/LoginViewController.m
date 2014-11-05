//
//  LoginViewController.m
//  Opho Record
//
//  Created by Idan Beck on 11/3/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "DefaultViewController.h"

extern OphoController * g_ophoController;

@interface LoginViewController () {

}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// pragma mark is used for easy access of code in Xcode
#pragma mark - TextField Delegates

// This method is called once we click inside the textField
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"Text field did begin editing");
}

// This method is called once we complete editing
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"Text field ended editing");
}

// This method enables or disables the processing of return key
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Navigation

- (IBAction)signinButtonClicked:(id)sender {
    if ( [[self usernameField] text] == nil || [[[self usernameField] text] isEqualToString:@""] == YES ) {
        
        //[self displayNotification:SIGNIN_USERNAME_INVALID turnRed:YES];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Username"
                                                        message:@"Username is invalid"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    if ( [[self passwordField] text] == nil || [[[self passwordField] text] isEqualToString:@""] == YES ) {
        //[self displayNotification:SIGNIN_PASSWORD_INVALID turnRed:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Password"
                                                        message:@"PAssword is invalid"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }

    [g_ophoController loginWithUsername:[[self usernameField] text] password:[[self passwordField] text]];
    
    return;
}

#pragma mark - Opho Controller Login Delegate Functions
- (void) OnLoggedIn {
    NSLog(@"User logged in successfully");
    
    // Push the default view
    DefaultViewController *defaultVC = [[DefaultViewController alloc] initWithNibName:@"DefaultViewController" bundle:nil];
    [self.navigationController pushViewController:defaultVC animated:YES];
}

- (void) OnLoginFail: (NSString *)error {
    NSLog(@"User login fail: %@", error);
}

@end
