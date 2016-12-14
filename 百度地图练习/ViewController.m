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
@property (nonatomic, strong) BMKLocationService *localService;
@property (weak, nonatomic) UIButton *mapPin;
@property (nonatomic, strong) BMKMapView *mapView;


@end

@implementation ViewController

- (BMKLocationService *)localService {
    if (_localService) {
        _localService = [[BMKLocationService alloc] init];
        [_localService setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    return _localService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.mapView = [[BMKMapView alloc] initWithFrame:self.view.frame];
    self.mapPin = [UIButton buttonWithType:UIButtonTypeSystem];//大头针
    self.mapPin.frame = CGRectMake(0, kScreenHeight-60, 50, 50);
    self.mapPin.backgroundColor = [UIColor redColor];
    self.mapPin.center = self.mapView.center;
    [self.mapPin setBackgroundImage:[UIImage imageNamed:@"serach_Map"] forState:UIControlStateNormal];
    self.mapPin.backgroundColor = [UIColor greenColor];
    [self.mapView addSubview:self.mapPin];
    [self.view addSubview:self.mapView];
    self.mapView.zoomLevel=17;//比例尺
    [self.mapView setMapType:BMKMapTypeStandard];//地图类型
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    self.mapView.showsUserLocation = YES;//显示定位图层
    self.localService.delegate = self;
    [self.localService startUserLocationService];//用户开始定位
    
    //self.mapView.showsUserLocation = NO;//先关闭显示的定位图层
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    self.mapView.showsUserLocation = YES;//显示定位图层
    [self.mapView bringSubviewToFront:self.mapPin];
}

#pragma mark - 点击定位
- (void)actionLoc {
    
}

#pragma mark -- BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    self.mapView.showsUserLocation = YES;//显示定位图层
    //设置地图中心为用户经纬度
    [self.mapView updateLocationData:userLocation];
    
    
    //    _mapView.centerCoordinate = userLocation.location.coordinate;
    BMKCoordinateRegion region ;//表示范围的结构体
    region.center = self.mapView.centerCoordinate;//中心点
    region.span.latitudeDelta = 0.004;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
    region.span.longitudeDelta = 0.004;//纬度范围
    [self.mapView setRegion:region animated:YES];
    
}
#pragma mark -- BMKMapViewDelegate
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //屏幕坐标转地图经纬度
    CLLocationCoordinate2D MapCoordinate=[_mapView convertPoint:_mapPin.center toCoordinateFromView:_mapView];
    NSLog(@"latitude == %f longitude == %f",MapCoordinate.latitude,MapCoordinate.longitude);
    if (_geoCodeSearch==nil) {
        //初始化地理编码类
        _geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
        _geoCodeSearch.delegate = self;
        
    }
    if (_reverseGeoCodeOption==nil) {
        
        //初始化反地理编码类
        _reverseGeoCodeOption= [[BMKReverseGeoCodeOption alloc] init];
    }
    
    //需要逆地理编码的坐标位置
    _reverseGeoCodeOption.reverseGeoPoint =MapCoordinate;
    [_geoCodeSearch reverseGeoCode:_reverseGeoCodeOption];
    
    //创建地理编码对象
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    //创建位置
    CLLocation *location=[[CLLocation alloc]initWithLatitude:MapCoordinate.latitude longitude:MapCoordinate.longitude];
    
    //反地理编码
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //判断是否有错误或者placemarks是否为空
        if (error !=nil || placemarks.count==0) {
            NSLog(@"%@",error);
            return ;
        }
        for (CLPlacemark *placemark in placemarks) {
            //赋值详细地址
            NSLog(@"%@",placemark.name);
        }
    }];
}
#pragma mark -- BMKGeoCodeSearchDelegate
//周边信息
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    for (BMKPoiInfo *poi in result.poiList) {
        NSLog(@"%@",poi.name);//周边建筑名
        NSLog(@"%d",poi.epoitype);
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
