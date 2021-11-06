//
//  Date+Ex.swift
//  SWFoundationKit
//
//  Created by ice on 2019/11/29.
//

import Foundation

/// 星期
public enum Weekday: Int {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

// MARK: - Format

extension DateFormatter {
    /// 初始化DateFormatter
    /// - Parameters:
    ///   - dateFormat: 日期格式字符串
    ///   - locale: 地区
    public convenience init(dateFormat: String, locale: Locale? = nil) {
        self.init()
        self.dateFormat = dateFormat
        if let locale = locale {
            self.locale = locale
        }
    }
}

extension Date {
    /// 从格式化的字符串中创建日期对象
    /// - Parameters:
    ///   - string: 日期字符串
    ///   - format: 日期格式字符串
    ///   - locale: 地区
    public init?(_ string: String, format: String = "yyyy-MM-dd HH:mm:ss", locale: Locale? = nil) {
        if let date = DateFormatter(dateFormat: format, locale: locale).date(from: string) {
            self = date
        } else {
            return nil
        }
    }
}

extension String {
    /// 日期格式化成字符串
    /// - Parameters:
    ///   - date: 日期
    ///   - format: 日期格式字符串
    ///   - locale: 地区
    public init(_ date: Date, format: String = "yyyy-MM-dd HH:mm:ss", locale: Locale? = nil) {
        self = DateFormatter(dateFormat: format, locale: locale).string(from: date)
    }
}

// MARK: - Components

extension Date {
    /// 获取DateComponents，包含：年 月 日 时 分 秒 周
    public func components(_ units: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second, .weekday], calendar: Calendar? = nil) -> DateComponents {
        let calendar = calendar ?? Calendar.current
        return calendar.dateComponents(units, from: self)
    }
    
    /// 返回星期
    public var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    /// 返回年份
    public var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    /// 返回月份
    public var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    /// 返回日期
    public var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    /// 返回小时
    public var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    /// 返回分钟
    public var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    /// 返回秒
    public var second: Int {
        return Calendar.current.component(.second, from: self)
    }
}

// MARK: - Timestamp

extension Date {
    /// Unix Timestamp: 从格林威治时间1970年01月01日00时00分00秒起至现在的总秒数
    public var unixTimestamp: Int {
        return Int(self.timeIntervalSince1970)
    }
    
    /// Timestamp: 从格林威治时间1970年01月01日00时00分00秒起至现在的总豪秒数
    public var timestamp: Int {
        return Int(self.timeIntervalSince1970 * 1000)
    }
    
    /// Now: 当前时间戳(从格林威治时间1970年01月01日00时00分00秒起至现在的总豪秒数)
    public static var now: Int {
        return Int(Date().timeIntervalSince1970 * 1000)
    }
    
    /// Now: 当前时间间隔(从格林威治时间1970年01月01日00时00分00秒起)
    public static var timeInterval: TimeInterval {
        return Date().timeIntervalSince1970
    }
}

// MARK: - Others

extension Date {
    /// 返回天数后缀，类似 th, st, nd, rd
    /// - Parameter locale: 地区。默认是`Locale.enUS`
    /// - Returns: 天数后缀
    public func dayOfMonthSuffix(locale: Locale = Locale.enUS) -> String {
        guard UIDevice.isEnglishLocale else {
            return ""
        }
        
        switch self.day {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
    
    /// 返回星期名称
    /// - Parameter short: 是否缩写
    /// - Parameter locale: 地区。默认是`Locale.enUS`
    /// - Returns: 星期名称
    public func weekdayName(short: Bool = false, locale: Locale = Locale.enUS) -> String {
        return String(self, format: short ? "EEE" : "EEEE", locale: locale)
    }
    
    /// 返回月份名称
    /// - Parameter short: 是否缩写
    /// - Parameter locale: 地区。默认是`Locale.enUS`
    /// - Returns: 月份名称
    public func monthName(short: Bool = false, locale: Locale = Locale.enUS) -> String {
        return String(self, format: short ? "MMM" : "MMMM", locale: locale)
    }
    
    /// 返回 "am" 或 "pm"
    /// - Parameter locale: 地区。默认是`Locale.enUS`
    /// - Returns: "am" 或 "pm"
    public func amOrPmName(locale: Locale = Locale.enUS) -> String {
        return String(self, format: "a", locale: locale).lowercased()
    }
    
    /// 时间戳转Date
    /// - Parameter timeStamp: 字符串时间戳
    /// - Returns: Date
    public func dateWithFromTimeStamp(timeStamp:String) ->Date {
        let interval:TimeInterval = TimeInterval.init(timeStamp)!
        return Date(timeIntervalSince1970: interval)
    }
}
