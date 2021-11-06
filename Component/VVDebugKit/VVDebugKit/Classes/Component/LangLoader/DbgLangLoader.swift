//
//  DbgLangLoader.swift
//  Pods
//
//  Created by dailiangjin on 2020/1/20.
//

import Foundation
import UIKit
import SWUIKit

class DbgLangLoader: DbgLoader {    
    func debug_title() -> String {
        return "Change Language"
    }
    
    func debug_action() {
        let title = "Current Language: " + UIDevice.currentLanguage() ?? ""
        let options = ["en", "zh-Hans"]
        SWAlert.showActionSheet(title: title, message: "", cancel: "Cancel", others: options, using: VVDebugKit.default.currentViewController) { (index) in
            guard index >= 0 else { return }
            
            if UIDevice.currentLocale().languageCode != options[index] {
                VVDebugKit.default.currentViewController.dismiss(animated: true, completion: nil)
                UIDevice.setLanguage(language: options[index])
                UIViewController.resetXibRootViewController()
            }
        }
    }
    
    func debug_group() -> String? {
        return "language"
    }
    
    func debug_comment() -> String? {
        let sysLan = UIDevice.deviceLanguage()
        let currentLan = UIDevice.currentLanguage()
        return "Device Language: \(sysLan) \nApp Language: \(currentLan)"
    }
}

public protocol DbgRootViewControllerConvertible {
    func dbgAppRootViewController() -> UIViewController?
}

extension UIViewController {
    /// 重新初始化App,根视图对象（xib）
    /// - Note:
    /// 1. UIWindow实现`DbgRootViewControllerConvertible`协议，或者
    /// 2. 调用该方法，必须在Main.storyboard中根实图的 StoryboardID 设置为RootVC，否则调用该方法将发生奔溃
    static func resetXibRootViewController() {
        let window = UIApplication.shared.delegate?.window!
        if let convertible = window as? DbgRootViewControllerConvertible {
            let rootVC = convertible.dbgAppRootViewController()
            window?.setRootViewControllerSafely(rootVC)
        } else {
            let rootVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RootVC")
            window?.setRootViewControllerSafely(rootVC)
        }
    }
}
