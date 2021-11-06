//
//  SWApp.swift
//  SWFoundationKit
//
//  Created by ice on 2020/6/8.
//

import Foundation

public struct SWApp {
    /// 读取`Info.plist`文件的数据
    public static let info = Info()
    
    /// 缓存管理
    public static let cache = Cache(manager: FileBasedCacheManager())
    
    /// Session数据管理
    public static let session = Session.shared
    
    /// Returns app's version number
    public static var version: String {
        return info.string("CFBundleShortVersionString")
    }
    
    /// Return app's build number
    public static var build: String {
        return info.string(kCFBundleVersionKey as String, defaultValue: "0")
    }
    
    /// Returns app's name
    public static var displayName: String {
        let bundleDisplayName = self.bundleDisplayName
        return bundleDisplayName.isEmpty ? self.bundleName : bundleDisplayName
    }
    
    /// Returns bundle display name
    public static var bundleDisplayName: String {
        return info.string("CFBundleDisplayName")
    }
    
    /// Returns bundle name
    public static var bundleName: String {
        return info.string("CFBundleName")
    }
    
    /// Returns app's bundle ID
    public static var bundleId: String {
        return Bundle.main.bundleIdentifier  ?? ""
    }
    
    /// Returns app's shceme, the scheme's Identifier must set main
    public static var scheme: String {
        guard
            let infoDic = Bundle.main.infoDictionary,
            let bundleUrltypes = infoDic["CFBundleURLTypes"] as? [[String: Any]]
            else { return "" }
        for item in bundleUrltypes {
            if let schemesName = item["CFBundleURLName"] as? String, schemesName == "main", let urlSchemes = item["CFBundleURLSchemes"] as? [String] {
                return urlSchemes[0] + "://"
            }
        }
        return ""
    }
    
    /// Returns app's language
    public static var language: String {
        get {
            return UIDevice.currentLanguage()
        }
        set {
            UIDevice.setLanguage(language: newValue)
        }
    }
    
    
}

extension SWApp {
    /// `Info.plist`文件处理类
    public struct Info {
        /// 用下标的方式读取`Info.plist`的值
        public subscript(key: String) -> Any? {
            return Bundle.main.object(forInfoDictionaryKey: key)
        }
        
        /// 获取`Info.plist`中对应键名的字符串值
        /// - Parameters:
        ///   - key: 键名
        ///   - defaultValue: 默认值
        /// - Returns: `Info.plist`中找到的字符串值，或者默认值
        public func string(_ key: String, defaultValue: String = "") -> String {
            return self[key] as? String ?? defaultValue
        }
    }
}
