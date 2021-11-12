//
//  AppDelegate+Config.swift
//  YunZaiApp
//
//  Created by ice on 2021/11/6.
//

import Foundation

extension AppDelegate {
    func config_application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Void {
        
        ToastManager.shared.position = .center
        /// 注册模块
        SWModuleManager.initAllModules()
        /// 开启日志监控
        SWRequestResponse.shouldMonitor = true
        /// 设置请求主域名
        //URLConfig.setHost()
    }
}
