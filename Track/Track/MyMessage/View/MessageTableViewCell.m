//
//  MessageTableViewCell.m
//  Track
//
//  Created by apple on 2016/11/14.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "MessageTableViewCell.h"

@implementation MessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lab.backgroundColor = [UIColor clearColor];
    self.lab.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
