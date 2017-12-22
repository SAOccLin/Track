//
//  FriendRequestCell.h
//  Track
//
//  Created by maralves on 16/9/4.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^acceptBlock)(NSString *);
@interface FriendRequestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *RequestImage;

@property (weak, nonatomic) IBOutlet UIButton *accept;
@property (strong, nonatomic) IBOutlet UILabel *lab;

@property (nonatomic,copy)acceptBlock acBlock;
@property (nonatomic,strong)NSString *userId;


@end
