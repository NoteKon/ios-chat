//
//  TimeSta.swift
//  SWFoundationKit
//
//  Created by ice on 2021/6/18.
//

import Foundation
extension TimeInterval {
    
    /// 时间戳转成字符串日期（秒）
    /// - Parameters:
    ///   - format: 时间格式
    ///   - locale: 时间区域
    /// - Returns: 字符串日期
    public func toString(format: String = "yyyy-MM-dd HH:mm:ss", locale: Locale? = nil) -> String {
        let date = Date.init(timeIntervalSince1970: self)
        let timeStr = DateFormatter(dateFormat: format, locale: locale).string(from: date)
        return timeStr
    }
}
