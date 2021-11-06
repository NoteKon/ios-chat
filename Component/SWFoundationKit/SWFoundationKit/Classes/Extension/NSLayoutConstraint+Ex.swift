//
//  NSLayoutConstraint+Extension.swift
//  Pods
//
//  Created by ice on 2020/1/19.
//

import Foundation
/// xib单约束适配方案
extension NSLayoutConstraint {
    /// 约束是否自动适配屏幕宽度，默认宽度375，iPhoneX屏幕宽度
    @IBInspectable var isScale: Bool {
        get {
            return true
        }
        set {
            if newValue == true {
                self.constant = self.constant.scaleW()
            }
        }
    }
}

/// 全局适配方案
/// 使用方式:
/*  1、配置全局缩放策略
 `SWAdaptScreenConfig.config { (floatValue) -> (CGFloat) in
 // 不缩放
 //return floatValue
 
 // 根据根据设计稿屏幕宽度来缩放
 // return floatValue * UIScreen.main.bounds.size.width/375
 // 放大1.2倍
 return floatValue * 1.2
 }`
 
 2、调用在UIViewController中 `func viewDidLoad()`
 view.adaptScreenWidth(type: .all)
 */

public func SWAdaptW(_ floatValue: CGFloat) -> CGFloat {
    return SWAdaptScreenConfig.service.adaptBlock?(floatValue) ?? floatValue
}

public class SWAdaptScreenConfig {
    public typealias SWAdaptScreenBlock = (CGFloat)->(CGFloat)
    
    private(set) var adaptBlock: SWAdaptScreenBlock?
    static let service = SWAdaptScreenConfig()
    
    public static func config(_ handle: SWAdaptScreenBlock?) {
        SWAdaptScreenConfig.service.adaptBlock = handle
    }
}

public struct AdaptScreenType: OptionSet {
    
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// 对约束的constant等比例
    public static let constraint = AdaptScreenType(rawValue: 1)
    /// 对字体等比例
    public static let fontSize = AdaptScreenType(rawValue: 2)
    /// 对圆角等比例
    public static let cornerRadius = AdaptScreenType(rawValue: 4)
    /// 对现有支持的属性等比例
    public static let all: AdaptScreenType = [constraint, fontSize, cornerRadius]
}

public extension UIView {
    /// 遍历当前view对象的subviews，对目标进行等比例换算
    ///
    /// - Parameters:
    ///   - type: 想要和基准屏幕等比例换算的属性类型
    ///   - recursion: 是否需要递归对子view进行操作
    ///   - recursionExceptViews: 递归时需要例外的viewclass
    func adaptScreenWidth(type: AdaptScreenType, recursion: Bool = true, recursionExceptViews: [AnyClass]? = nil) {
        if self.isExceptViewClassWithClassArray(recursionExceptViews) {
            return
        }
        
        // 约束
        if type.contains(.constraint) {
            for subConstraint in self.constraints {
                subConstraint.constant = SWAdaptW(subConstraint.constant)
            }
        }
        
        // 字体大小
        if type.contains(.fontSize) {
            if let labelSelf = self as? UILabel, !labelSelf.isKind(of: NSClassFromString("UIButtonLabel")!) {
                labelSelf.font = labelSelf.font.withSize(SWAdaptW(labelSelf.font.pointSize))
            } else if let textFieldSelf = self as? UITextField {
                textFieldSelf.font = textFieldSelf.font!.withSize(SWAdaptW(textFieldSelf.font!.pointSize))
            } else if let buttonSelf = self as? UIButton {
                buttonSelf.titleLabel!.font = buttonSelf.titleLabel!.font.withSize(SWAdaptW(buttonSelf.titleLabel!.font.pointSize))
            } else if let textViewSelf = self as? UITextView {
                textViewSelf.font = textViewSelf.font!.withSize(SWAdaptW(textViewSelf.font!.pointSize))
            }
        }
        
        // 圆角
        if type.contains(.cornerRadius), self.layer.cornerRadius != 0 {
            self.layer.cornerRadius = SWAdaptW(self.layer.cornerRadius)
        }
        
        if recursion {
            // 继续对子view操作
            for subView in self.subviews {
                subView.adaptScreenWidth(type: type, recursion: recursion, recursionExceptViews: recursionExceptViews)
            }
        }
    }
    
    /// 当前view对象是否是例外的视图
    func isExceptViewClassWithClassArray(_ classArray: [AnyClass]?) -> Bool {
        var isExcept = false
        if let classArray = classArray {
            for item in classArray {
                if self.isKind(of: item.class()) {
                    isExcept = true
                }
            }
        }
        return isExcept
    }
}
