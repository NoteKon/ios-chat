//
//  CreateBarCodeViewController.m
//  LBXScanDemo
//
//  Created by lbxia on 2017/1/5.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "CreateBarCodeViewController.h"
#import "LBXAlertAction.h"
#import "LBXScanNative.h"
#import "UIImageView+CornerRadius.h"
#import <WFChatClient/WFCChatClient.h>
#import <WFChatUIKit/WFChatUIKit.h>
#import "UIFont+YH.h"
#import "UIColor+YH.h"

@interface CreateBarCodeViewController ()
@property (nonatomic, strong)UIImageView *logoView;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UILabel *idLabel;
@property (nonatomic, strong) UIImageView* headerImageView;

@property (nonatomic, strong) UIView *qrView;
@property (nonatomic, strong) UIImageView* qrImgView;

@property (nonatomic, strong)NSString *qrStr;
@property (nonatomic, strong)NSString *qrLogo;
@property (nonatomic, strong)NSString *labelStr;

@property (nonatomic, strong)WFCCUserInfo *userInfo;
@property (nonatomic, strong)WFCCGroupInfo *groupInfo;

@property (nonatomic, strong)UIActivityIndicatorView *indicatorView;
@end

@implementation CreateBarCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"..." style:UIBarButtonItemStyleDone target:self action:@selector(onRightBtn:)];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xFBFBFB"]; //[WFCUConfigManager globalManager].backgroudColor;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    __weak typeof(self) ws = self;
    if (self.qrType == QRType_User) {
        self.qrStr = [NSString stringWithFormat:@"wildfirechat://user/%@", self.target];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kUserInfoUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
            if ([ws.target isEqualToString:notification.object]) {
                ws.userInfo = notification.userInfo[@"userInfo"];
            }
        }];
        
        self.userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[WFCCNetworkService sharedInstance].userId refresh:NO];
    } else if(self.qrType == QRType_Group) {
        self.qrStr = [NSString stringWithFormat:@"wildfirechat://group/%@", self.target];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kGroupInfoUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull notification) {
            if ([ws.target isEqualToString:notification.object]) {
                ws.groupInfo = notification.userInfo[@"groupInfo"];
            }
        }];
        
        self.groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:self.target refresh:NO];
    }
}


- (void)saveImage:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.view.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [_indicatorView removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 30);
    label.center = self.view.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:17];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = @"保存失败";
    } else {
        label.text = @"保存成功";
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}


- (void)onRightBtn:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *actionSave = [UIAlertAction actionWithTitle:@"保存二维码" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UIGraphicsBeginImageContext(self.qrView.bounds.size);
        [self.qrView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self saveImage:image];
    }];
    
    [actionSheet addAction:actionSave];
    [actionSheet addAction:actionCancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)setUserInfo:(WFCCUserInfo *)userInfo {
    _userInfo = userInfo;
    self.qrLogo = userInfo.portrait;
    if (userInfo.displayName.length) {
        self.labelStr = userInfo.displayName;
    } else {
        self.labelStr = @"用户";
    }
    
    self.idLabel.text = [NSString stringWithFormat:@"云圈号: %@", userInfo.userId];
}

- (void)setGroupInfo:(WFCCGroupInfo *)groupInfo {
    _groupInfo = groupInfo;
    
    if (groupInfo.portrait.length) {
        self.qrLogo = groupInfo.portrait;
    } else {
        NSString *filePath = [WFCCUtilities getGroupGridPortrait:groupInfo.target width:50 generateIfNotExist:YES defaultUserPortrait:^UIImage *(NSString *userId) {
            return [UIImage imageNamed:@"PersonalChat"];
        }];
        self.qrLogo = filePath;
    }
    
    if (groupInfo.name.length) {
        self.labelStr = groupInfo.name;
    } else {
        self.labelStr = @"群组";
    }
    self.idLabel.text = [NSString stringWithFormat:@"群号: %@", groupInfo.target];
}

