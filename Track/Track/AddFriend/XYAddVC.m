//
//  XYAddVC.m
//  Track
//
//  Created by Mac on 16/8/16.
//  Copyright © 2016年 Mac. All rights reserved.
//
#import <ContactsUI/ContactsUI.h>

@interface XYAddVC ()<CNContactPickerDelegate>
@property (nonatomic,strong)AddButton *addFriendsRequest;
@property (nonatomic,strong)AddButton *getPhoneBt;
@property (nonnull,strong) AFHTTPSessionManager *manage;
@property (nonatomic,strong)UIView *warningView;
@end

@implementation XYAddVC

#pragma mark - <CNContactPickerDelegate>
// 当选中某一个联系人时会执行该方法
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
{
    // 1.获取联系人的姓名
    NSString *lastname = contact.familyName;
    NSString *firstname = contact.givenName;
    NSLog(@"%@ %@", lastname, firstname);
    
    // 2.获取联系人的电话号码
    NSArray *phoneNums = contact.phoneNumbers;
    for (CNLabeledValue *labeledValue in phoneNums) {
//        // 2.1.获取电话号码的KEY
//        NSString *phoneLabel = labeledValue.label;
        
        // 2.2.获取电话号码
        CNPhoneNumber *phoneNumer = labeledValue.value;
        self.phoneField.textField.text= [phoneNumer.stringValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSLog(@"开%@",self.phoneField.textField.text);
    }
    
}
- (void)getPhone {
    // 1.创建选择联系人的控制器
    CNContactPickerViewController *contactVc = [[CNContactPickerViewController alloc] init];
    
    // 2.设置代理
    contactVc.delegate = self;
    
    // 3.弹出控制器
    [self presentViewController:contactVc animated:YES completion:nil];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    UIPinchGestureRecognizer *nieHe = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(nieHe)];
    [self.view addGestureRecognizer:nieHe];
    
    setWaring;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.phoneField = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    setNav;//导航栏设置
    
    self.navigationItem.title=@"添加好友";
    
    self.phoneField = [[AddText alloc]initWithFrame:CGRectMake(20, 84, WIDTH-40, 30)];
    self.phoneField.textField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.phoneField];
    
    self.addFriendsRequest = [[AddButton alloc]initWithFrame:CGRectMake(0, 134, WIDTH, 40) imageName:@"iconfont-mingpian.png" labText:@"从通讯录中获取"];
    [self.addFriendsRequest addTarget:self action:@selector(getPhone) forControlEvents:UIControlEventTouchUpInside];
    self.addFriendsRequest.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    [self.view addSubview:self.addFriendsRequest];
    
    self.getPhoneBt = [[AddButton alloc]initWithFrame:CGRectMake(0, 184, WIDTH, 40) imageName:@"添加用户.png" labText:@"申请添加好友"];
    [self.getPhoneBt addTarget:self action:@selector(addFriends) forControlEvents:UIControlEventTouchUpInside];
    self.getPhoneBt.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    [self.view addSubview:self.getPhoneBt];
    
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
            [_manage.operationQueue cancelAllOperations];
//    NSLog(@"你是猪吗");
    [SVProgressHUD dismiss];
    _addFriendsRequest.userInteractionEnabled = YES;
    _getPhoneBt.userInteractionEnabled = YES;
}
//点击主视图取消文本框的第一响应
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.phoneField endEditing:YES];
    
}

//添加好友
- (void)addFriends {
    BOOL isphone = [self validateMobile:self.phoneField.textField.text];
    if([[self.phoneField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0||self.phoneField.textField.text==nil){
        [self prompt:@"请输入手机号"];
    }else if(!isphone){
        [self prompt:@"请正确输入手机号"];
    }
    else{
        _addFriendsRequest.userInteractionEnabled =NO;
        _getPhoneBt.userInteractionEnabled = NO;
        NSString *url = [NSString stringWithFormat:@"%@searchuser/phone/%@",MYURL,self.phoneField.textField.text];
        url= [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        _manage=[AFHTTPSessionManager manager];
        _manage.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manage.responseSerializer = [AFHTTPResponseSerializer serializer];
        //因AFNetworking 2.0开始格式有误，下面这句代码必须添加，否则有些格式无法识别
        [SVProgressHUD showWithStatus:@"正在发送添加好友请求"];
        _manage.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        [_manage POST:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
            NSLog(@"搜索手机号信息返回：%@",dict);
            NSString *ss =[NSString stringWithFormat:@"%@",dict[@"status"]];
            if ([ss isEqualToString:@"1"]) {
                NSString *userid = [NSString stringWithFormat:@"%@",dict[@"id"]];
//                NSLog(@"%@",userid);
                NSString *friUrl = [NSString stringWithFormat:@"%@request/id/%@",MYURL,userid];
//                NSLog(@"%@",friUrl);
                friUrl= [friUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [_manage POST:friUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                    [SVProgressHUD dismiss];
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
                    NSLog(@"添加好友信息返回：%@",dic);
                    NSString *ssd = [NSString stringWithFormat:@"%@",dic[@"status"]];
                    if ([ssd isEqualToString:@"0"]) {
                        [self prompt:@"请勿重复发送请求"];
                    }else if([ssd isEqualToString:@"1"]){
                        [self prompt:@"请求成功"];
                    }else if([ssd isEqualToString:@"2"]){
                        [self prompt:@"此用户已是您的好友"];
                    }else if([ssd isEqualToString:@"3"]){
                        [self prompt:@"此用户已拒绝您的请求"];
                    }else{
                        [self prompt:@"当前服务器不可用"];
                    }
                    [SVProgressHUD dismiss];
                    _addFriendsRequest.userInteractionEnabled =YES;
                    _getPhoneBt.userInteractionEnabled = YES;
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [SVProgressHUD dismiss];
                    _addFriendsRequest.userInteractionEnabled =YES;
                    _getPhoneBt.userInteractionEnabled = YES;
                    [self prompt:@"当前网络不可用"];
                }];
            }else{
                [SVProgressHUD dismiss];
                _addFriendsRequest.userInteractionEnabled =YES;
                _getPhoneBt.userInteractionEnabled = YES;
                [self prompt:@"该手机没有注册"];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [SVProgressHUD dismiss];
            _addFriendsRequest.userInteractionEnabled =YES;
            _getPhoneBt.userInteractionEnabled = YES;
            [self prompt:@"当前网络不可用"];
        }];
    }
}

//手机号码验证
//手机号码验证
- (BOOL) validateMobile:(NSString *)mobileNum
{
    if (mobileNum.length != 11)
    {
        return NO;
    }
    /**
     * 手机号码:
     * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[6, 7, 8], 18[0-9], 170[0-9]
     * 移动号段: 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     * 联通号段: 130,131,132,155,156,185,186,145,176,1709
     * 电信号段: 133,153,180,181,189,177,1700
     */
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|70)\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     */
    NSString *CM = @"(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$)|(^1705\\d{7}$)";
    /**
     * 中国联通：China Unicom
     * 130,131,132,155,156,185,186,145,176,1709
     */
    NSString *CU = @"(^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)";
    /**
     * 中国电信：China Telecom
     * 133,153,180,181,189,177,1700
     */
    NSString *CT = @"(^1(33|53|77|8[019])\\d{8}$)|(^1700\\d{7}$)";
    
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
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
