//
//  Date+Ex.swift
//  SWUIKit
//
//  Created by ice on 2019/9/9.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import SwiftDate

public extension Date {
    
    func toString(format: String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en")
        let dateStr = formatter.string(from: self)
        
        return dateStr
    }
    
    static func getLocaleFormat() -> String {
        let locale = UIDevice.currentLocale().languageCode ?? kLanguageEn
        if locale == kLanguageZh {
            return "yyyy年MM月dd日 HH:mm"
        } else {
            return "dd MMM yyyy,HH:mm"
        }
    }
    
    /// 预定选择器获取日期格式
    static func getReserveDateLocaleFormat() -> String {
        let locale = UIDevice.currentLocale().languageCode ?? kLanguageEn
        if locale == kLanguageZh {
            return "MM-dd"
        } else {
            return "MM-dd"
        }
    }
    
    /// 预定选择器获取预定信息时间格式
    static func getReserveSumaryLocaleFormat() -> String {
        let locale = UIDevice.currentLocale().languageCode ?? kLanguageEn
        if locale == kLanguageZh {
            return "MM月dd日"
        } else {
            return "dd MMM"
        }
    }
    
    func getWeekDayName() -> String {
        let locale = UIDevice.currentLocale().languageCode ?? kLanguageEn
        switch self.weekday {
        case 1:
            return locale == kLanguageEn ? "Sun" : "周日"
        case 2:
            return locale == kLanguageEn ? "Mon" : "周一"
        case 3:
            return locale == kLanguageEn ? "Tue" : "周二"
        case 4:
            return locale == kLanguageEn ? "Wed" : "周三"
        case 5:
            return locale == kLanguageEn ? "Thu" : "周四"
        case 6:
            return locale == kLanguageEn ? "Fri" : "周五"
        case 7:
            return locale == kLanguageEn ? "Sat" : "周六"
        default:
            return locale == kLanguageEn ? "Sun" : "周日"
        }
    }
    
    static func vlTimeFormateWithInterval(interval: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(interval / 1000))
        let formatter = DateFormatter()
        let locale = Locale(identifier: "en-US")
        formatter.locale = locale
        formatter.dateFormat = UIDevice.isChineseLocale ? "yyyy-MM-dd HH:mm" : "dd MMM yyyy, HH:mm"
    
        let formatTime = formatter.string(from: date)
        return formatTime
    }
    
    /// 时间戳转预订订单样式的日期字符串
    /// - Parameter interval: 时间戳
    static func vlReserveOrderTimeFormateWithInterval(interval: Int) -> String {
        let date = DateInRegion(Date(timeIntervalSince1970: Double(interval / 1000)), region: .local)
        let isChinese = UIDevice.isChineseLocale
        let locale: Locales = isChinese ? .chinese : .english
        let format = isChinese ? "MMMdd'日'，EEE，HH:mm" : "dd MMM, EEE, HH:mm"
        let timeStr = date.toFormat(format, locale: locale)
        return timeStr
    }
    
    /// - Parameter interval: 5月28日
    static func vlMddTimeFormateWithInterval(interval: Int) -> String {
        let date = DateInRegion(Date(timeIntervalSince1970: Double(interval / 1000)), region: .local)
        let isChinese = UIDevice.isChineseLocale
        let locale: Locales = isChinese ? .chinese : .english
        let format = isChinese ? "M月dd日" : "M-dd"
        let timeStr = date.toFormat(format, locale: locale)
        return timeStr
    }
    
    /// 时间戳转首页生活计划提醒卡日期字符串
    /// - Parameters:
    ///   - interval: 原始时间戳
    ///   - isThisYear: 是否跨年，因无法使用系统当前时间去判断是否跨年(系统时间可以修改)
    static func vlMddTimeFormateWithInterval(interval: Int, isThisYear: Bool) -> String {
        let date = DateInRegion(Date(timeIntervalSince1970: Double(interval / 1000)), region: .local)
        let isChinese = UIDevice.isChineseLocale
        let locale: Locales = isChinese ? .chinese : .english
        var format: String
        if isThisYear {
            format = isChinese ? "M月d日" : "d MMM"
        } else {
            format = isChinese ? "yyyy年M月d日" : "d MMM yyyy"
        }
        let timeStr = date.toFormat(format, locale: locale)
        return timeStr
    }
    
    /// 时间戳转首页生活计划采买卡日期字符串
    /// - Parameters:
    ///   - interval: 原始时间戳
    static func vlCMTimeFormateWithInterval(interval: TimeInterval) -> String {
        let date = DateInRegion(Date(timeIntervalSince1970: Double(interval / 1000)), region: .local)
        let isChinese = UIDevice.isChineseLocale
        let locale: Locales = isChinese ? .chinese : .english
        let format: String = isChinese ? "M.d" : "d.M"
        let timeStr = date.toFormat(format, locale: locale)
        return timeStr
    }
    
    static func vlTimeFormateWithString(interval: TimeInterval, formatStr: String = "yyyy-MM-dd HH:mm") -> String {
        let date = Date(timeIntervalSince1970: Double(interval / 1000))
        let formatter = DateFormatter()
        let locale = Locale(identifier: "en-US")
        formatter.locale = locale
        formatter.dateFormat = formatStr
        let formatTime = formatter.string(from: date)
        return formatTime
    }
    
    static func vlTimeFormateWithStr(interval: TimeInterval, formatStr: String = "yyyy-MM-dd HH:mm") -> String {
        let date = DateInRegion(Date(timeIntervalSince1970: Double(interval / 1000)), region: .local)
        let isChinese = UIDevice.isChineseLocale
        let locale: Locales = isChinese ? .chinese : .english
        if isChinese { // 订单卡中英文状态上下午单位设置
//            date.formatter().shortWeekdaySymbols = date.formatter().shortWeekdaySymbols.map { $0.uppercased() }
            date.formatter().amSymbol = "上午"
            date.formatter().pmSymbol = "下午"
        } else {
            date.formatter().amSymbol = "a.m"
            date.formatter().pmSymbol = "p.m"
        }
        let timeStr = date.toFormat(formatStr, locale: locale)
        return timeStr
    }
}

