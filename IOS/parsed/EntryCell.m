//
//  EntryCell.m
//  parsed
//
//  Created by Aaron Burke on 4/3/14.
//  Copyright (c) 2014 Aaron Burke. All rights reserved.
//

#import "EntryCell.h"

@implementation EntryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
