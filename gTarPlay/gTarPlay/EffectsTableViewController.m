//
//  EffectsTableViewController.m
//  gTarPlay
//
//  Created by Franco on 4/8/13.
//
//

#import "EffectsTableViewController.h"

#import <AudioController/AudioController.h>
#import <AudioController/Effect.h>

@interface EffectsTableViewController ()

@property (retain, nonatomic) AudioController *audioController;

- (void) toggleEffect:(UIControl *)button;

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
    
    
    // Add on/off button to accessory view (right)
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button  setImage:[UIImage imageNamed:@"EffectsOffButton.png"] forState:UIControlStateNormal];
    [button  setImage:[UIImage imageNamed:@"EffectsOffButton.png"] forState:UIControlStateNormal | UIControlStateHighlighted];
    [button  setImage:[UIImage imageNamed:@"EffectsOnButton.png"] forState:UIControlStateSelected];
    [button  setImage:[UIImage imageNamed:@"EffectsOnButton.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    // Add click handler to button
    [button addTarget:self action:@selector(toggleEffect:) forControlEvents:UIControlEventTouchUpInside];
    
    // Set button size. When adding view to accessoryView it is automatically
    // centered in within the accessory view space, so no need to set buttons
    // frame x, y coordinates
    button.frame = CGRectMake(0, 0, 40, 40);
    
    // Set selected state of button based on effect on/off state.
    Effect *effect = (Effect*)[[[self.audioController GetEffects] objectAtIndex:indexPath.row] pointerValue];
    button.selected = effect->isOn() ? YES : NO;
    
    
    cell.accessoryView = button;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate didSelectEffectAtIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - button click handlers

- (void) toggleEffect:(UIControl *)button
{
    UITableViewCell *cell = (UITableViewCell*)button.superview;
    NSInteger effectNum = [self.tableView indexPathForCell:cell].row;
    
    Effect *effect = (Effect*)[[[self.audioController GetEffects] objectAtIndex:effectNum] pointerValue];
    
    // Toggle buttons selected state
    button.selected = !button.selected;
    
    // Set pass through of effect based on new state
    if ([button isSelected])
    {
        effect->SetPassThru(false);
        
        // TODO telemetry
        // Telemetetry log
        /*NSString* name = [NSString stringWithCString:m_effects[effectNum]->getName().c_str() encoding:[NSString defaultCStringEncoding]];
        
        [g_telemetryController logEvent:GtarFreePlayToggleFeature
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         @"On", name,
                                         nil]];
        
        [m_effectTimeStart[effectNum] release];
        m_effectTimeStart[effectNum] = [[NSDate date] retain];
         */
        
    }
    else
    {
        effect->SetPassThru(true);
        
        // Telemetetry log
        /*
        NSString* name = [NSString stringWithCString:m_effects[effectNum]->getName().c_str() encoding:[NSString defaultCStringEncoding]];
        
        NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_effectTimeStart[effectNum] timeIntervalSince1970] + m_playTimeAdjustment;
        
        [g_telemetryController logEvent:GtarFreePlayToggleFeature
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         @"Off", name,
                                         [NSNumber numberWithInteger:delta], @"PlayTime",
                                         nil]];
        
        [m_effectTimeStart[effectNum] release];
        m_effectTimeStart[effectNum] = [[NSDate date] retain];
         */  
    }
}


@end
