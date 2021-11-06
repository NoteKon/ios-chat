//
//  SWAppInfo.swift
//  Alamofire
//
//  Created by ice on 2019/8/13.
//

import Foundation

@available(*, deprecated, message: "使用`App.Info`类代替")
public class SWAppInfo: NSObject {
    
    private static let shared = SWAppInfo()
    
    /// 用下标的方式读取`Info.plist`的值
    private subscript(key: String) -> Any? {
        return Bundle.main.object(forInfoDictionaryKey: key)
    }
    
    private func string(_ key: String, defaultValue: String = "") -> String {
        return self[key] as? String ?? defaultValue
    }
    
    // 以下是废弃的方法
    
    /// Returns app's name
    @available(*, deprecated, message: "使用`SWApp.displayName`代替")
    @objc public static var appDisplayName: String {
        let bundleDisplayName = self.bundleDisplayName
        return bundleDisplayName.isEmpty ? self.bundleName : bundleDisplayName
    }
    
    /// Return bundle display name
    @available(*, deprecated, message: "使用`SWApp.bundleDisplayName`代替")
    @objc public static var bundleDisplayName: String {
        return shared.string("CFBundleDisplayName")
    }
    
    /// Return bundle name
    @available(*, deprecated, message: "使用`SWApp.bundleName`代替")
    @objc public static var bundleName: String {
        return shared.string("CFBundleName")
    }
    
    /// Returns app's version number
    @available(*, deprecated, message: "使用`SWApp.version`代替")
    @objc public static var appVersion: String {
        return shared.string("CFBundleShortVersionString")
    }
    
    /// Return app's build number
    @available(*, deprecated, message: "使用`SWApp.build`代替")
    @objc public static var appBuild: String {
        return shared.string(kCFBundleVersionKey as String)
    }
    
    /// Return app's bundle ID
    @available(*, deprecated, message: "使用`SWApp.bundleId`代替")
    @objc public static var appBundleID: String {
        return Bundle.main.bundleIdentifier  ?? ""
    }
    
    /// Return app's shceme, the scheme's Identifier must set main
    @available(*, deprecated, message: "使用`SWApp.scheme`代替")
    @objc public static func scheme() -> String {
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
    
    /// Returns true if its simulator and not a device //TODO: Add to readme
    @available(*, deprecated, message: "使用`UIDevice.isSimulator`代替")
    @objc public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}
