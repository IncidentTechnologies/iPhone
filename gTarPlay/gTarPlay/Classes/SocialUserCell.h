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

@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UIImageView *profilePic;
@property (retain, nonatomic) IBOutlet UIButton *followButton;

- (void)updateCell;

- (IBAction)followButtonClicked:(id)sender;

@end
