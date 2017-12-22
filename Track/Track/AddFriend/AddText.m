//
//  AddText.m
//  Track
//
//  Created by apple on 2016/11/13.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "AddText.h"
@interface AddText()<UITextFieldDelegate>

//
@property (nonatomic,strong)UIImageView *imageView;
//线
@property (nonatomic,strong) UIView *lineView;

//填充线
@property (nonatomic,strong) CALayer *lineLayer;


@end

@implementation AddText
static const CGFloat lineWidth = 1;

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        _imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _imageView.image =[UIImage imageNamed:@"搜索.png"];
        [self addSubview:_imageView];
        
        _textField = [[UITextField alloc]initWithFrame:CGRectZero];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.font = [UIFont systemFontOfSize:15.f];
        _textField.textColor = [UIColor whiteColor];
        _textField.delegate = self;
        _textField.tintColor = [UIColor whiteColor];
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"手机号" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
        [self addSubview:_textField];
        
        
        
        _lineView = [[UIView alloc]initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_lineView];
        
        _lineLayer = [CALayer layer];
        _lineLayer.frame = CGRectMake(0,0, 0, lineWidth);
        _lineLayer.anchorPoint = CGPointMake(0, 0.5);
        _lineLayer.backgroundColor = [UIColor whiteColor].CGColor;
        [_lineView.layer addSublayer:_lineLayer];
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    _imageView.frame =CGRectMake(0, 0, 30, 30);
    _textField.frame = CGRectMake(_imageView.frame.origin.x+_imageView.frame.size.width+5, 0, CGRectGetWidth(self.frame)-_imageView.frame.origin.x+_imageView.frame.size.width+5, CGRectGetHeight(self.frame)-lineWidth);
    _lineView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-lineWidth, CGRectGetWidth(self.frame), lineWidth);
}

-(void)setCursorColor:(UIColor *)cursorColor{
    _textField.tintColor = cursorColor;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
