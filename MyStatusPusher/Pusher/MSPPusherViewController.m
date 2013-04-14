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
    MKMapView *mapView = (MKMapView*)[self.view viewWithTag:4];
    UITextView *textView = (UITextView*)[self.view viewWithTag:2];
    
    [mapView setRegion:region animated:true];
    
    // 非同期通信で特定サーバ
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(globalQueue, ^{
        
        //時間のかかる処理
        int count = 0, i;
        for(i = 0; i < 10000; i++){
            NSLog(@"count = %d", count);
            count++;
        }
        
        //メインスレッドで途中結果表示
        dispatch_async(mainQueue, ^{
            [self appendLog:[self logStringWithCount:count]];
        });
        
        //時間のかかる処理
        for(i = 0; i < 10000; i++){
            NSLog(@"count = %d", count);
            count++;
        }
        
        //メインスレッドで終了処理
        dispatch_async(mainQueue, ^{
            [self appendLog:[self logStringWithCount:count]];
            //[_indicatorView stopAnimating];
            //_startButton.hidden = NO;
        });
    });
}

- (NSString *)logStringWithCount:(int)count
{
    return [NSString stringWithFormat:@"count is %d", count];
}

- (void)appendLog:(NSString *)log
{
    //_logView.text = [NSString stringWithFormat:@"%@\n%@", _logView.text, log];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
