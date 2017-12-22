//
//  LoginVC.m
//  Track
//
//  Created by apple on 16/9/5.
//  Copyright © 2016年 Mac. All rights reserved.
//


#import "AFHTTPRequestOperation.h"

@interface LoginVC ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)LoginText *phone;
@property (nonatomic,strong)LoginText *VerificationCode;
@property (nonatomic,strong)LoginText *passWord;
@property (nonatomic,strong)LoginText *confirmPassWord;
@property (nonatomic,strong)LoginText *userName;
@property (nonatomic,strong)UIButton *login;



@property (nonatomic,strong)NSData *imageData;
@property (nonatomic,strong)NSURLSessionDataTask *post;

@end

@implementation LoginVC
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    __weak LoginVC *weakSelf = self;
    self.VerificationCode.block =^(){
        if ([weakSelf validateMobile:weakSelf.phone.textField.text]) {
            [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:weakSelf.phone.textField.text
                                           zone:@"86"
                               customIdentifier:nil
                                         result:nil];
            [weakSelf prompt:@"已发送验证,请查看手机"];
        }else{
            [weakSelf prompt:@"请正确输入手机号"];
        }
    };
    self.passWord.textField.secureTextEntry = YES;
    self.confirmPassWord.textField.secureTextEntry = YES;
    self.phone.textField.keyboardType = UIKeyboardTypePhonePad;
    self.VerificationCode.textField.keyboardType = UIKeyboardTypePhonePad;
    self.automaticallyAdjustsScrollViewInsets = NO;
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeUserIcon:)];
    [self.imageView addGestureRecognizer:tap];
    UIPinchGestureRecognizer *nieHe = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(nieHe)];
    [self.view addGestureRecognizer:nieHe];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.view = nil;
    [self.view removeFromSuperview];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.contents =(id)[UIImage imageNamed:@"背景.jpg"].CGImage;
    
    UIButton *goBack = [[UIButton alloc]initWithFrame:CGRectMake(13, 25, 28, 28)];
    goBack.layer.contents =(id)[UIImage imageNamed:@"返回.png"].CGImage;
    [goBack addTarget:self action:@selector(goToLogon) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goBack];
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake((WIDTH/2)-40, 86, 80, 80)];
    self.imageView.image = [UIImage imageNamed:@"headView"];
    [self.view addSubview:self.imageView];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(41, 25, WIDTH-82, 28)];
    title.text = @"注册账号";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:16];
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
    
    self.phone = [[LoginText alloc]initWithFrame:CGRectMake(16, 186, WIDTH-32, 30) hidden:NO placeholder:YES labName:@"手机号" textName:@"请输入手机号"];
    [self.view addSubview:self.phone];
    
    self.VerificationCode = [[LoginText alloc]initWithFrame:CGRectMake(16, 236, WIDTH-32, 30) hidden:YES placeholder:YES labName:@"验证码" textName:@"请输入验证码"];
    [self.view addSubview:self.VerificationCode];
    
    self.passWord = [[LoginText alloc]initWithFrame:CGRectMake(16, 286, WIDTH-32, 30) hidden:NO placeholder:YES labName:@"密码" textName:@"6-16位数字字母区分大小写"];
    [self.view addSubview:self.passWord];
    
    self.confirmPassWord = [[LoginText alloc]initWithFrame:CGRectMake(16, 336, WIDTH-32, 30) hidden:NO placeholder:NO labName:@"确认密码" textName:nil];
    [self.view addSubview:self.confirmPassWord];
    
    self.userName = [[LoginText alloc]initWithFrame:CGRectMake(16, 386, WIDTH-32, 30) hidden:NO placeholder:NO labName:@"用户名" textName:nil];
    [self.view addSubview:self.userName];
    
    self.login =[[UIButton alloc]initWithFrame:CGRectMake(20, HIGHT-60, WIDTH-40, 40)];
    [self.login setTitleColor:[UIColor colorWithRed:86.0/255 green:142.0/255 blue:191.0/255 alpha:1] forState:UIControlStateNormal];
    [self.login setTitle:@"注册" forState:UIControlStateNormal];
    [self.login setTitleColor:[UIColor colorWithRed:86.0/255 green:142.0/255 blue:191.0/255 alpha:1] forState:UIControlStateNormal];
    self.login.titleLabel.font = [UIFont systemFontOfSize:21.0f];
    self.login.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    [self.login addTarget:self action:@selector(loginPhone) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.login];
    
    
    UIImage *image = [UIImage imageNamed:@"touxiang"];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.image = [self compressImage:image toTargetWidth:106];
}
-(void)goToLogon{
    LogonVC *VC =[[LogonVC alloc]init];
    [self presentViewController:VC animated:YES completion:nil];
}

-(void)nieHe{
    [_post cancel];
    [SVProgressHUD dismiss];
    _login.userInteractionEnabled=YES;
}
- (UIImage *)compressImage:(UIImage *)sourceImage toTargetWidth:(CGFloat)targetWidth {
    CGSize imageSize = sourceImage.size;
    
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetHeight = (targetWidth / width) * height;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)loginPhone{
//    self.passWord.textField.clearsOnBeginEditing = YES;//清除密码
//    self.confirmPassWord.textField.clearsOnBeginEditing = YES;
//    if(![self validatePassword:self.passWord.textField.text] ){
//        [self prompt:@"请输入9到25位数字或字母的密码"];
//    }else if(![self.passWord.textField.text isEqualToString:self.confirmPassWord.textField.text]){
//        [self prompt:@"两次密码不一致"];
//    }else if(![self validateNickname:self.userName.textField.text]&&![self validateUserName:self.userName.textField.text]){
//        [self prompt:@"帐号含有非法字符"];
//    }else if(self.userName.textField.text ==nil){
//        [self prompt:@"请输入用户名"];
//    }else{
//        [SMSSDK commitVerificationCode:self.VerificationCode.textField.text phoneNumber:self.phone.textField.text zone:@"86" result:^(NSError *error) {
//            if (!error) {
//                [self getData];
//            }
//            else
//            {
//                [self prompt:@"验证码输入错误,请重新请求验证码"];
//            }
//        }];
//    }
    [self getData];
}


