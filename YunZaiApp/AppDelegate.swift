//
//  AppDelegate.swift
//  YunZaiApp
//
//  Created by ice on 2021/11/5.
//

import UIKit
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, ConnectionStatusDelegate, ReceiveMessageDelegate, QrCodeDelegate {
    
    var window: UIWindow?
    var audioPlayer: AVAudioPlayer?
    var localCallNotification: UILocalNotification?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        config_application(application, didFinishLaunchingWithOptions: launchOptions)
        
        WFCCNetworkService.startLog()
        //WFCCNetworkService.sharedInstance().useSM4()
        WFCCNetworkService.sharedInstance().connectionStatusDelegate = self
        WFCCNetworkService.sharedInstance().receiveMessageDelegate = self
        WFCCNetworkService.sharedInstance().setServerAddress(IM_SERVER_HOST)
        WFCCNetworkService.sharedInstance().setBackupAddressStrategy(0)
        NotificationCenter.default.addObserver(self, selector: #selector(onFriendRequestUpdated(notification:)), name: NSNotification.Name(rawValue: kFriendRequestUpdated), object: nil)
        
        //当PC/Web在线时手机端是否静音，默认静音。如果修改为默认不静音，需要打开下面函数。
        //另外需要IM服务配置server.mobile_default_silent_when_pc_online为false。必须保持与服务器同步。
        //WFCCIMService.sharedWFCIM().setDefaultSilentWhenPcOnline(false)
        
#if WFCU_SUPPORT_VOIP
        //音视频高级版不需要stun/turn服务，请注释掉下面这行。单人版和多人版需要turn服务，请自己部署然后修改配置文件。
        WFAVEngineKit.shared().addIceServer(ICE_ADDRESS, userName: ICE_USERNAME, password: ICE_PASSWORD)
        WFAVEngineKit.shared().setVideoProfile(kWFAVVideoProfile360P, swapWidthHeight: true)
        WFAVEngineKit.shared().delegate = self
        
        //设置音视频参与者数量。多人音视频默认视频4路，音频9路，如果改成更多可能会导致问题；音视频高级版默认视频9路，音频16路。
        //WFAVEngineKit.shared().maxVideoCallCount = 4
        //WFAVEngineKit.shared().maxAudioCallCount = 9
        //音视频日志，当需要抓日志分析时可以打开这句话
        //RTCSetMinDebugLogLevel(RTCLoggingSeverityInfo)
#endif
        
        WFCUConfigManager.global().appServiceProvider = AppService.shared()
        WFCUConfigManager.global().fileTransferId = FILE_TRANSFER_ID
        
#if WFC_PTT
        //初始化对讲SDK
#endif
        
        let savedToken = UserDefaults.standard.string(forKey: "savedToken")
        let savedUserId = UserDefaults.standard.string(forKey: "savedUserId")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = WFCBaseTabBarController();
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        setupNavBar()
        setQrCodeDelegate(self);
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if error == nil {
                print("succeeded!")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        if savedToken?.count ?? 0 > 0 && savedUserId?.count ?? 0 > 0 {
            //需要注意token跟clientId是强依赖的，一定要调用getClientId获取到clientId，然后用这个clientId获取token，这样connect才能成功，如果随便使用一个clientId获取到的token将无法链接成功。另外不能多次connect，如果需要切换用户请先disconnect，然后3秒钟之后再connect（如果是用户手动登录可以不用等，因为用户操作很难3秒完成，如果程序自动切换请等3秒）。
            WFCCNetworkService.sharedInstance().connect(savedUserId, token: savedToken)
        } else {
            let loginVC = WFCLoginViewController()
            let nav = UINavigationController.init(rootViewController: loginVC)
            self.window?.rootViewController = nav
        }
        
        return true
    }
}

extension AppDelegate {
    @objc func onFriendRequestUpdated(notification: Notification) {
        if UIApplication.shared.applicationState == .background {
            let newRequests = notification.object as? [String]
            //            if newRequests?.count {
            //                return
            //            }
        }
    }
    
    func setupNavBar() {
        WFCUConfigManager.global().setupNavBar()
    }
    
    func handleUrlWithNav(url: String, nav: UINavigationController) -> Bool {
        if url.contains("wildfirechat://user") {
            let components = NSURLComponents.init(string: url)
            var fromUserId: String? = ""
            if let quers = components?.queryItems {
                for item in quers {
                    if "from" == item.name {
                        fromUserId = item.value
                        break
                    }
                }
            }
            
            let URL = URL(string: url)
            let userId = URL?.lastPathComponent
            let viewController = WFCUProfileTableViewController()
            viewController.userId = userId
            viewController.sourceType = .FriendSource_QrCode
            viewController.sourceTargetId = fromUserId
            viewController.hidesBottomBarWhenPushed = true
            
            nav.pushViewController(viewController, animated: true)
            return true
        } else if url.contains("wildfirechat://group") {
            let components = NSURLComponents.init(string: url)
            var fromUserId: String? = ""
            if let quers = components?.queryItems {
                for item in quers {
                    if "from" == item.name {
                        fromUserId = item.value
                        break
                    }
                }
            }
            let URL = URL(string: url)
            let groupId = URL?.lastPathComponent
            let viewController = WFCUGroupInfoViewController()
            viewController.groupId = groupId ?? ""
            viewController.sourceType = .GroupMemberSource_QrCode
            viewController.sourceTargetId = fromUserId ?? ""
            viewController.hidesBottomBarWhenPushed = true
            nav.pushViewController(viewController, animated: true)
            return true
        } else if url.contains("wildfirechat://pcsession") {
            let URL = URL(string: url)
            let sessionId = URL?.lastPathComponent
            let params = NSMutableDictionary()
            let urlComponents = NSURLComponents.init(string: url)
            if let items = urlComponents?.queryItems {
                for (_, obj) in items.enumerated() {
                    params[obj.name] = obj.value
                }
            }
            let platform = params["platform"] as? String
            
            let viewController = PCLoginConfirmViewController()
            viewController.sessionId = sessionId ?? "";
            viewController.platform =  WFCCPlatformType(rawValue: (platform?.intValue ?? 0)) ?? .PlatformType_UNSET
            viewController.modalPresentationStyle = .fullScreen;
            nav.pushViewController(viewController, animated: true)
        }
        
        return false
    }
}

/// ConnectionStatusDelegate
extension AppDelegate {
    func onConnectionStatusChanged(_ status: ConnectionStatus) {
        
    }
}

/// ReceiveMessageDelegate
extension AppDelegate {
    func onRecallMessage(_ messageUid: Int64) {
        cancelNotification(messageUid: messageUid)
        let count = updateBadgeNumber()
        if UIApplication.shared.applicationState == .background {
            if shouldMuteNotification() {
                return
            }
            if let msg = WFCCIMService.sharedWFCIM().getMessageByUid(messageUid) {
                notificationForMessage(msg: msg, badgeCount: NSInteger(count))
            }
        }
    }
    
    func onReceiveMessage(_ messages: [WFCCMessage]!, hasMore: Bool) {
        let state = UIApplication.shared.applicationState
        if state == .background {
            let count = updateBadgeNumber()
            if shouldMuteNotification() {
                return
            }
            
            for msg in messages {
                notificationForMessage(msg: msg, badgeCount: NSInteger(count))
            }
        } else if state == .active {
            var pcLoginRequest: WFCCPCLoginRequestMessageContent?
            for msg in messages {
                if (Int64(NSDate().timeIntervalSince1970) - (msg.serverTime - WFCCNetworkService.sharedInstance().serverDeltaTime)/1000) < 60 {
                    if msg.content.isKind(of: WFCCPCLoginRequestMessageContent.self) {
                        pcLoginRequest = msg.content as? WFCCPCLoginRequestMessageContent
                    }
                }
            }
            
            guard let pcLoginRequest = pcLoginRequest else {
                return
            }
            
            var nav: UINavigationController?
            if let flag = self.window?.rootViewController?.isKind(of: UINavigationController.self), flag {
                nav = self.window?.rootViewController as? UINavigationController
            } else if let flag = self.window?.rootViewController?.isKind(of: UITabBarController.self), flag {
                if let tab = self.window?.rootViewController as? UITabBarController, let rootVcs = tab.viewControllers {
                    for obj in rootVcs {
                        if obj.isKind(of: UINavigationController.self) {
                            nav = obj as? UINavigationController
                            break
                        }
                    }
                }
                if let _ = nav {
                    let viewController = PCLoginConfirmViewController()
                    viewController.sessionId = pcLoginRequest.sessionId
                    viewController.platform = pcLoginRequest.platform
                    viewController.modalPresentationStyle = .fullScreen;
                    self.window?.rootViewController?.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func updateBadgeNumber() -> Int32 {
        let unreadCount = WFCCIMService.sharedWFCIM().getUnreadCount( [NSNumber(value: WFCCConversationType.Single_Type.rawValue), NSNumber(value: WFCCConversationType.Group_Type.rawValue), NSNumber(value: WFCCConversationType.Channel_Type.rawValue)], lines: [0])
        let unreadFriendRequest = WFCCIMService.sharedWFCIM().getUnreadFriendRequestStatus()
        let count = unreadCount?.unread ?? 0 + unreadFriendRequest;
        UIApplication.shared.applicationIconBadgeNumber = Int(count)
        return count
    }
    
    func shouldMuteNotification() -> Bool {
        let isNoDisturbing = WFCCIMService.sharedWFCIM().isNoDisturbing()
        
        //免打扰
        if isNoDisturbing {
            return true
        }
        
        //全局静音
        if WFCCIMService.sharedWFCIM().isGlobalSilent() {
            return true
        }
        
        let pcOnline = WFCCIMService.sharedWFCIM().getPCOnlineInfos().count > 0
        let muteWhenPcOnline = WFCCIMService.sharedWFCIM().isMuteNotificationWhenPcOnline()
        
        if pcOnline && muteWhenPcOnline {
            return true
        }
        
        return false
    }
    
    func notificationForMessage(msg: WFCCMessage, badgeCount count: NSInteger) {
        //当在后台活跃时收到新消息，需要弹出本地通知。有一种可能时客户端已经收到远程推送，然后由于voip/backgroud fetch在后台拉活了应用，此时会收到接收下来消息，因此需要避免重复通知
        if (Int64(NSDate().timeIntervalSince1970) - (msg.serverTime - WFCCNetworkService.sharedInstance().serverDeltaTime)/1000) > 3 {
            return
        }
        
        if msg.direction == .MessageDirection_Send {
            return
        }
        
        let flag = 20 //msg.content.class.performSelector(Selector("WFCCMessageContent.getContentFlags"))
        let info = WFCCIMService.sharedWFCIM().getConversationInfo(msg.conversation)
        if (((flag & 0x03) != 0) || msg.content.isKind(of: WFCCRecallMessageContent.self)) && !(info?.isSilent ?? false) && !msg.content.isKind(of: WFCCCallStartMessageContent.self) {
            let localNote = UILocalNotification()
            if WFCCIMService.sharedWFCIM().isHiddenNotificationDetail() && msg.content.isKind(of: WFCCRecallMessageContent.self) {
                localNote.alertBody = "您收到了新消息";
            } else {
                localNote.alertBody = msg.digest()
            }
            
            let type = msg.conversation.type
            if type == .Single_Type {
                let sender = WFCCIMService.sharedWFCIM().getUserInfo(msg.conversation.target, refresh: false)
                localNote.alertTitle = sender?.displayName
            } else if type == .Group_Type {
                let group = WFCCIMService.sharedWFCIM().getGroupInfo(msg.conversation.target, refresh: false)
                let sender = WFCCIMService.sharedWFCIM().getUserInfo(msg.fromUser, refresh: false)
                if let displayName = sender?.displayName, let name = group?.name {
                    localNote.alertTitle = "\(displayName)\(name)"
                } else if let displayName = sender?.displayName {
                    localNote.alertTitle = displayName
                }
                
                if msg.status == .Message_Status_Mentioned || msg.status == .Message_Status_AllMentioned {
                    if let name = sender?.displayName {
                        localNote.alertBody = "\(name)在群里@了你"
                    } else {
                        localNote.alertBody = "有人在群里@了你"
                    }
                }
            }
            
            localNote.applicationIconBadgeNumber = count
            localNote.userInfo = ["conversationType" : msg.conversation.type,
                                  "conversationTarget" : msg.conversation.target,
                                  "conversationLine" : msg.conversation.line,
                                  "messageUid" : msg.messageUid]
            DispatchQueue.main.async {
                UIApplication.shared.scheduleLocalNotification(localNote)
            }
        }
    }
    
    func cancelNotification(messageUid: CLongLong) {
        if let notifications = UIApplication.shared.scheduledLocalNotifications {
            for obj in notifications {
                if let uid = obj.userInfo?["messageUid"] as? String, uid == "\(messageUid)", let obj = obj as? UILocalNotification {
                    UIApplication.shared.cancelLocalNotification(obj)
                }
            }
        }
    }
}

/// QrCodeDelegate
extension AppDelegate {
    func showQrCodeViewController(_ navigator: UINavigationController!, type: Int32, target: String!) {
        let viewController = CreateBarCodeViewController()
        viewController.qrType = type
        viewController.target = target
        navigator.pushViewController(viewController, animated: true)
    }
    
    func scanQrCode(_ navigator: UINavigationController!) {
        let viewController = QQLBXScanViewController()
        viewController.libraryType = .SLT_Native
        viewController.scanCodeType = .SCT_QRCode
        viewController.style = StyleDIY.qqStyle()
        //镜头拉远拉近功能
        viewController.isVideoZoom = true
        viewController.hidesBottomBarWhenPushed = true
        viewController.scanResult = { [weak self] (str) in
            _ = self?.handleUrlWithNav(url: str ?? "", nav: navigator)
        }
        navigator.pushViewController(viewController, animated: true)
    }
}

/// UNUserNotificationCenterDelegate
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let hexToken = deviceToken.map({ String(format: "%02.2hhx", $0) }).joined(separator: "")
        WFCCNetworkService.sharedInstance().setDeviceToken(hexToken)
    }
}
