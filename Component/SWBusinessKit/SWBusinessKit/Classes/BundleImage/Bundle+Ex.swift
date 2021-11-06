//
//  Bundle+Ex.swift
//  SWBundleImage
//
//  Created by Guo ZhongCheng on 2020/12/9.
//

import UIKit

public extension Bundle {

    /// 获取模块对应bundle
    /// - Parameters:
    ///   - resource: bundle文件夹名称（通常为为模块名称）
    ///   - customClass: 模块中的任意自定义类
    static func bundle(resource: String, customClass: AnyClass) -> Bundle {
        var bundle = Bundle.init(for: customClass)
        if let resourcePath = bundle.path(forResource: resource, ofType: "bundle") {
            if let resourcesBundle = Bundle(path: resourcePath) {
                bundle = resourcesBundle
            }
        }
        return bundle
    }
    
    /// 获取图片
    /// - Parameter imageName: 图片名称
    func bundleImage(imageName: String) -> UIImage? {
        if #available(iOS 13.0, *) {
            let image = UIImage(named: imageName, in: self, with: .none)
            return image
        } else {
            let image = UIImage(named: imageName, in: self, compatibleWith: .none)
            return image
        }
    }
    
    /// 获取路径图片（不会加入到系统缓存）
    /// - Parameters:
    ///   - path: 路径，相对于bundle
    ///   - type: 扩展名
    ///   - useScale: 是否根据屏幕分辨率拼接 @2x或@3x，默认为true
    /// - Returns: 图片
    func bundleImage(path: String, type: String = "png", useScale: Bool = true) -> UIImage? {
        var scaleString = ""
        if useScale {
            let scale: CGFloat = UIScreen.main.scale
            if scale == 2 {
                scaleString = "@2x"
            }
            if scale >= 3 {
                scaleString = "@3x"
            }
        }
        guard
            let fullPath = self.path(forResource: "\(path)\(scaleString)", ofType: type),
            let image = UIImage(contentsOfFile: fullPath)
        else {
            return nil
        }
        return image
    }
    
    /// 根据系统模式(light/dark)获取不同的图片（仅iOS13有效，iOS13以下直接返回light图片）
    ///
    /// - Parameters:
    ///     - light: light/unspecified 主题下返回的图片名称
    ///     - dark: dark 主题下返回的图片名称
    func bundleImage(lightImageName: String, darkImageName: String) -> UIImage? {
        if #available(iOS 13.0, *) {
            // 获取当前模式
            let currentMode = UITraitCollection.current.userInterfaceStyle
            if (currentMode == .dark) {
                let image = UIImage(named: darkImageName, in: self, with: .none)
                return image
            } else {
                let image = UIImage(named: lightImageName, in: self, with: .none)
                return image
            }
        } else {
            let image = UIImage(named: lightImageName, in: self, compatibleWith: .none)
            return image
        }
    }
}


