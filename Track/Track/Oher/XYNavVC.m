//
//  XYNavVC.m
//  Track
//
//  Created by Mac on 16/8/15.
//  Copyright © 2016年 Mac. All rights reserved.
//



@interface XYNavVC ()

@end

@implementation XYNavVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.translucent = NO;
    [[UINavigationBar appearance]setBarTintColor:[UIColor colorWithRed:0.164 green:0.657 blue:0.915 alpha:1.000]];
    
    
}
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.childViewControllers.count > 0)
    {
        //隐藏tabBar
        [viewController setHidesBottomBarWhenPushed:YES];
    }
    [super pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
