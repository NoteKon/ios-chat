//
//  WFCLoginViewController.m
//  Wildfire Chat
//
//  Created by WF Chat on 2017/7/9.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCLoginViewController.h"
#import <WFChatClient/WFCChatClient.h>
#import <WFChatUIKit/WFChatUIKit.h>
//#import "AppDelegate.h"
#import "WFCBaseTabBarController.h"
#import "MBProgressHUD.h"
#import "UILabel+YBAttributeTextTapAction.h"
#import "WFCPrivacyViewController.h"
#import "AppService.h"
#import "UIColor+YH.h"
#import "UIFont+YH.h"

//是否iPhoneX YES:iPhoneX屏幕 NO:传统屏幕
#define kIs_iPhoneX ([UIScreen mainScreen].bounds.size.height == 812.0f ||[UIScreen mainScreen].bounds.size.height == 896.0f ||[UIScreen mainScreen].bounds.size.height == 844.0f ||[UIScreen mainScreen].bounds.size.height == 926.0f)

#define kStatusBarAndNavigationBarHeight (kIs_iPhoneX ? 88.f : 64.f)

#define  kTabbarSafeBottomMargin        (kIs_iPhoneX ? 34.f : 0.f)

#define HEXCOLOR(rgbValue)                                                                                             \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
alpha:1.0]

@interface WFCLoginViewController () <UITextFieldDelegate>
@property (strong, nonatomic) UIImageView *topImageView;
@property (strong, nonatomic) UITextField *userNameField;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UIButton *loginBtn;

@property (strong, nonatomic) UIView *userNameLine;
@property (strong, nonatomic) UIView *passwordLine;

@property (strong, nonatomic) UIButton *sendCodeBtn;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, assign) NSTimeInterval sendCodeTime;
@property (nonatomic, strong) UILabel *privacyLabel;
@end

