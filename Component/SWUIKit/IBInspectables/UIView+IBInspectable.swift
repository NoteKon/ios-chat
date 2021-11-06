//
//  UIView+IBInspectable.swift
//  music_player
//
//  Created by young on 2019/4/18.
//  Copyright © 2019 yqc. All rights reserved.
//

@_exported import SWFoundationKit
@_exported import SWUIKit

var adapterScreenKey = "AdapterScreenKey"
var bundleNameKey = "BundleNameKey"
var localizedKeepKey = "LocalizedKeepKey"
var imageBundleNameKey = "ImageBundleNameKey"
var imageNameKey = "ImageNameKey"

extension UIView {
     @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
     @IBInspectable public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue > 0 ? newValue : 0
        }
    }
    
     @IBInspectable public var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
}

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
    /// 英文版使用的字体（字体名称和字号用空隔隔开，例如：Avenir-Heavy 18）
    @IBInspectable public var fontOfEnglish: String? {
        get {
            return titleLabel?.font.fontName
        }
        set {
            if UIDevice.isEnglishLocale {
                guard let fontName = newValue?.components(separatedBy: " ").first else {
                    return
                }
                guard let sizeStr: String = newValue?.components(separatedBy: " ").last, let size = NumberFormatter().number(from: sizeStr) else {
                    return
                }
                guard let font = UIFont(name: fontName, size: CGFloat(truncating: size)) else {
                    return
                }
                titleLabel?.font = font
            }
        }
    }
    /// 英文版使用的字体颜色
    @IBInspectable public var fontColorOfEnglish: UIColor? {
        get {
            return titleLabel?.textColor
        }
        set {
            /// 判断当前语言是否为英文、空值
            guard UIDevice.isEnglishLocale, let color = newValue  else {
                return
            }
            setTitleColor(color, for: .normal)
        }
    }
    
    @IBInspectable public var imageBundleName: String? {
        get {
            if let value = objc_getAssociatedObject(self, &imageBundleNameKey) as? String {
                return value
            }
            return Bundle.init(for: type(of: self)).className()
        }
        set {
            objc_setAssociatedObject(self, &imageBundleNameKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /// 设置图片
            if let name = imageName, name.count > 0 {
                let bundleImage = Bundle.loadImage(name: name, bundleName: newValue ?? "SWUIKitImages")
                setImage(bundleImage, for: .normal)
            }
        }
    }
    /// 配置xib或stroyboard上的图片名称,省去拉取属性
    @IBInspectable var imageName: String? {
        get {
            if let value = objc_getAssociatedObject(self, &imageNameKey) as? String {
                return value
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &imageNameKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /// 设置图片
            if let name = newValue, name.count > 0 {
                let bundleImage = Bundle.loadImage(name: name, bundleName: imageBundleName ?? "SWUIKitImages")
                setImage(bundleImage, for: .normal)
            }
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
    /// 英文版使用的字体（字体名称和字号用空隔隔开，例如：Avenir-Heavy 18）
    @IBInspectable public var fontOfEnglish: String? {
        get {
            return font.fontName
        }
        set {
            if UIDevice.isEnglishLocale {
                guard let fontName = newValue?.components(separatedBy: " ").first else {
                    return
                }
                guard let sizeStr: String = newValue?.components(separatedBy: " ").last, let size = NumberFormatter().number(from: sizeStr) else {
                    return
                }
                guard let font = UIFont(name: fontName, size: CGFloat(truncating: size)) else {
                    return
                }
                self.font = font
            }
        }
    }
    /// 英文版使用的字体颜色
    @IBInspectable public var fontColorOfEnglish: UIColor? {
        get {
            return textColor
        }
        set {
            /// 判断当前语言是否为英文、空值
            guard UIDevice.isEnglishLocale, let color = newValue  else {
                return
            }
            textColor = color
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

//@IBDesignable
public class RadiusLabel: UILabel {

    private var padding = UIEdgeInsets.zero
//    @IBInspectable
    var paddingLeft: CGFloat {
        get { return padding.left }
        set { padding.left = newValue }
    }
   
//    @IBInspectable
    var paddingRight: CGFloat {
        get { return padding.right }
        set { padding.right = newValue }
    }
    
//    @IBInspectable
    public var paddingTop: CGFloat {
        get { return padding.top }
        set { padding.top = newValue }
    }
    
//    @IBInspectable
    public var paddingBottom: CGFloat {
        get { return padding.bottom }
        set { padding.bottom = newValue }
    }
    
    //重新绘制文本
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    //重新text文字框大小
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insets = self.padding
        var rect = super.textRect(forBounds: bounds.inset(by: insets), limitedToNumberOfLines: numberOfLines)
        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
}

// MARK: UIImageView
public extension UIImageView {
    @IBInspectable var bundleName: String? {
        get {
            if let value = objc_getAssociatedObject(self, &bundleNameKey) as? String {
                return value
            }
            return Bundle.init(for: type(of: self)).className()
        }
        set {
            objc_setAssociatedObject(self, &bundleNameKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /// 判断空值
            guard let name = imageName, name.count > 0 else {
                return
            }
            let bundleImage = Bundle.loadImage(name: name, bundleName: newValue ?? "SWUIKitImages")
            self.image = bundleImage
        }
    }
    
    /// 配置xib或stroyboard上的图片名称,省去拉取属性
    @IBInspectable var imageName: String? {
        get {
            if let value = objc_getAssociatedObject(self, &imageNameKey) as? String {
                return value
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &imageNameKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /// 判断空值
            guard let name = newValue, name.count > 0 else {
                return
            }
            let bundleImage = Bundle.loadImage(name: name, bundleName: newValue ?? "SWUIKitImages")
            self.image = bundleImage
        }
    }
}

// MARK: ImageView
public extension ImageView {
    /// See UIImageView documentation
    @IBInspectable var image: UIImage? {
        get { return _image }
        set { _image = newValue }
    }

    /// See UIImageView documentation
    @IBInspectable var highlightedImage: UIImage? {
        get { return _highlightedImage }
        set { _highlightedImage = newValue }
    }

    /// See UIImageView documentation
    @IBInspectable var isHighlighted: Bool {
        get { return _isHighlighted }
        set { _isHighlighted = newValue }
    }
    
    @IBInspectable var bundleName: String? {
        get {
            if let value = objc_getAssociatedObject(self, &bundleNameKey) as? String {
                return value
            }
            return Bundle.init(for: type(of: self)).className()
        }
        set {
            objc_setAssociatedObject(self, &bundleNameKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /// 判断空值
            guard let name = imageName, name.count > 0 else {
                return
            }
            let bundleImage = Bundle.loadImage(name: name, bundleName: newValue ?? "SWUIKitImages")
            self.image = bundleImage
        }
    }
    
    /// 配置xib或stroyboard上的图片名称,省去拉取属性
    @IBInspectable var imageName: String? {
        get {
            if let value = objc_getAssociatedObject(self, &imageNameKey) as? String {
                return value
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &imageNameKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /// 判断空值
            guard let name = newValue, name.count > 0 else {
                return
            }
            let bundleImage = Bundle.loadImage(name: name, bundleName: newValue ?? "SWUIKitImages")
            self.image = bundleImage
        }
    }
}

// MARK: SWPageViewController
public extension SWPageViewController {
    @IBInspectable var defaultSelectedIndex: Int {
        get { return _defaultSelectedIndex }
        set { _defaultSelectedIndex = newValue }
    }
    @IBInspectable var isScrollEnabled: Bool {
        get { return _isScrollEnabled }
        set { _isScrollEnabled = newValue }
    }
}
