//
//  FriendsList.h
//  Track
//
//  Created by apple on 16/9/5.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FriendsList : NSObject

@property (nonatomic,strong)NSString *appId;
@property (nonatomic,strong)NSString *cid;
@property (nonatomic,strong)NSString *userId;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *portrait;

-(void)stValue:(NSDictionary *)dic;
@end
