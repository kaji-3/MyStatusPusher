//
//  MSPSettingViewController.m
//  MyStatusPusher
//
//  Created by y_kajikawa on 13/04/06.
//  Copyright (c) 2013年 y_kajikawa. All rights reserved.
//

#import "MSPSettingViewController.h"

@interface MSPSettingViewController ()

@end

@implementation MSPSettingViewController

@synthesize userSettings;
@synthesize myTableView;

NSString * const SETTING_KEY_OF_POST_DEST_URL = @"Put_Dest_Url";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 設定項目の取得
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *Put_Dest_Url = [ud stringForKey:SETTING_KEY_OF_POST_DEST_URL];
    
    if (Put_Dest_Url == nil) {
        Put_Dest_Url = @"http://www.kaji-3.com";
    }
    
    // 画面項目への設定
    userSettings = [NSMutableDictionary dictionary];
    [userSettings setObject:Put_Dest_Url forKey:SETTING_KEY_OF_POST_DEST_URL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

// セクション数の提供
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [userSettings count];
}

// セクション名の提供
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch(section) {
        case 0:
            return @"送信先URL";
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 1カテゴリ、1項目
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch(indexPath.section) {
        case 0:
            cell.textLabel.text = [userSettings objectForKey:SETTING_KEY_OF_POST_DEST_URL];
            break;

    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *message =
    [[UIAlertView alloc] initWithTitle:@"" message:@"変更値を入力してください"
                              delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    UITextField *textField = [message textFieldAtIndex:0];
    //TODO 表示値と設定値で何を参考にするか確定すること
    [textField setText:[userSettings objectForKey:SETTING_KEY_OF_POST_DEST_URL]];
    [message show];
    
}

// AlertView delegete
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==1) {
        NSString* chengedValue = [[alertView textFieldAtIndex:0] text];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        //TODO 表示値と設定値で何を参考にするか確定すること
        [ud setObject:chengedValue forKey:SETTING_KEY_OF_POST_DEST_URL];
        [ud synchronize];
    }
    

}



@end
