//
//  LocationRequestList.h
//  Track
//
//  Created by apple on 2017/3/24.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationRequestList : NSObject
@property (nonatomic,strong)NSString *userId;
@property (nonatomic,strong)NSString *index_id;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *time;

-(void)saveLocationRequestList:(NSDictionary *)dic;
@end
