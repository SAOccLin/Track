//
//  ForgetPassWordVC.m
//  Track
//
//  Created by apple on 16/9/5.
//  Copyright © 2016年 Mac. All rights reserved.
//


@interface ForgetPassWordVC ()

@property (nonatomic,strong) MyText *phone;
@property (nonatomic,strong) MyText *verificationCode;
@property (nonatomic,strong) MyText *passWord;
@property (nonatomic,strong) MyText *confirmPassWord;
@property (nonatomic,strong) UIButton *goBack;


@end

@implementation ForgetPassWordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLabAndText];
   
//    self.passWord.hidden = YES;
    
    self.verificationCode.textField.keyboardType = UIKeyboardTypePhonePad;
    self.automaticallyAdjustsScrollViewInsets = NO;
}
-(void)setLabAndText{
    self.view.layer.contents = (id)[UIImage imageNamed:@"背景.jpg"].CGImage;
    
    self.goBack = [[UIButton alloc]initWithFrame:CGRectMake(13, 25, 28, 28)];
    self.goBack.layer.contents =(id)[UIImage imageNamed:@"返回.png"].CGImage;
    [self.goBack addTarget:self action:@selector(goToLogon) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.goBack];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(41, 25, WIDTH-82, 28)];
    title.text = @"修改密码";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:16];
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
    
    UILabel *phone = [[UILabel alloc]initWithFrame:CGRectMake(20, 100, 45, 30)];
    phone.font = [UIFont systemFontOfSize:14.0f];
    phone.text = @"手机号";
    phone.textColor = [UIColor whiteColor];
    [self.view addSubview:phone];
    
    self.phone =[[MyText alloc]initWithFrame:CGRectMake(90, 100, WIDTH-100, 30) hidden:NO name:@"     请输入手机号"];
    self.phone.textField.keyboardType = UIKeyboardTypePhonePad;
    [self.view addSubview:self.phone];
    
    
    
    
    UILabel *verificationCode = [[UILabel alloc]initWithFrame:CGRectMake(20, 150, 45, 30)];
    verificationCode.font = [UIFont systemFontOfSize:14.0f];
    verificationCode.text = @"验证码";
    verificationCode.textColor = [UIColor whiteColor];
    [self.view addSubview:verificationCode];
    
    self.verificationCode =[[MyText alloc]initWithFrame:CGRectMake(90, 150, WIDTH-100, 30) hidden:YES name:@"     请输入验证码"];
    __weak ForgetPassWordVC *weakSelf = self;
    self.verificationCode.block = ^(){
        if (![weakSelf validateMobile:weakSelf.phone.textField.text]) {
            [weakSelf prompt:@"请正确输入手机号"];
        }
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:weakSelf.phone.textField.text
                                       zone:@"86"
                           customIdentifier:nil
                                     result:nil];
        [weakSelf prompt:@"已发送验证码,请查看手机"];
    };
    [self.view addSubview:self.verificationCode];
    

    
    UILabel *passWord = [[UILabel alloc]initWithFrame:CGRectMake(20, 200, 60, 30)];
    passWord.font = [UIFont systemFontOfSize:14.0f];
    passWord.text = @"新的密码";
    passWord.textColor = [UIColor whiteColor];
    [self.view addSubview:passWord];
    
    self.passWord =[[MyText alloc]initWithFrame:CGRectMake(90, 200, WIDTH-100, 30) hidden:NO name:@"     填写密码"];
    [self.view addSubview:self.passWord];
    
    UILabel *confirmPassWord = [[UILabel alloc]initWithFrame:CGRectMake(20, 250, 60, 30)];
    confirmPassWord.font = [UIFont systemFontOfSize:14.0f];
    confirmPassWord.text = @"确认密码";
    confirmPassWord.textColor = [UIColor whiteColor];
    [self.view addSubview:confirmPassWord];
    
    self.confirmPassWord =[[MyText alloc]initWithFrame:CGRectMake(90, 250, WIDTH-100, 30) hidden:NO name:@"     再次填写密码"];
    [self.view addSubview:self.confirmPassWord];
}

-(void)goToLogon{
    LogonVC *VC =[[LogonVC alloc]init];
    [self presentViewController:VC animated:YES completion:nil];
}

- (IBAction)verification:(UIButton *)sender {

//    [self getData];
    
    if (![self validatePassword:_passWord.textField.text]) {
        [self prompt:@"请输入9到25位点数字或字母"];
    }else if(![_passWord.textField.text isEqualToString:_confirmPassWord.textField.text]){
        [self prompt:@"两次密码输入不一致"];
    }else if(![self verificationCode:_verificationCode.textField.text]){
        [self prompt:@"请输入四位纯数字验证码"];
    }else{
        [SMSSDK commitVerificationCode:self.verificationCode.textField.text phoneNumber:self.phone.textField.text zone:@"86" result:^(NSError *error) {
            if (!error) {
                [self getData];
            }
            else
            {
                [self prompt:@"验证码输入错误,请重新获取验证码"];
            }
        }];
    }
}
//返回登录界面
- (IBAction)Return:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//修改密码
-(void)getData{
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    manage.requestSerializer = [AFHTTPRequestSerializer serializer];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    //因AFNetworking 2.0开始格式有误，下面这句代码必须添加，否则有些格式无法识别
    manage.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    [manage.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *approveUrl = [NSString stringWithFormat: @"%@modification/phone/%@/password/%@",MYURL,_phone.textField.text,_passWord.textField.text];
    NSLog(@"修改密码接口:%@",approveUrl);
    approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manage POST:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
        NSLog(@"修改密码返回：%@",dict);
        if ([dict[@"message"] isEqualToString:@"modification success"]) {
            [self prompt:@"修改密码成功"];
        }else if([dict[@"message"] isEqualToString:@"modification defeated"]){
            [self prompt:@"修改密码失败"];
        }else{
            [self prompt:@"该手机号码还没注册"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self prompt:@"当前网络不可用"];
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

//密码
- (BOOL) validatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{9,25}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}
//验证码
- (BOOL) verificationCode:(NSString *)passWord
{
    NSString *passWordRegex = @"^[0-9]{4,4}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}

//点击主视图取消文本框的第一响应
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.phone endEditing:YES];
    [self.verificationCode endEditing:YES];
    [self.passWord endEditing:YES];
    [self.confirmPassWord endEditing:YES];
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
