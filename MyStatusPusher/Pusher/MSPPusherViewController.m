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
    
    [mapView setRegion:region animated:true];
    
    // 非同期通信で特定サーバ
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(globalQueue, ^{
        CLLocationCoordinate2D coordinate = newLocation.coordinate;
        
        //時間のかかる処理
        [NSThread sleepForTimeInterval:0.5];
        
        //メインスレッドで途中結果表示
        dispatch_async(mainQueue, ^{
            [self appendLog:[NSString stringWithFormat:@"%@ %@",@"送信中...",[self location2String:newLocation]]];
        });
        
        //時間のかかる処理
        [NSThread sleepForTimeInterval:0.5];
        
        //メインスレッドで終了処理
        dispatch_async(mainQueue, ^{
            [self appendLog:[NSString stringWithFormat:@"%@ %@",@"送信完了...",[self location2String:newLocation]]];
        });
    });
}

- (NSString*) location2String: (CLLocation *)newLocation
{
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    // NSDateFormatterのインスタンス生成
    NSDateFormatter* form = [[NSDateFormatter alloc] init];
    
    // NSDateFormatterに書式指定を行う
    [form setDateFormat:@"G yyyy/MM/dd(EEE) K:mm:ss"];
    
    // 書式指定に従って文字出力
    NSString* str = [form stringFromDate:[newLocation timestamp]];
    
    return [NSString stringWithFormat:@"%@ 緯度%f 軽度 %f", str, coordinate.latitude, coordinate.longitude];
    //return @"hoge";
}


- (void)appendLog:(NSString *)log
{
    UITextView *textView = (UITextView*)[self.view viewWithTag:2];
    textView.text = [NSString stringWithFormat:@"%@\n%@", log, textView.text];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
