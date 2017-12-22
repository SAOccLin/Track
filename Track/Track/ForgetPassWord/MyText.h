//
//  MyText.h
//  Track
//
//  Created by apple on 2016/11/12.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^sendBlock)();
@interface MyText : UIView
//文本框
@property (nonatomic,strong) UITextField *textField;

//光标颜色
@property (nonatomic,strong) UIColor *cursorColor;


@property (nonatomic,copy)sendBlock block;
-(instancetype)initWithFrame:(CGRect)frame hidden:(BOOL)hid name:(NSString *)name;
@end
