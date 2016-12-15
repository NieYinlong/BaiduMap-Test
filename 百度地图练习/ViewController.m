//
//  ViewController.m
//  百度地图练习
//
//  Created by YinlongNie on 16/12/12.
//  Copyright © 2016年 Jiuzhekan. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>


@interface ViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
    BMKAnnotationView *newAnnotation;
    
    BMKGeoCodeSearch *_geoCodeSearch;
    
    BMKReverseGeoCodeOption *_reverseGeoCodeOption;
    
    
}
@property (nonatomic, strong) BMKLocationService *locService;
@property (weak, nonatomic) UIButton *mapPin;
@property (nonatomic, strong) BMKMapView *mapView;

@property (nonatomic,assign) BMKUserLocation *userLocation;


@end

@implementation ViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _mapView.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _mapView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
  
    
    
    
//#pragma mark 地图类
    _mapView = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _mapView.delegate = self; // 设置代理
    [self.view addSubview:_mapView];
    
    // 设置地图类型 // 切换卫星地图
    //[_mapView setMapType:BMKMapTypeSatellite];
    
    //打开实时路况图层
    //[_mapView setTrafficEnabled:YES];
    
    
    // 热力图
    //    [_mapView setBaiduHeatMapEnabled:YES];
    
    // 3D楼块 (默认显示)
    [_mapView setBuildingsEnabled:YES];
    
    // 设置地图跟随位置移动
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    
    // 设定显示比例尺
    _mapView.showMapScaleBar = YES;
    
    _mapView.overlooking = 45;
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    _locService.desiredAccuracy = kCLLocationAccuracyBest; //定位精度
    _locService.distanceFilter = 10;
    //启动LocationService
    [_locService startUserLocationService];
    
    
    UIButton *locBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];;
    locBtn.frame = CGRectMake(0, kScreenHeight-50-30, 50, 50);
    locBtn.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:locBtn];
    [locBtn addTarget:self action:@selector(actionLoc) forControlEvents:(UIControlEventTouchUpInside)];
    

    [self actionLoc];
    
   
}

#pragma mark - 点击定位
- (void)actionLoc {
    _mapView.zoomLevel = 19;//地图级别
    _mapView.showsUserLocation = YES;//显示定位图层
    [_mapView setCenterCoordinate:self.userLocation.location.coordinate];
    
}

//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    
     self.userLocation = userLocation;
    
    NSLog(@"heading is %f",userLocation.location.coordinate.latitude);
    NSLog(@"heading is %f",userLocation.location.coordinate.longitude);
    
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"😆didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
    //userLocation.title = @"杭州";
    
    
//    //普通态
//    //以下_mapView为BMKMapView对象
    _mapView.showsUserLocation = YES;//显示定位图层
    [_mapView updateLocationData:userLocation];
    
    
//
//    
//    
//    CLLocationCoordinate2D coord;
//    coord.latitude=userLocation.location.coordinate.latitude;
//    coord.longitude=userLocation.location.coordinate.longitude;
//    BMKCoordinateRegion region ;//表示范围的结构体
//    region.center = coord;//指定地图中心点
//    region.span.latitudeDelta = 0.1;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
//    region.span.longitudeDelta = 0.1;//纬度范围
//    [_mapView setRegion:region animated:YES];
}




//- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
//{
//    
//    BMKAnnotationView *annView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"TTTT"];
//    return annView;
//}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    
    return nil;
}

- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
}


// test
- (void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate {
    NSLog(@"长按");
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"🌹");
}



@end
