//
//  MSPPusherViewController.h
//  MyStatusPusher
//
//  Created by y_kajikawa on 13/04/07.
//  Copyright (c) 2013年 y_kajikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MSPPusherViewController : UIViewController <CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
}

@end
