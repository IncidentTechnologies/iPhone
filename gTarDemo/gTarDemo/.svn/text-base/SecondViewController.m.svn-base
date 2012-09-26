//
//  SecondViewController.m
//  gTarDemo
//
//  Created by Joel Greenia on 11/15/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import "SecondViewController.h"

#import "GuitarEffect.h"
#import "GuitarEffectCell.h"
#import "ThirdViewController.h"

@implementation SecondViewController

@synthesize m_table;
@synthesize m_thirdViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        self.title = NSLocalizedString(@"Order", @"Order");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        
        m_effectsList = [[NSMutableArray alloc] init];
        
    }
    
    return self;
    
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setM_table:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [m_table reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)addEffect:(GuitarEffect*)effect
{
    
    [m_effectsList addObject:effect];
    m_thirdViewController.m_effectsSequence = m_effectsList;
    
}

- (void)moveEffectUp:(GuitarEffect*)effect
{
    
    NSInteger currentIndex = [m_effectsList indexOfObject:effect];
    
    currentIndex--;
    
    if ( currentIndex < 0 )
    {
        // already at top
        return;
    }
    
    [m_effectsList removeObject:effect];
    
    [m_effectsList insertObject:effect atIndex:currentIndex];
    
    [m_table reloadData];
    
}

- (void)moveEffectDown:(GuitarEffect*)effect
{
    NSInteger currentIndex = [m_effectsList indexOfObject:effect];
    
    currentIndex++;
    
    if ( currentIndex >= [m_effectsList count] )
    {
        // already at bottom
        return;
    }
    
    [m_effectsList removeObject:effect];
    
    [m_effectsList insertObject:effect atIndex:currentIndex];
    
    [m_table reloadData];

}

- (void)deleteEffect:(GuitarEffect*)effect
{
    
    [m_effectsList removeObject:effect];
    
    [m_table reloadData];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [m_effectsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    
    GuitarEffectCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil )
    {
        cell = [[GuitarEffectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        [[NSBundle mainBundle] loadNibNamed:@"GuitarEffectCell" owner:cell options:nil];
        
        cell.m_secondViewController = self;
    }
    
    // Configure the cell...
    NSInteger row = [indexPath row];
    
    cell.m_guitarEffect = [m_effectsList objectAtIndex:row];
    
    [cell updateCell];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


@end
