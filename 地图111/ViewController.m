//
//  ViewController.m
//  地图111
//
//  Created by 上海均衡 on 2016/10/8.
//  Copyright © 2016年 上海均衡. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface ViewController ()<CLLocationManagerDelegate>{
    CLLocation *newLocation;
}
@property(strong,nonatomic)CLLocationManager *manager;
@end

@implementation ViewController
-(CLLocationManager *)manager{
    if (_manager==nil) {
        _manager=[[CLLocationManager alloc]init];
        _manager.delegate=self;
        //设置过滤距离
        _manager.distanceFilter=100;
        //精确度
        /*
         kCLLocationAccuracyBestForNavigation
         kCLLocationAccuracyBest;
         kCLLocationAccuracyNearestTenMeters;
         kCLLocationAccuracyHundredMeters;
         kCLLocationAccuracyKilometer;
         kCLLocationAccuracyThreeKilometers;
         */
        _manager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        //请求前后台授权
        //判断版本号
        if ([[UIDevice currentDevice].systemVersion floatValue]>=8.0) {
            [_manager requestAlwaysAuthorization];
            
        }
        if ([[UIDevice currentDevice].systemVersion floatValue]>=9.0) {
            _manager.allowsBackgroundLocationUpdates=YES;
            
        }
//        if ([_manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//            [_manager requestAlwaysAuthorization];
//        }
        
        
    }
    return _manager;
}
#pragma mark 当前定位授权发生改变时使用
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    /*
     kCLAuthorizationStatusNotDetermined
     kCLAuthorizationStatusRestricted
     kCLAuthorizationStatusDenied
     kCLAuthorizationStatusAuthorizedAlways
     kCLAuthorizationStatusAuthorizedWhenInUse
     kCLAuthorizationStatusAuthorized
     */
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"用户未决定授权");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"受限制");
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"被拒绝");
            //判断当前设备是否支持定位，定位服务是否开启
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@"真正被拒绝");
                //真正被拒绝之后跳转到相对饮的设置界面引导用户开启定位服务
                NSURL *url=[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }else{
                NSLog(@"定位服务被关闭");
            }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"前后台定位授权");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"前台定位授权");
            break;
        default:
            break;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //1、创建位置管理者
    //2、使用位置管理者更新用户位置信息
//    [self.manager startUpdatingLocation];
    //如果定位失败，就会调用定位失败的方法
    if ([[UIDevice currentDevice].systemVersion floatValue]>=9.0) {
        [self.manager requestLocation];
        
    }
    
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"定位失败");
}
//当定位到之后进入到这个方法内
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"已经定位");
    //按时间点进行的排序
    CLLocation *lastLocation=[locations lastObject];
    
    /*
     场景演示：打印当前用户的行走方向，偏离角度以及对应的行走距离
     例如：北偏东30°，移动了8米
     */
    /*
     1、确定当前航向
     2、确定偏离角度
     3、确定行走距离
     4、拼串打印
     */
    //如果当前位置可以使用
    if (lastLocation.horizontalAccuracy < 0) {
        return;
    }

    //1、确定当前航向
    NSInteger index=(int)lastLocation.course/90;
    NSArray *courseArr=@[@"北偏东",@"东偏南",@"南偏西",@"西偏北"];
    NSString *courseString=courseArr[index];
    //2、确定偏离角度
    NSInteger angle=(int)lastLocation.course % 90;
    //确定行走距离
    CGFloat distance=0;
    if (newLocation) {
        distance = [newLocation distanceFromLocation:newLocation];
    }
    newLocation = lastLocation;
    //拼接字符串
    NSString *notice=[NSString stringWithFormat:@"%@ %ld度方向 移动了%f米",courseString,(long)angle,distance];
    NSLog(@"%@",notice);
//    NSLog(@"%@",lastLocation);
}



@end
