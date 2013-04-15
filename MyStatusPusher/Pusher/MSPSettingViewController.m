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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

// セクション数の提供
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    return  [[[NSUserDefaults standardUserDefaults] persistentDomainForName:appDomain] count];;
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
        {
            cell.textLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:SETTING_KEY_OF_POST_DEST_URL];
        }
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
    [textField setText:[[NSUserDefaults standardUserDefaults] stringForKey:SETTING_KEY_OF_POST_DEST_URL]];
    [message show];
    
}

// AlertView delegete
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==1) {
        NSString* changedValue = [[alertView textFieldAtIndex:0] text];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:changedValue forKey:SETTING_KEY_OF_POST_DEST_URL];
        [ud synchronize];
    }
}



@end
