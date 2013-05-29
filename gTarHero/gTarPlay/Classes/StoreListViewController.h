//
//  StoreListViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomViewController.h"

@interface StoreListViewController : CustomViewController
{

    IBOutlet UITableView * m_table;
    IBOutlet UILabel * m_genreLabel;
    
    NSString * m_genreName;
    NSArray * m_userSongList;

}

@property (nonatomic, retain) IBOutlet UITableView * m_table;
@property (nonatomic, retain) IBOutlet UILabel * m_genreLabel;
@property (nonatomic, retain) NSString * m_genreName;
@property (nonatomic, retain) NSArray * m_userSongList;

@end
