//
//  PlayCell.m
//  EtarLearn
//
//  Created by Marty Greenia on 10/7/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "PlayCell.h"


@implementation PlayCell

@synthesize songName;
@synthesize songGenre;
@synthesize songProgress;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
