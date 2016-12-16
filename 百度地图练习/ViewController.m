//
//  ViewController.m
//  百度地图练习
//
//  Created by YinlongNie on 16/12/12.
//  Copyright © 2016年 Jiuzhekan. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件


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

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) UIImageView *centerImageView;

@end

@implementation ViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _mapView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 添加一个PointAnnotation

    for (int i = 0; i < 5; i++) {
        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        coor.latitude = 29.1625+i*0.06;
        coor.longitude = 120.432+i*0.06;
        annotation.coordinate = coor;//self.userLocation.location.coordinate;
        annotation.title = @"这里是杭州";
        [_mapView addAnnotation:annotation];
        
        self.coordinate = annotation.coordinate;
        
        
    }
  

    
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _mapView.delegate = nil;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
  
    
    
    
    
    
    /*计算两点的距离(直线距离)*/
    BMKMapPoint pointA = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(29, 120));
    BMKMapPoint pointB = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(30, 121));
    CLLocationDistance distance = BMKMetersBetweenMapPoints(pointA, pointB);
    NSLog(@"🌹====== %.f km", distance/1000);
    
    
    
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
    
    
    _centerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"centerLoc"]];
    _centerImageView.frame = CGRectMake((kScreenWidth-30)/2, (kScreenHeight-30)/2, 30, 30);
    [self.view addSubview:_centerImageView];
   
}

#pragma mark - 点击定位
- (void)actionLoc {
    _mapView.zoomLevel = 12;// 地图比例尺级别，在手机上当前可使用的级别为3-21级
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
    
    self.userLocation = userLocation;


}





/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 * 注意:: 只有创建了BMKPointAnnotation, 该代理才会执行
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {

    
    
//     删除标注方法如下：
//    if (annotation != nil) {
//        [_mapView removeAnnotation:annotation];
//    }
    
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKAnnotationView *annView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"TESTSS"];
        annView.image = [UIImage imageNamed:@"carImg.png"];
        
        
        //-------计算两点距离------ start
        BMKMapPoint locPoint = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(self.userLocation.location.coordinate.latitude, self.userLocation.location.coordinate.longitude));
        BMKMapPoint currPoint = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(self.coordinate.latitude, self.coordinate.longitude));
        CLLocationDistance distance = BMKMetersBetweenMapPoints(locPoint, currPoint);
        //-------计算两点距离------ end
        
        
        
        //----- 自定义泡泡----------- start
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        aView.backgroundColor = [UIColor yellowColor];
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        
        lb.text = [NSString stringWithFormat:@"这是自定义的泡泡\n还有3分钟到达\n距您%.fkm", distance/1000];
        lb.numberOfLines = 0;
        lb.font = [UIFont systemFontOfSize:10];
        [aView addSubview:lb];
        BMKActionPaopaoView *paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:aView];
        annView.paopaoView = paopaoView;
        //----- 自定义泡泡----------- end
        return annView;
    }
    return nil;
}

//http://www.jianshu.com/p/dc18c6b5be8b


/**
 *地图区域改变完成后会调用此接口
 *@param mapView 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"====="); // 每当拖动一次地图执行1次改代理方法
    
    
    
    
    // 中心动画
    [UIView animateWithDuration:0.6 animations:^{
        _centerImageView.frame = CGRectMake((kScreenWidth-30)/2 , (kScreenHeight-30)/2 -20, 30, 30);
    } completion:^(BOOL finished) {
        _centerImageView.frame = CGRectMake((kScreenWidth-30)/2, (kScreenHeight-30)/2, 30, 30);
        
    }];
    
    
    
    CGFloat centerLongitude = self.mapView.region.center.longitude;
    CGFloat centerLatitude = self.mapView.region.center.latitude;     //当前屏幕显示范围的经纬度
    
    NSLog(@"%.5f====%.5f", centerLatitude, centerLongitude);
    
    BMKGeoCodeSearch *search = [[BMKGeoCodeSearch alloc] init];
    search.delegate = self;
    CLLocationCoordinate2D coordinate2D;
    coordinate2D.latitude =centerLatitude;
    coordinate2D.longitude =centerLongitude;
    
    BMKReverseGeoCodeOption *op = [[BMKReverseGeoCodeOption alloc] init];
    op.reverseGeoPoint = coordinate2D;
    [search reverseGeoCode:op];

    
}

//反地理编码
/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    NSLog(@"😆👌====== %@", result);
    
}



///**
// *地图渲染每一帧画面过程中，以及每次需要重绘地图时（例如添加覆盖物）都会调用此接口
// *@param mapView 地图View
// *@param status 此时地图的状态
// */
//- (void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus*)status {
//    NSLog(@"=====%@", status); // 执行多次
//}




//
//- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
//    
//}
//
///**
// * 当选中一个annotation views时，调用此接口
// * @param mapView 地图View
// * @param view 选中的annotation views
// */
//- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
//{
//    
//  
//    
//}
//
//
//
//
//
//// test
//- (void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate {
//    NSLog(@"长按地图 调用此方法");
//}





@end
