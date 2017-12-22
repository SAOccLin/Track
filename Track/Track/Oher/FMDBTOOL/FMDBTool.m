//
//  FMDBTool.m
//  NetWorkTool
//
//  Created by lanou on 16/5/23.
//  Copyright © 2016年 zxl. All rights reserved.
//


#import "FMDBTool.h"

@interface FMDBTool ()

@property(nonatomic,strong)FMDatabase *db;

@end


@implementation FMDBTool

//单例
+ (instancetype)shareDataBase{
    static FMDBTool *tool = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        tool = [[FMDBTool alloc]init];
    });
    return tool;
}
//初始化创建数据库
- (instancetype)init{
    self = [super init];
    if (self) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        NSString *docuPath = [path stringByAppendingPathComponent:@"Track.sqlite"];
        NSLog(@"%@",docuPath);
        _db = [[FMDatabase alloc]initWithPath:docuPath];
        [_db open];
        BOOL success1 = [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS FriendsList (appId text not null,cid text,userId text, name TEXT,portrait text)"];
         
         if (success1) {
             NSLog(@"创建好友列表成功");
         } else {
             NSLog(@"创建好友列表失败");
         }
        BOOL success2 = [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS  FriendsRequest (appId text not null,cid TEXT ,name text,portrait text,userId text)"];
        
        if (success2) {
            NSLog(@"创建好友申请列表成功");
        } else {
            NSLog(@"创建好友申请列表失败");
        }
        BOOL success3 = [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS  LocationRequest (userId text not null, index_id text,name TEXT ,time text)"];
        
        if (success3) {
            NSLog(@"创建位置请求列表成功");
        } else {
            NSLog(@"创建位置请求列表失败");
        }
        BOOL success4 = [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS MyMessage (userId text not null, name TEXT , phone text ,portrait text,company text,job text)"];
        
        if (success4) {
            NSLog(@"创建个人信息列表成功");
        } else {
            NSLog(@"创建个人信息列表失败");
        }
        BOOL success5 = [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS PassWord ( name TEXT , passWord text, online text)"];
        if (success5) {
            NSLog(@"创建账号密码列表成功");
        } else {
            NSLog(@"创建账号密码列表失败");
        }
        [_db close];
    }
    return self;
}

//写入好友列表
- (void)insertFriendsList:(FriendsList *)model{
    [self.db open];
    BOOL resut =[self.db executeStatements:[NSString stringWithFormat:@"insert into FriendsList values('%@','%@','%@','%@','%@');",model.appId,model.cid,model.userId,model.name,model.portrait]];
    if (resut==YES) {
        NSLog(@"写入好友列表成功");
    }else{
        NSLog(@"写入好友列表失败");
    }
    [self.db close];
}

//搜素好友列表
-(NSArray *)selectFriendsList{
    [_db open];
    FMResultSet *set = [self.db executeQuery:@"SELECT *FROM FriendsList;"];
    NSArray *arr = [NSArray array];
    while ([set next]) {
        FriendsList *an = [[FriendsList alloc]init];
        an.appId = [set objectForColumnName:@"appId"];
        an.cid = [set objectForColumnName:@"cid"];
        an.userId = [set objectForColumnName:@"userId"];
        an.name = [set objectForColumnName:@"name"];
        an.portrait = [set objectForKeyedSubscript:@"portrait"];
        arr = [arr arrayByAddingObject:an];
    }
    [self.db close];
    return arr;
}
//寻找指定好友
-(NSArray *)selectFriendsList:(NSString *)userId{
    [_db open];
    FMResultSet *set = [self.db executeQuery:[NSString stringWithFormat:@"SELECT *FROM FriendsList where userId = '%@';",userId]];
    NSArray *arr = [NSArray array];
    while ([set next]) {
        FriendsList *an = [[FriendsList alloc]init];
        an.appId = [set objectForColumnName:@"appId"];
        an.cid = [set objectForColumnName:@"cid"];
        an.userId = [set objectForColumnName:@"userId"];
        an.name = [set objectForColumnName:@"name"];
        an.portrait = [set objectForKeyedSubscript:@"portrait"];
        arr = [arr arrayByAddingObject:an];
    }
    [self.db close];
    return arr;
}

//删除好友列表数据
- (void)deleteFriendsList{
    [self.db open];
    BOOL resut = [self.db executeStatements:[NSString stringWithFormat:@"DELETE FROM FriendsList"]];
    if (resut==YES) {
        NSLog(@"删除好友列表成功");
    }else{
        NSLog(@"删除好友列表失败");
    }
    [self.db close];
}

//写入好友申请列表
- (void)insertFriendsRequest:(FriendRequestList *)model{
    [self.db open];
    BOOL resut = [self.db executeStatements:[NSString stringWithFormat:@"insert into FriendsRequest values('%@','%@','%@','%@','%@');",model.appId,model.cid,model.name,model.portrait,model.userId]];
    if (resut==YES) {
        NSLog(@"写入好友申请列表成功");
    }else{
        NSLog(@"写入好友申请列表失败");
    }
    [self.db close];

}

//搜素好友申请列表
-(NSArray *)selectFriendsRequest{
    [_db open];
    FMResultSet *set = [_db executeQuery:@"select *from FriendsRequest;"];
    NSArray *arr = [NSArray array];
    while ([set next]) {
        FriendRequestList *an = [[FriendRequestList alloc]init];
        an.appId = [set objectForColumnName:@"appId"];
        an.cid = [set objectForColumnName:@"cid"];
        an.name = [set objectForColumnName:@"name"];
        an.portrait = [set objectForKeyedSubscript:@"portrait"];
        an.userId = [set objectForKeyedSubscript:@"userId"];
        arr = [arr arrayByAddingObject:an];
    }
    [self.db close];
    return arr;
}
//删除指定好友申请
-(void)deleteFriendsRequest:(FriendRequestList *)model{
    [self.db open];
    BOOL resut = [self.db executeStatements:[NSString stringWithFormat:@"delete from FriendsRequest where appId = '%@' and userId = '%@';",model.appId,model.userId]];
    if (resut==YES) {
        NSLog(@"删除指定好友申请成功");
    }else{
        NSLog(@"删除指定好友申请失败");
    }
    [self.db close];
}

//删除好友申请列表
- (void)deleteFriendsRequest{
    [self.db open];
    BOOL resut = [self.db executeStatements:[NSString stringWithFormat:@"DELETE FROM FriendsRequest"]];
    if (resut==YES) {
        NSLog(@"删除好友申请列表成功");
    }else{
        NSLog(@"删除好友申请列表失败");
    }
    [self.db close];
}

//写入位置请求信息列表
- (void)insertLocationRequest:(LocationRequestList *)model{
    [self.db open];
    BOOL resut = [self.db executeStatements:[NSString stringWithFormat:@"insert into LocationRequest values('%@','%@','%@','%@');",model.userId,model.index_id,model.name,model.time]];
    if (resut == YES) {
        NSLog(@"写入位置请求信息列表成功");
    }else{
        NSLog(@"写入位置请求信息列表失败");
    }
    [self.db close];
    
}

//搜素位置请求信息列表
-(NSArray *)selectLocationRequest{
    [_db open];
    FMResultSet *set = [_db executeQuery:@"select *from LocationRequest;"];
    NSArray *arr = [NSArray array];
    while ([set next]) {
        LocationRequestList *an = [[LocationRequestList alloc]init];
        an.userId = [set objectForColumnName:@"userId"];
        an.index_id = [set objectForColumnName:@"index_id"];
        an.name = [set objectForColumnName:@"name"];
        an.time = [set objectForKeyedSubscript:@"time"];
        arr = [arr arrayByAddingObject:an];
    }
    [self.db close];
    return arr;
}

//删除指定位置请求信息
-(void)deleteLocationRequest:(LocationRequestList *)model{
    [self.db open];
    BOOL resut = [self.db executeStatements:[NSString stringWithFormat:@"delete from LocationRequest where userId = '%@' and time = '%@';",model.userId,model.time]];
    if (resut==YES) {
        NSLog(@"删除指定位置请求信息成功");
    }else{
        NSLog(@"删除指定位置请求信息失败");
    }
    [self.db close];
}

//删除位置请求列表
- (void)deleteLocationRequest{
    [self.db open];
    BOOL resut = [self.db executeStatements:[NSString stringWithFormat:@"DELETE FROM LocationRequest"]];
    if (resut==YES) {
        NSLog(@"删除位置请求列表成功");
    }else{
        NSLog(@"删除位置请求列表失败");
    }
    [self.db close];
}


//写入个人信息列表
- (void)insertMyMessage:(UpDataMessage *)model{
    [self.db open];
    BOOL resut = [self.db executeStatements:[NSString stringWithFormat:@"insert into MyMessage values('%@','%@','%@','%@','%@','%@');",model.userId,model.name,model.phone,model.portrait,model.company,model.job]];
    if (resut==YES) {
           NSLog(@"写入个人信息列表成功");
    }else{
           NSLog(@"写入个人信息列表失败");
    }
    [self.db close];
}
//修改用户名
-(void)upDateMyMessage:(NSString *)name{
    [_db open];
   BOOL resut = [_db executeUpdate:[NSString stringWithFormat:@"update MyMessage set name = '%@';",name]];
    if (resut==YES) {
        NSLog(@"修改用户名成功");
    }else{
        NSLog(@"修改用户名失败");
    }
    [_db close];
}

//搜素个人信息
-(NSArray *)selectMyMessage{
    [_db open];
    FMResultSet *set = [_db executeQuery:@"select *from MyMessage;"];
    NSArray *arr = [NSArray array];
    while ([set next]) {
        UpDataMessage *an = [[UpDataMessage alloc]init];
        an.userId = [set objectForColumnName:@"userId"];
        an.name = [set objectForColumnName:@"name"];
        an.phone = [set objectForKeyedSubscript:@"phone"];
        an.portrait = [set objectForKeyedSubscript:@"portrait"];
        an.company = [set objectForKeyedSubscript:@"company"];
        an.job = [set objectForKeyedSubscript:@"job"];
        arr = [arr arrayByAddingObject:an];
    }
    [self.db close];
    return arr;
    
}
//删除请求列表
- (void)deleteMyMessage{
    [self.db open];
    BOOL resut = [self.db executeStatements:[NSString stringWithFormat:@"DELETE FROM MyMessage"]];
    if (resut==YES) {
        NSLog(@"删除个人信息列表成功");
    }else{
        NSLog(@"删除个人信息列表失败");
    }
    [self.db close];
}

//写入个人账号密码
-(void)insertPassWord:(PassWord *)model{
    [self.db open];
    BOOL resut = [self.db executeStatements:[NSString stringWithFormat:@"insert into PassWord values('%@','%@','%@');",model.name,model.passWord,model.online]];
    if (resut==YES) {
        NSLog(@"写入账号密码列表成功");
    }else{
        NSLog(@"写入账号密码列表失败");
    }
    [self.db close];
}
//搜素个人账号密码
-(NSArray *)selectPassWord{
    [_db open];
    FMResultSet *set = [_db executeQuery:@"select *from PassWord;"];
    NSArray *arr = [NSArray array];
    while ([set next]) {
        PassWord *an = [[PassWord alloc]init];;
        an.name = [set objectForColumnName:@"name"];
        an.passWord = [set objectForColumnName:@"passWord"];
        an.online = [set objectForColumnName:@"online"];
        arr = [arr arrayByAddingObject:an];
    }
    [self.db close];
    return arr;
}

//更新个人账号
-(void)updatePassWord:(NSString *)online{
    [_db open];
    BOOL resut = [_db executeUpdate:[NSString stringWithFormat:@"update MyMessage set online = '%@';",online]];
    if (resut==YES) {
        NSLog(@"修改登录状态成功");
    }else{
        NSLog(@"修改登录状态失败");
    }
    [_db close];
}
//删除个人账号密码
-(void)deletePassWord{
    [self.db open];
    BOOL resut = [self.db executeStatements:[NSString stringWithFormat:@"DELETE FROM PassWord"]];
    if (resut==YES) {
        NSLog(@"删除账号密码列表成功");
    }else{
        NSLog(@"删除账号密码列表失败");
    }
    [self.db close];
}

@end
