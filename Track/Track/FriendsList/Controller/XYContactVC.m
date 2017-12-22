//
//  XYContactVC.m
//  Track
//
//  Created by maralves on 16/9/4.
//  Copyright © 2016年 Mac. All rights reserved.
//


#import "FriendsList.h"


@interface XYContactVC ()

@property(nonatomic,assign)NSIndexPath *index;
@property(nonatomic,assign)BOOL cellRequest;//是否正在请求好友位置
@property(nonatomic,assign)NSNumber *add;
@property (nonatomic,strong) Reachability *hostReach;
@property(nonatomic,assign) BOOL isRequesting;
@property (nonatomic,strong) AFHTTPSessionManager *manager;

@property (nonatomic,strong)NSURLSessionDataTask *post;
@property (nonatomic,strong)NSDictionary *dic;
@property (nonatomic,strong)FriendsList *list;
@property (nonatomic,strong)UIView *warningView;
@property (nonatomic,strong)NSString *phone;
@property (nonatomic,strong)NSString *url;
@end

@implementation XYContactVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self getURLData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    setNav;
    
    //添加右边按钮
    UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    addBtn.layer.contents = (id)[UIImage imageNamed:@"添加图片.png"].CGImage;
    [addBtn addTarget:self action:@selector(addContact) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *temporaryBarButtonItem1 = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem=temporaryBarButtonItem1;
    
    [self tableViewSetUp];
    
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
//表示图设置
-(void)tableViewSetUp{
    self.automaticallyAdjustsScrollViewInsets = NO;//取消自动对齐
    _tableView.backgroundColor = [UIColor clearColor];
    //去除分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //注册cell
    [_tableView registerNib:[UINib nibWithNibName:@"FriendsTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];


    _cellRequest=NO;
    
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getURLData];
    }];
    
//    // 马上进入刷新状态
//    [self.tableView.mj_header beginRefreshing];
    
    UIPinchGestureRecognizer *nieHe = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(nieHe)];
    [_tableView addGestureRecognizer:nieHe];
    _isRequesting = NO;

}
-(void)nieHe{
    [_post cancel];
    [SVProgressHUD dismiss];
    _cellRequest = NO;
}

//下拉刷新
-(void)getURLData{
    _isRequesting = YES;
    NSString *url = [NSString stringWithFormat:@"%@friendList",MYURL];
    url= [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"获取好友列表接口：%@",url);
    _post = [self.manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
        NSLog(@"获取好友列表返回信息:%@",dict);
        self.contactArr =nil;
        [[FMDBTool shareDataBase] deleteFriendsList];
        for (NSDictionary *dic in dict) {
            FriendsList * list = [[FriendsList alloc]init];
            [list stValue:dic];
            [self.contactArr insertObject:list atIndex:0];
        }
        _isRequesting = NO;
        [self.tableView reloadData];
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.tableView.mj_header endRefreshing];
    } failure:nil];

}

