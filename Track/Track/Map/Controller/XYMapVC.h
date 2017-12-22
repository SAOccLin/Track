//
//  XYMapVC.h
//  Track
//
//  Created by Mac on 16/8/16.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapAnnotation.h"
#import "FriendsList.h"
@interface XYMapVC : UIViewController
@property(strong,nonatomic)NSString *titleStr;
@property(nonatomic,assign)CLLocationCoordinate2D coor2D;
@property(nonatomic,strong)NSString *time;
@property (nonatomic,strong)FriendsList *list;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;



@end
