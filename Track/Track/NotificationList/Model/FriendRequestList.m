//
//  FriendRequestList.m
//  Track
//
//  Created by apple on 2017/3/24.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "FriendRequestList.h"

@implementation FriendRequestList
-(void)saveFriendRequestList:(NSDictionary *)dic{
    self.appId = [NSString stringWithFormat:@"%@",dic[@"appId"]];
    self.cid = [NSString stringWithFormat:@"%@",dic[@"cid"]];
    self.name =[NSString stringWithFormat:@"%@请求添加你为好友",[dic valueForKey:@"name"]];
    self.portrait = [NSString stringWithFormat:@"%@",dic[@"portrait"]];
    self.userId = [NSString stringWithFormat:@"%@",dic[@"id"]];
    [[FMDBTool shareDataBase] insertFriendsRequest:self];
}
@end
