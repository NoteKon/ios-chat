//
//  UIWindow+Ex.swift
//  SWUIKit
//
//  Created by huang on 2020/2/19.
//

import Foundation

extension UIWindow {
    public func setRootViewControllerSafely(_ vc: UIViewController?) {
        if let presentedVC = rootViewController?.presentedViewController {
            presentedVC.dismiss(animated: false, completion: nil)
        }
        rootViewController = vc
    }
    
    /// 获取最顶层的window
    /// - Note: - 解决需要在键盘之上添加视图
    class func topWindow() -> UIWindow? {
        let windows = UIApplication.shared.windows
        for view in windows {
            if view.className().hasSuffix("UIRemoteKeyboardWindow") {
                return view
            }
        }
        return UIApplication.shared.windows.last
    }
}
