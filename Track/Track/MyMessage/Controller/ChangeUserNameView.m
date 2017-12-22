//
//  ChangeUserNameView.m
//  Track
//
//  Created by apple on 16/9/20.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "ChangeUserNameView.h"

@interface ChangeUserNameView ()
@property (weak, nonatomic) IBOutlet UIButton *change;
@property (nonatomic,strong)NSURLSessionDataTask *post;
@end

@implementation ChangeUserNameView
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.contents =(id)[UIImage imageNamed:@"背景.jpg"].CGImage;
    self.userName.text=self.name;
    self.userName.textColor = [UIColor blueColor];
    UIPinchGestureRecognizer *nieHe = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(nieHe)];
    [self.view addGestureRecognizer:nieHe];
    
}
-(void)nieHe{
    [_post cancel];
    [SVProgressHUD dismiss];
    _change.userInteractionEnabled=YES;
}

- (IBAction)changeUserName:(id)sender {
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    manage.requestSerializer = [AFHTTPRequestSerializer serializer];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    //因AFNetworking 2.0开始格式有误，下面这句代码必须添加，否则有些格式无法识别
    [SVProgressHUD showWithStatus:@"正在修改用户名"];
    manage.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *approveUrl = [NSString stringWithFormat:@"%@rename/name/%@",MYURL,self.userName.text];
    approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:
                 [NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"改变名字地址：%@",approveUrl);
    _change.userInteractionEnabled = NO;
    _post = [manage POST:approveUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
        NSLog(@"fick%@",dict);
        NSString *dd = [NSString stringWithFormat:@"%@",dict[@"status"]];
        if ([dd isEqualToString:@"1"]) {
            [[FMDBTool shareDataBase] upDateMyMessage:self.userName.text];
            [SVProgressHUD dismiss];
            //创建通知
            NSNotification *notification =[NSNotification notificationWithName:@"changeSuccess" object:nil userInfo:nil];
            //通过通知中心发送通知
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            [self prompt:@"修改用户名成功"];
        }else{
            [self prompt:@"用户名含有非法字符"];
            [SVProgressHUD dismiss];
        }
        self.change.userInteractionEnabled = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self prompt:@"网络异常"];
        self.change.userInteractionEnabled = YES;
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

//点击主视图取消文本框的第一响应
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
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
