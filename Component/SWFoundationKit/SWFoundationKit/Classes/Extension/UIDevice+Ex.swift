//
//  UIDevice+SWExtension.swift
//  SWFoundationKit
//
//  Created by ice on 2019/8/13.
//

import UIKit
import AdSupport

private let DeviceList = [
    /* iPod 5 */          "iPod5,1": "iPod Touch 5",
    /* iPod 6 */          "iPod7,1": "iPod Touch 6",
    /* iPhone 4 */        "iPhone3,1": "iPhone 4",
                          "iPhone3,2": "iPhone 4",
                          "iPhone3,3": "iPhone 4",
    /* iPhone 4S */       "iPhone4,1": "iPhone 4S",
    /* iPhone 5 */        "iPhone5,1": "iPhone 5",
                          "iPhone5,2": "iPhone 5",
    /* iPhone 5C */       "iPhone5,3": "iPhone 5C",
                          "iPhone5,4": "iPhone 5C",
    /* iPhone 5S */       "iPhone6,1": "iPhone 5S",
                          "iPhone6,2": "iPhone 5S",
    /* iPhone 6 */        "iPhone7,2": "iPhone 6",
    /* iPhone 6 Plus */   "iPhone7,1": "iPhone 6 Plus",
    /* iPhone 6S */       "iPhone8,1": "iPhone 6S",
    /* iPhone 6S Plus */  "iPhone8,2": "iPhone 6S Plus",
    /* iPhone 7 */        "iPhone9,1": "iPhone 7",
                          "iPhone9,3": "iPhone 7",
    /* iPhone 7 Plus */   "iPhone9,2": "iPhone 7 Plus",
                          "iPhone9,4": "iPhone 7 Plus",
    /* iPhone SE */       "iPhone8,4": "iPhone SE",
    /* iPhone 8 */        "iPhone10,1": "iPhone 8",
                          "iPhone10,4": "iPhone 8",
    /* iPhone 8 Plus */   "iPhone10,2": "iPhone 8 Plus",
                          "iPhone10,5": "iPhone 8 Plus",
    /* iPhone X */        "iPhone10,3": "iPhone X",
                          "iPhone10,6": "iPhone X",

    /* iPad 2 */          "iPad2,1": "iPad 2",
                          "iPad2,2": "iPad 2",
                          "iPad2,3": "iPad 2",
                          "iPad2,4": "iPad 2",
    /* iPad 3 */          "iPad3,1": "iPad 3",
                          "iPad3,2": "iPad 3",
                          "iPad3,3": "iPad 3",
    /* iPad 4 */          "iPad3,4": "iPad 4",
                          "iPad3,5": "iPad 4",
                          "iPad3,6": "iPad 4",
    /* iPad Air */        "iPad4,1": "iPad Air",
                          "iPad4,2": "iPad Air",
                          "iPad4,3": "iPad Air",
    /* iPad Air 2 */      "iPad5,3": "iPad Air 2",
                          "iPad5,4": "iPad Air 2",
    /* iPad Mini */       "iPad2,5": "iPad Mini",
                          "iPad2,6": "iPad Mini",
                          "iPad2,7": "iPad Mini",
    /* iPad Mini 2 */     "iPad4,4": "iPad Mini 2",
                          "iPad4,5": "iPad Mini 2",
                          "iPad4,6": "iPad Mini 2",
    /* iPad Mini 3 */     "iPad4,7": "iPad Mini 3",
                          "iPad4,8": "iPad Mini 3",
                          "iPad4,9": "iPad Mini 3",
    /* iPad Mini 4 */     "iPad5,1": "iPad Mini 4",
                          "iPad5,2": "iPad Mini 4",
    /* iPad Pro */        "iPad6,7": "iPad Pro",
                          "iPad6,8": "iPad Pro",
    /* AppleTV */         "AppleTV5,3": "AppleTV",
    /* Simulator */       "x86_64": "Simulator",
                          "i386": "Simulator"
]

extension UIDevice {
    
