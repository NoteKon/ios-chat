//
//  NSAttributedString+Ex.swift
//  VVLife
//
//  Created by 黄泳东 on 2020/7/29.
//  Copyright © 2020 vv. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    
    /// 生成包含图片和文字的富文本
    /// - Parameters:
    ///   - image: 图片
    ///   - bounds: 图片范围
    ///   - isFront: 图片是否在文字前面
    ///   - string: 字符串
    ///   - font: 字体
    ///   - textColor: 文字颜色
    /// - Returns: 包含图片和文字的富文本
    public static func attributedString(image: UIImage?, bounds: CGRect, isFront: Bool, string: String, font: UIFont, textColor: UIColor) -> NSMutableAttributedString {
        var mAttributedString = NSMutableAttributedString()
        // 图片是否在文字前面
        if isFront {
            mAttributedString = NSMutableAttributedString(attributedString: attributedString(image: image, bounds: bounds))
            mAttributedString.append(attributedString(string: string, font: font, textColor: textColor))
        } else {
            mAttributedString = NSMutableAttributedString(attributedString: attributedString(string: string, font: font, textColor: textColor))
            mAttributedString.append(attributedString(image: image, bounds: bounds))
        }
        return mAttributedString
    }
    
    
    /// 生成文字富文本
    /// - Parameters:
    ///   - string: 字符串
    ///   - font: 字体
    ///   - textColor: 文字颜色
    /// - Returns: 文字富文本
    public static func attributedString(string: String?, font: UIFont, textColor: UIColor) -> NSMutableAttributedString {
        guard let string = string else {
            return NSMutableAttributedString()
        }
        return NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.font: font])
    }
    
    /// 生成图片富文本
    /// - Parameters:
    ///   - image: 图片
    ///   - bounds: 图片范围
    /// - Returns: 图片富文本
    public static func attributedString(image: UIImage?, bounds: CGRect) -> NSMutableAttributedString {
        guard let image = image else {
            return NSMutableAttributedString()
        }
        let attach = NSTextAttachment()
        attach.image = image
        attach.bounds = bounds
        return NSMutableAttributedString(attachment: attach)
    }
    
    /// 生成带阴影的富文本
    /// - Parameters:
    ///   - string: 字符串
    ///   - font: 字体
    ///   - textColor: 字体颜色
    ///   - shadowBlurRadius: 阴影半径
    ///   - shadowColor: 阴影颜色
    ///   - shadowOffset: 阴影偏移
    /// - Returns: 富文本
    public static func attributedString(string: String?, font: UIFont?, textColor: UIColor?, shadowBlurRadius: CGFloat = 2.0, shadowColor: UIColor = .black, shadowOffset: CGSize = CGSize(width: 0, height: 1)) -> NSMutableAttributedString {
        guard let string = string else {
            return NSMutableAttributedString()
        }
        let shadow: NSShadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowBlurRadius = shadowBlurRadius
        shadow.shadowOffset = shadowOffset
        let attributeString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.shadow: shadow])
        if let textColor = textColor {
            attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: NSMakeRange(0, attributeString.length))
        }
        if let font = font {
            attributeString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, attributeString.length))
        }
        return attributeString
    }
    
    /// 生成带阴影的富文本
    /// - Parameters:
    ///   - string: 字符串
    ///   - shadowBlurRadius: 阴影半径
    ///   - shadowColor: 阴影颜色
    ///   - shadowOffset: 阴影偏移
    /// - Returns: 富文本
    public static func attributedString(string: String?, shadowBlurRadius: CGFloat = 2.0, shadowColor: UIColor = .black, shadowOffset: CGSize = CGSize(width: 0, height: 1)) -> NSMutableAttributedString {
        guard let string = string else {
            return NSMutableAttributedString()
        }
        let shadow: NSShadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowBlurRadius = shadowBlurRadius
        shadow.shadowOffset = shadowOffset
        let attributeString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.shadow: shadow])
        return attributeString
    }
}
