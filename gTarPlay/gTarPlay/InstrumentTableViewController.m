//
//  InstrumentTableViewController.m
//  gTarPlay
//
//  Created by Franco on 4/1/13.
//
//

#import "InstrumentTableViewController.h"

#import <AudioController/AudioController.h>

@interface InstrumentTableViewController ()

@property (retain, nonatomic) AudioController *audioController;
@property (retain, nonatomic) NSArray *instruments;

@end

@implementation InstrumentTableViewController

- (id)initWithAudioController:(AudioController*)AC instrumentList:(NSArray*)instruments
{
    self = [super initWithNibName:@"InstrumentTableViewController" bundle:nil];
    if (self) {
        _instruments = [instruments retain];
    }
    return self;
}

- (void)dealloc
{
    [_instruments release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    self.view = tableView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.instruments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"InstrumentTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [self.instruments objectAtIndex:indexPath.row];
    return cell;
}

@end
