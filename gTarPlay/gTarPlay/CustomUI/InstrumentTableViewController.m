//
//  InstrumentTableViewController.m
//  gTarPlay
//
//  Created by Franco on 4/1/13.
//
//

#import "InstrumentTableViewController.h"

@interface InstrumentTableViewController () {
    BOOL _flickerState;
    BOOL _isLoadingInstrument;
}

//@property (retain, nonatomic) AudioController *audioController;
@property (strong, nonatomic) NSArray *instruments;

@property (strong, nonatomic) NSTimer *loadingTimer;

- (void) samplerFinishedLoadingCB:(NSNumber*)result;

@end

@implementation InstrumentTableViewController

@synthesize delegate;
@synthesize instruments;

//- (id)initWithAudioController:(AudioController*)AC {
-(id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        CGRect frame = CGRectMake(0, 0, 0, 0);
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        
        _isLoadingInstrument = NO;
        _flickerState = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeInstrument:) name:@"InstrumentChanged" object:nil];
    }
    
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"InstrumentChanged" object:nil];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    instruments = [[NSArray alloc] initWithArray:[delegate getInstrumentList]];
    
    NSLog(@"Instrument array is %@",instruments);
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    self.tableView.allowsMultipleSelection = NO;
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSInteger instrumentIndex = [delegate getSelectedInstrumentIndex];
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:instrumentIndex inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];
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
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Avenir Next" size:17.0]];
    cell.textLabel.text = NSLocalizedString([self.instruments objectAtIndex:indexPath.row], NULL);  // will localize the string
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(132/255.0) blue:(53/255.0) alpha:1];
    cell.selectedBackgroundView = selectionColor;
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_isLoadingInstrument){
        return nil;
    }else{
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    _isLoadingInstrument = YES;
    
    NSString *instrumentName = [instruments objectAtIndex:indexPath.row];
    
    [self waitForCell:indexPath];
    
    [delegate didSelectInstrument:instrumentName withSelector:@selector(samplerFinishedLoadingCB:) andOwner:self];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

# pragma mark - AudioController callbacks

- (void)samplerFinishedLoadingCB:(NSNumber*)result
{
    NSLog(@"Sampler finished loading CB");
    
    _isLoadingInstrument = NO;
    
    if ([result boolValue])
    {
        // Keep audio effects for now
        [delegate stopAudioEffects];
        [self stopFlicker];
    }
    
    if ([delegate respondsToSelector:@selector(didLoadInstrument)])
        [delegate didLoadInstrument];
}

// Make the currently selected (center) item flash on and off. The flashing will
// continue until stopFlicker is called. If scroll is moved to select a new item
// then the first item will stop flickering and the newly selected item will flicker.
- (void) waitForCell:(NSIndexPath *)indexPath
{
    NSLog(@"*** flicker selected item ***");
    
    UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[_tableView indexPathForSelectedRow]];
    
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(132/255.0) blue:(53/255.0)  alpha:0.5];
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    
    // If selected item is already flickering do nothing, i.e. only start a
    // new timer if it is currently invalid, let a running timer continue
    if (![_loadingTimer isValid])
    {
        [_loadingTimer invalidate];
        self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(animateFlicker:) userInfo:nil repeats:YES];
    }
}

- (void) stopFlicker
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [_loadingTimer invalidate];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[_tableView indexPathForSelectedRow]];
        
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
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(239/255.0) green:(132/255.0) blue:(53/255.0)  alpha:0.5];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    }
}

- (void) didChangeInstrument:(NSNotification *)notification
{
    
    NSInteger instrumentIndex = [[[notification userInfo] objectForKey:@"instrumentIndex"] intValue];
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:instrumentIndex inSection:0];
    
    if([self.tableView numberOfRowsInSection:0] > indexPath.row){
        
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        
        [self stopFlicker];
        
        
        if (delegate && [delegate respondsToSelector:@selector(didLoadInstrument)])
            [delegate didLoadInstrument];
        
    }else{
        
        NSLog(@" *** attempted to select instrument not available in table");
        
    }
    
    
}

@end
