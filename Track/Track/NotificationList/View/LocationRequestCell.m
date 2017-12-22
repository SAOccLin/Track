//
//  LocationRequestCell.m
//  Track
//
//  Created by maralves on 16/9/4.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "LocationRequestCell.h"

@implementation LocationRequestCell

- (void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    _time.textColor = [UIColor whiteColor];
    _content.textColor = [UIColor whiteColor];
}


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
