//
//  WSTextField.m
//  封装输入框demo
//
//  Created by iMac on 16/8/25.
//  Copyright © 2016年 sinfotek. All rights reserved.
//

#import "WSTextField.h"

#define padding 5
#define heightSpaceing 2

@interface WSTextField()<UITextFieldDelegate>



//注释
@property (nonatomic,strong) UILabel *placeholderLabel;

//线
@property (nonatomic,strong) UIView *lineView;

//填充线
@property (nonatomic,strong) CALayer *lineLayer;

//移动一次
@property (nonatomic,assign) BOOL moved;
//隐藏按钮
@property (nonatomic,strong)UIButton *hideButton;

@end


@implementation WSTextField

static const CGFloat lineWidth = 1;

-(instancetype)initWithFrame:(CGRect)frame hidden:(BOOL)hid{
    if(self = [super initWithFrame:frame]){
        
        _textField = [[UITextField alloc]initWithFrame:CGRectZero];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.font = [UIFont systemFontOfSize:15.f];
        _textField.textColor = [UIColor whiteColor];
        _textField.tintColor = [UIColor whiteColor];
        _textField.delegate = self;
        [self addSubview:_textField];
        
        _placeholderLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _placeholderLabel.font = [UIFont systemFontOfSize:15.f];
        [self addSubview:_placeholderLabel];
        
        _lineView = [[UIView alloc]initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
        [self addSubview:_lineView];
        
        _lineLayer = [CALayer layer];
        _lineLayer.frame = CGRectMake(0,0, 0, lineWidth);
        _lineLayer.anchorPoint = CGPointMake(0, 0.5);
        [_lineView.layer addSublayer:_lineLayer];
        
        if (hid==YES) {
            _hideButton = [[UIButton alloc]initWithFrame:CGRectZero];
            _hideButton.layer.contents = (id)[UIImage imageNamed:@"隐藏密码.png"].CGImage;
            self.textField.secureTextEntry = YES;
            [_hideButton addTarget:self action:@selector(hidePassWord) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_hideButton];
        }
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(obserValue:) name:UITextFieldTextDidChangeNotification object:_textField];
        
    }
    return self;
}
-(void)hidePassWord{
    NSLog(@"123");
    if (self.textField.secureTextEntry == YES) {
        _hideButton.layer.contents = (id)[UIImage imageNamed:@"显示密码.png"].CGImage;
        self.textField.secureTextEntry = NO;
    }else{
        _hideButton.layer.contents = (id)[UIImage imageNamed:@"隐藏密码.png"].CGImage;
        self.textField.secureTextEntry = YES;
    }
}
-(void)layoutSubviews{
    [super layoutSubviews];
    _placeholderLabel.textColor = [UIColor whiteColor];
    
    _textField.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-lineWidth);
    _placeholderLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-lineWidth);
    _lineView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-lineWidth, CGRectGetWidth(self.frame), lineWidth);
    _hideButton.frame = CGRectMake(CGRectGetWidth(self.frame)-30, 0, 30, 30);
}

-(void)obserValue:(NSNotification *)obj{
    [self changeFrameOfPlaceholder];
}

-(void)changeFrameOfPlaceholder{
    
    CGFloat y = _placeholderLabel.center.y;
    CGFloat x = _placeholderLabel.center.x;
    if(_textField.text.length != 0 && !_moved){
        [self moveAnimation:x y:y];
    }else if(_textField.text.length == 0 && _moved){
        [self backAnimation:x y:y];
    }
}

-(void)moveAnimation:(CGFloat)x y:(CGFloat)y{
    __block CGFloat moveX = x;
    __block CGFloat moveY = y;
    
    _placeholderLabel.font = [UIFont systemFontOfSize:14.f];
    _placeholderLabel.textColor = _placeholderSelectStateColor?_placeholderSelectStateColor:[UIColor whiteColor];

    [UIView animateWithDuration:0.15 animations:^{
        moveY -= _placeholderLabel.frame.size.height/2 + heightSpaceing;
        moveX -= padding;
        _placeholderLabel.center = CGPointMake(moveX, moveY);
        _placeholderLabel.alpha = 1;
        _moved = YES;
        _lineLayer.bounds = CGRectMake(0, 0, CGRectGetWidth(self.frame), lineWidth);
    }];
}

-(void)backAnimation:(CGFloat)x y:(CGFloat)y{
    __block CGFloat moveX = x;
    __block CGFloat moveY = y;
    
    _placeholderLabel.font = [UIFont systemFontOfSize:13.f];
    _placeholderLabel.textColor = _placeholderNormalStateColor?_placeholderNormalStateColor:[UIColor whiteColor];

    [UIView animateWithDuration:0.15 animations:^{
        moveY += _placeholderLabel.frame.size.height/2 + heightSpaceing;
        moveX += padding;
        _placeholderLabel.center = CGPointMake(moveX, moveY);
        _placeholderLabel.alpha = 1;
        _moved = NO;
        _lineLayer.bounds = CGRectMake(0, 0, 0, lineWidth);
    }];
}

-(void)setLy_placeholder:(NSString *)ly_placeholder{
    _ly_placeholder = ly_placeholder;
    _placeholderLabel.text = ly_placeholder;
}
-(void)setCursorColor:(UIColor *)cursorColor{
    _textField.tintColor = cursorColor;
}

@end