    /// Returns true if its simulator and not a device //TODO: Add to readme
    public class var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// 查询系统名称
    ///
    /// - Returns: 返回系统名称
    public class func systemName() -> String {
        return UIDevice.current.systemName
    }
    
    /// 查询系统版本号
    ///
    /// - Returns: 返回系统版本号
    public class func systemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    /// 查询系统版本号
    ///
    /// - Returns: 返回系统版本号
    public class func systemFloatVersion() -> Float {
        return (systemVersion() as NSString).floatValue
    }
    
    /// 查询设备名
    ///
    /// - Returns: 返回设备名
    public class func deviceName() -> String {
        return UIDevice.current.name
    }
    
    /// 设备语言
    ///
    /// - Returns: 返回当前系统语言
    public class func deviceLanguage() -> String {
        return Locale.preferredLanguages.first ?? Locale.autoupdatingCurrent.identifier
    }
    
    /// 判断是否iPhone
    ///
    /// - Returns: 返回是否iPhone
    public class func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }
    
    /// 判断是否ipad
    ///
    /// - Returns: 返回是否iPad
    public class func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    /// 设备名称
    ///
    /// - Returns: 返回设备名称
    public class func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        var identifier = ""
        let mirror = Mirror(reflecting: machine)
        
        for child in mirror.children {
            let value = child.value
            
            if let value = value as? Int8, value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
        }
        
        return identifier
    }
    
    /// 判断方便读取的设备名
    ///
    /// - Returns: 返回方便读取的设备名
    public class func deviceModelReadable() -> String {
        let model = deviceModel()
        return DeviceList[model] ?? model
    }
    
    /// 获取idfa
    ///
    /// - Returns: 手机的idfa
    public class func idfa() -> String? {
        let ai = ASIdentifierManager.shared()
        return (ai.isAdvertisingTrackingEnabled) ? ai.advertisingIdentifier.uuidString : ""
    }
    
    /// 获取idfv
    ///
    /// - Returns: 手机idfv
    public class func idfv() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    /// 获取当前App语言
    ///
    /// - Returns: 当前App语言
    public class func currentLanguage() -> String {
        if let language = UserDefaults.standard.string(forKey: "AppLanguage") {
            return language
        }
        
        return deviceLanguage()
    }
    
    /// 设置当前App语言
    /// - Parameter language: 设置的语言
    public class func setLanguage(language: String?) {
        UserDefaults.standard.set(language, forKey: "AppLanguage")
    }
    
    /// 获取当前Locale
    ///
    /// - Returns: 当前App Locale
    public class func currentLocale() -> Locale {
        let language = currentLanguage()
        var locale = Locale(identifier: language)
        if String.isEmpty(locale.languageCode) || String.isEmpty(locale.regionCode) {
            let languageCode = locale.languageCode ?? (systemLocale().languageCode ?? Locale.defaultLanguageCode)
            let regionCode = locale.regionCode ?? (systemLocale().regionCode ?? Locale.defaultRegionCode)
            locale = Locale(identifier: "\(languageCode)-\(regionCode)")
        }
        return locale
    }
    
    /// 获取系统Locale
    public class func systemLocale() -> Locale {
        return Locale(identifier: UIDevice.deviceLanguage())
    }
    
    public static var isEnglishLocale: Bool {
        return currentLocale().languageCode == "en"
    }
    
    public static var isChineseLocale: Bool {
        return currentLocale().languageCode == "zh"
    }

    /// 查询设备空间
    ///
    /// - Returns: 设备空间
    public class func totalDiskSpace() -> Int64 {
        var fattributes: [FileAttributeKey: Any]?
        do {
            fattributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        } catch {
        }
        let totalSize = fattributes?[.systemSize] as? NSNumber
        return totalSize?.int64Value ?? 0
    }
    
    /// 查询设备剩余空间
    ///
    /// - Returns: 设备剩余空间
    public class func freeDiskSpace() -> Int64 {
        var fattributes: [FileAttributeKey: Any]?
        do {
            fattributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        } catch {
        }
        let freeSize = fattributes?[.systemFreeSize] as? NSNumber
        return freeSize?.int64Value ?? 0
    }
}
