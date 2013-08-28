//
//  StoreViewController.m
//  gTarPlay
//
//  Created by Franco on 8/28/13.
//
//

#import "StoreViewController.h"
#import "InAppPurchaseManager.h"

@interface StoreViewController ()

@end

@implementation StoreViewController

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
    // Do any additional setup after loading the view from its nib.
    
    InAppPurchaseManager* purchaseManager = [InAppPurchaseManager sharedInstance];
    if ([purchaseManager canMakePurchases])
    {
        NSLog(@"Can make in app purchase");
        [purchaseManager loadStore];
    }
    else
    {
        NSLog(@"Can NOT make in app purchase");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)purchaseSong:(id)sender
{
    [[InAppPurchaseManager sharedInstance] purchaseSong];
}


@end
