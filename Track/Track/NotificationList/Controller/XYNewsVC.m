//
//  XYNewsVC.m
//  Track
//
//  Created by apple on 16/8/27.
//  Copyright © 2016年 Mac. All rights reserved.
//


#import "LocationRequestCell.h"
#import "FriendRequestCell.h"
#import "FriendsList.h"
#import "LocationRequestList.h"
#import "FriendRequestList.h"

@interface XYNewsVC ()

@property (nonatomic,strong) NSMutableArray *positionArry2;
@property (nonatomic,strong) NSMutableArray *friendsArry2;

@property (nonatomic,strong) AFHTTPSessionManager *manage;

@property (nonatomic,strong)NSURLSessionDataTask *post;

@property(nonatomic,assign) BOOL isRequesting;//是否正确请求

@property (nonatomic,assign)BOOL isOpenFriends;
@property (nonatomic,assign)BOOL isOpenLocation;

@property (nonatomic,strong)NotificationButton *button1;
@property (nonatomic,strong)NotificationButton *button2;

@property (nonatomic,strong)UIView *warningView;
@property (nonatomic,assign)NSInteger listNumber;
@end

@implementation XYNewsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.listNumber = 0;
    self.isOpenFriends = YES;
    self.isOpenLocation = YES;
    setNav;
    [self setTableview];
}
-(void)setTableview{
    _tableView.backgroundColor = [UIColor clearColor];
    //注册cell
    [_tableView registerNib:[UINib nibWithNibName:@"FriendRequestCell" bundle:nil] forCellReuseIdentifier:@"friendCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"LocationRequestCell" bundle:nil] forCellReuseIdentifier:@"loactionCell"];
    _tableView.delaysContentTouches = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;//取消自动对齐
    
    __weak __typeof(self) weakSelf = self;
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        self.isOpenFriends = YES;
        [weakSelf getFriendRequest];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getLocationRequest];
    }];
    
    _isRequesting = NO;
    
    UIPinchGestureRecognizer *nieHe = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(nieHe)];
    [self.view addGestureRecognizer:nieHe];
    setWaring;
}
//隐藏警告
-(void)hideView{
    self.warningView.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
}
//显示警告
-(void)NotHideView{
    self.warningView.hidden = NO;
    self.navigationController.navigationBarHidden = YES;
}
-(void)goToSetLocation{
    //判断版本是否大于10.0
    if (NSFoundationVersionNumber >NSFoundationVersionNumber_iOS_9_x_Max) {
        //注意首字母改成了大写，prefs->Prefs
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        NSDictionary *dic = [NSDictionary dictionary];
        [[UIApplication sharedApplication] openURL:url options:dic completionHandler:nil];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
    }
}

-(void)nieHe{
    [_post cancel];
    [SVProgressHUD dismiss];
}

//好友申请列表
-(void)getFriendRequest{
    _isRequesting = YES;
    NSMutableArray *myMessage = [NSMutableArray array];
    [myMessage addObjectsFromArray:[[FMDBTool shareDataBase]selectMyMessage]];
    UpDataMessage *model = myMessage[0];
    NSString *approveUrl = [NSString stringWithFormat:@"%@getRequest/user_id/%@",MYURL,model.userId];
    approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"获取好友请求列表接口：%@",approveUrl);
    [self.manage POST:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [self getLocationRequest];
        NSArray *arr= [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
        NSLog(@"获取好友请求列表返回：%@",arr);
        self.friendsArry = nil;
        [[FMDBTool shareDataBase] deleteFriendsRequest];
        if (arr.count != 0) {
            for (NSDictionary *dic in arr) {
                FriendRequestList *list = [[FriendRequestList alloc]init];
                [list saveFriendRequestList:dic];
                [self.friendsArry addObject:list];
            }
        }
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.tableView.mj_header endRefreshing];
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.friendsArry = nil;
        self.isRequesting = NO;
        [self.friendsArry addObject:[[FMDBTool shareDataBase] selectFriendsRequest]];
        [self.tableView reloadData];
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.tableView.mj_header endRefreshing];
    }];
}

