//
//  UIView+IBInspectable.swift
//  VVPartner
//
//  Created by ice on 2019/10/12.
//  Copyright © 2019 vv. All rights reserved.
//

import UIKit

public extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue > 0 ? newValue : 0
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            let o: Any = newValue
            do {
                try set(borderColor: o, for: layer)
            } catch  {
                if let color = o as? UIColor {
                    layer.borderColor = color.cgColor
                } else {
                    assert(false, "mmp")
                }
            }
        }
    }
    
    func set(borderColor: Any, for layer: CALayer) throws -> Void {
        if "\(type(of: borderColor))".hasPrefix("UI") {
            throw NSError(domain: "borderColor", code: -1000, userInfo: nil)
        }
        layer.borderColor = (borderColor as! CGColor)
    }

    // MARK: 阴影相关
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor {
        get {
            return UIColor(cgColor: layer.shadowColor ?? UIColor(hex: 0x000000).cgColor)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
}
