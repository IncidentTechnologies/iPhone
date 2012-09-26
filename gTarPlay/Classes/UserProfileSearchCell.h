//
//  UserProfileSearchCell.h
//  gTarPlay
//
//  Created by Marty Greenia on 9/26/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"

@class UserProfile;
@class UserProfileSearchViewController;

@interface UserProfileSearchCell : CustomCell
{
    
    UserProfileSearchViewController * m_parent;
    
    IBOutlet UIView * m_view1;
    IBOutlet UIView * m_view2;
    IBOutlet UIImageView * m_portrait1;
    IBOutlet UIImageView * m_portrait2;
    IBOutlet UILabel * m_statusLabel1;
    IBOutlet UILabel * m_statusLabel2;
    IBOutlet UIButton * m_nameButton1;
    IBOutlet UIButton * m_nameButton2;
    IBOutlet UIButton * m_addFriendButton1;
    IBOutlet UIButton * m_addFriendButton2;
    IBOutlet UIButton * m_removeFriendButton1;
    IBOutlet UIButton * m_removeFriendButton2;
    
    UserProfile * m_userProfile1;
    UserProfile * m_userProfile2;
    
    BOOL m_isSelf1;
    BOOL m_isSelf2;
    BOOL m_areFriends1;
    BOOL m_areFriends2;

}

@property (nonatomic, assign) UserProfileSearchViewController * m_parent;
@property (nonatomic, retain) IBOutlet UIView * m_view1;
@property (nonatomic, retain) IBOutlet UIView * m_view2;
@property (nonatomic, retain) IBOutlet UIImageView * m_portrait1;
@property (nonatomic, retain) IBOutlet UIImageView * m_portrait2;
@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel1;
@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel2;
@property (nonatomic, retain) IBOutlet UIButton * m_nameButton1;
@property (nonatomic, retain) IBOutlet UIButton * m_nameButton2;
@property (nonatomic, retain) UserProfile * m_userProfile1;
@property (nonatomic, retain) UserProfile * m_userProfile2;
@property (nonatomic, retain) IBOutlet UIButton * m_addFriendButton1;
@property (nonatomic, retain) IBOutlet UIButton * m_addFriendButton2;
@property (nonatomic, retain) IBOutlet UIButton * m_removeFriendButton1;
@property (nonatomic, retain) IBOutlet UIButton * m_removeFriendButton2;
@property (nonatomic, assign) BOOL m_isSelf1;
@property (nonatomic, assign) BOOL m_isSelf2;
@property (nonatomic, assign) BOOL m_areFriends1;
@property (nonatomic, assign) BOOL m_areFriends2;

- (IBAction)addFriend1Clicked:(id)sender;
- (IBAction)addFriend2Clicked:(id)sender;
- (IBAction)removeFriend1Clicked:(id)sender;
- (IBAction)removeFriend2Clicked:(id)sender;
- (IBAction)displayProfile1Clicked:(id)sender;
- (IBAction)displayProfile2Clicked:(id)sender;

@end
