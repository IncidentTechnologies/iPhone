//
//  GtarViewController.m
//  gTarCreate
//
//  Created by Idan Beck on 5/13/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import "GtarViewController.h"

extern GtarController *g_gtarController;

@interface GtarViewController () {
    
}

@end

@implementation GtarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //m_firmwares = [NSArray arrayWithObjects:@"one", @"two", @"three", nil];
    m_firmwares = [[NSBundle mainBundle] pathsForResourcesOfType:@"bin" inDirectory:@""];
    
    m_disableView = [[UIView alloc] initWithFrame:self.view.frame];
    [m_disableView setBackgroundColor:[UIColor blackColor]];
    [m_disableView setAlpha:0.5f];
    [self.view addSubview:m_disableView];
    [m_disableView setHidden:TRUE];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = m_disableView.center;
    [activityView startAnimating];
    [m_disableView addSubview:activityView];
    
    [self.view bringSubviewToFront:m_disableView];
}

- (void)receivedFirmwareUpdateProgress:(unsigned char)percentage {
    NSLog(@"update progress %d%%", percentage);
}

- (void)receivedFirmwareUpdateStatusSucceeded {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                     message:@"Update Succeeded"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
    [m_disableView setHidden:TRUE];
}

- (void)receivedFirmwareUpdateStatusFailed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:@"Update Failed -- Restart the gTar"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
    [m_disableView setHidden:TRUE];
}

-(IBAction)OnFWUpgradeClick:(id)sender {
    NSIndexPath *indexPath = [_m_tableViewFirmwares indexPathForSelectedRow];
    if(indexPath == NULL) {
        NSLog(@"No fw selected");
        return;
    }
    
    int row = indexPath.row;
    NSLog(@"Programming FW %@", [m_firmwares objectAtIndex:row]);
    
    // Try to load file as data
    NSData *fwdata = [[NSData alloc] initWithContentsOfFile:[m_firmwares objectAtIndex:row]];
    if(fwdata == NULL) {
        NSLog(@"Error: could not load data");
        return;
    }
    
    if(g_gtarController.m_delegate != self)
        g_gtarController.m_delegate = self;
    
    if([g_gtarController sendFirmwareUpdate:fwdata] == false) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                         message:@"Failed to update firmware"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    }
    else {
        [m_disableView setHidden:FALSE];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [m_firmwares count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSString* filename = [[[m_firmwares objectAtIndex:indexPath.row] lastPathComponent] stringByDeletingPathExtension];
    cell.textLabel.text = [[NSString alloc] initWithString:filename];
    return cell;
}

@end