public extension Date {
    /// ***********发现模块*************
    /// 根据对比当前时间，返回几分钟前，几小时前，几天前(支持国际化)
    var ago: String {
        let dfmatter = DateFormatter()
        let calendar = Calendar.current
        let nowYear: Int = calendar.component(.year, from: Date())
        let selfYear: Int = calendar.component(.year, from: self)
        /// *****不是今年*****
        if nowYear != selfYear {
            // yyyy-MM-dd
            dfmatter.dateFormat = "yyyy-MM-dd"
            return dfmatter.string(from: self)
        }
        /// ******今年******
        // 获取当前的时间戳
        let currentTime = floor(Date().timeIntervalSince1970)
        let timeStamp = self.timeIntervalSince1970
        // 时间差
        let reduceTime: TimeInterval = currentTime - timeStamp
        // 时间差小于5分钟
        if reduceTime < 60 * 5 {
            return localizedString("sw_finder_common_time_just_now")
        }
        // 时间差大于5分钟小于60分钟内
        let mins = Int(reduceTime / 60)
        if mins < 60 {
            let minAgo = localizedString("sw_finder_common_time_min_ago")
            return "\(mins)" + minAgo
        }
        let hours = Int(reduceTime / 3600)
        // 小于24小时
        if hours < 24 {
            let hoursAgo = localizedString("sw_finder_common_time_hours_ago")
            return "\(hours)" + hoursAgo
        }
        let days = Int(reduceTime / 3600 / 24)
        // 小于168小时
        if hours < 168 {
            let daysAgo = localizedString("sw_finder_common_time_days_ago")
            return "\(days)" + daysAgo
        }
        // 大于168小时且是今年
        dfmatter.dateFormat = "MM-dd"
        return dfmatter.string(from: self)
    }
    
    /// 判断当前系统是否是12小时制
    static var is12HourClock: Bool {
        guard let dateFormat: String = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current), dateFormat.range(of: "a") != nil else {
            return false
        }
        return true
    }
}

public extension Date {
    
    /// 日期拼接时间
    /// - Parameters:
    ///   - originTime: 原始日期
    ///   - newTime: 待拼接时间
    static func mergeStringTime(originTime: TimeInterval, newTime: String) -> Int {
        let origainDate = DateInRegion(milliseconds: Int(originTime), region: .local)
        if let date = newTime.toDate(), let newDate = origainDate.dateBySet(hour: date.hour, min: date.minute, secs: date.second) {
            return Int(newDate.timeIntervalSince1970 * 1000)
        }
        
        return Int(originTime)
    }
    
    /// 时间戳转成新的时间戳 1565230140000 (2019-08-08 10:09:00) -> 1565193600000 (2019-08-08 00:00:00)
    /// - Parameters:
    ///   - originTime: 原始时间戳
    ///   - format: 转换格式
    static func toNewInterval(originTime: TimeInterval) -> TimeInterval? {
        let orginDate = Date(timeIntervalSince1970: originTime / 1000)
        let beginDate = Calendar.current.startOfDay(for: orginDate)
        return beginDate.timeIntervalSince1970 * 1000
    }
    
    /// 返回形如：XX分钟  X小时YY分钟
    /// - Parameter time: 时间戳（单位：秒）
    static func consumeTimeStrings(time: Int?, prefix: String = "") -> String? {
        guard let time = time, time > 0 else { return nil }
        
        let hour = time / 60
        
        let min = time % 60
        let hourStr = hour > 0 ? "\(hour)小时" : ""
        let minuteStr = min > 0 ? "\(min)分钟" : ""
        
        // 演示单语言，避免出现部分中文部分英文
//        let hourStr = hour > 0 ? "\(hour)\(localizedString("vl_consume_time_unit_minute"))" : ""
//        let minuteStr = time > 0 ? "\(time)\(localizedString("vl_consume_time_unit_hour"))" : ""
        return prefix + hourStr + minuteStr
    }
    