@implementation WFCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    NSString *savedName = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedName"];
    CGFloat topPos = kStatusBarAndNavigationBarHeight + 65;
    
    self.topImageView = [[UIImageView alloc] init];
    self.topImageView.image = [UIImage imageNamed:@"login_top"];
    [self.view addSubview:self.topImageView];
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(78, 96));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).with.offset(topPos);
    }];
    
    UIView *userNameContainer = [[UIView alloc] init];
    [self.view addSubview:userNameContainer];
    [userNameContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).with.offset(33);
        make.right.mas_equalTo(self.view).with.offset(-33);
        make.top.mas_equalTo(self.topImageView.mas_bottom).offset(61);
        make.height.mas_equalTo(75);
    }];
    
    UILabel *userNameLabel = [[UILabel alloc] init];
    userNameLabel.text = LocalizedString(@"login_phone");
    userNameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    userNameLabel.textColor = [UIColor colorWithHexString:@"0xA3A3A3"];
    [userNameContainer addSubview:userNameLabel];
    [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(userNameContainer);
        make.top.equalTo(userNameContainer.mas_top);
        make.height.mas_equalTo(15);
    }];
    
    UIButton *countryCodeBtn = [[UIButton alloc] init];
    countryCodeBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    [countryCodeBtn setTitle:@"+86 " forState:UIControlStateNormal];
    [countryCodeBtn setImage:[UIImage imageNamed:@"login_arrow"] forState:UIControlStateNormal];
    [countryCodeBtn setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
    [countryCodeBtn setTitleColor:[UIColor colorWithHexString:@"0x1E233A"] forState:UIControlStateNormal];
    [countryCodeBtn addTarget:self action:@selector(onConuntryCode:) forControlEvents:UIControlEventTouchDown];
    [userNameContainer addSubview:countryCodeBtn];
    [countryCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(userNameContainer);
        make.width.mas_greaterThanOrEqualTo(30).priority(20);
        make.top.equalTo(userNameLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(13);
    }];
    
    self.userNameField = [[UITextField alloc] init];
    self.userNameField.text = savedName;
    self.userNameField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.userNameField.textColor = [UIColor colorWithHexString:@"0x1E233A"];
    //self.userNameField.placeholder = @"请输入手机号(仅支持中国大陆号码)";
    self.userNameField.returnKeyType = UIReturnKeyNext;
    self.userNameField.keyboardType = UIKeyboardTypePhonePad;
    self.userNameField.delegate = self;
    self.userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.userNameField.tintColor = [UIColor colorWithHexString:@"0x3eeeed"];
    [self.userNameField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [userNameContainer addSubview:self.userNameField];
    [_userNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(countryCodeBtn.mas_centerY);
        make.left.equalTo(countryCodeBtn.mas_right).offset(5);
        make.width.mas_greaterThanOrEqualTo(100);
        make.right.equalTo(userNameContainer);
        make.height.mas_equalTo(30);
    }];
    
    self.userNameLine = [[UIView alloc] init];
    self.userNameLine.backgroundColor = [UIColor colorWithHexString:@"0x1E233A" alpha: 0.1];
    [userNameContainer addSubview:self.userNameLine];
    [self.userNameLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(userNameContainer.mas_bottom);
        make.height.mas_equalTo(0.5);
        make.left.right.equalTo(userNameContainer);
    }];
    
    UIView *passwordContainer  = [[UIView alloc] init];
    [self.view addSubview:passwordContainer];
    [passwordContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(userNameContainer.mas_left);
        make.right.equalTo(userNameContainer.mas_right);
        make.top.equalTo(userNameContainer.mas_bottom);
        make.height.mas_equalTo(60);
    }];
    
    UILabel *passwordLabel = [[UILabel alloc] init];
    passwordLabel.text = LocalizedString(@"login_vercode");
    passwordLabel.textColor = [UIColor colorWithHexString:@"0xA3A3A3"];
    passwordLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:17];
    [passwordContainer addSubview:passwordLabel];
    [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(passwordContainer.mas_left);
        make.top.equalTo(passwordContainer.mas_top).offset(21);
        make.height.mas_equalTo(15);
    }];
    
    self.passwordField = [[UITextField alloc] init];
    self.passwordField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    //self.passwordField.placeholder = @"请输入验证码";
    self.passwordField.returnKeyType = UIReturnKeyDone;
    self.passwordField.keyboardType = UIKeyboardTypeNumberPad;
    self.passwordField.delegate = self;
    self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordField.tintColor = [UIColor colorWithHexString:@"0x3eeeed"];
    [self.passwordField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [passwordContainer addSubview:self.passwordField];
    [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(passwordLabel.mas_right).offset(5);
        make.centerY.equalTo(passwordLabel.mas_centerY);
        make.width.mas_greaterThanOrEqualTo(100);
        make.height.mas_equalTo(30);
    }];
    
    self.sendCodeBtn = [[UIButton alloc] init];
    [self.sendCodeBtn setTitle:LocalizedString(@"login_send_vercode") forState:UIControlStateNormal];
    self.sendCodeBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12.45];
    self.sendCodeBtn.layer.cornerRadius = 5;
    [self.sendCodeBtn setTitleColor:[UIColor colorWithHexString:@"0x626262"] forState:UIControlStateNormal];
    [self.sendCodeBtn setTitleColor:[UIColor colorWithHexString:@"0x626262"] forState:UIControlStateSelected];
    [self.sendCodeBtn setBackgroundColor:[UIColor colorWithHexString:@"0xFFD767" alpha:0.3]];
    [self.sendCodeBtn addTarget:self action:@selector(onSendCode:) forControlEvents:UIControlEventTouchDown];
    self.sendCodeBtn.enabled = NO;
    [passwordContainer addSubview:self.sendCodeBtn];
    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_greaterThanOrEqualTo(81);
        make.height.mas_equalTo(30);
        make.top.equalTo(passwordContainer.mas_top).offset(13);
        make.left.equalTo(self.passwordField.mas_right).offset(5);
        make.right.equalTo(passwordContainer.mas_right).offset(-2.5);
    }];
    
    self.passwordLine = [[UIView alloc] init];
    self.passwordLine.backgroundColor = [UIColor colorWithHexString:@"0x1E233A" alpha: 0.1];
    [passwordContainer addSubview:self.passwordLine];
    [self.passwordLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(passwordContainer);
        make.bottom.equalTo(passwordContainer);
        make.height.mas_equalTo(0.5);
    }];
    
    self.loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 29 * 2, 48)];
    [self.loginBtn addTarget:self action:@selector(onLoginButton:) forControlEvents:UIControlEventTouchDown];
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = 24.f;
    [self.loginBtn setTitle:LocalizedString(@"login_action") forState:UIControlStateNormal];
    //self.loginBtn.backgroundColor = [UIColor colorWithHexString:@"0x59ECEB" alpha:0.4];
    [self.loginBtn setBackgroundImage:[self loginImage:NO] forState:UIControlStateNormal];
    
    [self.loginBtn setTitleColor:[UIColor colorWithHexString:@"0x1E233A"] forState:UIControlStateNormal];
    self.loginBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18];
    self.loginBtn.enabled = NO;
    UIColor *shadowColor = [UIColor colorWithRed:85/255.0 green:235/255.0 blue:234/255.0 alpha:0.79];
    [self.loginBtn addShadow:shadowColor offset:CGSizeMake(0, 2) opacity:1 radius:5];
    [self.view addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(29);
        make.right.equalTo(self.view).offset(-29);
        make.top.equalTo(passwordContainer.mas_bottom).offset(34);
        make.height.mas_equalTo(48);
    }];
    
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    if(self.isKickedOff) {
        self.isKickedOff = NO;
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:LocalizedString(@"login_tip") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle: LocalizedString(@"login_konw") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];

        [actionSheet addAction:actionCancel];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)onConuntryCode:(id)sender {
    NSLog(@"国际冠码选择");
}

