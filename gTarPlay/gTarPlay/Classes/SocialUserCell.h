//
//  SocialUserCell.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/29/13.
//
//

#import <UIKit/UIKit.h>

@class UserProfile;

@interface SocialUserCell : UITableViewCell

@property (retain, nonatomic) UserProfile *userProfile;
@property (retain, nonatomic) NSInvocation *followInvocation;
@property (assign, nonatomic) BOOL following;
@property (assign, nonatomic) BOOL isUser;

@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) IBOutlet UIButton *followButton;

@property (retain, nonatomic) IBOutlet UILabel *followButtonText;

- (void)updateCell;
- (void)localizeViews;
- (IBAction)followButtonClicked:(id)sender;

@end