    func getYearMonthDay() -> (year: Int, month: Int, day: Int) {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        guard let year =  components.year, let month = components.month, let day = components.day else { return (0, 0, 0) }
        return (year, month, day)
    }
}

public extension Date {
    static func setCurrentDayWithHour(_ hour: Int, minute: Int, second: Int) -> TimeInterval {
        let calendar = Calendar(identifier: .gregorian)
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        
        var dateComponentsForDate = DateComponents()
        dateComponentsForDate.year = dateComponents.year
        dateComponentsForDate.month = dateComponents.month
        dateComponentsForDate.day = dateComponents.day
        dateComponentsForDate.hour = hour
        dateComponentsForDate.minute = minute
        dateComponentsForDate.second = second
        
        let date = calendar.date(from: dateComponentsForDate)
        
        return (date?.timeIntervalSince1970 ?? 0)
    }
    
    static func stringFromDate(_ date: Date, format: String, locale: Locale = Locale(identifier: "en_US")) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        dateFormat.locale = locale
        
        return dateFormat.string(from: date)
    }
    
    static func dateFromString(_ string: String, format: String, locale: Locale = Locale(identifier: "en_US")) -> Date? {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        dateFormat.locale = locale
        
        return dateFormat.date(from: string)
    }
    
    func getPreMonthDate() -> Date {
        let calendar = NSCalendar.current
        var components = calendar.dateComponents([.year, .month], from: self)
        components.month = (components.month ?? 0) - 1
        return calendar.date(from: components) ?? date
    }
    
    func getNextMonthDate() -> Date {
        let calendar = NSCalendar.current
        var components = calendar.dateComponents([.year, .month], from: self)
        components.month = (components.month ?? 0) + 1
        return calendar.date(from: components) ?? date
    }
    
    func getPreDayDate() -> Date {
        let calendar = NSCalendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.day = (components.day ?? 0) - 1
        return calendar.date(from: components) ?? date
    }
    
    func getNextDayDate() -> Date {
        let calendar = NSCalendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.day = (components.day ?? 0) + 1
        return calendar.date(from: components) ?? date
    }
    
    /// 指定日期月的开始日期
    func startOfMonth() -> Date {
        let calendar = NSCalendar.current
        var components = calendar.dateComponents([.year, .month], from: self)
        components.day = 1
        let startDate = calendar.date(from: components)!
        return startDate
    }
     
    /// 指定日期月的结束日期
    func endOfMonth() -> Date {
        let calendar = NSCalendar.current
        let nextMonth = getNextMonthDate()
        var components = calendar.dateComponents([.year, .month], from: nextMonth)
        components.second = -1
        return calendar.date(from: components)!
    }
    /// 当前年+1（明年今时今日）
    func getNextYearDate() -> Date {
        let calendar = NSCalendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.year = (components.year ?? 0) + 1
        return calendar.date(from: components) ?? date
    }
}

public extension Date {
    /// 判断是否是同一天
    /// - Parameter time1: 时间戳1（单位：豪秒）
    /// - Parameter time2: 时间戳2（单位：豪秒）
    /// - Returns: true-同一天，false-不是同一天
    static func isSameDay(time1: Int64, time2: Int64) -> Bool {
        let date1 = Date(timeIntervalSince1970: TimeInterval(time1 / 1000))
        let date2 = Date(timeIntervalSince1970: TimeInterval(time2 / 1000))
        
        let calendar = Calendar.current
        
        let year1 = calendar.component(.year, from: date1)
        let year2 = calendar.component(.year, from: date2)
        if year1 != year2 {
            return false
        }
        
        let month1 = calendar.component(.month, from: date1)
        let month2 = calendar.component(.month, from: date2)
        if month1 != month2 {
            return false
        }
        
        let day1 = calendar.component(.day, from: date1)
        let day2 = calendar.component(.day, from: date2)
        if day1 != day2 {
            return false
        }
        
        return true
    }
    
    static func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day, .month, .year]
        let nowComps = calendar.dateComponents(unit, from: Date())
        let selfCmps = calendar.dateComponents(unit, from: date)
        
        return (selfCmps.year == nowComps.year) &&
            (selfCmps.month == nowComps.month) &&
            (selfCmps.day == nowComps.day)
    }
    
    static func isYesterday(interval: TimeInterval?) -> Bool {
        if let interval = interval {
            let calendar = Calendar.current
            let date = Date(timeIntervalSince1970: interval)
            if calendar.isDateInYesterday(date) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    static func isTomorrow(interval: TimeInterval?) -> Bool {
        if let interval = interval {
            let calendar = Calendar.current
            let date = Date(timeIntervalSince1970: interval)
            if calendar.isDateInTomorrow(date) {
                return true
            } else {
                return false
            }
        }
        return false
    }
}
