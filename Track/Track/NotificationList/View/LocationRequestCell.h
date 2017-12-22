//
//  LocationRequestCell.h
//  Track
//
//  Created by maralves on 16/9/4.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LocationRequestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userimage;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UIView *topLine;
@property (strong, nonatomic) IBOutlet UIView *bottonLine;




@end