- (void)onSendCode:(id)sender {
    self.sendCodeBtn.enabled = NO;
    [self.sendCodeBtn setTitle:LocalizedString(@"login_vercode_sending") forState:UIControlStateNormal];
    __weak typeof(self)ws = self;
    [[AppService sharedAppService] sendCode:self.userNameField.text success:^{
       [ws sendCodeDone:YES];
    } error:^(NSString * _Nonnull message) {
        [ws sendCodeDone:NO];
    }];
}

- (void)updateCountdown:(id)sender {
    int second = (int)([NSDate date].timeIntervalSince1970 - self.sendCodeTime);
    [self.sendCodeBtn setTitle:[NSString stringWithFormat:@"%ds", 60-second] forState:UIControlStateNormal];
    if (second >= 60) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
        [self.sendCodeBtn setTitle:LocalizedString(@"login_send_vercode") forState:UIControlStateNormal];
        self.sendCodeBtn.enabled = YES;
    }
}
- (void)sendCodeDone:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = LocalizedString(@"login_send_vercode_sucess");
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            self.sendCodeTime = [NSDate date].timeIntervalSince1970;
            self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                target:self
                                                                 selector:@selector(updateCountdown:)
                                                              userInfo:nil
                                                               repeats:YES];
            [self.countdownTimer fire];
            
            
            [hud hideAnimated:YES afterDelay:1.f];
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = LocalizedString(@"login_send_vercode_failed");
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.sendCodeBtn setTitle:LocalizedString(@"login_send_vercode") forState:UIControlStateNormal];
                self.sendCodeBtn.enabled = YES;
            });
        }
    });
}

- (void)resetKeyboard:(id)sender {
    [self.userNameField resignFirstResponder];
    self.userNameLine.backgroundColor = [UIColor colorWithHexString:@"0x1E233A" alpha: 0.1];
    [self.passwordField resignFirstResponder];
    self.passwordLine.backgroundColor = [UIColor colorWithHexString:@"0x1E233A" alpha: 0.1];
}

