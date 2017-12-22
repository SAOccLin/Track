//
//  UpDataMessage.h
//  Track
//
//  Created by apple on 16/9/8.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface UpDataMessage : NSObject
@property (nonatomic,strong)NSString *userId;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *phone;
@property (nonatomic,strong)NSString *portrait;//图片网址
@property (nonatomic,strong)NSString *company;
@property (nonatomic,strong)NSString *job;




-(void)sdValue:(NSDictionary *)dic;
@end
