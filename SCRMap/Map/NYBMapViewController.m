//
//  NYBMapViewController.m
//  appNYB2
//
//  Created by Facebook on 2017/11/12.
//  Copyright © 2017年 leetcode. All rights reserved.
//

#import "NYBMapViewController.h"
#import "NYBCustomPinAnnotationView.h"
#import "NYBAnnotation.h"

@interface NYBMapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
@property(nonatomic,strong)BMKMapView *mapView;
@property(nonatomic,strong)BMKLocationService *locationService;     //定位
@property(nonatomic,strong)BMKUserLocation *userLocation;   //用户位置
@property(nonatomic,strong)NSMutableArray *annotationArray;  //标注数组
@property(nonatomic,strong)BMKGeoCodeSearch *geoCodeSearch;  //反编码
@property(nonatomic,strong)NYBAnnotation *MyAnnotation;     ///自定义大头针
@property(nonatomic,strong)UIButton *userLoctionButton;
@property(nonatomic,strong)UIButton *minZoomButton;
@property(nonatomic,strong)UIButton *maxZoomButton;
@end

@implementation NYBMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWithMap];
}

#pragma mark   --  BMKMapViewDelegate
- (void)willStartLocatingUser{
    NSLog(@"开始定位");
}
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation{       //方向
    NSLog(@"位置变更:%@",userLocation.title);
}


/**
 * 解决比例尺不显示的问题
 
 @param mapView mapView description
 */
