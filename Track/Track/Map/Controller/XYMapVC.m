//
//  XYMapVC.m
//  Track
//
//  Created by Mac on 16/8/16.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "UpDataMessage.h"

@interface XYMapVC ()<MKMapViewDelegate>
@property (nonatomic,strong)id annotation;
@end

@implementation XYMapVC

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    self.mapView.showsUserLocation = YES;//是否显示用户位置
    //比例尺
    self.mapView.showsScale = YES;
    //显示指南针
    self.mapView.showsCompass = YES;
    //显示交通
//    self.mapView.showsTraffic = YES;
    //自动追踪到用户位置
    //    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    
    self.navigationItem.title=_titleStr;
    _mapView.delegate=self;
    _mapView.mapType=MKMapTypeStandard;//地图类型
    
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.coor2D, 50, 50)];
    MapAnnotation *annotation = [[MapAnnotation alloc] init];
    annotation.coordinate = self.coor2D;
    NSString *friendLocation = [NSString stringWithFormat:@"%@的位置%@",self.list.name,self.time];
    annotation.title = friendLocation;
    [self.mapView addAnnotation:annotation];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.mapView = nil;
    self.view = nil;
    [self.view removeFromSuperview];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *delcedBtn=[[UIBarButtonItem alloc]initWithTitle:@"导航" style:UIBarButtonItemStylePlain target:self action:@selector(Navigation)];
    self.navigationItem.rightBarButtonItem=delcedBtn;
    
    //导航栏组建颜色设置
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //    判断是不是用户的大头针数据模型
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        MKAnnotationView *userView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"user"];
        
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        
        NSMutableArray *myMessage = [NSMutableArray array];
        [myMessage addObjectsFromArray:[[FMDBTool shareDataBase] selectMyMessage]];
        UpDataMessage *message = myMessage[0];
        
        [imageView2 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.sunsyi.com:8081/portrait/%@",message.portrait]] placeholderImage:[UIImage imageNamed:@"圆头像.png"] options:SDWebImageRefreshCached];
        
        
        // 开始图形上下文
        UIGraphicsBeginImageContextWithOptions(imageView2.frame.size, NO, 0.0);
        
        // 获得图形上下文
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        // 设置一个范围
        CGRect rect = CGRectMake(0, 0, imageView2.frame.size.width, imageView2.frame.size.height);
        
        // 根据一个rect创建一个椭圆
        CGContextAddEllipseInRect(ctx, rect);
        
        // 裁剪
        CGContextClip(ctx);
        
        // 将原照片画到图形上下文
        [imageView2.image drawInRect:rect];
        
        // 从上下文上获取剪裁后的照片
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // 关闭上下文
        UIGraphicsEndImageContext();
        
        //        image 设置大头针视图的图片
        userView.image = newImage;
        
        userView.canShowCallout = YES;
        
        return userView;

    }else{
        
        MKAnnotationView *userView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"user"];
     
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        
        [imageView2 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.sunsyi.com:8081/portrait/%@",self.list.portrait]] placeholderImage:[UIImage imageNamed:@"圆头像.png"] options:SDWebImageRefreshCached];
        // 开始图形上下文
        UIGraphicsBeginImageContextWithOptions(imageView2.frame.size, NO, 0.0);
        
        // 获得图形上下文
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        // 设置一个范围
        CGRect rect = CGRectMake(0, 0, imageView2.frame.size.width, imageView2.frame.size.height);
        
        // 根据一个rect创建一个椭圆
        CGContextAddEllipseInRect(ctx, rect);
        
        // 裁剪
        CGContextClip(ctx);
        
        // 将原照片画到图形上下文
        [imageView2.image drawInRect:rect];
        
        // 从上下文上获取剪裁后的照片
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // 关闭上下文
        UIGraphicsEndImageContext();
        
        //        image 设置大头针视图的图片
        userView.image = newImage;
        
        userView.canShowCallout = YES;
        return userView;
    }
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    userLocation.title=@"您的位置";
}
-(void)Navigation{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选取导航系统" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    
    
    //打开苹果自带地图
    UIAlertAction *openAppleMap= [UIAlertAction actionWithTitle:@"打开苹果自带地图" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
                                  {
                                      [self getMap];
                                  }];
    
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
//        //打开百度地图
//        UIAlertAction *openBaiDuMap = [UIAlertAction actionWithTitle:@"百度地图" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
//                                       {
//                                           NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin=我的位置&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02&src=webapp.marker.yourCompanyName.yourAppName",self.latitude, self.longitude]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
//                                       }];
//        [alert addAction:openBaiDuMap];
//    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        //打开高德地图
        UIAlertAction *openGouldMap = [UIAlertAction actionWithTitle:@"打开高德地图" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
                                       {
                                           NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=Track&backScheme=com.sunsyi.Track&lat=%f&lon=%f&dev=0&style=2",self.coor2D.latitude,self.coor2D.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                                       }];
        [alert addAction:openGouldMap];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        //打开谷歌地图
        UIAlertAction *openGoogleMap = [UIAlertAction actionWithTitle:@"打开谷歌地图" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action)
                                        {
                                            NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=Track&x-success=com.sunsyi.Track&saddr=&daddr=%f,%f&directionsmode=driving",self.coor2D.longitude,self.coor2D.latitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                                        }];
        [alert addAction:openGoogleMap];
    }
    //取消按钮
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    
    [alert addAction:openAppleMap];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)getMap{
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.coor2D addressDictionary:nil]];
    [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                   launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                   MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
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
