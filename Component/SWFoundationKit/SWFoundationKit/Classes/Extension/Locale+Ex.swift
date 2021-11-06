//
//  Locale+Ex.swift
//  SWFoundationKit
//
//  Created by ice on 2020/1/13.
//

import Foundation

extension Locale {
    public static let zhHansCN = Locale(identifier: "zh_Hans_CN")
    public static let enUS = Locale(identifier: "en_US")
    
    /// 默认语言码
    static var defaultLanguageCode = "en"
    /// 默认区域码
    static var defaultRegionCode = "US"
    
    /// 返回形如：en-US, zh-CN 的字符串
    public var genericIdentifier: String {
        let languageCode = self.languageCode ?? Locale.defaultLanguageCode
        let regionCode = self.regionCode ?? Locale.defaultRegionCode
        return "\(languageCode)-\(regionCode)"
    }
}
