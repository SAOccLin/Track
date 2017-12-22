//
//  AppDelegate.m
//  Track
//
//  Created by Mac on 16/8/15.
//  Copyright © 2016年 Mac. All rights reserved.
//


#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "AvoidCrash.h"

@interface AppDelegate ()<MKMapViewDelegate>
@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)NSString *requestId;
@property (nonatomic,strong)AFHTTPSessionManager *manage;
@property (nonatomic,strong)Reachability *hostReach;
@property (nonatomic,strong)NSDictionary *app;
@property (nonatomic,assign)BOOL loginAppkey;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,assign)NSTimeInterval lastTime;
@property (nonatomic,assign)NSInteger i;
@property (nonatomic,strong)CLCircularRegion *fkit;
@property (nonatomic,strong)CLCircularRegion *fkit2;
@property (nonatomic,strong)XYMainVC *MVC;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.app =[NSDictionary dictionaryWithDictionary:launchOptions];

    //启动防止崩溃功能
//    [AvoidCrash becomeEffective];
    _loginAppkey = NO;
    [self monitoringNetwork];
    
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLocation)name:@"getLocation" object:nil];
    
    //数据库存放路径
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObjectsFromArray:[[FMDBTool shareDataBase] selectPassWord]];
    if (arr.count != 0) {
        PassWord *pswd = arr[0];
        NSString *approveUrl = [NSString stringWithFormat:@"%@login/phone/%@/password/%@/appId/%@",MYURL,pswd.name,pswd.passWord,DeviceID];
        
        approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSLog(@"自动登录接口地址:%@",approveUrl);
        [self.manage POST:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
            NSLog(@"自动登录返回信息：%@",dict);
            NSString *dd = [NSString stringWithFormat:@"%@",dict[@"status"]];
            if ([dd isEqualToString:@"1"]) {
                self.MVC = [[XYMainVC alloc]init];
                [[FMDBTool shareDataBase] deleteMyMessage];
                UpDataMessage *message=[[UpDataMessage alloc]init];
                [message sdValue:dict];
                [[FMDBTool shareDataBase] updatePassWord:@"YES"];
                [self getLocation];
                _window.rootViewController = self.MVC;
                [self.window makeKeyAndVisible];
            }else{
                LogonVC *logonVC = [[LogonVC alloc]init];
                _window.rootViewController = logonVC;
                [self.window makeKeyAndVisible];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[FMDBTool shareDataBase] updatePassWord:@"NO"];
            self.MVC = [[XYMainVC alloc]init];
            _window.rootViewController = self.MVC;
            [self.window makeKeyAndVisible];
        }];
    }else{
        LogonVC *logonVC = [[LogonVC alloc]init];
        _window.rootViewController = logonVC;
        [self.window makeKeyAndVisible];
    }
    
    //  如果你期望使用交互式(只有iOS 8.0及以上有)的通知，请参考下面注释部分的初始化代码
//    register remoteNotification types （iOS 8.0及其以上版本）
//    UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
//    action1.identifier = @"action1_identifier";
//    action1.title=@"Accept";
//    action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
//    
//    UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
//    action2.identifier = @"action2_identifier";
//    action2.title=@"Reject";
//    action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
//    action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
//    action2.destructive = YES;
//    
//    UIMutableUserNotificationCategory *actionCategory = [[UIMutableUserNotificationCategory alloc] init];
//    actionCategory.identifier = @"category1";//这组动作的唯一标示
//    [actionCategory setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
//    
//    NSSet *categories = [NSSet setWithObject:actionCategory];
    
//    如果默认使用角标，文字和声音全部打开，请用下面的方法
//    [UMessage registerForRemoteNotifications:categories];
    
//    如果对角标，文字和声音的取舍，请用下面的方法
//    UIRemoteNotificationType types7 = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
//    UIUserNotificationType types8 = UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge;
//    [UMessage registerForRemoteNotifications:categories withTypesForIos7:types7 withTypesForIos8:types8];
    
    return YES;
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
//            NSLog(@"网络不通3");
            break;
        }
        case ReachableViaWiFi:
        case ReachableViaWWAN:{
            if (_loginAppkey==NO) {
                //初始化应用，appKey和appSecret从后台申请得
                [SMSSDK registerApp:@"1245e4c892c04"
                         withSecret:@"f7117e1d6c81a30c758e5db1de1eeb47"];

                //设置 AppKey 及 LaunchOptions
                //公司的
                [UMessage startWithAppkey:@"57c3fc82e0f55a60930001ab" launchOptions:self.app];
                //自己的
//                [UMessage startWithAppkey:@"57da77d767e58eefa6004f62" launchOptions:self.app];
                //1.3.0版本开始简化初始化过程。如不需要交互式的通知，下面用下面一句话注册通知即可。
                [UMessage registerForRemoteNotifications];
                [UMessage setLogEnabled:YES];
                //添加Alias
                [UMessage addAlias:DeviceID type:@"appid" response:nil];
                NSLog(@"%@",DeviceID);
                _loginAppkey =YES;
        }
            break;
        }
        default:
            break;
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"%@",deviceToken);
    // 1.2.7版本开始不需要用户再手动注册devicetoken，SDK会自动注册
    [UMessage registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [UMessage didReceiveRemoteNotification:userInfo];
}
//当接收到静默推送时执行
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"收到的推送内容%@",userInfo);
    NSDictionary *aps=userInfo[@"aps"];
    NSArray *ask = [aps[@"ask"] componentsSeparatedByString:@":"];
    
    NSArray *approve = [aps[@"approve"] componentsSeparatedByString:@":"];

    if(ask.count==2){//收到请求好友信息
        NSDictionary *dic = @{@"name":ask[1],@"id":ask[0]};
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:@"AddFriendRequest" object:nil userInfo:dic];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }else if(approve.count==2){//返回请求好友信息
        NSNotification *notification =[NSNotification notificationWithName:@"AddFriendReply" object:nil userInfo:nil];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }else if(userInfo[@"delete"]!=nil){
        NSNotification *notification =[NSNotification notificationWithName:@"AddFriendReply" object:nil userInfo:nil];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}
