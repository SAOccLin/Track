//
//  NotificationButton.m
//  Track
//
//  Created by apple on 2016/11/14.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "NotificationButton.h"
@interface NotificationButton()
@property (nonatomic,strong)UILabel *lab;
@property (nonatomic,strong)UIImageView *circularImageV;

@end
@implementation NotificationButton
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
        
        _circularImageV = [[UIImageView alloc]initWithFrame:CGRectZero];
        _circularImageV.image = [UIImage imageNamed:@"圆点.png"];
        [self addSubview:_circularImageV];
    }
    return self;
}
-(void)upDataImage:(UIImage *)image{
    _imageV.image =image;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    _circularImageV.frame = CGRectMake(20, 15, 15, 15);
    _lab.frame = CGRectMake(40, 5, CGRectGetWidth(self.frame)-30, 30);
    _lab.textColor = [UIColor whiteColor];
    _imageV.frame = CGRectMake(WIDTH-35, 15, 15, 15);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
