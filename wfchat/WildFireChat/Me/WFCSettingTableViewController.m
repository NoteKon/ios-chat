//
//  SettingTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/6.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCSettingTableViewController.h"
#import <WFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>
#import <WFChatUIKit/WFChatUIKit.h>
#import "WFCSecurityTableViewController.h"
#import "WFCAboutViewController.h"
#import "WFCPrivacyViewController.h"
#import "WFCPrivacyTableViewController.h"
#import "WFCDiagnoseViewController.h"
#import "UIColor+YH.h"
#import "UIFont+YH.h"
#import "WFCThemeTableViewController.h"
#import "AppService.h"


@interface WFCSettingTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)UITableView *tableView;
@end

@implementation WFCSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor =  [UIColor colorWithHexString: @"#FBFBFB"];
    self.tableView.separatorColor = [WFCUConfigManager globalManager].separateColor;
    self.title = LocalizedString(@"Settings");
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.sectionHeaderHeight = 12;
    self.tableView.sectionFooterHeight = 0.01;

    [self.tableView reloadData];
    
    [self.view addSubview:self.tableView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        WFCPrivacyTableViewController *pvc = [[WFCPrivacyTableViewController alloc] init];
        pvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pvc animated:YES];
    } else {
        [self.view makeToast:@"敬请期待"];
    }
}

//#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { // 隐私设置
        return 1;
    } else if (section == 1) {
        return 4;
    } else if (section == 2) { //logout
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"style1Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"style1Cell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    cell.textLabel.textColor = [UIColor blackColor];
    if(indexPath.section == 0) {
        cell.textLabel.text = LocalizedString(@"settings_private_set");
    } else if(indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = LocalizedString(@"settings_about");
        } if (indexPath.row == 1) {
            cell.textLabel.text = LocalizedString(@"settings_judge");
        } else if (indexPath.row == 2) {
            cell.textLabel.text = LocalizedString(@"settings_upload_msg");
        } else if (indexPath.row == 3) {
            cell.textLabel.text = LocalizedString(@"settings_improve");
        }
    } else if(indexPath.section == 2) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"buttonCell"];
        for (UIView *subView in cell.subviews) {
            [subView removeFromSuperview];
        }
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(-5, 0, self.view.frame.size.width + 10, 50)];
        [btn setTitle:LocalizedString(@"Logout") forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onLogoutBtn:) forControlEvents:UIControlEventTouchUpInside];
        if (@available(iOS 14, *)) {
            [cell.contentView addSubview:btn];
        } else {
            [cell addSubview:btn];
        }
    }
    
    return cell;
}

- (void)onLogoutBtn:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedToken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedUserId"];
    [[AppService sharedAppService] clearAppServiceAuthInfos];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //退出后就不需要推送了，第一个参数为YES
    //如果希望再次登录时能够保留历史记录，第二个参数为NO。如果需要清除掉本地历史记录第二个参数用YES
    [[WFCCNetworkService sharedInstance] disconnect:YES clearSession:NO];
}
@end
