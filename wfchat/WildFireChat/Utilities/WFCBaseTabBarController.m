//
//  WFCBaseTabBarController.m
//  Wildfire Chat
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCBaseTabBarController.h"
#import <WFChatClient/WFCChatClient.h>
#import <WFChatUIKit/WFChatUIKit.h>
#import "DiscoverViewController.h"
#import "WFCMeTableViewController.h"
#ifdef WFC_MOMENTS
#import <WFMomentUIKit/WFMomentUIKit.h>
#import <WFMomentClient/WFMomentClient.h>
#endif
#import "UIImage+ERCategory.h"
#define kClassKey   @"rootVCClassString"
#define kTitleKey   @"title"
#define kImgKey     @"imageName"
#define kSelImgKey  @"selectedImageName"

@interface WFCBaseTabBarController ()<UINavigationControllerDelegate>
@property (nonatomic, strong)UINavigationController *firstNav;
@property (nonatomic, strong)UINavigationController *settingNav;
@end

@implementation WFCBaseTabBarController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIOffset textOffset = UIOffsetMake(0, -5);
    UIEdgeInsets imageInsets = UIEdgeInsetsMake(-3, 0, 3, 0);
    if kIs_iPhoneX {
        textOffset = UIOffsetMake(0, 0);
        imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    UIColor *textNormalColor = [UIColor colorWithHexString:@"0x191D33"];
    UIColor *textSelectColor = [UIColor colorWithHexString:@"0x3EEEED"];
    self.tabBar.tintColor = textSelectColor;
    [[UITabBar appearance] setUnselectedItemTintColor: textNormalColor];
    [self setTabBarAppearance];
    
    /// 云圈
    UIViewController *vc = [WFCUConversationTableViewController new];
    vc.title = LocalizedString(@"tab_cloud");
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    UITabBarItem *item = nav.tabBarItem;
    nav.delegate = self;
    item.title = LocalizedString(@"tab_cloud");
    item.titlePositionAdjustment = textOffset;
    item.imageInsets = imageInsets;
    item.image = [[UIImage imageNamed:@"tab_cloud_unselect"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = [[UIImage imageNamed:@"tab_cloud_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : textSelectColor} forState:UIControlStateSelected];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : textNormalColor} forState:UIControlStateNormal];
    [self addChildViewController:nav];
    
    self.firstNav = nav;
    
    /// 通信录
    vc = [WFCUContactListViewController new];
    vc.title = LocalizedString(@"tab_contact");
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.delegate = self;
    item = nav.tabBarItem;
    item.titlePositionAdjustment = textOffset;
    item.imageInsets = imageInsets;
    item.title = LocalizedString(@"tab_contact");
    item.image = [[UIImage imageNamed:@"tab_contact_unselect"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = [[UIImage imageNamed:@"tab_contact_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : textSelectColor} forState:UIControlStateSelected];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : textNormalColor} forState:UIControlStateNormal];
    [self addChildViewController:nav];
    
    /// 发现
    vc = [DiscoverViewController new];
    vc.title = LocalizedString(@"tab_discover");
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.delegate = self;
    item = nav.tabBarItem;
    item.titlePositionAdjustment = textOffset;
    item.imageInsets = imageInsets;
    item.title = LocalizedString(@"tab_discover");
    item.image = [[UIImage imageNamed:@"tab_discover_unselect"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = [[UIImage imageNamed:@"tab_discover_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : textSelectColor} forState:UIControlStateSelected];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : textNormalColor} forState:UIControlStateNormal];
    [self addChildViewController:nav];
    
    /// 我的
    //vc = [WFCMeTableViewController new];
    vc = [[UIStoryboard storyboardWithName:@"My" bundle: nil] instantiateViewControllerWithIdentifier:@"MyViewController"];
    vc.title = LocalizedString(@"tab_me");
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.delegate = self;
    item = nav.tabBarItem;
    item.titlePositionAdjustment = textOffset;
    item.imageInsets = imageInsets;
    item.title = LocalizedString(@"tab_me");
    item.image = [[UIImage imageNamed:@"tab_me_unselect"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = [[UIImage imageNamed:@"tab_me_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : textSelectColor} forState:UIControlStateSelected];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : textNormalColor} forState:UIControlStateNormal];
    [self addChildViewController:nav];
    self.settingNav = nav;

#ifdef WFC_MOMENTS
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveComments:) name:kReceiveComments object:nil];
#endif
}

- (void)onReceiveComments:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateBadgeNumber];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateBadgeNumber];
}

- (void)updateBadgeNumber {
#ifdef WFC_MOMENTS
    [self.tabBar showBadgeOnItemIndex:2 badgeValue:[[WFMomentService sharedService] getUnreadCount]];
#endif
}

- (void)setNewUser:(BOOL)newUser {
    if (newUser) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"欢迎注册" message:@"请更新您头像和昵称，以便您的朋友能更好地识别！" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.selectedViewController = self.settingNav;
            }];
            [alertController addAction:action];
            NSLog(@"hahahah");
            [self.firstNav presentViewController:alertController animated:YES completion:nil];
        });
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(setupNavBar)]) {
                [[UIApplication sharedApplication].delegate performSelector:@selector(setupNavBar)];
            }
            UIView *superView = self.view.superview;
            [self.view removeFromSuperview];
            [superView addSubview:self.view];
        }
    }
}


#pragma mark -
/// UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    ///
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    ///
}

- (void)setTabBarAppearance {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UIImage *shadowImage = [UIImage imageWithColor:[WFCUConfigManager globalManager].separateColor size: CGSizeMake(width, 0.5)];
    
    UITabBarAppearance *barAppearance = [self.tabBar.standardAppearance copy];
    barAppearance.shadowImage = shadowImage;
    barAppearance.backgroundColor = [UIColor whiteColor];
    self.tabBar.standardAppearance = barAppearance;
    if (@available(iOS 15.0, *)) {
        self.tabBar.scrollEdgeAppearance = barAppearance;
    } else {
        // Fallback on earlier versions
    }
}

- (void)hideShadowView:(UIView *)rootView {
    if (rootView == nil) {
        return;
    }
    
    for (UIView *subView in rootView.subviews) {
        Class subClass = NSClassFromString(@"_UIBarBackgroundShadowView");
        if ([subClass isKindOfClass:[subClass class]]) {
            subView.backgroundColor = [UIColor redColor];
        }
        
        [self hideShadowView:subView];
    }
}

@end
