//
//  StoreSearchViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/30/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomViewController.h"

@interface StoreSearchViewController : CustomViewController <UITableViewDelegate, UITableViewDataSource>
{
    
    IBOutlet UIActivityIndicatorView * m_activityIndicator;
    IBOutlet UITableView * m_tableView;
    IBOutlet UILabel * m_statusLabel;
    
    NSArray * m_userSongsArray;

}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_activityIndicator;
@property (nonatomic, retain) IBOutlet UITableView * m_tableView;
@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel;
@property (nonatomic, retain) NSArray * m_userSongsArray;

- (void)startIndicator;
- (void)stopIndicator;
- (void)displayResults:(NSArray*)userSongsArray;

@end
