//
//  SongViewCell.h
//  Sketch
//
//  Created by Franco on 7/22/13.
//
//

#import <UIKit/UIKit.h>

@interface SongViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songDetails;

@end
