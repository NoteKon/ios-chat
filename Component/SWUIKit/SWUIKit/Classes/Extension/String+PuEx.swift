//
//  String+PuEx.swift
//  SWUIKit
//
//  Created by vv on 2019/10/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

public extension String {
    
    /// 日期格式转转时间戳示例26-09-2021 20:45:46"
    /// - Parameter dateFormat: dateFormat description
    /// - Returns: description
     func timeStrChangeTotimeInterval(_ dateFormat:String? = "dd-MM-yyyy HH:mm:ss") -> String {
        if self.isEmpty {
            return ""
        }
        let format = DateFormatter.init()
        format.dateStyle = .medium
        format.timeStyle = .short
        if dateFormat == nil {
            format.dateFormat = "dd-MM-yyyy HH:mm:ss"
        }else{
            format.dateFormat = dateFormat
        }
        let date = format.date(from: self)
        //精确到毫秒
        if date != nil {
            return String(Int(date!.timeIntervalSince1970*1000))
        }else{
            return ""
        }
    }
    /// 转换类似朋友圈时间格式的时间字符串
    /// - Parameter intervalString: 时间戳字符串
    static func getFormatedTime(intervalString: String?) -> String {
        guard let time = intervalString, let interval = Int(time), interval != -1 else {
            return ""
        }
        let requestDate = Date.init(timeIntervalSince1970: Double(interval / 1000))
        
        //获取当前时间
        let calendar = Calendar.current
        var formatterString = " HH:mm"
        var prefix = ""
        
        //判断是否是今天
        if calendar.isDateInToday(requestDate as Date) {
            //获取当前时间和系统时间的差距(单位是秒)
            //强制转换为Int
//            let since = Int(Date().timeIntervalSince(requestDate as Date))
            //  是否是刚刚
//            if since < 60 {
//                return localizedString("sw_remarks_comment_a_moment_ago")
//            }else{
                prefix = localizedString("sw_remarks_comment_today")
//            }
        } else if calendar.isDateInYesterday(requestDate as Date) {
            //判断是否是昨天
            prefix = localizedString("sw_remarks_comment_yesterday")
        } else {
            // 48小时之外
            formatterString = "dd/MM/yyyy"
        }
        
        //按照指定的格式将日期转换为字符串
        //创建formatter
        let formatter = DateFormatter()
        //设置时间格式
        formatter.dateFormat = formatterString
        //设置时间区域
        formatter.locale = Locale.init(identifier: "en_US")
        
        //格式化
        let formateTime = prefix + formatter.string(from: requestDate as Date)
        return formateTime
    }
    /// 格式化日期
    /// - Parameter intervalString: 时间戳字符串
    /// - Parameter formatterString:格式“dd/MM/yyyy”
    
    static func timeStampformatedDate(intervalString: String?,formatterString:String?) -> String {
        guard let time = intervalString, let interval = Int(time), interval != -1 else {
            return ""
        }
        let forString = formatterString ?? "dd/MM/yyyy";
        let requestDate = Date.init(timeIntervalSince1970: Double(interval / 1000))
        //按照指定的格式将日期转换为字符串
        //创建formatter
        let formatter = DateFormatter()
        //设置时间格式
        formatter.dateFormat = forString
        //设置时间区域
//        formatter.locale = Locale.init(identifier: "en_US")
        
        //格式化
        let formateTime = formatter.string(from: requestDate as Date)
        return formateTime
    }
    /// 转换类似朋友圈时间格式的时间字符串
    /// - Parameter intervalString: 时间戳字符串
    static func getDayFormatedTime(intervalString: String?) -> String {
        guard let time = intervalString, let interval = Int(time), interval != -1 else {
            return ""
        }
        let requestDate = Date.init(timeIntervalSince1970: Double(interval / 1000))
        
        //获取当前时间
        let calendar = Calendar.current
        var formatterString = " HH:mm"
        
        //判断是否是今天
        if calendar.isDateInToday(requestDate as Date) {
            //获取当前时间和系统时间的差距(单位是秒)
            return localizedString("sw_remarks_comment_today")
        } else if calendar.isDateInYesterday(requestDate as Date) {
            //判断是否是昨天
            return localizedString("sw_remarks_comment_yesterday")
        } else {
            // 48小时之外
            formatterString = "dd/MM/yyyy"
            //按照指定的格式将日期转换为字符串
            //创建formatter
            let formatter = DateFormatter()
            //设置时间格式
            formatter.dateFormat = formatterString
            //设置时间区域
            formatter.locale = Locale.init(identifier: "en_US")
            
            //格式化
            let formateTime = formatter.string(from: requestDate as Date)
            return formateTime
        }
    }
    
    /// 截取规定下标之后的字符串
    /// - Parameter index: index
    func subStringFrom(index: Int) -> String {
        let temporaryString: String = self
        let temporaryIndex = temporaryString.index(temporaryString.startIndex, offsetBy: index)
        return String(temporaryString[temporaryIndex...])
    }
    
    /// 截取规定下标之前的字符串
    /// - Parameter index: index
    func subStringTo(index: Int) -> String {
        let temporaryString = self
        let temporaryIndex = temporaryString.index(temporaryString.startIndex, offsetBy: index)
        return String(temporaryString[...temporaryIndex])
        
    }
}
