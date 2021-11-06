//
//  VVDebugKit.swift
//  Alamofire
//
//  Created by dailiangjin on 2019/9/3.
//

import Foundation
import SWFoundationKit

public protocol DbgInitialEvent {
    func dbgInit()
}

let kDebugKitURL = "vvlife://debug"

public class VVDebugKit: DbgRootViewControllerDelegate {
    public static let `default` = VVDebugKit()
    
    private var window: DbgWindow?
    private var _controller: DbgRootViewController?
    
    public var loaders: [DbgLoader]?
    
    private init() {
        customInit()
        
        DispatchQueue.main.async {
            if let proto = self as? DbgInitialEvent {
                proto.dbgInit()
            }
        }
    }
    
    private func customInit() {
        self.loaders = [DbgEnvLoader(), DbgLogLoader(), DbgNetLoader(), DbgEditEnvLoader()]
        
        SWRouter.registerRouteURL(kDebugKitURL) { (params) in
            if let nav = VVDebugKit.navigationViewController {
                nav.presentedViewController?.dismiss(animated: false, completion: nil)
                nav.dismiss(animated: true, completion: nil)
            } else {
                let vc = DbgMainViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                VVDebugKit.default.currentViewController.present(nav, animated: true, completion: nil)
            }
        }
        
        self.window = DbgWindow(frame: UIScreen.main.bounds)
        self.window?.eventDelegate = self
        self.window?.rootViewController = self.rootViewController
    }
    
    public func show() {
        self.window?.isHidden = false
    }
    
    public func hide() {
        self.window?.isHidden = true
    }
    
    var rootViewController: DbgRootViewController {
        if _controller == nil {
            _controller = DbgRootViewController()
            _controller?.delegate = self
        }
        return _controller!
    }
    
    var rootWindow: UIWindow? {
        return window
    }
    
    static var navigationViewController: UINavigationController? {
        let root = UIApplication.shared.delegate?.window??.rootViewController
        let present = root?.presentedViewController as? UINavigationController
        if let nav = present, nav.viewControllers.first is DbgMainViewController {
            return nav
        }
        return nil
    }
    
    public var currentViewController: UIViewController! {
        let rootViewController = self.window?.rootViewController
        return currentViewControllerFrom(rootViewController)
    }
    
    private func currentViewControllerFrom(_ viewController: UIViewController!) -> UIViewController! {
        if let navVC = viewController as? UINavigationController {
            return self.currentViewControllerFrom(navVC.viewControllers.last)
        } else if let tabVC = viewController as? UITabBarController {
            return self.currentViewControllerFrom(tabVC.selectedViewController)
        } else if let presented = viewController.presentedViewController, !(presented is UIAlertController) {
            return self.currentViewControllerFrom(presented)
        } else {
            return viewController
        }
    }
}

extension VVDebugKit: DbgWindowEventDelegate {
    func shouldHandleTouchAtPoint(point: CGPoint) -> Bool {
        return self.rootViewController.shouldReceiveTouchAtWindowPoint(point: point)
    }
}
