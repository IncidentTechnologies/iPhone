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
{
    BOOL _flickerState;
}

@property (retain, nonatomic) AudioController *audioController;
@property (retain, nonatomic) NSArray *instruments;

@property (retain, nonatomic) NSTimer *loadingTimer;

- (void) samplerFinishedLoadingCB:(NSNumber*)result;

@end

@implementation InstrumentTableViewController

- (id)initWithAudioController:(AudioController*)AC
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _audioController = [AC retain];
        _instruments = [[AC getInstrumentNames] retain];
        
        CGRect frame = CGRectMake(0, 0, 0, 0);
        _tableView = [[[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain] retain];
        
        _flickerState = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeInstrument:) name:@"InstrumentChanged" object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"InstrumentChanged" object:nil];
    
    [_audioController release];
    [_instruments release];
    [_loadingTimer release];
    
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
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSInteger instrumentIndex = [_audioController getCurrentSamplePackIndex];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:instrumentIndex inSection:0];
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
    [selectionColor release];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *instrumentName = [self.instruments objectAtIndex:indexPath.row];
    [self flickerSelectedItem];
    
    if ([_delegate respondsToSelector:@selector(didSelectInstrument)])
        [_delegate didSelectInstrument];
    
    [self.audioController setSamplePackWithName:instrumentName withSelector:@selector(samplerFinishedLoadingCB:) andOwner:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

# pragma mark - AudioController callbacks

- (void)samplerFinishedLoadingCB:(NSNumber*)result
{
    // TODO telemetry
    if ([result boolValue])
    {
        [self.audioController ClearOutEffects];
        [self.audioController startAUGraph];
        [self stopFlicker];
    }
    
    if ([_delegate respondsToSelector:@selector(didLoadInstrument)])
        [_delegate didLoadInstrument];
}

// Make the currently selected (center) item flash on and off. The flashing will
// continue until stopFlicker is called. If scroll is moved to select a new item
// then the first item will stop flickering and the newly selected item will flicker.
- (void) flickerSelectedItem
{
    // If selected item is already flickering do nothing, i.e. only start a
    // new timer if it is currently invalid, let a running timer continue
    if (![_loadingTimer isValid])
    {
        [_loadingTimer invalidate];
        self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.45 target:self selector:@selector(animateFlicker:) userInfo:nil repeats:YES];
    }
}

- (void) stopFlicker
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [_loadingTimer invalidate];
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[_tableView indexPathForSelectedRow]];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(132/255.0) blue:(53/255.0) alpha:1];
    }];
    
}

- (void) animateFlicker:(NSTimer*)theTimer
{
    UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[_tableView indexPathForSelectedRow]];
    
    _flickerState = !_flickerState;
    if (_flickerState) {
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1];
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
    }
    else{
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(132/255.0) blue:(53/255.0)  alpha:1];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    }
}

- (void) didChangeInstrument:(NSNotification *)notification
{
    NSInteger instrumentIndex = [[[notification userInfo] objectForKey:@"instrumentIndex"] intValue];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:instrumentIndex inSection:0];
    
    [self.tableView selectRowAtIndexPath:indexPath animated:NO  scrollPosition:UITableViewScrollPositionNone];
    
    [self stopFlicker];
    
    if ([_delegate respondsToSelector:@selector(didLoadInstrument)])
        [_delegate didLoadInstrument];
}

@end
