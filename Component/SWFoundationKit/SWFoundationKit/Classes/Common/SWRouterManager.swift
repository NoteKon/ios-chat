//
//  SWRouterManager.swift
//  SWFoundationKit_Example
//
//  Created by ice on 2019/8/22.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import FFRouter

public typealias SWRouterHandler = FFRouterHandler
public typealias SWCallbackRouterHandler = FFCallbackRouterHandler
public typealias SWObjectRouterHandler = FFObjectRouterHandler
public typealias SWRouterCallback = FFRouterCallback
public typealias SWRouterManager = SWRouter

/// 路由管理
public class SWRouter: NSObject {
    @objc public class func router(_ url: String?) {
        FFRouter.routeURL(url)
    }
    
    @objc public class func router(_ url: String?, withParameters parameters: [String: Any]?) {
        FFRouter.routeURL(url, withParameters: parameters)
    }
    
    @objc public class func router(_ url: String?, withParameters parameters: [String: Any]? = nil, callback: SWRouterCallback?) {
        FFRouter.routeCallbackURL(url, withParameters: parameters, targetCallback: callback)
    }
    
    @objc public class func routeObjectURL(_ url: String?) -> Any? {
        let obj = FFRouter.routeObjectURL(url)
        return obj
    }
    
    @objc public class func routeObjectURL(_ url: String?, withParameters parameters: [String: Any]?) -> Any? {
        let obj = FFRouter.routeObjectURL(url, withParameters: parameters)
        return obj
    }
    
    @objc public class func push(_ viewController: UIViewController!, animated: Bool, replace: Bool = false) {
        FFRouterNavigation.push(viewController, replace: replace, animated: animated)
    }
    
    @objc public class func present(_ viewController: UIViewController!, animated: Bool, completion: (() -> Void)? = nil) {
        FFRouterNavigation.present(viewController, animated: animated, completion: completion)
    }
    
    @objc public class func autoHidesBottomBar(whenPushed: Bool) {
        FFRouterNavigation.autoHidesBottomBar(whenPushed: whenPushed)
    }
    
    @objc public class func closeViewController(animated: Bool) {
        FFRouterNavigation.closeViewController(animated: animated)
    }
    
    @objc public class func currentViewController() -> UIViewController {
        return FFRouterNavigation.currentViewController()
    }
    
    @objc public class func currentNavigationViewController() -> UINavigationController? {
        return FFRouterNavigation.currentNavigationViewController()
    }
    
    @objc public class func registerRouteURL(_ routeURL: String!, handler: SWRouterHandler!) {
        FFRouter.registerRouteURL(routeURL, handler: handler)
    }
    
    @objc public class func registerCallbackRouteURL(_ routeURL: String!, handler: SWCallbackRouterHandler!) {
        FFRouter.registerCallbackRouteURL(routeURL, handler: handler)
    }
    
    @objc public class func registerObjectRouteURL(_ routeURL: String!, handler: SWObjectRouterHandler!) {
        FFRouter.registerObjectRouteURL(routeURL, handler: handler)
    }
    
    @objc public class func unregisterRouteURL(_ routeURL: String!) {
        FFRouter.unregisterRouteURL(routeURL)
    }
    
    @objc public class func unregisterAllRoutes() {
        FFRouter.unregisterAllRoutes()
    }
    
    @objc public class func dismissAllAlerts(completion: (() -> Void)?) {
        var alerts: [UIAlertController] = []
        var vc: UIViewController? = currentViewController()
        while let alert = vc as? UIAlertController {
            alerts.append(alert)
            vc = vc?.presentingViewController
        }
        
        if alerts.count == 0 {
            completion?()
            return
        }
        
        let total = alerts.count
        var count = 0
        alerts.forEach { (alert) in
            alert.dismiss(animated: false) {
                count += 1
                if count >= total {
                    completion?()
                }
            }
        }
    }
}