//注册
-(void)getData{
    _login.userInteractionEnabled=NO;
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    manage.requestSerializer = [AFHTTPRequestSerializer serializer];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    //因AFNetworking 2.0开始格式有误，下面这句代码必须添加，否则有些格式无法识别
    manage.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    [manage.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    _imageData =UIImageJPEGRepresentation(self.imageView.image,0.7);
    
    NSString *approveUrl = [NSString stringWithFormat: @"%@register/name/%@/password/%@/phone/%@/company/%@/job/%@/appId/%@/portrait",MYURL,self.userName.textField.text,self.passWord.textField.text,self.phone.textField.text,nil,nil,DeviceID];
    NSLog(@"注册接口：%@",approveUrl);
    approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [SVProgressHUD showWithStatus:@"正在注册,请稍后"];
    _post =[manage POST:approveUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        
        //上传的参数(上传图片，以文件流的格式)
        //name的名字要和服务器一致
        [formData appendPartWithFileData:_imageData
                                    name:@"portrait"
                                fileName:fileName
                                mimeType:@"image/jpeg"];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
        [SVProgressHUD dismiss];
        NSLog(@"注册返回数据%@",dict);
        if ([dict[@"message"] isEqualToString:@"register successfully"]) {
            NSString *approveUrl = [NSString stringWithFormat:@"%@login/phone/%@/password/%@/appId/%@",MYURL,self.phone.textField.text,self.passWord.textField.text,DeviceID];
            approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSLog(@"注册后登陆接口：%@",approveUrl);
            [SVProgressHUD showWithStatus:@"正在登录,请稍后"];
            _post = [manage POST:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
//                NSLog(@"%@",dict);
                NSString *ss =[NSString stringWithFormat:@"%@",dict[@"status"]];
                if ([ss isEqualToString:@"1"]) {
                    
                    [SVProgressHUD dismiss];
                    XYMainVC *MVC = [[XYMainVC alloc]init];
                    //刷新账号密码信息
                    PassWord *pswd =[[PassWord alloc]init];
                    pswd.name =self.phone.textField.text;
                    pswd.passWord=self.passWord.textField.text;
                    pswd.online = @"YES";
                    [[FMDBTool shareDataBase] insertPassWord:pswd];
                    
                    [[FMDBTool shareDataBase] deleteMyMessage];
                    UpDataMessage *message=[[UpDataMessage alloc]init];
                    [message sdValue:dict];
                    [[FMDBTool shareDataBase] insertMyMessage:message];
                    _login.userInteractionEnabled=YES;
                    [self presentViewController:MVC animated:YES completion:nil];
                    [SVProgressHUD dismiss];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                _login.userInteractionEnabled=YES;
                [SVProgressHUD dismiss];
            }];
        }else if([dict[@"message"] isEqualToString:@"the phone is registered"]){
            [SVProgressHUD dismiss];
            [self prompt:@"该手机已被注册"];
        }else{
            [SVProgressHUD dismiss];
            [self prompt:@"该账号已被注册"];
        }
        _login.userInteractionEnabled=YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self prompt:@"注册失败"];
        _login.userInteractionEnabled=YES;
    }];
}
- (IBAction)return:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)changeUserIcon:(UITapGestureRecognizer *)tap{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选取图片" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIImagePickerController *pick = [[UIImagePickerController alloc]init];
    pick.delegate = self;
    pick.allowsEditing = YES;
    pick.modalTransitionStyle = UIModalPresentationOverCurrentContext;
    
    //打开相册按钮
    UIAlertAction *openPhoto = [UIAlertAction actionWithTitle:@"打开相册" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
                                {
                                    pick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                    [self presentViewController:pick animated:YES completion:nil];
                                }];
    
    //打开相机按钮
    UIAlertAction *openCamera = [UIAlertAction actionWithTitle:@"打开相机" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
                                 {
                                     pick.sourceType = UIImagePickerControllerSourceTypeCamera;
                                     [self presentViewController:pick animated:YES completion:nil];
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
//    NSLog(@"%@",info);
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *data =UIImagePNGRepresentation(image);
//        NSLog(@"快；快%u",data.length);
        if(data.length>2097152 ){
            [self prompt:@"图片大小不能超过2M"];
        }else{
            self.imageView.image=image;
        }
        //process image
        [picker dismissViewControllerAnimated:YES completion:^{
        }];
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
//昵称
- (BOOL) validateNickname:(NSString *)nickname
{
    NSString *nicknameRegex = @"^[\u4e00-\u9fa5]{2,12}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nicknameRegex];
    return [passWordPredicate evaluateWithObject:nickname];
}
//用户名
- (BOOL) validateUserName:(NSString *)name
{
    NSString *userNameRegex = @"^[A-Za-z0-9]{4,20}+$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    BOOL B = [userNamePredicate evaluateWithObject:name];
    return B;
}
//点击主视图取消文本框的第一响应
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.phone endEditing:YES];
    [self.VerificationCode endEditing:YES];
    [self.passWord endEditing:YES];
    [self.confirmPassWord endEditing:YES];
    [self.userName endEditing:YES];

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