-(void)mapViewDidFinishLoading:(BMKMapView *)mapView{
    NSLog(@"定位完成");
    [self.mapView setCompassPosition:CGPointMake(_mapView.frame.size.width - 60,10)];      //指南针
    self.mapView.showMapScaleBar = YES;                         //比例尺
    self.mapView.mapScaleBarPosition = CGPointMake(10, _mapView.frame.size.height - 68);
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{   //坐标更新
    NSLog(@"经纬度: lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    userLocation.title = nil;
    self.userLocation = userLocation;
    [_mapView updateLocationData:userLocation];
    [_mapView setCenterCoordinate:userLocation.location.coordinate];
    [_locationService stopUserLocationService];       //关闭定位
    
    ///MARK: 设置位置
    BMKPointAnnotation* userAnnotation = [[BMKPointAnnotation alloc]init];
    userAnnotation.coordinate = userLocation.location.coordinate;
    [_mapView addAnnotation:userAnnotation];
    
    ///MARK: GeoCode 获取当前城市信息
    BMKReverseGeoCodeOption *reverseGeoCodeOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeOption.reverseGeoPoint = userLocation.location.coordinate;
    [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
    [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{  //数据显示
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([BMKPointAnnotation class])];
        if(!annotationView){
            annotationView = [[BMKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([BMKPointAnnotation class])];
            annotationView.image = [UIImage imageNamed:@"userLocation"];        ///显示用户当前位置
        }
        return annotationView;
    }
    
    NYBCustomPinAnnotationView *annotationView = (NYBCustomPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([NYBCustomPinAnnotationView class])];
    if (!annotationView) {
        annotationView = [[NYBCustomPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([NYBCustomPinAnnotationView class])];
    }
    
    NYBAnnotation *NYB_Annotation = (id)annotation;
    switch (NYB_Annotation.userInfoModel.type) {
        case NYBBatteryStatusTypeGreenColor:
        {
            NSLog(@"绿色大头针标记");
            [annotationView InitDataBaiDuWithModel:NYB_Annotation.userInfoModel];
        }
            break;
        case NYBBatteryStatusTypeRedColor:
        {
            NSLog(@"红色大头针标记");
            [annotationView InitDataBaiDuWithModel:NYB_Annotation.userInfoModel];
        }
            break;
        default:
            break;
    }
    
    annotationView.canShowCallout = NO;
    return annotationView;
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {      //滑动地图
    CLLocationCoordinate2D carLocation = [_mapView convertPoint:self.view.center toCoordinateFromView:self.view];
    BMKReverseGeoCodeOption *option = [[BMKReverseGeoCodeOption alloc] init];
    option.reverseGeoPoint = CLLocationCoordinate2DMake(carLocation.latitude, carLocation.longitude);
    NSLog(@"滑动地图经纬度:%f=%f", option.reverseGeoPoint.latitude, option.reverseGeoPoint.longitude);
    [self.annotationArray removeAllObjects];
    NSArray* array = [NSArray arrayWithArray:mapView.annotations];
    for (int i = 0; i < [array count]; i ++) {
        if ([array[i] isKindOfClass:[NYBAnnotation class]]) {
            [mapView removeAnnotation:array[i]];
        }
    }
    ///MARK: 移除大头针
    [_mapView removeAnnotation:self.MyAnnotation];
    //重新请求数据
    [self mapRequstWithreverseGeoPoint:option.reverseGeoPoint];
}



/**
 * 点击大头针请求参数

 @param model model description
 @return return value description
 */
-(NSMutableDictionary *)MerchantPargram:(NYBAnnotationUserInfo *)model{
    NSMutableDictionary *pargram = [NSMutableDictionary dictionary];
    [pargram setValue:[NYBUserDefault objectForKey:@"gid"] forKey:@"ems_gid"];
    [pargram setValue:@(model.ID.integerValue) forKey:@"gid"];
    return pargram;
}

/**
 * 点击大头针跳转
 @param mapView mapView description
 @param view view description
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{        ///点击大头针
    NSLog(@"点击大头针");
    if ([ view isKindOfClass:[NYBCustomPinAnnotationView class ]]){
        _MyAnnotation = (id)view.annotation;
        ///点击大头针跳转到回收列表
        NYBAnnotationUserInfo *merchantModel = _MyAnnotation.userInfoModel;
        NSDictionary *pargram = [self MerchantPargram:merchantModel];
//        [NYBRequestManger GetMerchantPointWithPargarm:pargram CompleteSuccessfull:^(id responseObject) {
//            NYBMerchantViewController *MerchantViewCtrl = [[NYBMerchantViewController alloc] initWithNibName:nil bundle:nil NetDotGid:@(merchantModel.ID.integerValue) NetDotUid:@(merchantModel.uid.integerValue) NetDotAreaId:@(merchantModel.area_id.integerValue) shopTitle:merchantModel.gname userName:merchantModel.uname imageURL:merchantModel.img_url userAddress:merchantModel.address phone:merchantModel.phone];
//            MerchantViewCtrl.hidesBottomBarWhenPushed =YES;
//            [self.navigationController pushViewController:MerchantViewCtrl animated:YES];
//        } failure:^(NSError *error, NSDictionary *errorInfor) {
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            hud.labelText = convertToString(errorInfor[@"message"]);
//            hud.removeFromSuperViewOnHide = YES;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [hud hide:YES];
//            });
//        }];
    }
}

-(void)mapRequstWithreverseGeoPoint:(CLLocationCoordinate2D)coordinate{     ///服务器请求数据
    WS(weakSelf);
    NSMutableDictionary *pargram = [NSMutableDictionary dictionary];
    [pargram setObject:(NSNumber *)[NYBUserDefault objectForKey:@"gid"] forKey:@"ems_id"];
//    [NYBRequestManger GetWaitPickListWithPargarm:pargram CompleteSuccessfull:^(id responseObject) {
//        if (responseObject) {
//            NSArray *dictArray = responseObject[@"list"];
//            if (dictArray.count == 0) { return  ;}
//            for ( NSDictionary *Detaildict in dictArray) {
//                NYBAnnotationUserInfo *model = [NYBAnnotationUserInfo mj_objectWithKeyValues:Detaildict];
//                //添加大头针
//                NYBAnnotation* annotation = [[NYBAnnotation alloc]init];
//                CLLocationCoordinate2D coor;
//                coor = CLLocationCoordinate2DMake([model.area_x doubleValue], [model.area_y doubleValue]);
//                annotation.coordinate = coor;
//                annotation.userInfoModel = model;
//                [weakSelf.annotationArray addObject:annotation];
//                [weakSelf.mapView addAnnotations:weakSelf.annotationArray];
//            }
//        }
//    } failure:^(NSError *error, NSDictionary *errorInfor) {
//        NSLog(@"网络请求服务器失败%@",error);
//    }];
}



-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error { // 根据坐标返回反地理编码搜索结果
    
    BMKAddressComponent *addressComponent = result.addressDetail;
    NSLog(@"根据坐标返回反地理编码搜索结果:%@",addressComponent.city);
}


/**
 * 点击事件
 
 @param sender sender description
 */
-(void)dothings:(UIButton *)sender{
    
    switch (sender.tag-100) {
        case 1:
        {
            NSLog(@"定位位置");
            BMKCoordinateRegion region ;//表示范围的结构体
            region.center = self.userLocation.location.coordinate;
            region.span.latitudeDelta = 0.1;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
            region.span.longitudeDelta = 0.1;//纬度范围
            [_mapView setRegion:region animated:YES];
        }
            break;
        case 2:
        {
            NSLog(@"地图放大");
            if (_mapView.zoomLevel >16) {
                _mapView.zoomLevel = 16;
            }else{
                _mapView.zoomLevel += 1;
            }
            
        }
            break;
        case 3:
        {
            NSLog(@"地图缩小");
            if (_mapView.zoomLevel <10) {
                _mapView.zoomLevel = 10;
            }else{
                _mapView.zoomLevel -= 1;
            }
        }
            break;
            
        default:
            break;
    }
    
}

/**
 * 初始化
 
 @return return value description
 */

-(void)initWithMap{
    [self.view addSubview:self.mapView];
    [self.mapView addSubview:self.userLoctionButton];
    [self.mapView addSubview:self.maxZoomButton];
    [self.mapView addSubview:self.minZoomButton];
    self.mapView.frame =CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT - NavBarHeight - HS_TabbarHeight);      ///此处不能用Masony 不然mapPadding不合法
    self.mapView.mapPadding = UIEdgeInsetsMake(0, 0, 28, 0);
    [self.locationService startUserLocationService]; //打开定位服务
    
    [self.userLoctionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mapView).mas_offset(-20.0);
        make.right.mas_equalTo(self.mapView).mas_offset(-20.0);
        make.width.height.mas_equalTo(40.0);
    }];
    [self.minZoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.userLoctionButton.mas_top).mas_offset(-20.0);
        make.right.mas_equalTo(self.mapView).mas_offset(-20.0);
        make.width.height.mas_equalTo(40.0);
    }];
    [self.maxZoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.minZoomButton.mas_top).mas_offset(-10.0);
        make.right.mas_equalTo(self.mapView).mas_offset(-20.0);
        make.width.height.mas_equalTo(40.0);
    }];
}

