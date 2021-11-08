//
//  AppDelegate.swift
//  YunZaiApp
//
//  Created by ice on 2021/11/5.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var audioPlayer: AVAudioPlayer?
    var localCallNotification: UILocalNotification?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        config_application(application, didFinishLaunchingWithOptions: launchOptions)
        
        WFCCNetworkService.startLog()
        //WFCCNetworkService.sharedInstance().connectionStatusDelegate = self
        //WFCCNetworkService.sharedInstance().receiveMessageDelegate = self
        WFCCNetworkService.sharedInstance().setServerAddress(IM_SERVER_HOST)
        WFCCNetworkService.sharedInstance().setBackupAddressStrategy(0)
        NotificationCenter.default.addObserver(self, selector: #selector(onFriendRequestUpdated(notification:)), name: NSNotification.Name(rawValue: kFriendRequestUpdated), object: nil)
        
#if WFCU_SUPPORT_VOIP
        //音视频高级版不需要stun/turn服务，请注释掉下面这行。单人版和多人版需要turn服务，请自己部署然后修改配置文件。
        WFAVEngineKit.shared().addIceServer(ICE_ADDRESS, userName: ICE_USERNAME, password: ICE_PASSWORD)
        WFAVEngineKit.shared().setVideoProfile(kWFAVVideoProfile360P, swapWidthHeight: true)
        WFAVEngineKit.shared().delegate = self
#endif
        
        WFCUConfigManager.global().appServiceProvider = AppService.shared()
        WFCUConfigManager.global().fileTransferId = FILE_TRANSFER_ID
        
        //#ifdef WFC_PTT
        //        //初始化对讲SDK
        //        WFPttClient.sha
        //#endif
        
        let savedToken = UserDefaults.standard.string(forKey: "savedToken")
        let savedUserId = UserDefaults.standard.string(forKey: "savedUserId")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = WFCBaseTabBarController();
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        setupNavBar()
        //setQrCodeDelegate(self);
        
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
}

extension AppDelegate {
    
}
