//
//  XYMineVC.m
//  Track
//
//  Created by Mac on 16/8/15.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "XYMineVC.h"
#import "UpDataMessage.h"
#import "UIImageView+WebCache.h"
#import "AboutUsViewController.h"

@interface XYMineVC ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong)UIButton *logout;
@property (nonatomic,strong)NSURLSessionDataTask *post;
@property (strong, nonatomic) IBOutlet UIView *imageBackGroundView;
@property (nonatomic,strong)UIView *warningView;
@property (nonatomic,strong)UIImageView *imageView;//备份
@property (nonatomic,strong)AFHTTPSessionManager *manage;
@property (nonatomic,assign)BOOL isUpload;
@end

@implementation XYMineVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self getMessManage];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.headView = nil;
    self.imageView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    setNav;
    self.isUpload = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor clearColor]}];
    //去除 navigationBar 底部的细线
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    //设置退出登录按钮
    self.logout = [[UIButton alloc]initWithFrame:CGRectMake(20, HIGHT-92, WIDTH-40, 30)];
    [self.logout setTitleColor:[UIColor colorWithRed:86.0/255 green:142.0/255 blue:191.0/255 alpha:1] forState:UIControlStateNormal];
    self.logout.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    [self.logout setTitle:@"退出登录" forState:UIControlStateNormal];
    [self.logout addTarget:self action:@selector(goToLogon) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logout];
    
    self.imageBackGroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    self.mineTv.backgroundColor = [UIColor clearColor];
    
    self.mineTv.separatorStyle = UITableViewCellSelectionStyleNone;
    [self setTableView];
    
    UIPinchGestureRecognizer *nieHe = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(nieHe)];
    [self.view addGestureRecognizer:nieHe];
    setWaring;
    self.headView.userInteractionEnabled = YES;
}
- (IBAction)changeUserIcon:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选取图片" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIImagePickerController *pick = [[UIImagePickerController alloc]init];
    pick.delegate = self;
    pick.allowsEditing = YES;
    pick.modalTransitionStyle = UIModalPresentationOverCurrentContext;
    
    //打开相册按钮
    UIAlertAction *openPhoto = [UIAlertAction actionWithTitle:@"打开相册" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
                                {
                                    dispatch_after(0.2, dispatch_get_main_queue(), ^{
                                    pick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                    [self presentViewController:pick animated:YES completion:nil];
                                        });
                                }];
    
    //打开相机按钮
    UIAlertAction *openCamera = [UIAlertAction actionWithTitle:@"打开相机" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
                                 {
                                     dispatch_after(0.2, dispatch_get_main_queue(), ^{
                                     self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
                                     pick.sourceType = UIImagePickerControllerSourceTypeCamera;
                                     [self presentViewController:pick animated:YES completion:nil];
                                         });
                                 }];
    
    //取消按钮
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    
    [alert addAction:openPhoto];
    [alert addAction:openCamera];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

//选取相册照片触发的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
                NSLog(@"照片属性:%@",info);
        NSData * imageData = UIImageJPEGRepresentation(image,1);
        NSLog(@"图片大小%lu",(unsigned long)[imageData length]);
        if ([imageData length]/1000 <= 5000) {
            self.imageView.image = self.headView.image;
            self.headView.image=image;
            [picker dismissViewControllerAnimated:YES completion:^{
                [self prompt2:@"是否修改头像"];
            }];
        }else{
            [picker dismissViewControllerAnimated:YES completion:^{
                [self prompt:@"图片不能超过5M"];
            }];
        }
    }
}

