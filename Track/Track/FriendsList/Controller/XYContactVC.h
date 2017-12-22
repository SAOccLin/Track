//
//  XYContactVC.h
//  Track
//
//  Created by maralves on 16/9/4.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYContactVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *contactArr;
@property (strong, nonatomic) IBOutlet UILabel *warning;

-(void)getURLData;

@end
