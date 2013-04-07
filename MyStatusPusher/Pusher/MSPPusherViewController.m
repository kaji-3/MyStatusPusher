//
//  MSPPusherViewController.m
//  MyStatusPusher
//
//  Created by y_kajikawa on 13/04/07.
//  Copyright (c) 2013年 y_kajikawa. All rights reserved.
//

#import "MSPPusherViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MSPPusherViewController ()

@end

@implementation MSPPusherViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 位置情報の取得
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    if ([CLLocationManager locationServicesEnabled]) {
        [_locationManager startUpdatingLocation];
    }
}

// 位置情報更新時に呼ばれるハンドラ
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    
    // 表示範囲の指定
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005f, 0.005f);
    
    // 更新された位置をマップの中心に設定
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    MKMapView *mapView = (MKMapView*) self.view;
    [mapView setRegion:region animated:true];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
