//
//  AppDelegate.swift
//  YunZaiApp
//
//  Created by ice on 2021/11/5.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
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
        window?.rootViewController = ViewController();
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        setupNavBar()
        //setQrCodeDelegate(self);
        
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
}

extension AppDelegate {
    func setupNavBar() {
        WFCUConfigManager.global().setupNavBar()
    }
}
