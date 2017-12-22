//
//  AddButton.m
//  Track
//
//  Created by apple on 2016/11/13.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "AddButton.h"

@interface AddButton()
@property (nonatomic,strong)UIImageView *imageV;
@property (nonatomic,strong)UILabel *lab;

@end
@implementation AddButton
-(instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)imageName labText:(NSString *)labText{
    self = [super initWithFrame:frame];
    if (self) {
        _imageV = [[UIImageView alloc]initWithFrame:CGRectZero];
        _imageV.image = [UIImage imageNamed:imageName];
        [self addSubview:_imageV];
        
        _lab = [[UILabel alloc]initWithFrame:CGRectZero];
        _lab.text = labText;
        _lab.textColor = [UIColor whiteColor];
        [self addSubview:_lab];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _imageV.frame = CGRectMake(10, 5, 30, 30);
    _lab.frame = CGRectMake(50, 5, CGRectGetWidth(self.frame)-30, 30);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
