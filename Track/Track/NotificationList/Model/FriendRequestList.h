//
//  FriendRequestList.h
//  Track
//
//  Created by apple on 2017/3/24.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendRequestList : NSObject
@property (nonatomic,strong)NSString *appId;
@property (nonatomic,strong)NSString *cid;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *portrait;
@property (nonatomic,strong)NSString *userId;

-(void)saveFriendRequestList:(NSDictionary *)dic;
@end
