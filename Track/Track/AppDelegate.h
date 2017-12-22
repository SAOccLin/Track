//
//  AppDelegate.h
//  Track
//
//  Created by Mac on 16/8/15.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,assign)double longitude;
@property (nonatomic,assign)double latitude;
@property (nonatomic,strong)CLLocationManager *locationManager;

@end

