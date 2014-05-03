//
//  EffectsTableViewController.m
//  gTarPlay
//
//  Created by Franco on 4/8/13.
//
//

#import "EffectsTableViewController.h"

@interface EffectsTableViewController ()

- (void) toggleEffect:(UIControl *)button;

@end

@implementation EffectsTableViewController

@synthesize delegate;
@synthesize tableView;

-(id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        //_audioController = [AC retain];
        
        CGRect frame = CGRectMake(0, 0, 0, 0);
        tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    
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
    return [delegate getNumEffects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"InstrumentTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Avenir Next" size:17.0]];
    cell.textLabel.text = [delegate getEffectNameAtIndex:indexPath.row];
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
    button.tag = indexPath.row;
    [button addTarget:self action:@selector(toggleEffect:) forControlEvents:UIControlEventTouchUpInside];
    
    // Set button size. When adding view to accessoryView it is automatically
    // centered in within the accessory view space, so no need to set buttons
    // frame x, y coordinates
    button.frame = CGRectMake(0, 0, 40, 40);
    
    // Set selected state of button based on effect on/off state.
    button.selected = [delegate isEffectOnAtIndex:indexPath.row];
    
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

- (void) toggleEffect:(id)sender
{
    UIButton * button = (UIButton *)sender;
    
    NSInteger effectNum = button.tag;
    
    // Toggle buttons selected state
    button.selected = !button.selected;
    
    // Set pass through of effect based on new state
    if ([button isSelected])
    {
        [delegate toggleEffect:effectNum isOn:FALSE];
        
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
        [delegate toggleEffect:effectNum isOn:TRUE];
        
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
