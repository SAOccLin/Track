//
//  NotificationButton.h
//  Track
//
//  Created by apple on 2016/11/14.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationButton : UIButton

@property (nonatomic,strong)UIImageView *imageV;
-(instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)imageName labText:(NSString *)labText;

-(void)upDataImage:(UIImage*)image;
@end
