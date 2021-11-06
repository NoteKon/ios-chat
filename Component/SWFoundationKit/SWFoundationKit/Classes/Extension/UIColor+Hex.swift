//
//  UIColor+Hex.swift
//  SWFoundationKit
//
//  Created by ice on 2019/7/3.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

extension UIColor {
    
    /// 根据单色值（0～255）和alpha值（0.0～1.0）构建`UIColor`
    /// - Parameters:
    ///   - r: 红色值（0～255）
    ///   - g: 绿色值（0～255）
    ///   - b: 蓝色值（0～255）
    ///   - alpha: alpha值（0.0～1.0）
    public convenience init(r: UInt32, g: UInt32, b: UInt32, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    /// 根据RGB颜色值和alpha值（0.0～1.0）构建`UIColor`
    /// - Parameters:
    ///   - hex: RGB颜色值（0x000000~0xFFFFFF）
    ///   - alpha: alpha值（0.0～1.0）
    public convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(r: hex >> 16, g: hex >> 8 & 0xFF, b: hex & 0xFF, alpha: alpha)
    }
    
    /// 根据RGBA颜色值构建`UIColor`
    /// - Parameter rgba: RGBA颜色值（0x00000000～0xFFFFFFFF）
    public convenience init(rgba: UInt32) {
        self.init(r: rgba >> 24, g: rgba >> 16 & 0xFF, b: rgba >> 8 & 0xFF, alpha: CGFloat(rgba & 0xFF) / 255)
    }
}

public extension UIColor {
    /// 根据颜色生成图片
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 图片大小
    ///   - opaque: 是否透明
    /// - Returns: 图片
    static func imageFromColor(color: UIColor, size: CGSize = CGSize(width: 100, height: 100), opaque: Bool = false) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fillEllipse(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    /// 生成随机颜色
    static var randomColor: UIColor {
        let red = CGFloat(arc4random() % 256 ) / 255.0
        let green = CGFloat(arc4random() % 256) / 255.0
        let blue = CGFloat(arc4random() % 256) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// 根据字符串的MD5值中数字的和作为唯一key，获取相同的随机颜色
    /// - Parameters:
    ///   - str: 字符串
    ///   - arr: 随机颜色数组
    /// - Returns: 颜色
    static func randowColorByString(str: String?, arr: [UInt32] = [0x41A2FF, 0x45E79E, 0x56CCF2, 0x6FCF97, 0xA5A6F6, 0xEB5757, 0xF178B6, 0xFFBA29]) -> UIColor? {
        guard let str = str else {
            return nil
        }
        
        let md5Vaule = str.md5()
        var sum = 0
        for ch in md5Vaule {
            let tmp = "\(ch)"
            if tmp.isDigit() {
                sum += tmp.intValue
            }
        }
        let code = sum + str.count
        var index = code%arr.count
        if index < 0 {
            index = -index
        }
        
        let color = UIColor(hex: arr[index])
        return color
    }
}
