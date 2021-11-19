//
//  WFCUVerifyRequestViewController.m
//  WFChatUIKit
//
//  Created by WF Chat on 2018/11/4.
//  Copyright © 2018 WF Chat. All rights reserved.
//

#import "WFCUVerifyRequestViewController.h"
#import <WFChatClient/WFCChatClient.h>
#import "MBProgressHUD.h"
#import "WFCUConfigManager.h"


@interface WFCUVerifyRequestViewController ()<UITextFieldDelegate>
@property(nonatomic, strong)UITextField *verifyField;
@property (nonatomic, strong) UIView *lineView;
@end

@implementation WFCUVerifyRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect clientArea = self.view.bounds;
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 23 + kStatusBarAndNavigationBarHeight, clientArea.size.width - 16, 16)];
    hintLabel.text = WFCString(@"AddFriendReasonHint");
    hintLabel.font = [UIFont systemFontOfSize:14];
    hintLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.view addSubview:hintLabel];
    self.view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    
    self.verifyField = [[UITextField alloc] initWithFrame:CGRectMake(21, 73 + kStatusBarAndNavigationBarHeight, clientArea.size.width - 21 * 2, 32)];
    self.verifyField.delegate = self;
    self.verifyField.tintColor = [WFCUConfigManager globalManager].textFieldColor;
    WFCCUserInfo *me = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFCCNetworkService sharedInstance].userId refresh:NO];
    self.verifyField.font = [UIFont systemFontOfSize:16];
    if(me.displayName){
        self.verifyField.text = [NSString stringWithFormat:WFCString(@"DefaultAddFriendReason"), me.displayName];
    }else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(!self.verifyField.text) {
                WFCCUserInfo *me = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFCCNetworkService sharedInstance].userId refresh:NO];
                if (me.displayName) {
                    self.verifyField.text = [NSString stringWithFormat:WFCString(@"DefaultAddFriendReason"), me.displayName];
                } else {
                    self.verifyField.text = WFCString(@"DefaultAddFriendReason");
                }
            }
        });
    }
    self.verifyField.borderStyle = UITextBorderStyleNone;
    self.verifyField.clearButtonMode = UITextFieldViewModeAlways;
    
    
    [self.view addSubview:self.verifyField];
    [self.view addSubview:self.lineView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:WFCString(@"Send") style:UIBarButtonItemStyleDone target:self action:@selector(onSend:)];
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(_verifyField.frame.origin.x, _verifyField.frame.origin.y + _verifyField.frame.size.height + 10, _verifyField.frame.size.width, 0.5)];
        _lineView.backgroundColor = [WFCUConfigManager globalManager].separateColor;
    }
    return _lineView;
}

- (void)onSend:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = WFCString(@"Sending");
    [hud showAnimated:YES];
    
    NSString *extraStr = nil;
//    if(self.sourceType) {
//        NSMutableDictionary *sourceDict = [[NSMutableDictionary alloc] init];
//        [sourceDict setValue:@(self.sourceType) forKey:@"t"/*type*/];
//        [sourceDict setValue:self.sourceTargetId forKey:@"i"/*targetId*/];
//        NSDictionary *extraDict = @{@"s"/*source*/:sourceDict};
//        
//        NSData *extraData = [NSJSONSerialization dataWithJSONObject:extraDict
//                                                                               options:kNilOptions
//                                                                                 error:nil];
//        extraStr = [[NSString alloc] initWithData:extraData encoding:NSUTF8StringEncoding];
//    }
    
    __weak typeof(self) ws = self;
    [[WFCCIMService sharedWFCIMService] sendFriendRequest:self.userId reason:self.verifyField.text extra:extraStr success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = WFCString(@"Sent");
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
            [ws.navigationController popViewControllerAnimated:YES];
        });
    } error:^(int error_code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = WFCString(@"SendFailure");
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
        });
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    textField.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
    self.lineView.backgroundColor = HEXCOLOR(0x64EEED);
    return YES;
}

@end
