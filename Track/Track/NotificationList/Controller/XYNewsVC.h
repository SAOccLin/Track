//
//  XYNewsVC.h
//  Track
//
//  Created by apple on 16/8/27.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYNewsVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *friendsArry;
@property (nonatomic,strong) NSMutableArray *positionArry;

-(void)getFriendRequest;
-(void)addFriendRequest:(NSNotification *)data;

@end
