//
//  LearnLessonCell.m
//  gTar
//
//  Created by wuda on 11/3/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "LearnLessonCell.h"


@implementation LearnLessonCell

@synthesize m_lessonName;

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
