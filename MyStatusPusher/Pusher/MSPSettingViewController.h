//
//  MSPSettingViewController.h
//  MyStatusPusher
//
//  Created by y_kajikawa on 13/04/06.
//  Copyright (c) 2013年 y_kajikawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSPSettingViewController : UITableViewController

// 設定項目一覧
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong) NSMutableDictionary *userSettings;

@end
