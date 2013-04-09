//
//  EffectsTableViewController.m
//  gTarPlay
//
//  Created by Franco on 4/8/13.
//
//

#import "EffectsTableViewController.h"

#import <AudioController/AudioController.h>

@interface EffectsTableViewController ()

@property (retain, nonatomic) AudioController *audioController;

@end

@implementation EffectsTableViewController

- (id)initWithAudioController:(AudioController*)AC
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        _audioController = [AC retain];
        
        CGRect frame = CGRectMake(0, 0, 0, 0);
        _tableView = [[[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain] retain];
    }
    return self;
}

- (void)dealloc
{
    [_audioController release];
    
    [_tableView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.audioController getEffectNames] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"InstrumentTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [[self.audioController getEffectNames] objectAtIndex:indexPath.row];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(162/255.0) blue:(54/255.0) alpha:1];
    cell.selectedBackgroundView = selectionColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString *instrumentName = [self.instruments objectAtIndex:indexPath.row];
    //[m_instrumentsScroll flickerSelectedItem];
    //[self.audioController setSamplePackWithName:instrumentName withSelector:@selector(samplerFinishedLoadingCB:) andOwner:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}



@end
