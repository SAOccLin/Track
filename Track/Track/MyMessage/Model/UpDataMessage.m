//
//  UpDataMessage.m
//  Track
//
//  Created by apple on 16/9/8.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "UpDataMessage.h"
#import "UIImageView+WebCache.h"
@implementation UpDataMessage
-(void)sdValue:(NSDictionary *)dic{
    self.userId = [NSString stringWithFormat:@"%@",[dic valueForKey:@"id"]];
    self.name = [NSString stringWithFormat:@"%@",[dic valueForKey:@"name"]];
    self.phone = [NSString stringWithFormat:@"%@",[dic valueForKey:@"phone"]];
    self.portrait = [NSString stringWithFormat:@"%@",[dic valueForKey:@"portrait"]];
//    self.company = [NSString stringWithFormat:@"%@",[dic valueForKey:@"company"]];
//    self.job = [NSString stringWithFormat:@"%@",[dic valueForKey:@"job"]];
    self.company = @"广州星弈";
    self.job = @"iOS";
    [[FMDBTool shareDataBase]insertMyMessage:self];
}
//空实现
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
