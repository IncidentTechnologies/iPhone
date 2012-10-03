//
//  StoreFeaturedViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StoreFeaturedViewController.h"
#import "StoreFeaturedGenreViewController.h"
#import "StoreNavigationViewController.h"
#import "StoreFeaturedCell.h"
#import "StoreSubcategoryCell.h"

#import "CustomSegmentedControl.h"

#import <QuartzCore/QuartzCore.h>

#import <gTarAppCore/StoreFeatureCollection.h>
#import <gTarAppCore/StoreGenreCollection.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/FeaturedSong.h>
#import <gTarAppCore/FileController.h>

#define MAX_FEATURES 3

extern FileController * g_fileController;

@implementation StoreFeaturedViewController

@synthesize m_tableView;
@synthesize m_headlinerImageView;
@synthesize m_headlinerIndexButtonsView;

@synthesize m_feedSelectorButton;

@synthesize m_featureCollection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_tableView release];
    [m_headlinerImageView release];
    [m_feedSelectorButton release];
    [m_headlinerIndexButtonsView release];

    [m_featureCollection release];
    
    [m_slideshowTimer invalidate];
    [m_slideshowRestartTimer invalidate];
    
    m_slideshowTimer = nil;
    m_slideshowRestartTimer = nil;
    
    [super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [m_feedSelectorButton changeTitles:[NSArray arrayWithObjects:@"New", @"Popular", @"Genre", nil]];
    
    // Reset the selected table, if needed
    NSInteger selectedSegment = m_feedSelectorButton.m_selectedSegmentIndex;
    
    if ( selectedSegment != 0 || selectedSegment != 1 || selectedSegment != 2 )
    {
        [m_feedSelectorButton setSelectedIndex:0];
    }
    
    m_currentFeature = 0;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.m_tableView = nil;
    self.m_headlinerImageView = nil;
    self.m_feedSelectorButton = nil;
    self.m_headlinerIndexButtonsView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    // Headliner
    UIImage * image;
    
    NSArray * featuredArray = m_featureCollection.m_featuredSongs;
    
    if ( [featuredArray count] > 0 )
    {
        
        FeaturedSong * featuredSong = [featuredArray objectAtIndex:m_currentFeature];
        
        image = [g_fileController getFileOrDownloadSync:featuredSong.m_picFileId];
        
        if ( image != nil )
        {
            [m_headlinerImageView setBackgroundImage:image forState:UIControlStateNormal];
        }
        
    }
    
    if ( [featuredArray count] > 1 )
    {
        // create the buttons that go under the slide show
        NSInteger featureCount = MIN( MAX_FEATURES, [featuredArray count] );
        CGFloat usableSpace = m_headlinerIndexButtonsView.frame.size.width - (featureCount * m_headlinerIndexButtonsView.frame.size.height);
        CGFloat shift = usableSpace / (featureCount+1);
        
        for ( NSInteger i = 0; i < featureCount; i++ )
        {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [button setFrame:CGRectMake(0, 0, 
                                        m_headlinerIndexButtonsView.frame.size.height,
                                        m_headlinerIndexButtonsView.frame.size.height)];
            
            UIColor * color = [UIColor colorWithRed:0.0f/255.0f green:130.0f/255.0f blue:183.0f/255.0f alpha:1.0f];
            
            button.backgroundColor = color;
            button.layer.cornerRadius = button.frame.size.width / 2.0;
            button.layer.borderWidth = 1;
            button.layer.borderColor = [[UIColor whiteColor] CGColor];
            button.clipsToBounds = NO;
            
            button.transform = CGAffineTransformMakeTranslation( (i+1)*shift +  i*button.frame.size.width, 0 );
            
            [button addTarget:self action:@selector(headlinerIndexButtonClicked:) forControlEvents:UIControlEventTouchDown];
            
            m_headlinerIndexButtons[i] = button;
            
            [m_headlinerIndexButtonsView addSubview:button];
        }
        
        m_currentFeature = 0;
        
        [self setCurrentFeature:0];
        
        [self startSlideshow];
        
    }
    
    [m_tableView reloadData];
    
    [super viewWillAppear:animated];
            
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [m_slideshowTimer invalidate];
    [m_slideshowRestartTimer invalidate];
    
    m_slideshowTimer = nil;
    m_slideshowRestartTimer = nil;
    
    for ( NSInteger index = 0; index < MAX_FEATURES; index++ )
    {
        // Note that we didn't retain this object, so removing it should dealloc it
        [m_headlinerIndexButtons[index] removeFromSuperview];
        
        m_headlinerIndexButtons[index] = nil;
    }
    
    [super viewWillDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.

    if ( m_feedSelectorButton.m_selectedSegmentIndex == 0 )
    {
    
        NSArray * newArray = m_featureCollection.m_newUserSongs;

        return [newArray count];

    }
    else if ( m_feedSelectorButton.m_selectedSegmentIndex == 1 )
    {

        NSArray * popularArray = m_featureCollection.m_popularUserSongs;
        
        return [popularArray count];
        
    }
    else if ( m_feedSelectorButton.m_selectedSegmentIndex == 2 )
    {
        
        NSArray * genreArray = m_featureCollection.m_genreList;
        
        return [genreArray count];
        
    }
    
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    NSInteger row = [indexPath row];

    NSInteger selectedSegment = m_feedSelectorButton.m_selectedSegmentIndex;
    
    if ( selectedSegment == 0 || selectedSegment == 1 )
    {
        
        m_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        static NSString * CellIdentifier = @"StoreFeaturedCell";
        
        StoreFeaturedCell * cell = (StoreFeaturedCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            
            cell = [[[StoreFeaturedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [[NSBundle mainBundle] loadNibNamed:@"StoreFeaturedCell" owner:cell options:nil];
            
        }
        
        
        if ( selectedSegment == 0 )
        {
            
            NSArray * newArray = m_featureCollection.m_newUserSongs;
            
            if ( [newArray count] > row )
            {
                cell.m_userSong = [newArray objectAtIndex:row];
                cell.m_rankNumber = (row + 1);
            }
            
        }
        else if ( selectedSegment == 1 )
        {

            NSArray * popularArray = m_featureCollection.m_popularUserSongs;

            if ( [popularArray count] > row )
            {
                cell.m_userSong = [popularArray objectAtIndex:row];
                cell.m_rankNumber = (row + 1);
            }
            
        }
        
        [cell updateCell];

        return cell;

    }
    else if ( selectedSegment == 2 )
    {
        
        m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        static NSString * CellIdentifier = @"StoreSubcategoryCell";
        
        StoreSubcategoryCell * cell = (StoreSubcategoryCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            
            cell = [[[StoreSubcategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [[NSBundle mainBundle] loadNibNamed:@"StoreSubcategoryCell" owner:cell options:nil];
            
        }
    
        NSArray * genreArray = m_featureCollection.m_genreList;
        
        cell.m_subcategoryName = [genreArray objectAtIndex:row];
        
        [cell updateCell];
        
        return cell;
    
    }

    return nil;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // +1 for the separator
    NSInteger selectedSegment = m_feedSelectorButton.m_selectedSegmentIndex;
    
    if ( selectedSegment == 0 || selectedSegment == 1 )
    {
        return [StoreFeaturedCell cellHeight] + 1;
    }
    else if ( selectedSegment == 2 )
    {
        return [StoreSubcategoryCell cellHeight] + 1;
    }

    // there won't be any others though
    return 44.0f;
    
}

#pragma mark -
#pragma mark Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    
	NSInteger row = [indexPath row];
	
    if ( m_feedSelectorButton.m_selectedSegmentIndex == 0 )
    {

        NSArray * newArray = m_featureCollection.m_newUserSongs;
        
        if ( [newArray count] > row )
        {
            [(StoreNavigationViewController*)m_navigationController showUserSongDetail:[newArray objectAtIndex:row]];
        }
        
    }
    else if ( m_feedSelectorButton.m_selectedSegmentIndex == 1 )
    {
        
        NSArray * popularArray = m_featureCollection.m_popularUserSongs;

        if ( [popularArray count] > row )
        {
            [m_navigationController showUserSongDetail:[popularArray objectAtIndex:row]];
        }
    }
    else if ( m_feedSelectorButton.m_selectedSegmentIndex == 2 )
    {
        
        NSArray * genreArray = m_featureCollection.m_genreList;
        
        if ( [genreArray count] > row )
        {
            NSString * genre = [genreArray objectAtIndex:row];
            
            StoreGenreCollection * collection = [m_featureCollection.m_genreCollectionDictionary objectForKey:genre];
            
            [m_navigationController showSubcategory:collection];
        }
        
    }

}

#pragma mark - Click handlers

- (IBAction)headlinerButtonClicked:(id)sender
{
    
    NSArray * featureArray = m_featureCollection.m_featuredSongs;
    
    FeaturedSong * featuredSong = [featureArray objectAtIndex:m_currentFeature];
    UserSong * userSong = featuredSong.m_userSong;
    
    [(StoreNavigationViewController*) m_navigationController showUserSongDetail:userSong];
    
}

- (void)headlinerIndexButtonClicked:(id)sender
{
    
    for ( NSInteger index = 0; index < MAX_FEATURES; index++ )
    {
        
        if ( m_headlinerIndexButtons[index] == sender )
        {
            // we clicked it
            [m_slideshowTimer invalidate];
            [m_slideshowRestartTimer invalidate];
            
            m_slideshowTimer = nil;
            m_slideshowRestartTimer = nil;
            
            [self setCurrentFeature:index];
            
            m_slideshowRestartTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(startSlideshow) userInfo:nil repeats:NO];
            
        }
    }
}

- (IBAction)segmentedButtonClicked:(id)sender
{
    [m_tableView reloadData];
}

- (void)changeSlideshow
{
    
    NSArray * featuredArray = m_featureCollection.m_featuredSongs;
    
    NSInteger features = [featuredArray count];
    
    NSInteger newCurrentIndex = (m_currentFeature+1) % MIN( MAX_FEATURES, features );
    
    [self setCurrentFeature:newCurrentIndex];
    
}

- (void)setCurrentFeature:(NSInteger)index
{
    
    // change button color
    UIColor * color = [UIColor colorWithRed:0.0f/255.0f green:130.0f/255.0f blue:183.0f/255.0f alpha:1.0f];
    
    m_headlinerIndexButtons[ m_currentFeature ].backgroundColor = color;
    
    m_currentFeature = index;
    
    m_headlinerIndexButtons[ m_currentFeature ].backgroundColor = [UIColor whiteColor];
    
    // change image 
    NSArray * featuredArray = m_featureCollection.m_featuredSongs;
    
    FeaturedSong * featuredSong = [featuredArray objectAtIndex:m_currentFeature];
    
    UIImage * image = [g_fileController getFileOrDownloadSync:featuredSong.m_picFileId];
    
    [m_headlinerImageView setBackgroundImage:image forState:UIControlStateNormal];
    
    // set up the transition
    CATransition * transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [m_headlinerImageView.layer addAnimation:transition forKey:nil];

}

- (void)startSlideshow
{
    
    [m_slideshowTimer invalidate];
    [m_slideshowRestartTimer invalidate];
    
    m_slideshowTimer = nil;
    m_slideshowRestartTimer = nil;
    
    m_slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(changeSlideshow) userInfo:nil repeats:YES];
}

@end
