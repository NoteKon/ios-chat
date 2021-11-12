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

/// Xib、StoryBoard 多语言设置
var bundleNameKey = "BundleNameKey"
var localizedKeepKey = "LocalizedKeepKey"

extension UIButton {
    @IBInspectable public var bundleName: String? {
        get {
            if let value = objc_getAssociatedObject(self, &bundleNameKey) as? String {
                return value
            }
            return Bundle.init(for: type(of: self)).className()
        }
        set {
            objc_setAssociatedObject(self, &bundleNameKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /// 判断空值
            guard let key = localizedKey, key.count > 0 else {
                return
            }
            setTitle(Bundle.localizedString(key: key, value: "", bundleName: newValue ?? ""), for: .normal)
        }
    }
    
    /// 配置xib或stroyboard上button文本的本地化语言，省去拉取属性，暂时只支持默认文本
    @IBInspectable public var localizedKey: String? {
        get {
            if let value = objc_getAssociatedObject(self, &localizedKeepKey) as? String {
                return value
            }
            return titleLabel?.text
        }
        set {
            /// 判断空值
            objc_setAssociatedObject(self, &localizedKeepKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            guard newValue?.count ?? 0 > 0 else {
                return
            }
            setTitle(
                Bundle.localizedString(key: newValue!, value: "", bundleName: bundleName ?? ""), for: .normal)
        }
    }
}

extension UILabel {
    @IBInspectable public var bundleName: String? {
        get {
            if let value = objc_getAssociatedObject(self, &bundleNameKey) as? String {
                return value
            }
            return Bundle.init(for: type(of: self)).className()
        }
        set {
            objc_setAssociatedObject(self, &bundleNameKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /// 判断空值
            guard let key = localizedKey, key.count > 0 else {
                return
            }
            text =
                Bundle.localizedString(key: key, value: "", bundleName: newValue ?? "")
        }
    }
    
    /// 配置xib或stroyboard上label文本的本地化语言,省去拉取属性
    @IBInspectable public var localizedKey: String? {
        get {
            if let value = objc_getAssociatedObject(self, &localizedKeepKey) as? String {
                return value
            }
            return text
        }
        set {
            objc_setAssociatedObject(self, &localizedKeepKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /// 判断空值
            guard let key = newValue, key.count > 0 else {
                return
            }
            text = Bundle.localizedString(key: key, value: "", bundleName: bundleName ?? "")
        }
    }
}

extension UITextField {
    @IBInspectable public var bundleName: String? {
        get {
            if let value = objc_getAssociatedObject(self, &bundleNameKey) as? String {
                return value
            }
            return Bundle.init(for: type(of: self)).className()
        }
        set {
            objc_setAssociatedObject(self, &bundleNameKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /// 判断空值
            guard let key = placeholderLocalizedKey, key.count > 0 else {
                return
            }
            placeholder =
                Bundle.localizedString(key: key, value: "", bundleName: newValue ?? "")
        }
    }
    
    /// 配置xib或stroyboard上label文本的本地化语言,省去拉取属性
    @IBInspectable public var placeholderLocalizedKey: String? {
        get {
            if let value = objc_getAssociatedObject(self, &localizedKeepKey) as? String {
                return value
            }
            return placeholder
        }
        set {
            objc_setAssociatedObject(self, &localizedKeepKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /// 判断空值
            guard let key = newValue, key.count > 0 else {
                return
            }
            placeholder = Bundle.localizedString(key: key, value: "", bundleName: bundleName ?? "")
        }
    }
}
