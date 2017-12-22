//
//  FriendRequestCell.m
//  Track
//
//  Created by maralves on 16/9/4.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "FriendRequestCell.h"


@implementation FriendRequestCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectZero];
    
    line.frame =CGRectMake(17, CGRectGetHeight(self.frame)-5, CGRectGetWidth(self.frame)-34, 1);
    line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
    [self addSubview:line];
    self.backgroundColor = [UIColor clearColor];
    self.lab.textColor = [UIColor whiteColor];
    self.lab.font = [UIFont systemFontOfSize:16];
    self.lab.textAlignment = NSTextAlignmentCenter;
    _accept.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    [_accept setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_accept setTitleColor:[UIColor colorWithRed:86.0/255 green:142.0/255 blue:191.0/255 alpha:1] forState:UIControlStateNormal];
    
//    _RequestImage = [UIImageView new];
//    _RequestImage.layer.cornerRadius=_RequestImage.frame.size.width/2;
//    _RequestImage.layer.masksToBounds=YES;
    _RequestImage.contentMode = UIViewContentModeScaleToFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)accept:(UIButton *)sender {
    if (self.accept) {
        self.acBlock(self.userId);
    }
}

@end
