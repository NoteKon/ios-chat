//
//  UINavigationController+Ex.swift
//  VVLife
//
//  Created by julian on 2020/6/8.
//  Copyright © 2020 vv. All rights reserved.
//

import Foundation

public extension UINavigationController {
    func vlPopThenPush(vc: UIViewController, animated: Bool) {
        if viewControllers.count <= 1 {
            pushViewController(vc, animated: animated)
            return
        }
        
        var vcs = viewControllers
        vcs.removeLast()
        vcs.append(vc)
        
        setViewControllers(vcs, animated: animated)
    }
    
    func vlPopToRootThenPush(vc: UIViewController, animated: Bool) {
        if viewControllers.count <= 1 {
            pushViewController(vc, animated: animated)
            
            return
        }
        
        var vcs = viewControllers
        let firstVC = vcs[0]
        vcs.removeAll()
        vcs.append(firstVC)
        vcs.append(vc)
        
        setViewControllers(vcs, animated: animated)
    }
    
    /// 返回到指定的控制器
    func vlPopTo(viewController: UIViewController, animated: Bool) {
        let count = viewControllers.count
        if count <= 1 {
            popViewController(animated: animated)
            
            return
        }
        
        var vcs = [UIViewController]()
        
        for i in 0..<count {
            let vc = viewControllers[i]
            vcs.append(vc)
            if viewController == vc {
                break
            }
        }

        setViewControllers(vcs, animated: animated)
    }
    
    func findTargetController(_ className: UIViewController.Type, compareBlock: ((UIViewController) -> Bool)? = nil) -> UIViewController? {
        for vc in self.viewControllers.reversed() {
            if vc.isKind(of: className) {
                if compareBlock != nil {
                    if compareBlock!(vc) {
                        return vc
                    }
                } else {
                    return vc
                }
            }
        }
        return nil
           
    }
}
