//
//  LoginText.m
//  Track
//
//  Created by apple on 2016/11/13.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "LoginText.h"

@interface LoginText()<UITextFieldDelegate>

//
@property (nonatomic,strong)UILabel *lab;
//线
@property (nonatomic,strong) UIView *lineView;

//填充线
@property (nonatomic,strong) CALayer *lineLayer;


//隐藏按钮
@property (nonatomic,strong)UIButton *hideButton;

//竖线
@property (nonatomic,strong)UIView *line;
@end

@implementation LoginText

static const CGFloat lineWidth = 1;

-(instancetype)initWithFrame:(CGRect)frame hidden:(BOOL)hid placeholder:(BOOL)placeholder labName:(NSString *)labName textName:(NSString *)textName{
    if(self = [super initWithFrame:frame]){
        
        _lab = [[UILabel alloc]initWithFrame:CGRectZero];
        _lab.textColor = [UIColor whiteColor];
        _lab.text = labName;
        [self addSubview:_lab];
        
        _textField = [[UITextField alloc]initWithFrame:CGRectZero];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.font = [UIFont systemFontOfSize:15.f];
        _textField.textColor = [UIColor whiteColor];
        _textField.tintColor = [UIColor whiteColor];
        _textField.delegate = self;
        if (placeholder==YES) {
            _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textName attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
        }
        [self addSubview:_textField];
        
        
        
        _lineView = [[UIView alloc]initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
        [self addSubview:_lineView];
        
        _lineLayer = [CALayer layer];
        _lineLayer.frame = CGRectMake(0,0, 0, lineWidth);
        _lineLayer.anchorPoint = CGPointMake(0, 0.5);
        [_lineView.layer addSublayer:_lineLayer];
        
        if (hid==YES) {
            _hideButton = [[UIButton alloc]initWithFrame:CGRectZero];
            [_hideButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            [_hideButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _hideButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [_hideButton addTarget:self action:@selector(hidePassWord) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_hideButton];
            
            _line = [[UIView alloc]initWithFrame:CGRectZero];
            _line.backgroundColor = [UIColor lightGrayColor];
            [self addSubview:_line];
            
        }
    }
    return self;
}
-(void)hidePassWord{
    self.block();
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    
    _lab.frame =CGRectMake(0, 0, 4*20, CGRectGetHeight(self.frame)-lineWidth);
    _textField.frame = CGRectMake(_lab.frame.origin.x+_lab.frame.size.width+5, 0, CGRectGetWidth(self.frame)-_lab.frame.origin.x+_lab.frame.size.width+5, CGRectGetHeight(self.frame)-lineWidth);
    _lineView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-lineWidth, CGRectGetWidth(self.frame), lineWidth);
    _hideButton.frame = CGRectMake(CGRectGetWidth(self.frame)-85, 0, 85, 30);
    
    _line.frame = CGRectMake(CGRectGetWidth(self.frame)-90, 0, 1, 25);
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
