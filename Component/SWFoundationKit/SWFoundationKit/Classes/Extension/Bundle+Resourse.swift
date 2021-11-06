//
//  Bundle+Resourse.swift
//  SWLoginSDK_Example
//
//  Created by ice on 2019/7/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

private enum BundlePackageType: String {
    case app = "APPL"
    case framework = "FMWK"
    case bundle = "BNDL"
}

extension Bundle {
    public static func resourceBundle(bundleName: String,
                                      targetClass: AnyClass? = nil) -> Bundle? {
        var frameworkBundle: Bundle?
        if let targetClass = targetClass {
            frameworkBundle = Bundle(for: targetClass)
        } else {
            frameworkBundle = Bundle(identifier: "org.cocoapods." + bundleName)
            if let type = frameworkBundle?.infoDictionary?["CFBundlePackageType"] as? String,
                type == BundlePackageType.bundle.rawValue {
                return frameworkBundle
            }
        }
        
        return findResourceBundle(bundleName: bundleName, from: frameworkBundle)
    }
    
    /// 加载图片
    /// - Parameters:
    ///   - name: 图片名称
    ///   - bundleName: bundle名称
    ///   - targetClass: 目标类
    /// - Returns: 图片对象
    public static func loadImage(name: String,
                                 bundleName: String,
                                 targetClass: AnyClass? = nil) -> UIImage? {
        let bundle = Bundle.resourceBundle(bundleName: bundleName, targetClass: targetClass)
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        return image
    }
    
    /// 获取本地化字符串
    /// - Parameters:
    ///   - key: 本地化字符串key值
    ///   - value: 默认值
    ///   - bundleName: bundle名称
    ///   - targetClass: 目标类
    /// - Returns: 本地化后的字符串
    public static func localizedString(key: String,
                                       value: String? = nil,
                                       bundleName: String,
                                       targetClass: AnyClass? = nil) -> String {
        
        func findLanguage(_ language: String, bundle: Bundle, key: String, value: String? = nil) -> String? {
            guard let path = bundle.path(forResource: language, ofType: "lproj") else {
                return nil
            }
            let currentBundle = Bundle(path: path)
            return currentBundle?.localizedString(forKey: key, value: value, table: nil)
        }
        
        if let bundle = Bundle.resourceBundle(bundleName: bundleName, targetClass: targetClass) {
            // 使用App内配置语言,默认为系统语言
            let languages = lprojFileNames(language: UIDevice.currentLanguage())
            
            let never = "~&^@"
            for language in languages {
                if let string = findLanguage(language, bundle: bundle, key: key, value: never), string != never {
                    return string
                }
            }
        }
        
        return value ?? key
    }
    
    public static func loadNibNamed(_ name: String,
                                    owner: Any?,
                                    options: [UINib.OptionsKey: Any]? = nil,
                                    bundleName: String,
                                    targetClass: AnyClass? = nil) -> [Any]? {
        let bundle = Bundle.resourceBundle(bundleName: bundleName, targetClass: targetClass)
        return bundle?.loadNibNamed(name, owner: owner, options: options)
    }
    
    /// 默认的多语言文件名（不包括.lproj后缀，例如 `zh-Hans`, `en`）
    /// - Note: 在找不到与当前语言匹配的多语言资源文件时，就使用该默认值
    public static var defaultLprojName = "en"
}

extension Bundle {
    /// 寻找资源bundle
    /// - Parameters:
    ///   - bundleName: bundle名称
    ///   - from: 父级bundle
    /// - Returns: bundle对象
    private static func findResourceBundle(bundleName: String, from: Bundle?) -> Bundle? {
        if let bundleUrl = from?.url(forResource: bundleName, withExtension: "bundle") {
            let currentBundel = Bundle(url: bundleUrl)
            return currentBundel
        }
        return Bundle.main
    }
    
    /// 寻找合适的语言资源名集合
    /// - Parameter language: 当前语言
    private static func lprojFileNames(language: String) -> [String] {
        let language = language.lowercased()
        
        // 明确指定简体中文
        if language.hasPrefix("zh-hans") || language.hasSuffix("zh-chs") {
            return ["zh-Hans", "en"]
        }
        // 明确指定繁体中文
        if language.hasPrefix("zh-hant") || language.hasSuffix("zh-cht") {
            return ["zh-Hant", "en"]
        }
        // 根据地区判断中文：港澳台繁体，其余简体
        if language.hasPrefix("zh") {
            let isTraditional = language.hasSuffix("tw") || language.hasSuffix("hk") || language.hasSuffix("mo")
            return isTraditional ? ["zh-Hant", "en"] : ["zh-Hans", "en"]
        }
        
        if defaultLprojName == "en" {
            return [defaultLprojName]
        }
        
        return [defaultLprojName, "en"]
    }
}
