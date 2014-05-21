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

@property (strong, nonatomic) UserProfile *userProfile;
@property (strong, nonatomic) NSInvocation *followInvocation;
@property (assign, nonatomic) BOOL following;
@property (assign, nonatomic) BOOL isUser;

@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIImageView *profilePic;
@property (strong, nonatomic) IBOutlet UIButton *followButton;

@property (strong, nonatomic) IBOutlet UILabel *followButtonText;

- (void)updateCell;
- (void)localizeViews;
- (IBAction)followButtonClicked:(id)sender;

@end