//地理位置查看列表
-(void)getLocationRequest{
    NSMutableArray *myMessage = [NSMutableArray array];
    [myMessage addObjectsFromArray:[[FMDBTool shareDataBase]selectMyMessage]];
    UpDataMessage *model = myMessage[0];
    NSString *approveUrl = [NSString stringWithFormat:@"%@getRequest/user_id/%@/limit/%ld:10",MYURL,model.userId,(long)self.listNumber];
    approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"地理位置列表接口：%@",approveUrl);
    [self.manage POST:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (self.isOpenLocation == NO) {
            self.isOpenLocation = YES;
            __weak __typeof(self) weakSelf = self;
            self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                [weakSelf getLocationRequest];
            }];
        }
        NSArray *arr= [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
        NSLog(@"地理位置列表返回信息：%@",arr);
        self.positionArry = nil;
        [self.positionArry addObjectsFromArray:[[FMDBTool shareDataBase] selectLocationRequest]];
        if (arr.count != 0) {
            self.listNumber = self.listNumber +10;
            for (NSDictionary *dic in arr) {
                LocationRequestList *list = [[LocationRequestList alloc]init];
                [list saveLocationRequestList:dic];
                [self.positionArry addObject:list];
            }
            _isRequesting = NO;
            [self.tableView reloadData];
            // 拿到当前的下拉刷新控件，结束刷新状态
            [self.tableView.mj_footer endRefreshing];
        }
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.positionArry = nil;
        [self.positionArry addObjectsFromArray:[[FMDBTool shareDataBase] selectLocationRequest]];
        self.isRequesting = NO;
        [self.tableView reloadData];
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.tableView.mj_footer endRefreshing];
    }];
}

-(void)addFriendRequest:(NSNotification *)data{
    [self getFriendRequest];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return self.friendsArry.count;
    }else{
        return self.positionArry.count;
    }
}
//改变头部视图文字
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return @"申请好友信息列表";
    }else{
        return @"请求地理位置信息列表";
    }
}
//改变头部视图背景颜色
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section{
    view.tintColor = [UIColor colorWithWhite:1 alpha:0.3];
}
//头部视图高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 48;
}
//尾部视图高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

//添加头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *views = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 48)];
    views.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    if (section==0) {
        if (self.isOpenFriends==YES) {
            self.button1 = [[NotificationButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 48) imageName:@"arrow-down.png" labText:@"申请好友信息列表"];
        }else{
            self.button1 = [[NotificationButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 48) imageName:@"arrow-right.png" labText:@"申请好友信息列表"];
        }
        [self.button1 addTarget:self action:@selector(showFriends) forControlEvents:UIControlEventTouchUpInside];
        [views addSubview:self.button1];
    }else{
        if (self.isOpenLocation==YES) {
            self.button2 = [[NotificationButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 48) imageName:@"arrow-down.png" labText:@"请求地理位置信息列表"];
        }else{
            self.button2 = [[NotificationButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 48) imageName:@"arrow-right.png" labText:@"请求地理位置信息列表"];
        }
        [self.button2 addTarget:self action:@selector(showLocation) forControlEvents:UIControlEventTouchUpInside];
        [views addSubview:self.button2];
    }
    return views;
}

