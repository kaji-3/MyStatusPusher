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
    
    //位置変更時の確認
    //TODO 実装
    
    // 表示範囲の指定
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005f, 0.005f);
    
    // 更新された位置をマップの中心に設定
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    MKMapView *mapView = (MKMapView*)[self.view viewWithTag:4];
    
    [mapView setRegion:region animated:true];
    
    // 非同期通信で特定サーバへの送信
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(globalQueue, ^{
        //TODO リクエストIDを作成する

        //メインスレッドで途中結果表示
        dispatch_async(mainQueue, ^{
            [self appendLog:
             [NSString stringWithFormat:@"%@ %@",@"送信開始...",[self location2String:newLocation]]];
        });

        
        //時間のかかる処理
        NSString* result = [self postData2Server:newLocation];
                
        
        //時間のかかる処理
        [NSThread sleepForTimeInterval:0.5];
        
        //メインスレッドで終了処理
        dispatch_async(mainQueue, ^{
            [self appendLog:
                [NSString stringWithFormat:@"%@ %@",@"送信完了...",[self location2String:newLocation]]];
        });
    });
}

- (NSString*) postData2Server: (CLLocation *)newLocation
{
    //送信するパラメータの組み立て
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    [mutableDic setValue:@"2013/04/21" forKey:@"latitude"];
    [mutableDic setValue:@"10" forKey:@"longitude"];
    [mutableDic setValue:@"10" forKey:@"timestamp"];
    
    //Dictionary -> String(JSON)
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:mutableDic options:NSJSONWritingPrettyPrinted error:&err];
    NSString *requestData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(requestData);
        
    NSMutableURLRequest *request;
    request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.kaji-3.com/"]
                            cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    //HTTPメソッドは"POST"
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d",
                       [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: data];
    
    //レスポンス
    NSURLResponse *resp;
    NSError *responseErr;
    
    //HTTPリクエスト送信
    NSData *result = [NSURLConnection sendSynchronousRequest:request 
                                           returningResponse:&resp error:&responseErr];
    //結果処理
    NSString *responseString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSLog(responseString);
    
    return @"OK :-D";
}

- (NSString*) location2String: (CLLocation *)newLocation
{
    //位置情報取得時刻
    NSDateFormatter* form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"G yyyy/MM/dd(EEE) K:mm:ss"];
    NSString* str = [form stringFromDate:[newLocation timestamp]];

    //取得位置
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    return [NSString stringWithFormat:@"%@ 緯度%f 軽度 %f", str, coordinate.latitude, coordinate.longitude];
}

// UUID作成メソッド
- (NSString*) uuidWithCreated2String
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    CFStringRef string = CFUUIDCreateString(NULL, uuidObj);
    CFRelease(uuidObj);
    return (__bridge_transfer NSString *)string;
}

// 日付文字列化メソッド
- (NSString*) date2String:(NSDate*)timestamp
{
    //TODO 実装
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
