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
    NSString *Put_Dest_Url = [ud stringForKey:@"Put_Dest_Url"];
    
    // 画面項目への設定
    userSettings = [NSMutableDictionary dictionary];
    [userSettings setObject:Put_Dest_Url forKey:@"Put_Dest_Url"];
    [userSettings setObject:@"送信記録なし" forKey:@"Send_Result"];
    
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
        case 1: 
            return @"送信ログ";
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
    
    // Configure the cell...
    switch(indexPath.section) {
        case 0:
            cell.textLabel.text = [userSettings objectForKey:@"Put_Dest_Url"];
            break;
        case 1:
            cell.textLabel.text = [userSettings objectForKey:@"Send_Result"];
            break;
    }
    return cell;
}

- (IBAction)saveButton_Touched:(id)sender {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    [ud setObject:@"http://www.kaji-3.com" forKey:@"Put_Dest_Url"];
    [ud synchronize];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
