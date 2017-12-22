//
//  FMDBTool.h
//  NetWorkTool
//
//  Created by lanou on 16/5/23.
//  Copyright © 2016年 zxl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FriendsList.h"
#import "FriendRequestList.h"
#import "LocationRequestList.h"
#import "UpDataMessage.h"
#import "PassWord.h"

@interface FMDBTool : NSObject

/**单例 */
+ (instancetype)shareDataBase;

//写入好友列表
- (void)insertFriendsList:(FriendsList *)model;
//搜素好友列表
-(NSArray *)selectFriendsList;
-(NSArray *)selectFriendsList:(NSString *)userId;
//删除好友列表
- (void)deleteFriendsList;

//写入请求好友信息列表
- (void)insertFriendsRequest:(FriendRequestList *)model;
//搜素请求好友信息列表
-(NSArray *)selectFriendsRequest;
//删除指定好友请求信息
-(void)deleteFriendsRequest:(FriendRequestList *)model;
//删除好友请求列表
- (void)deleteFriendsRequest;


//写入位置请求信息列表
- (void)insertLocationRequest:(LocationRequestList *)model;
//搜素位置请求信息列表
-(NSArray *)selectLocationRequest;
//删除指定位置请求信息
-(void)deleteLocationRequest:(LocationRequestList *)model;
//删除位置请求列表
- (void)deleteLocationRequest;

//搜素个人信息
-(NSArray *)selectMyMessage;
//修改用户名
-(void)upDateMyMessage:(NSString *)name;
//写入个人信息列表
- (void)insertMyMessage:(UpDataMessage *)model;
//删除个人信息
- (void)deleteMyMessage;

//写入个人账号
-(void)insertPassWord:(PassWord *)model;
//搜素个人账号
-(NSArray *)selectPassWord;
//更新个人账号
-(void)updatePassWord:(NSString *)online;
//删除个人账号
-(void)deletePassWord;
@end
