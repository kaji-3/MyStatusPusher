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
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    CLLocationCoordinate2D oldCoordinate = oldLocation.coordinate;
    if (fabs(coordinate.latitude - oldCoordinate.latitude) < FLT_EPSILON
        && fabs(coordinate.longitude - oldCoordinate.longitude) < FLT_EPSILON) {
        return;
    }
    
    // 表示範囲の指定
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005f, 0.005f);
    
    // 更新された位置をマップの中心に設定

    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    MKMapView *mapView = (MKMapView*)[self.view viewWithTag:4];
    
    [mapView setRegion:region animated:true];
    
    // 非同期通信で特定サーバへの送信
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(globalQueue, ^{
        //TODO リクエストIDを作成する
        NSString* theUUID = [self uuidWithCreated2String];

        //メインスレッドで途中結果表示
        
        //TODO 送信パラメータを書き込み
        dispatch_async(mainQueue, ^{
            [self appendLog:
             [NSString stringWithFormat:@"%@ %@ %@",@"送信開始...",[self location2String:newLocation], theUUID]];
        });

        
        //時間のかかる処理
        NSString* result = [self postData2Server:newLocation requestId:theUUID];
                
        
        //時間のかかる処理
        [NSThread sleepForTimeInterval:0.5];
        
        //メインスレッドで終了処理
        dispatch_async(mainQueue, ^{
            [self appendLog:[NSString stringWithFormat:@"%@ %@ %@",@"送信完了!", result, theUUID]];
        });
    });
}

- (NSString*) postData2Server: (CLLocation *)newLocation
                    requestId:(NSString*) requestID
{
    //位置情報から座標の取得
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    
    //送信するパラメータの組み立て
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    [mutableDic setValue:[NSNumber numberWithDouble:coordinate.latitude] forKey:@"latitude"];
    [mutableDic setValue:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"longitude"];
    //TODO NSDate のシリアライズ化
    [mutableDic setValue:[self date2String:newLocation.timestamp] forKey:@"timestamp"];
    [mutableDic setValue:requestID forKey:@"requestID"];
    
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
    return responseString;
}

- (NSString*) location2String: (CLLocation *)newLocation
{
    //位置情報取得時刻


    //取得位置
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    return [NSString stringWithFormat:@"緯度%f 経度 %f", coordinate.latitude, coordinate.longitude];
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
    NSDateFormatter* form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"G yyyy/MM/dd HH:mm:ss"];
    return [form stringFromDate:timestamp];
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
