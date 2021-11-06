//
//  UIFont+Ex.swift
//  SWFoundationKit
//
//  Created by ice on 2019/7/5.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

/// 系统字体
extension UIFont {
    public static func pingFangRegular(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    public static func pingFangMedium(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    public static func pingFangSemibold(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    public static func pingFangLight(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .light)
    }
    
    public static func pingFangThin(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .thin)
    }
}

/// 自定义字体
/// 1、导入三方字体文件
/// 2、使用 familyFont 查找字体名称
/// 3、Info.plist 文件添加字体  对应的添加Fonts provided by application，value是数组把你的自定义字体文件名写入即可
/// 4、通过 UIFont(name: "Avenir-Book", size: size) 加载字体
/// Avenir字体通用API
extension UIFont {
    
    /// Book
    /// - Parameter size: 字体大小
    public static func avenirBook(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "Avenir-Book", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    /// Medium
    /// - Parameter size: 字体大小
    public static func avenirMedium(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "Avenir-Medium", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    /// Heavy
    /// - Parameter size: 字体大小
    public static func avenirHeavy(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "Avenir-Heavy", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    /// Light
    /// - Parameter size: 字体大小
    public static func avenirLight(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "Avenir-Light", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    /// Roman
    /// - Parameter size: 字体大小
    public static func avenirRoman(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "Avenir-Roman", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    public static func familyFont() {
        for familyName in UIFont.familyNames {
            print("FamilyName: \(familyName)")
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                print("FontName: \(fontName)")
            }
        }
    }
}



