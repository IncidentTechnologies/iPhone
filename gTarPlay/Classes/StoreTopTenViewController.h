//
//  StoreTopTenViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomViewController.h"

@interface StoreTopTenViewController : CustomViewController <UITableViewDelegate>
{

    IBOutlet UISegmentedControl * m_genreSelectorControl;
    IBOutlet UITableView * m_tableView;
    
    NSDictionary * m_userSongsDictionary;
    
}

@property (nonatomic, retain) IBOutlet UISegmentedControl * m_genreSelectorControl;
@property (nonatomic, retain) IBOutlet UITableView * m_tableView;

@property (nonatomic, retain) NSDictionary * m_userSongsDictionary;

- (IBAction)segmentClickedHandler:(id)sender;

@end