//跳转到添加好友界面
-(void)addContact{
    XYAddVC *addVC=[[XYAddVC alloc]init];
    [self.navigationController pushViewController:addVC animated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
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
        
        [self prompt2:@"是否删除好友" index:indexPath.row];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.contactArr addObjectsFromArray:[[FMDBTool shareDataBase]selectFriendsList]];
    FriendsList *s = self.contactArr[indexPath.row];
    FriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell=[[FriendsTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.layer.opaque = YES;
        //取消点击效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.lab.text=s.name;
    [cell.imageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.sunsyi.com:8081/portrait/%@",s.portrait]] placeholderImage:[UIImage imageNamed:@"圆头像.png"] options:SDWebImageRefreshCached];
    cell.imageV.layer.cornerRadius=22;
    cell.imageV.layer.masksToBounds=YES;;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_cellRequest==NO) {
        _cellRequest = YES;
        FriendsList *list = self.contactArr[indexPath.row];
        self.list = list;
        [self getLocation:indexPath];
    }
}
//请求位好友位置
-(void)getLocation:(NSIndexPath *)index;{
    [SVProgressHUD showWithStatus:@"正在请求好友位置"];
    FriendsList *list = self.contactArr[index.row];
    NSMutableArray *myArr = [NSMutableArray array];
    [myArr addObjectsFromArray:[[FMDBTool shareDataBase] selectMyMessage]];
    UpDataMessage *message = myArr[0];
    if (list.appId.length == 16) {
        self.url = [NSString stringWithFormat:@"http://api.sunsyi.com:8081/Track/lastposition/appid/%@/user_id/%@/id/%@/t/2",DeviceID,message.userId,list.userId];
    }else{
        self.url = [NSString stringWithFormat:@"http://api.sunsyi.com:8081/Track/lastposition/appid/%@/user_id/%@/id/%@",DeviceID,message.userId,list.userId];
    }
    self.url= [self.url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"请求好友位置接口:%@",self.url);
    [self.manager POST:self.url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        self.dic = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
        if ([self.dic[@"status"] isEqualToString:@"1"]) {
            [self lastPosition];
        }else{
            [self prompt:@"请求地理位置失败"];
        }
        _cellRequest = NO;
        NSLog(@"获取好友位置返回：%@",self.dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self  prompt:@"当前网络不可用"];
        _cellRequest = NO;
    }];
}
-(void)lastPosition{
    [SVProgressHUD dismiss];
    /*
    NSArray *ar = [NSArray array];
    ar=[self.dic[@"content"] componentsSeparatedByString:@":"];
    CLLocationCoordinate2D coor2D = CLLocationCoordinate2DMake([ar[1] doubleValue], [ar[0] doubleValue]);
    XYMapVC *mapVC = [[XYMapVC alloc]init];

    NSString *time = self.dic[@"createtime"];
    time = [time substringToIndex:16];
    mapVC.coor2D = coor2D;
    mapVC.time = time;
    mapVC.list = self.list;
    mapVC.titleStr = @"好友的位置";
    [self.navigationController pushViewController:mapVC animated:YES];
    */
    
    NSArray *ar = [NSArray array];
    ar=[self.dic[@"content"] componentsSeparatedByString:@":"];
    CLLocationCoordinate2D coor2D = CLLocationCoordinate2DMake([ar[1] doubleValue], [ar[0] doubleValue]);
    coor2D = [LocationChange bd09ToWgs84:coor2D];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coor2D.latitude longitude:coor2D.longitude];
    CLGeocoder *geoC = [[CLGeocoder alloc] init];
    [geoC reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(error == nil)
        {
            XYMapVC *mapVC = [[XYMapVC alloc]init];
            
            NSString *time = self.dic[@"createtime"];
            time = [time substringToIndex:16];
            mapVC.time = time;
            mapVC.list = self.list;
            mapVC.titleStr = @"好友的位置";
            
            CLPlacemark *pl = [placemarks firstObject];
            
            mapVC.coor2D = CLLocationCoordinate2DMake(pl.location.coordinate.latitude, pl.location.coordinate.longitude);
            [self.navigationController pushViewController:mapVC animated:YES];
        }
    }];
}

//提示框
-(void)prompt2:(NSString *)message index:(NSInteger)index{
    // 1.创建alert控制器
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    // 2.添加按钮以及触发事件
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        FriendsList *list = self.contactArr[index];
        NSString *url = [NSString stringWithFormat:@"%@friendDelete/id/%@",MYURL,list.userId];
        url= [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSLog(@"删除好友接口:%@",url);
        [self.manager POST:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
            
            NSLog(@"删除好友返回信息：%@",dict);
            if ([dict[@"message"] isEqualToString:@"delete a friend successfully"]) {
                [self prompt:@"删除好友成功"];
                [self getURLData];
            }else{
                [self prompt:@"删除好友失败"];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self prompt:@"当前网络不可用"];
        }];

    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVc addAction:action1];
    [alertVc addAction:action2];
    // 3.presentViewController弹出一个控制器
    [self presentViewController:alertVc animated:YES completion:nil];
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
-(AFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager=[AFHTTPSessionManager manager];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        //因AFNetworking 2.0开始格式有误，下面这句代码必须添加，否则有些格式无法识别
        _manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    }
    return _manager;
}
-(NSMutableArray *)contactArr{
    if (!_contactArr) {
        _contactArr = [NSMutableArray array];
    }
    return _contactArr;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
