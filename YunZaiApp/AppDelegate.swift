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
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController();
        window?.makeKeyAndVisible()
        return true
    }
}

