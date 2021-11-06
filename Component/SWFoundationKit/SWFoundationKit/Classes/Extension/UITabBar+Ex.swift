//
//  UITabBar+Ex.swift
//  SWFoundationKit
//
//  Created by ice on 2021/9/15.
//

import Foundation
import UIKit
extension UITabBar {
    public func hideShadowView(rootView: UIView?) {
        guard let rootView = rootView else {
            return
        }

        for subView in rootView.subviews {
            if let subClass = NSClassFromString("_UIBarBackgroundShadowView"), subView.isKind(of: subClass.self) {
                subView.isHidden = true
            }
            
            hideShadowView(rootView: subView)
        }
    }
}
