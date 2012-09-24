//
//  BasemapsTableViewCell.m
//  Map
//
//  Created by Scott Sirowy on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BasemapsTableViewCell.h"

@implementation BasemapsTableViewCell

@synthesize view = _view;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
