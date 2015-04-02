//
//  SettingsViewController.m
//  Flyr1
//
//  Created by Rachel Pinsker on 1/14/15.
//  Copyright (c) 2015 ___rpinsker___. All rights reserved.
//

#import "MoreViewController.h"
#import "ShareViewController.h"
#import "SettingsViewController.h"
#import <Parse/Parse.h>

@interface MoreViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *moreTableView;

@end

#define NUM_CELLS 3
#define LOGOUT 2
#define CREATE_EVENT 1
#define SETTINGS 0
#define FONT_STRING @"AvenirNext-Medium"

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    // initialize table view
    self.moreTableView = [[UITableView alloc] initWithFrame:self.view.frame
                                                      style:UITableViewStylePlain];
    self.moreTableView.backgroundColor = [UIColor clearColor];
    self.moreTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.moreTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.moreTableView.dataSource = self;
    self.moreTableView.delegate = self;
    
    [self.view addSubview:self.moreTableView];
    
    
}

#pragma mark -- TABLE VIEW

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUM_CELLS;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.moreTableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (indexPath.row == CREATE_EVENT)
        [cell.textLabel setText:@"Create Event"];
    else if (indexPath.row == SETTINGS)
        [cell.textLabel setText:@"Settings"];
    else if (indexPath.row == LOGOUT)
        [cell.textLabel setText:@"Logout"];
    
    cell.backgroundColor = [UIColor colorWithWhite:.1 alpha:.5];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:FONT_STRING size:20.0];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == CREATE_EVENT) {
        // create event
        NSLog(@"event");
    }
    else if (indexPath.row == SETTINGS) {
        // settings
        SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
        [self.navigationController pushViewController:settingsVC animated:YES];
    }
    else if (indexPath.row == LOGOUT) {
        // logout
        [PFUser logOut];
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            NSLog(@"%@",vc);
        }
        ShareViewController *shareVC = self.navigationController.viewControllers.firstObject;
        shareVC.isLogout = YES;
        [self.navigationController popToViewController:shareVC animated:NO];

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
