//
//  XYMainVC.m
//  Track
//
//  Created by Mac on 16/8/15.
//  Copyright © 2016年 Mac. All rights reserved.
//
#import "Reachability.h"
@interface XYMainVC ()
@property (nonatomic,strong) Reachability *hostReach;
@property (nonatomic,strong) XYNewsVC *locationVC;
@property (nonatomic,strong) XYMineVC *mineVC;
@property (nonatomic,strong) AFHTTPSessionManager *manage;
@property (nonatomic,assign) BOOL isFirstTime;


@end

@implementation XYMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //将导航栏透明化
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //去除玻璃层
    self.navigationController.navigationBar.translucent = YES;
    self.view.layer.contents = (id)[UIImage imageNamed:@"背景.jpg"].CGImage;
    
    //设置为半透明
    self.tabBarController.tabBar.translucent = YES;
    self.tabBar.backgroundColor = [UIColor clearColor];
    [[UITabBar appearance] setBackgroundImage:[UIImage new]];
    
    self.tabBar.translucent = YES;
    self.tabBar.layer.contents = (id)[UIImage new].CGImage;
    self.isFirstTime = YES;
   
    
    self.contactVC=[[XYContactVC alloc]init];
    [self setupChildViewControllers:self.contactVC WithTitle:@"好友" imageName:@"好友.png" selectedImageName:@"好友.png"];
    
    
    self.locationVC=[[XYNewsVC alloc]init];
    [self setupChildViewControllers:self.locationVC WithTitle:@"通知" imageName:@"message.png" selectedImageName:@"message.png"];
    
    self.mineVC=[[XYMineVC alloc]init];
    [self setupChildViewControllers:self.mineVC WithTitle:@"我" imageName:@"我.png" selectedImageName:@"我.png"];
    

    [self MonitorNotification];
    [self monitoringNetwork];
//    [self hsUpdateApp];

}
/**
 *  天朝专用检测app更新
 */
-(void)hsUpdateApp
{
    //2先获取当前工程项目版本号
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    
    //3从网络获取appStore版本号
    NSError *error;
    NSData *response = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",STOREAPPID]]] returningResponse:nil error:nil];
    if (response == nil) {
//        NSLog(@"你没有连接网络哦");
        return;
    }
    NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
//        NSLog(@"hsUpdateAppError:%@",error);
        return;
    }
    NSArray *array = appInfoDic[@"results"];
    NSDictionary *dic = array[0];
    NSString *appStoreVersion = dic[@"version"];
    //打印版本号
//    NSLog(@"当前版本号:%@\n商店版本号:%@",currentVersion,appStoreVersion);
    //4当前版本号小于商店版本号,就更新
    if([currentVersion floatValue] < [appStoreVersion floatValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"版本有更新" message:[NSString stringWithFormat:@"检测到新版本(%@),是否更新?",appStoreVersion] delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"更新",nil];
        [alert show];
    }else{
//        NSLog(@"版本号好像比商店大噢!检测到不需要更新");
    }
    
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //5实现跳转到应用商店进行更新
    if(buttonIndex==1)
    {
        //6此处加入应用在app store的地址，方便用户去更新，一种实现方式如下：
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@?ls=1&mt=8", STOREAPPID]];
        [[UIApplication sharedApplication] openURL:url];
    }
}
//监听通知
-(void)MonitorNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self.contactVC selector:@selector(getURLData) name:@"AddFriendSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.contactVC selector:@selector(getURLData) name:@"AgreeSuccess" object:nil];
    
    //返回添加好友信息
    [[NSNotificationCenter defaultCenter] addObserver:self.contactVC selector:@selector(getURLData) name:@"AddFriendReply" object:nil];

    //收到添加好友请求
    [[NSNotificationCenter defaultCenter] addObserver:self.locationVC selector:@selector(addFriendRequest:) name:@"AddFriendRequest" object:nil];
    
    //收到修改用户名通知
     [[NSNotificationCenter defaultCenter] addObserver:self.mineVC selector:@selector(getMessManage)name:@"changeSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideView) name:@"haveLocation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotHideView) name:@"haveNotLocation" object:nil];
}
-(void)hideView{
    self.tabBar.userInteractionEnabled = YES;
}
-(void)NotHideView{
    self.tabBar.userInteractionEnabled = NO;
}
//监听网络
-(void)monitoringNetwork{
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    self.hostReach = reach;
    [[NSNotificationCenter defaultCenter]addObserver:self  selector:@selector(netStatusChange:) name:kReachabilityChangedNotification object:nil];
    //实现监听
    [reach startNotifier];
}