- (void)onUserInfoUpdated:(NSNotification *)notification {
        self.userInfo = notification.userInfo[@"userInfo"];
}

- (void)onGroupInfoUpdated:(NSNotification *)notification {
        self.groupInfo = notification.userInfo[@"groupInfo"];
}

- (void)setQrLogo:(NSString *)qrLogo {
    _qrLogo = qrLogo;
    __weak typeof(self)ws = self;
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        UIImage *logo;
        if ([NSURL URLWithString:qrLogo].baseURL) {
            logo = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:ws.qrLogo]]];
        } else {
            logo = [UIImage imageWithContentsOfFile:qrLogo];
        }
        if (!logo) {
            logo = [UIImage imageNamed:@"group_default_portrait"];
        }
        
        //_headerImageView
        dispatch_async(dispatch_get_main_queue(), ^{
            self.headerImageView.image = logo;
        });
    });
}

- (void)setLabelStr:(NSString *)labelStr {
    _labelStr = labelStr;
    self.nameLabel.text = labelStr;
}

- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(31, 28, 50, 50)];
        _headerImageView.layer.cornerRadius = 25;
        _headerImageView.clipsToBounds = YES;
        [self.qrView addSubview:_headerImageView];
    }
    return _headerImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(101, 28, self.qrView.bounds.size.width - 101 - 34, 15)];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor blackColor];
        [self.qrView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)idLabel {
    if (!_idLabel) {
        _idLabel = [[UILabel alloc] initWithFrame:CGRectMake(101, 61, self.qrView.bounds.size.width - 101 - 34, 14)];
        _idLabel.font = [UIFont systemFontOfSize:14];
        _idLabel.textColor = [UIColor colorWithHexString:@"0x000000" alpha:0.6];
        [self.qrView addSubview:_idLabel];
    }
    return _idLabel;
}

- (UIImageView *)qrImgView {
    if (!_qrImgView) {
        _qrImgView = [[UIImageView alloc] initWithFrame:CGRectMake(31, 111, self.qrView.frame.size.width - 62, 244)];
        [self.qrView addSubview:_qrImgView];
    }
    return _qrImgView;
}

- (UIView *)qrView {
    if (!_qrView) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(31, 45, CGRectGetWidth(self.view.frame) - 62, 428)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 15;
        view.layer.borderColor = [WFCUConfigManager globalManager].separateColor.CGColor;
        view.layer.borderWidth = 0.5;
        _qrView = view;
        [self.view addSubview:view];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 14 - 35, view.frame.size.width, 14)];
        tipLabel.font = [UIFont systemFontOfSize:14];
        tipLabel.textColor = [UIColor colorWithHexString:@"0x000000" alpha:0.8];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = @"扫一扫加群聊";
        [view addSubview:tipLabel];
    }
    return _qrView;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self createQR_logo];
}

- (void)createQR_logo
{
    _qrView.hidden = NO;
    self.qrImgView.image = [LBXScanNative createQRWithString:self.qrStr QRSize:self.qrImgView.bounds.size];
}

- (UIImageView*)roundCornerWithImage:(UIImage*)logoImg size:(CGSize)size
{
    //logo圆角
    UIImageView *backImage = [[UIImageView alloc] initWithCornerRadiusAdvance:25.0f rectCornerType:UIRectCornerAllCorners];
    backImage.frame = CGRectMake(0, 0, size.width, size.height);
    backImage.backgroundColor = [UIColor whiteColor];
    
    UIImageView *logImage = [[UIImageView alloc] initWithCornerRadiusAdvance:25.0f rectCornerType:UIRectCornerAllCorners];
    logImage.image =logoImg;
    CGFloat diff  =2;
    logImage.frame = CGRectMake(diff, diff, size.width - 2 * diff, size.height - 2 * diff);
    
    [backImage addSubview:logImage];
    
    return backImage;
}

- (void)showError:(NSString*)str
{
    [LBXAlertAction showAlertWithTitle:@"提示" msg:str buttonsStatement:@[@"知道了"] chooseBlock:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
