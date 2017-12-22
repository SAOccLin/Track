//
//  LocationRequestList.m
//  Track
//
//  Created by apple on 2017/3/24.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "LocationRequestList.h"

@implementation LocationRequestList
-(void)saveLocationRequestList:(NSDictionary *)dic{
    self.userId = [NSString stringWithFormat:@"%@",dic[@"id"]];
    self.index_id = [NSString stringWithFormat:@"%@",dic[@"index_id"]];
    self.name = [NSString stringWithFormat:@"%@正在查看你的位置",dic[@"name"]];
    self.time = [NSString stringWithFormat:@"%@",dic[@"time"]];
    NSDate *nowDate =[NSDate dateWithTimeIntervalSince1970:[self.time integerValue]];
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc]init];
    dataFormatter.dateFormat = @"YYYY-MM-dd hh:mm:ss";
    self.time = [dataFormatter stringFromDate:nowDate];
    [[FMDBTool shareDataBase] insertLocationRequest:self];
}
@end