//通知监听回调 网络状态发送改变 系统会发出一个kReachabilityChangedNotification通知，然后会触发此回调方法
- (void)netStatusChange:(NSNotification *)noti{
//    NSLog(@"-----%@",noti.userInfo);
    //判断网络状态
    switch (self.hostReach.currentReachabilityStatus) {
        case NotReachable:{
            self.contactVC.contactArr=nil;
            [self.contactVC.contactArr addObjectsFromArray:[[FMDBTool shareDataBase] selectFriendsList]];
            [self.contactVC.tableView reloadData];
            
            self.locationVC.friendsArry=nil;
            self.locationVC.positionArry=nil;
            [self.locationVC.friendsArry addObjectsFromArray:[[FMDBTool shareDataBase] selectFriendsRequest]];
            [self.locationVC.positionArry addObjectsFromArray:[[FMDBTool shareDataBase] selectLocationRequest]];
            [self.locationVC.tableView reloadData];
//            NSLog(@"网络不通1");
            break;
        }
        case ReachableViaWiFi:
        case ReachableViaWWAN:{
            if (self.isFirstTime == YES) {
                NSMutableArray *arr = [NSMutableArray array];
                [arr addObjectsFromArray:[[FMDBTool shareDataBase] selectPassWord]];
                if (arr.count != 0) {
                    PassWord *pass = arr[0];
                    if ([pass.online isEqualToString:@"NO"]) {
                        NSString *approveUrl = [NSString stringWithFormat:@"%@login/phone/%@/password/%@/appId/%@",MYURL,pass.name,pass.passWord,DeviceID];
                        approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                        NSLog(@"断网重连登陆接口：%@",approveUrl);
                        [self.manage POST:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
                            NSString *dd = [NSString stringWithFormat:@"%@",dict[@"status"]];
                            if ([dd isEqualToString:@"1"]) {
                                [self.locationVC getFriendRequest];
                                [[FMDBTool shareDataBase] updatePassWord:@"YES"];
                            }else{
                                [self prompt];
                            }
                        } failure:nil];
                    }
                }

                self.isFirstTime = NO;
                [[FMDBTool shareDataBase] deleteLocationRequest];
                //创建通知
                NSNotification *notification =[NSNotification notificationWithName:@"getLocation" object:nil userInfo:nil];
                //通过通知中心发送通知
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                [self.contactVC getURLData];
                [self.locationVC getFriendRequest];
            }
            break;
        }
        default:
            break;
    }
}

- (void)setupChildViewControllers:(UIViewController *)childView WithTitle:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
{
    childView.title=title;
    
    childView.tabBarItem.image= [UIImage imageNamed:imageName];
    [childView.tabBarItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childView.tabBarItem.selectedImage=[UIImage imageNamed:selectedImageName];
    [childView.tabBarItem.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    XYNavVC *nav=[[XYNavVC alloc]initWithRootViewController:childView];
    
    [self addChildViewController:nav];
}
//有后续的提示框
-(void)prompt{
    // 1.创建alert控制器
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"密码已被修改,请重新登录" preferredStyle:UIAlertControllerStyleAlert];
    // 2.添加按钮以及触发事件
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertVc addAction:action1];
    // 3.presentViewController弹出一个控制器
    [self presentViewController:alertVc animated:YES completion:^{
        LogonVC *VC = [[LogonVC alloc]init];
        [[FMDBTool shareDataBase] deletePassWord];
        [self presentViewController:VC animated:YES completion:nil];
    }];
}

-(AFHTTPSessionManager *)manage{
    if (!_manage) {
        _manage = [AFHTTPSessionManager manager];
        _manage.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manage.responseSerializer = [AFHTTPResponseSerializer serializer];
        //因AFNetworking 2.0开始格式有误，下面这句代码必须添加，否则有些格式无法识别
        _manage.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    }
    return _manage;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
