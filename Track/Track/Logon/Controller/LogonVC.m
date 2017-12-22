//
//  LogonVC.m
//  Track
//
//  Created by apple on 16/9/5.
//  Copyright © 2016年 Mac. All rights reserved.
//



#import "AFHTTPRequestOperation.h"
#import "WSTextField.h"
@interface LogonVC ()

@property (nonatomic,strong)UIButton *logon;
@property (weak, nonatomic) IBOutlet UIButton *login;
@property (nonatomic,strong) UIButton *forgetPassWord;
@property (nonatomic,strong)FMDBTool *db;
@property (nonatomic,strong)NSURLSessionDataTask *post;
@property (nonatomic,strong)WSTextField *phoneView;
@property (nonatomic,strong)WSTextField *passWordView;

@end

@implementation LogonVC
-(void)setLabAndText{
    self.view.layer.contents =(id)[UIImage imageNamed:@"背景.jpg"].CGImage;
   
    self.phoneView = [[WSTextField alloc]initWithFrame:CGRectMake(20, 164, WIDTH-40, 30) hidden:NO];
    self.phoneView.ly_placeholder = @"手机号码";
    self.phoneView.textField.keyboardType = UIKeyboardTypePhonePad;
    [self.view addSubview:self.phoneView];
    
    self.passWordView = [[WSTextField alloc]initWithFrame:CGRectMake(20, 214, WIDTH-40, 30) hidden:YES];
    self.passWordView.ly_placeholder = @"登录密码";
    [self.view addSubview:self.passWordView];
    
    self.forgetPassWord = [[UIButton alloc]initWithFrame:CGRectMake(WIDTH-90, self.passWordView.frame.origin.y+self.passWordView.frame.size.height+10, 70, 30)];
    [self.forgetPassWord setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [self.forgetPassWord addTarget:self action:@selector(goToForgetPassWord) forControlEvents:UIControlEventTouchUpInside];
    self.forgetPassWord.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    self.forgetPassWord.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.forgetPassWord];
    
    self.logon = [[UIButton alloc]initWithFrame:CGRectMake(20, self.forgetPassWord.frame.origin.y+self.forgetPassWord.frame.size.height+20, WIDTH-40, 40)];
    [self.logon setTitle:@"登录" forState:UIControlStateNormal];
    [self.logon addTarget:self action:@selector(goToFriendlist) forControlEvents:UIControlEventTouchUpInside];
    self.logon.titleLabel.font = [UIFont systemFontOfSize:21.0f];
    self.logon.backgroundColor =[UIColor colorWithWhite:1 alpha:0.9];
    [self.logon setTitleColor:[UIColor colorWithRed:86.0/255 green:142.0/255 blue:191.0/255 alpha:1] forState:UIControlStateNormal];
    [self.view addSubview:self.logon];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLabAndText];
    
    UIPinchGestureRecognizer *nieHe = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(nieHe)];
    [self.view addGestureRecognizer:nieHe];
}
-(void)nieHe{
    [_post cancel];
    self.logon.userInteractionEnabled = YES;
    self.login.userInteractionEnabled =YES;
    self.forgetPassWord.userInteractionEnabled=YES;
    
    [SVProgressHUD dismiss];
}
- (void)goToFriendlist {
    self.logon.userInteractionEnabled =NO;
    self.login.userInteractionEnabled =NO;
    self.forgetPassWord.userInteractionEnabled=NO;
//    NSLog(@"%@,%@",self.phone.text,self.passWord.text);
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    manage.requestSerializer = [AFHTTPRequestSerializer serializer];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    //因AFNetworking 2.0开始格式有误，下面这句代码必须添加，否则有些格式无法识别
    manage.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *approveUrl = [NSString stringWithFormat:@"%@login/phone/%@/password/%@/appId/%@",MYURL,self.phoneView.textField.text,self.passWordView.textField.text,DeviceID];
    NSLog(@"登录接口地址：%@",approveUrl);
    approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [SVProgressHUD showWithStatus:@"正在登录，请稍候"];
   _post = [manage POST:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
        NSLog(@"登录返回信息%@",dict);
       NSString *dd= [NSString stringWithFormat:@"%@",dict[@"status"]];
        if ([dd isEqualToString:@"1"]) {

            [SVProgressHUD dismiss];
            XYMainVC *MVC = [[XYMainVC alloc]init];
            //刷新账号密码信息
            PassWord *pswd =[[PassWord alloc]init];
            pswd.name =self.phoneView.textField.text;
            pswd.passWord=self.passWordView.textField.text;
            pswd.online = @"YES";
            [[FMDBTool shareDataBase] insertPassWord:pswd];
            
            [[FMDBTool shareDataBase] deleteMyMessage];
            UpDataMessage *message=[[UpDataMessage alloc]init];
            [message sdValue:dict];
            
            self.logon.userInteractionEnabled = YES;
            self.login.userInteractionEnabled =YES;
            self.forgetPassWord.userInteractionEnabled=YES;
            [self presentViewController:MVC animated:YES completion:nil];
        }else{
            [SVProgressHUD dismiss];
            [self prompt:@"账号密码错误"];
            self.logon.userInteractionEnabled = YES;
            self.login.userInteractionEnabled =YES;
            self.forgetPassWord.userInteractionEnabled=YES;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self prompt:@"网络异常"];
        self.logon.userInteractionEnabled = YES;
        self.login.userInteractionEnabled =YES;
        self.forgetPassWord.userInteractionEnabled=YES;
    }];
}
- (IBAction)jumpLogin:(id)sender {
    LoginVC *loginVC = [[LoginVC alloc]init];
    [self presentViewController:loginVC animated:YES completion:nil];
}

-(void)goToForgetPassWord {
    ForgetPassWordVC *FPWVC = [[ForgetPassWordVC alloc]init];
    [self presentViewController:FPWVC animated:YES completion:nil];
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

//点击主视图取消文本框的第一响应
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.phoneView endEditing:YES];
    [self.passWordView endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
//    NSLog(@"c.c");
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
