//
//  XYMineVC.h
//  Track
//
//  Created by Mac on 16/8/15.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XYMineVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *headView;
@property (nonatomic,strong)NSMutableArray *MyMessage;
@property (weak, nonatomic) IBOutlet UITableView *mineTv;
@property (strong, nonatomic) IBOutlet UIButton *userName;


-(void)getMessManage;
@end