//开始定位
-(void)getLocation{
    // 开始定位
    [self.locationManager startUpdatingLocation];
}
//获取当前定位位置信息
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    [self.locationManager stopUpdatingLocation];
//    self.locationManager=nil;
    //  获取当前位置信息
    CLLocation *locationC = locations.lastObject;
    
    //更新地理围栏中心
    [self UpDateCircular:locationC.coordinate.latitude longitude:locationC.coordinate.longitude];
    CLLocationCoordinate2D sss = CLLocationCoordinate2DMake(locationC.coordinate.latitude, locationC.coordinate.longitude);
    sss = [LocationChange wgs84ToBd09:sss];
    
    self.latitude = sss.latitude;
    self.longitude = sss.longitude;
    [self uploadLocation];
}
//当定位发生错误时调用
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"定位错误原因:%@",error);
}
//网络请求,上传自己的地理位置
-(void)uploadLocation{
    NSDate *date =[NSDate dateWithTimeIntervalSinceNow:0];
     NSTimeInterval a = [date timeIntervalSince1970];
    //如果两次上传时间大于5秒就上传
    NSLog(@"%f,%f",a-self.lastTime,a);
    if (a-self.lastTime>20) {
        self.lastTime= a;
        NSString *longitude = [NSString stringWithFormat:@"%f:",self.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%f",self.latitude];
        self.content = [longitude stringByAppendingString:latitude];

        self.url = [NSString stringWithFormat:@"http://api.sunsyi.com:8081/Position/responsePosition/id/0/position/%@/appid/%@",self.content,DeviceID];
        self.url= [self.url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSLog(@"上传地址%@",self.url);
    
        [self.manage GET:self.url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSLog(@"上传地理位置返回数据：%@",[NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil]);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"上传地理位置失败");
        }];
    }
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
-(CLLocationManager *)locationManager{
    if (!_locationManager) {
        // 初始化定位管理器
        _locationManager = [[CLLocationManager alloc] init];
        // 设置代理
        _locationManager.delegate = self;
        // 设置定位精确度到米
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 设置过滤器为无
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        //这句话ios8以上版本使用。
        [_locationManager requestAlwaysAuthorization];
        //运行后台定位
        _locationManager.allowsBackgroundLocationUpdates = YES;
        //禁止App暂停定位
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        [_locationManager startMonitoringSignificantLocationChanges];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkLocationPermissions) userInfo:nil repeats:YES];
    }
    return _locationManager;
}
//检查定位权限
-(void)checkLocationPermissions{
    if ([CLLocationManager locationServicesEnabled] && ( [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:@"haveLocation" object:nil userInfo:nil];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        //定位功能可用
    }else{
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:@"haveNotLocation" object:nil userInfo:nil];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}
//进入了围栏
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"进入围栏的属性：%@",region);
    [self getLocation];
    self.i++;
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    manage.requestSerializer = [AFHTTPRequestSerializer serializer];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    //因AFNetworking 2.0开始格式有误，下面这句代码必须添加，否则有些格式无法识别
    manage.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *approveUrl = [NSString stringWithFormat:@"http://api.sunsyi.com:8081/app/reg/appid/12345678901234567890123456789012345%ld",(long)self.i];
    approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:
                 [NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"记录进入地理围栏地址：%@",approveUrl);
    [manage POST:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"记录成功");
    } failure:nil];
    NSLog(@"进入了围栏");
  
}
//离开了围栏
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    NSLog(@"离开围栏的属性：%@",region);
    [self getLocation];
    self.i++;
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    manage.requestSerializer = [AFHTTPRequestSerializer serializer];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    //因AFNetworking 2.0开始格式有误，下面这句代码必须添加，否则有些格式无法识别
    manage.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *approveUrl = [NSString stringWithFormat:@"http://api.sunsyi.com:8081/app/reg/appid/12345678901234567890123456789012345%ld",(long)self.i];
    approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:
                 [NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"记录离开地理围栏地址：%@",approveUrl);
    [manage POST:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"离开成功");
    } failure:nil];
    NSLog(@"离开了围栏");
   
}



-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}
-(void)UpDateCircular:(double)latitude longitude:(double)longitude{
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]){
        CLLocationCoordinate2D companyCenter;
        companyCenter.latitude = latitude;
        companyCenter.longitude = longitude;
        // 使用CLCircularRegion创建两个圆形区域，一个半径为30米,另一个半径80米
        self.fkit = nil;
        self.fkit2 = nil;
        self.fkit = [[CLCircularRegion alloc] initWithCenter:companyCenter radius:100 identifier:@"MDZZ"];
        self.fkit2 = [[CLCircularRegion alloc] initWithCenter:companyCenter radius:80 identifier:@"MDZZ2"];
        //监测这个区域
        [self.locationManager startMonitoringForRegion:self.fkit];
//        [self.locationManager startMonitoringForRegion:self.fkit2];
        //进入/离开区域调用协议方法
        [self.locationManager requestStateForRegion:self.fkit];
//        [self.locationManager requestStateForRegion:self.fkit2];
    }else{
        NSLog(@"不能用");
    }

}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
