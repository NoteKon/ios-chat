//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

//如果您不需要voip功能，请在ChatUIKit工程中关掉voip功能，然后这里定义WFCU_SUPPORT_VOIP为0
//ChatUIKit关闭voip的方式是，找到ChatUIKit工程下的Predefine.h头文件，定义WFCU_SUPPORT_VOIP为0，
//然后找到脚本“xcodescript.sh”，删除掉“cp -af WFChatUIKit/AVEngine/*  ${DST_DIR}/”这句话。
//在删除掉ChatUIKit工程的WebRTC和WFAVEngineKit的依赖。
//删除掉应用工程中的WebRTC.framework和WFAVEngineKit.framework。
#define WFCU_SUPPORT_VOIP 1

#import <WFChatClient/WFCChatClient.h>
#if WFCU_SUPPORT_VOIP
#import <WFAVEngineKit/WFAVEngineKit.h>
#import <WebRTC/WebRTC.h>
#endif
#import "WFCLoginViewController.h"
#import "WFCConfig.h"
#import "WFCBaseTabBarController.h"
#import <WFChatUIKit/WFChatUIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "CreateBarCodeViewController.h"
#import "PCLoginConfirmViewController.h"
#import "QQLBXScanViewController.h"
#import "StyleDIY.h"
//#import <Bugly/Bugly.h>
#import "AppService.h"
#import "UIColor+YH.h"
#import "SharedConversation.h"
#import "SharePredefine.h"
#ifdef WFC_PTT
#import <PttClient/WFPttClient.h>
#import "WFCCNetworkService.h"
#endif

#import "WFCSettingTableViewController.h"
#import "WFCSecurityTableViewController.h"

#import "Help.h"