//隐藏警告
-(void)hideView{
    self.warningView.hidden = YES;
    self.warningView.userInteractionEnabled = NO;
    self.navigationController.navigationBarHidden = NO;
}
//显示警告
-(void)NotHideView{
    self.warningView.hidden = NO;
    self.warningView.userInteractionEnabled = YES;
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
    if (self.isUpload == YES) {
        self.headView.image = self.imageView.image;
    }
    _logout.userInteractionEnabled = YES;
}
-(void)setTableView{
    //注册cell
    [_mineTv registerNib:[UINib nibWithNibName:@"MessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    
    self.mineTv.scrollEnabled=NO;//禁止tableView滚动
    self.mineTv.delegate = self;
    self.mineTv.dataSource = self;
}

-(void)getMessManage{
    UpDataMessage *list = [[FMDBTool shareDataBase] selectMyMessage][0];
    [_MyMessage addObject:list];
    [_userName setTitle:list.name forState:UIControlStateNormal];
    
    _headView.layer.cornerRadius=60;
    _headView.layer.masksToBounds=YES;
    [_headView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.sunsyi.com:8081/portrait/%@",list.portrait]] placeholderImage:[UIImage imageNamed:@"圆头像.png"] options:SDWebImageRefreshCached];
    _headView.backgroundColor = [UIColor clearColor];
}
- (IBAction)goToChangeUserName:(id)sender {
    UpDataMessage *upData = [[FMDBTool shareDataBase] selectMyMessage][0];
    ChangeUserNameView *VC = [[ChangeUserNameView alloc]init];
    VC.name = upData.name;
    [self.navigationController pushViewController:VC animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.MyMessage addObjectsFromArray:[[FMDBTool shareDataBase] selectMyMessage]];
    UpDataMessage *upData = [[FMDBTool shareDataBase] selectMyMessage][0];
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.imageV.contentMode = UIViewContentModeScaleToFill;
    if (!cell) {
        cell=[[MessageTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.layer.opaque = YES;
        cell.backgroundColor=[UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone; 
    if (indexPath.row==0) {
        cell.imageV.image=[UIImage imageNamed:@"iconfont-phone.png"];
        cell.lab.text=[NSString stringWithFormat:@"Tel: %@",upData.phone];
    }else if (indexPath.row==1) {
        cell.imageV.image=[UIImage imageNamed:@"wxb定位.png"];
        cell.lab.text=[NSString stringWithFormat:@"Position: 广东省广州市天河区"];
    }else if (indexPath.row==2) {
            cell.imageV.image=[UIImage imageNamed:@"认证邮箱.png"];
            cell.lab.text=[NSString stringWithFormat:@"E-mail: 122039647@qq.com"];
    }else if (indexPath.row == 3){
        cell.imageV.image=[UIImage imageNamed:@"认证邮箱.png"];
        cell.lab.text=[NSString stringWithFormat:@"关于我们"];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3) {
        AboutUsViewController *vc = [[AboutUsViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)goToLogon {
    
    _logout.userInteractionEnabled =NO;
    [SVProgressHUD showWithStatus:@"正在退出登录"];
   
    NSString *approveUrl = [NSString stringWithFormat:@"%@quit",MYURL];
    approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"退出登录接口：%@",approveUrl);
    _post = [self.manage POST:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
        NSLog(@"退出登录返回信息：%@",dict);
        NSString *dd = [NSString stringWithFormat:@"%@",dict[@"status"]];
        if ([dd isEqualToString:@"1"]) {
            [[FMDBTool shareDataBase] deletePassWord];
            LogonVC *logonVC = [[LogonVC alloc]init];
            [SVProgressHUD dismiss];
            _logout.userInteractionEnabled = YES;
            [self presentViewController:logonVC animated:YES completion:nil];
        }else{
            [self prompt:@"当前网络不可用"];
            [SVProgressHUD dismiss];
            self.logout.userInteractionEnabled = YES;
        }
        self.manage = nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.manage = nil;
        [SVProgressHUD dismiss];
        [self prompt:@"网络异常"];
        self.logout.userInteractionEnabled = YES;
    }];
}
//有选择的提示框
-(void)prompt2:(NSString *)message{
    // 1.创建alert控制器
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    // 2.添加按钮以及触发事件
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.isUpload = YES;
        [self upLoadImage];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.headView.image = self.imageView.image;
    }];
    [alertVc addAction:action1];
     [alertVc addAction:action2];
    // 3.presentViewController弹出一个控制器
    [self presentViewController:alertVc animated:YES completion:nil];
}
-(void)upLoadImage{
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    manage.requestSerializer = [AFHTTPRequestSerializer serializer];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    //因AFNetworking 2.0开始格式有误，下面这句代码必须添加，否则有些格式无法识别
    manage.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    [manage.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSData *imageData =UIImageJPEGRepresentation(self.headView.image,0.7);
    
    UpDataMessage *upData = [[FMDBTool shareDataBase] selectMyMessage][0];
    NSString *approveUrl = [NSString stringWithFormat: @"%@portrait/phone/%@",MYURL,upData.phone];
    NSLog(@"修改头像接口：%@",approveUrl);
    approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [SVProgressHUD showWithStatus:@"正在修改头像,请稍后"];
    _post =[manage POST:approveUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        
        //上传的参数(上传图片，以文件流的格式)
        //name的名字要和服务器一致
        [formData appendPartWithFileData:imageData
                                    name:@"portrait"
                                fileName:fileName
                                mimeType:@"image/jpeg"];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
        NSLog(@"修改头像返回：%@",dict);
        self.isUpload = NO;
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.isUpload = NO;
        self.headView.image = self.imageView.image;
        [self prompt:@"当前网络状态不好,请稍后重试"];
    }];
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
-(NSMutableArray *)MyMessage{
    if (!_MyMessage) {
        _MyMessage = [NSMutableArray array];
    }
    return _MyMessage;
}
-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(127.5, 42, 120, 120)];
        _imageView.layer.cornerRadius=60;
        _imageView.layer.masksToBounds=YES;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.hidden = YES;
    }
    return _imageView;
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