//展示好友请求列表
-(void)showFriends{
    if (self.isOpenFriends == YES) {
        [self.friendsArry2 addObjectsFromArray:self.friendsArry];
        self.friendsArry = nil;
        
        self.isOpenFriends = NO;
    }else{
        [self.friendsArry addObjectsFromArray:self.friendsArry2];
        self.friendsArry2 = nil;
        
        self.isOpenFriends = YES;
    }
    [self.tableView reloadData];
}
//展示地理位置请求列表
-(void)showLocation{
    if (self.isOpenLocation == YES) {
        [self.positionArry2 addObjectsFromArray:self.positionArry];
        self.positionArry = nil;
        self.tableView.mj_footer = nil;
        self.isOpenLocation = NO;
    }else{
        [self.positionArry addObjectsFromArray:self.positionArry2];
        self.positionArry2 = nil;
        __weak __typeof(self) weakSelf = self;
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf getLocationRequest];
        }];
        self.isOpenLocation = YES;
    }
    [self.tableView reloadData];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 60;
    }else{
        return 112;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //如果是地理请求
    if (indexPath.section==1) {
        if (self.positionArry.count == 0) {
            return [tableView dequeueReusableCellWithIdentifier:@"loactionCell"];
        }
        LocationRequestList *locationList = self.positionArry[indexPath.row];
        LocationRequestCell *loactionCell = [tableView dequeueReusableCellWithIdentifier:@"loactionCell"];
        if (loactionCell == nil) {
            loactionCell=[[LocationRequestCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"loactionCell"];
            loactionCell.layer.opaque = YES;
            //取消点击效果
            loactionCell.selectionStyle = UITableViewCellSelectionStyleNone;
            loactionCell.backgroundColor = [UIColor clearColor];
        }

        loactionCell.content.text = locationList.name;
        loactionCell.time.text = locationList.time;
        NSMutableArray *fird = [NSMutableArray array];
        [fird addObjectsFromArray:[[FMDBTool shareDataBase] selectFriendsList:locationList.userId]];
        if (fird.count != 0) {
            FriendsList *firends = fird[0];
            [loactionCell.userimage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.sunsyi.com:8081/portrait/%@",firends.portrait]] placeholderImage:[UIImage imageNamed:@"圆头像.png"] options:SDWebImageRefreshCached];
        }else{
            loactionCell.userimage.image = [UIImage imageNamed:@"圆头像.png"];
        }
        loactionCell.userimage.layer.cornerRadius = 35;
        loactionCell.userimage.layer.masksToBounds=YES;;
        return loactionCell;
    }else{
        if (self.friendsArry.count == 0) {
            return [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
        }
        FriendRequestList *list = self.friendsArry[indexPath.row];
        FriendRequestCell *friendCell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
        if (friendCell == nil) {
            friendCell = [[FriendRequestCell alloc]initWithStyle:1 reuseIdentifier:@"friend"];
            friendCell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            friendCell.layer.opaque = YES;
            friendCell.backgroundColor = [UIColor clearColor];
        }
        
        friendCell.acBlock=^(NSString *userId){
            NSString *approveUrl = [NSString stringWithFormat:@"%@approve/id/%@",MYURL,userId];
            approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSLog(@"同意添加好友接口：%@",approveUrl);
            [SVProgressHUD showWithStatus:@"正在添加好友"];
            [self.manage POST:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
                NSString *ss =[NSString stringWithFormat:@"%@",dict[@"status"]];
                NSLog(@"同意添加好友返回信息：%@",dict);
                
                if ([ss isEqualToString:@"1"]) {
                    [self prompt:@"同意成功"];
//                    NSLog(@"fhkh%@",list);
                    [[FMDBTool shareDataBase] deleteFriendsRequest:list];
                    /** 1. 更新数据源(数组): 根据indexPaht.row作为数组下标, 从数组中删除数据. */
                    [self.friendsArry removeObjectAtIndex:indexPath.row];
                    /** 2. TableView中 删除一个cell. */
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                    //创建通知
                    NSNotification *notification =[NSNotification notificationWithName:@"AgreeSuccess" object:nil userInfo:nil];
                    //通过通知中心发送通知
                    [[NSNotificationCenter defaultCenter] postNotification:notification];
                }else{
                    [self prompt:@"同意失败"];
                }
            } failure:nil];
            [SVProgressHUD dismiss];
        };
        [friendCell.RequestImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.sunsyi.com:8081/portrait/%@",list.portrait]] placeholderImage:[UIImage imageNamed:@"圆头像.png"] options:SDWebImageRefreshCached];
        friendCell.lab.text = list.name;
        friendCell.userId = list.userId;
        return friendCell;
    }
}


/** 确定哪些行的cell可以编辑 (UITableViewDataSource协议中方法). */
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//指定cell的编辑状态(删除还是插入)(UITableViewDelegate 协议方法)
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

//
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

/** 提交编辑状态 (UITableViewDataSource协议中方法). */
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    /**   点击 删除 按钮的操作 */
    if (editingStyle == UITableViewCellEditingStyleDelete) { /**< 判断编辑状态是删除时. */
        if (indexPath.section==0) {
            FriendRequestList *list = self.friendsArry[indexPath.row];
//            NSLog(@"list.userId-%@",list.userId);
            NSString *approveUrl = [NSString stringWithFormat:@"%@refused/id/%@",MYURL,list.userId];
            NSLog(@"删除好友%@",approveUrl);
            approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [SVProgressHUD showWithStatus:@"正在拒绝好友请求"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.post cancel];
            });
            self.post = [self.manage POST:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
                NSLog(@"拒绝好友信息返回：%@",dict);
                NSString *ss =[NSString stringWithFormat:@"%@",dict[@"status"]];
                if ([ss isEqualToString:@"1"]) {
                    [self prompt:@"拒绝成功"];
                    [SVProgressHUD dismiss];
                    [[FMDBTool shareDataBase] deleteFriendsRequest:list];
                    /** 1. 更新数据源(数组): 根据indexPaht.row作为数组下标, 从数组中删除数据. */
                    [self.friendsArry removeObjectAtIndex:indexPath.row];
                    /** 2. TableView中 删除一个cell. */
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                }else{
                    [self prompt:@"拒绝失败"];
                    [SVProgressHUD dismiss];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self prompt:@"当前网络不可用"];
                [SVProgressHUD dismiss];
            }];
        }else{
            LocationRequestList *list = self.positionArry[indexPath.row];
//            NSLog(@"list.userId-%@",list.userId);
            [SVProgressHUD showWithStatus:@"正在删除信息"];
            NSString *approveUrl = [NSString stringWithFormat:@"%@deleteHistory/id/%@",MYURL,list.userId];
            NSLog(@"删除地理位置请求信息接口：%@",approveUrl);
            approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            _post = [self.manage GET:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
                NSLog(@"删除地理位置请求返回信息：%@",dict);
                [[FMDBTool shareDataBase] deleteLocationRequest:list];
                /** 1. 更新数据源(数组): 根据indexPaht.row作为数组下标, 从数组中删除数据. */
                [self.positionArry removeObjectAtIndex:indexPath.row];
                /** 2. TableView中 删除一个cell. */
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [SVProgressHUD dismiss];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self prompt:@"删除信息失败"];
                [SVProgressHUD dismiss];
            }];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消选择效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];// 取消选中
}

//提示框
-(void)prompt:(NSString *)message{
    // 1.创建alert控制器
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    // 2.添加按钮以及触发事件
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertVc addAction:action1];
    // 3.presentViewController弹出一个控制器
    [self presentViewController:alertVc animated:YES completion:nil];
}

-(NSMutableArray *)friendsArry{
    if (!_friendsArry) {
        _friendsArry = [NSMutableArray array];
    }
    return _friendsArry;
}

-(NSMutableArray *)friendsArry2{
    if (!_friendsArry2) {
        _friendsArry2 = [NSMutableArray array];
    }
    return _friendsArry2;
}

-(NSMutableArray *)positionArry{
    if (!_positionArry) {
        _positionArry = [NSMutableArray array];
    }
    return _positionArry;
}
-(NSMutableArray *)positionArry2{
    if (!_positionArry2) {
        _positionArry2 = [NSMutableArray array];
    }
    return _positionArry2;
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