- (void)onLoginButton:(id)sender {
    NSString *user = self.userNameField.text;
    NSString *password = self.passwordField.text;
  
    if (!user.length || !password.length) {
        return;
    }
    
    [self resetKeyboard:nil];
    
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.label.text = LocalizedString(@"login_loging");
  [hud showAnimated:YES];
  
    [[AppService sharedAppService] login:user password:password success:^(NSString *userId, NSString *token, BOOL newUser) {
        [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"savedName"];
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"savedToken"];
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"savedUserId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
    //需要注意token跟clientId是强依赖的，一定要调用getClientId获取到clientId，然后用这个clientId获取token，这样connect才能成功，如果随便使用一个clientId获取到的token将无法链接成功。
        [[WFCCNetworkService sharedInstance] connect:userId token:token];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          [hud hideAnimated:YES];
            WFCBaseTabBarController *tabBarVC = [WFCBaseTabBarController new];
            tabBarVC.newUser = newUser;
            [UIApplication sharedApplication].delegate.window.rootViewController =  tabBarVC;
        });
    } error:^(int errCode, NSString *message) {
        NSLog(@"login error with code %d, message %@", errCode, message);
      dispatch_async(dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
          hud.label.text = LocalizedString(@"login_failed");
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:1.f];
      });
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userNameField) {
        [self.passwordField becomeFirstResponder];
    } else if(textField == self.passwordField) {
        [self onLoginButton:nil];
    }
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.userNameField) {
        self.userNameLine.backgroundColor = [UIColor colorWithHexString:@"0x3eeeed"];
        self.passwordLine.backgroundColor = [UIColor colorWithHexString:@"0x1E233A" alpha: 0.1];
    } else if (textField == self.passwordField) {
        self.userNameLine.backgroundColor = [UIColor colorWithHexString:@"0x1E233A" alpha: 0.1];
        self.passwordLine.backgroundColor = [UIColor colorWithHexString:@"0x3eeeed"];
    }
    return YES;
}
#pragma mark - UITextInputDelegate
- (void)textDidChange:(id<UITextInput>)textInput {
    if (textInput == self.userNameField) {
        [self updateBtn];
    } else if (textInput == self.passwordField) {
        [self updateBtn];
    }
}

- (void)updateBtn {
    if ([self isValidNumber]) {
        if (!self.countdownTimer) {
            self.sendCodeBtn.enabled = YES;
            [self.sendCodeBtn setBackgroundColor:[UIColor colorWithHexString:@"0xFFD767" alpha:0.8]];
        } else {
            self.sendCodeBtn.enabled = NO;
            [self.sendCodeBtn setBackgroundColor:[UIColor colorWithHexString:@"0xFFD767" alpha:0.3]];
        }
        
        if ([self isValidCode]) {
            [self.loginBtn setBackgroundImage:[self loginImage:YES] forState:UIControlStateNormal];
            self.loginBtn.enabled = YES;
        } else {
            [self.loginBtn setBackgroundImage:[self loginImage:NO] forState:UIControlStateNormal];
            self.loginBtn.enabled = NO;
        }
    } else {
        self.sendCodeBtn.enabled = NO;
        [self.sendCodeBtn setBackgroundColor:[UIColor colorWithHexString:@"0xFFD767" alpha:0.3]];
        [self.loginBtn setBackgroundImage:[self loginImage:NO] forState:UIControlStateNormal];
        self.loginBtn.enabled = NO;
    }
}

- (BOOL)isValidNumber {
    NSString * MOBILE = @"^((1[23456789]))\\d{9}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    if (self.userNameField.text.length == 11 && ([regextestmobile evaluateWithObject:self.userNameField.text] == YES)) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isValidCode {
    if (self.passwordField.text.length >= 4) {
        return YES;
    } else {
        return NO;
    }
}

- (UIImage *)loginImage:(BOOL)normal {
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 29 * 2, 48)];
    colorView.layer.cornerRadius = 24;
    colorView.clipsToBounds = YES;
    UIColor *startColor = [UIColor colorWithHexString:@"0x91FDFC"];
    UIColor *endColor = [UIColor colorWithHexString:@"0x55EBEA"];
    if (!normal) {
        startColor = [UIColor colorWithHexString:@"0x91FDFC" alpha:0.4];
        endColor = [UIColor colorWithHexString:@"0x55EBEA" alpha:0.4];
    }
    [colorView addGradentColor:startColor endColor:endColor];
    
    UIImage *image = [colorView viewToImage];
    return image;
}

@end
