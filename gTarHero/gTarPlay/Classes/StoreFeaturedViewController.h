//
//  StoreFeaturedViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomViewController.h"

#define MAX_FEATURES 3

@class StoreFeatureCollection;
@class UserSong;
@class CustomSegmentedControl;

@interface StoreFeaturedViewController : CustomViewController <UITableViewDelegate, UITableViewDataSource>
{

    IBOutlet UITableView * m_tableView;
    IBOutlet UIButton * m_headlinerImageView;
    IBOutlet UIView * m_headlinerIndexButtonsView;
    UIButton * m_headlinerIndexButtons[MAX_FEATURES];

    IBOutlet CustomSegmentedControl * m_feedSelectorButton;
    
    StoreFeatureCollection * m_featureCollection;
    
    NSInteger m_currentFeature;
    UIView * m_currentFeatureView;
    UIView * m_nextFeatureView;
    NSTimer * m_slideshowTimer;
    NSTimer * m_slideshowRestartTimer;

}

@property (nonatomic, retain) IBOutlet UITableView * m_tableView;

@property (nonatomic, retain) IBOutlet UIButton * m_headlinerImageView;
@property (nonatomic, retain) IBOutlet UIView * m_headlinerIndexButtonsView;

@property (nonatomic, retain) IBOutlet CustomSegmentedControl * m_feedSelectorButton;

@property (nonatomic, retain) StoreFeatureCollection * m_featureCollection;

- (IBAction)headlinerButtonClicked:(id)sender;
- (void)headlinerIndexButtonClicked:(id)sender;
- (IBAction)segmentedButtonClicked:(id)sender;

- (void)changeSlideshow;
- (void)setCurrentFeature:(NSInteger)index;
- (void)startSlideshow;

@end