-(BMKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[BMKMapView alloc]init];
        _mapView.backgroundColor = [UIColor whiteColor];
        _mapView.mapType = BMKMapTypeStandard ;//标准地图
        _mapView.showsUserLocation = NO;
        _mapView.userTrackingMode = BMKUserTrackingModeFollow ;//定位跟随模式
        _mapView.zoomLevel = 14;        //当前
        _mapView.minZoomLevel = 10;
        _mapView.maxZoomLevel = 16;
        _mapView.delegate = self;
        _mapView.overlookEnabled = YES; //设定地图View能否支持俯仰角
        _mapView.buildingsEnabled = YES;//设定地图是否现显示3D楼块效果
    }
    return _mapView;
}

- (BMKLocationService *)locationService{
    if(!_locationService){
        _locationService=[[BMKLocationService alloc] init];
        _locationService.desiredAccuracy=kCLLocationAccuracyBest;
        _locationService.delegate=self;
        _locationService.distanceFilter = 20;//设定定位的最小更新距离，这里设置 100m 定位一次，频繁定位
        _locationService.desiredAccuracy = kCLLocationAccuracyBest;//设定定位精度
        
    }
    return _locationService;
}

-(UIButton *)userLoctionButton{
    if (!_userLoctionButton) {
        _userLoctionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userLoctionButton setImage:[UIImage imageNamed:@"bnavi_icon_location"] forState:UIControlStateNormal];
        _userLoctionButton.tag = 101;
        [_userLoctionButton addTarget:self action:@selector(dothings:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _userLoctionButton;
}

-(UIButton *)maxZoomButton{
    if (!_maxZoomButton) {
        _maxZoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_maxZoomButton setTitle:@"+" forState:UIControlStateNormal];
        [_maxZoomButton setTitleColor:UIColorFromRGB(0x17BAEF) forState:UIControlStateNormal];
        [_maxZoomButton setTitleColor:UIColorFromRGB(0x17BAEF) forState:UIControlStateHighlighted];
        [_maxZoomButton setBackgroundColor:[UIColor whiteColor]];
        _maxZoomButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _maxZoomButton.tag = 102;
        [_maxZoomButton addTarget:self action:@selector(dothings:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _maxZoomButton;
}

-(UIButton *)minZoomButton{
    if (!_minZoomButton) {
        _minZoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_minZoomButton setTitle:@"-" forState:UIControlStateNormal];
        _minZoomButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_minZoomButton setTitleColor:UIColorFromRGB(0x17BAEF) forState:UIControlStateNormal];
        [_minZoomButton setTitleColor:UIColorFromRGB(0x17BAEF) forState:UIControlStateHighlighted];
        [_minZoomButton setBackgroundColor:[UIColor whiteColor]];
        _minZoomButton.tag = 103;
        [_minZoomButton addTarget:self action:@selector(dothings:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _minZoomButton;
}

- (NSMutableArray *)annotationArray {
    if (!_annotationArray) {
        _annotationArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _annotationArray;
}

/**
 * viewWillAppear
 
 @param animated animated description
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.mapView.delegate = self;
    self.locationService.delegate = self;
    [_mapView viewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    self.mapView.delegate=nil;
    self.locationService.delegate = nil;
}

-(void)dealloc{
    NSLog(@"MAP ==dealloc");
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

