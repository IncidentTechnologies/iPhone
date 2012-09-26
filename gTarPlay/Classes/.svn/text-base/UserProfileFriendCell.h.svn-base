//
//  UserProfileFriendCell.h
//  gTarPlay
//
//  Created by Marty Greenia on 9/22/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomCell.h"

@class UserProfile;
@class UserProfileViewController;

@interface UserProfileFriendCell : CustomCell
{
    
    IBOutlet UIImageView * m_profileImageView;
    IBOutlet UILabel * m_nameLabel;
    IBOutlet UIButton * m_addFriendButton;
    IBOutlet UIButton * m_removeFriendButton;
    
    UserProfile * m_userProfile;
    
    UserProfileViewController * m_parent;
    
    BOOL m_areFriends;
    BOOL m_isSelf;
    
}

@property (nonatomic, retain) IBOutlet UIImageView * m_profileImageView;
@property (nonatomic, retain) IBOutlet UILabel * m_nameLabel;
@property (nonatomic, retain) IBOutlet UIButton * m_addFriendButton;
@property (nonatomic, retain) IBOutlet UIButton * m_removeFriendButton;
@property (nonatomic, retain) UserProfile * m_userProfile;
@property (nonatomic, assign) UserProfileViewController * m_parent;
@property (nonatomic, assign) BOOL m_areFriends;
@property (nonatomic, assign) BOOL m_isSelf;

- (IBAction)addUserButtonClicked:(id)sender;
- (IBAction)removeUserButtonClicked:(id)sender;

@end