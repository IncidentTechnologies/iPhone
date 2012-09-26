//
//  PlayCell.h
//  EtarLearn
//
//  Created by Marty Greenia on 10/7/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlayCell : UITableViewCell {
	IBOutlet UILabel * songName;
	IBOutlet UILabel * songGenre;
	IBOutlet UILabel * songAuthor;
//	IBOutlet UIProgressView * songProgress;
}

@property (nonatomic, retain) UILabel * songName;
@property (nonatomic, retain) UILabel * songGenre;
@property (nonatomic, retain) UILabel * songAuthor;
//@property (nonatomic, retain) UIProgressView * songProgress;

@end
