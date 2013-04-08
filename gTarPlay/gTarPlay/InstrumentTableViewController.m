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

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) AudioController *audioController;
@property (retain, nonatomic) NSArray *instruments;

- (void) samplerFinishedLoadingCB:(NSNumber*)result;

@end

@implementation InstrumentTableViewController

- (id)initWithAudioController:(AudioController*)AC
{
    self = [super initWithNibName:@"InstrumentTableViewController" bundle:nil];
    if (self)
    {
        _audioController = AC;
        _instruments = [[AC getInstrumentNames] retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_instruments release];
    
    [_tableView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate and DataSource

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
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(132/255.0) blue:(53/255.0) alpha:1];
    cell.selectedBackgroundView = selectionColor;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *instrumentName = [self.instruments objectAtIndex:indexPath.row];
    //[m_instrumentsScroll flickerSelectedItem];
    [self.audioController setSamplePackWithName:instrumentName withSelector:@selector(samplerFinishedLoadingCB:) andOwner:self];
}

# pragma mark - AudioController callbacks

- (void)samplerFinishedLoadingCB:(NSNumber*)result
{
    if ([result boolValue])
    {
        [self.audioController ClearOutEffects];
        [self.audioController startAUGraph];
        //[m_instrumentsScroll stopFlicker];
    }
}

@end
