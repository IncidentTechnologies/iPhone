//
//  InstrumentView.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "InstrumentTableViewController.h"

@implementation InstrumentTableViewController

@synthesize instrumentTable;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        NSLog(@"enter table view controller");
        
        // get instruments - this will eventually be part of the selector not the list
        [self retrieveInstrumentOptions];
        
    }
    return self;
}

#pragma mark Instruments Data

- (void)retrieveInstrumentOptions
{
    
    NSLog(@"retrieve instrument options...");
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sequencerInstruments" ofType:@"plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSLog(@"The sequencer instrument plist exists");
    } else {
        NSLog(@"The sequencer instrument plist does not exist");
    }
    
    NSMutableDictionary * plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    masterInstrumentOptions = [plistDictionary objectForKey:@"Instruments"];
    remainingInstrumentOptions = [[NSMutableArray alloc] init];
    
    // Copy master options into remaining options:
    for (NSDictionary * dict in masterInstrumentOptions) {
        [remainingInstrumentOptions addObject:dict];
    }
    
    // at some point added instruments get removed
 
}

#pragma mark UITableView Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return [masterInstrumentOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // Temporary instrument display
    NSDictionary * dict = [remainingInstrumentOptions objectAtIndex:0];
    
    // Remove that instrument from the array:
    [remainingInstrumentOptions removeObjectAtIndex:0];
    NSString * instName = [dict objectForKey:@"Name"];
    
    // Build the cell...
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell.textLabel setText:instName];
    
    return cell;
}

@end
