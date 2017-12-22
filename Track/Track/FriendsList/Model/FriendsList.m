//
//  FriendsList.m
//  Track
//
//  Created by apple on 16/9/5.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "FriendsList.h"
#import "UIImageView+WebCache.h"
@implementation FriendsList
-(void)stValue:(NSDictionary *)dic{
    
    self.appId = [NSString stringWithFormat:@"%@",[dic valueForKey:@"appId"]];
    self.cid = [NSString stringWithFormat:@"%@",[dic valueForKey:@"cid"]];
    self.userId = [NSString stringWithFormat:@"%@",[dic valueForKey:@"id"]];
    self.name = [NSString stringWithFormat:@"%@",[dic valueForKey:@"name"]];
    self.portrait = [NSString stringWithFormat:@"%@",[dic valueForKey:@"portrait"]];
    [[FMDBTool shareDataBase] insertFriendsList:self];
    }
//空实现
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
