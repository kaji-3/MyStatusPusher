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
#import "MSPSettingViewController.h"

@interface MSPPusherViewController ()

@end

@implementation MSPPusherViewController

const int MAP_VIEW_TAG = 4;
const int TEXT_VIEW_TAG = 2;


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
    if ([self isSameLocation:newLocation compareTo:oldLocation]) {
        return;
    }
    
    // 表示範囲の指定
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005f, 0.005f);
    
    // 更新された位置をマップの中心に設定
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    MKMapView *mapView = (MKMapView*)[self.view viewWithTag:MAP_VIEW_TAG];
    [mapView setRegion:region animated:true];
    
    // 非同期通信で特定サーバへの送信
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(globalQueue, ^{
        //TODO リクエストIDを作成する
        NSString* requestUUID = [self uuidWithCreated2String];
        
        //TODO 送信パラメータを書き込み
        dispatch_async(mainQueue, ^{
            [self appendLog:
             [NSString stringWithFormat:@"%@ %@ %@",@"送信開始...",[self location2String:newLocation], requestUUID]];
        });

        
        //時間のかかる処理
        NSString* result = [self postData2Server:newLocation requestId:requestUUID];
        
        //メインスレッドで終了処理
        dispatch_async(mainQueue, ^{
            [self appendLog:[NSString stringWithFormat:@"%@ %@ %@",@"送信完了!", result, requestUUID]];
        });
    });
}

// ２つの場所を比較する
- (BOOL) isSameLocation: (CLLocation *) newLocation compareTo:(CLLocation *) oldLocation
{
    
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    CLLocationCoordinate2D oldCoordinate = oldLocation.coordinate;

    return (fabs(coordinate.latitude - oldCoordinate.latitude) < FLT_EPSILON
            && fabs(coordinate.longitude - oldCoordinate.longitude) < FLT_EPSILON);
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
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *Put_Dest_Url = [ud stringForKey:SETTING_KEY_OF_POST_DEST_URL];
    
    NSMutableURLRequest *request;
    request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:Put_Dest_Url]
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

//CLLocation情報をNSStringに変換
- (NSString*) location2String: (CLLocation *)newLocation
{
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    return [NSString stringWithFormat:@"緯度%f 経度 %f", coordinate.latitude, coordinate.longitude];
}

// UUIDオブジェクトを作成、文字列として返す
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
    UITextView *textView = (UITextView*)[self.view viewWithTag:TEXT_VIEW_TAG];
    textView.text = [NSString stringWithFormat:@"%@\n%@", log, textView.text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
