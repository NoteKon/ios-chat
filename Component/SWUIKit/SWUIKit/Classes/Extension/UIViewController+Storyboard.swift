//
//  UIViewController+Storyboard.swift
//  VVLife
//
//  Created by huangxianhui on 2020/10/19.
//  Copyright © 2020 vv. All rights reserved.
//

import Foundation

public protocol ViewControllerStoryboardProtocol: AnyObject {
    static func instanceFromStoryboard(_ name: String, bundle: Bundle?) -> Self
}

extension UIViewController: ViewControllerStoryboardProtocol {
    static func instanceFromStoryboard(_ name: String) -> Self {
        return instanceFromStoryboard(name, bundle: nil)
    }
    
    public static func instanceFromStoryboard(_ name: String, bundle: Bundle? = nil) -> Self {
        let storyboard = UIStoryboard(name: name, bundle: bundle)
         let vc = storyboard.instantiateViewController(withIdentifier: String(describing: Self.self))
        return vc as! Self
    }
}
