//
//  NetMonitorData.swift
//  URLIntercept
//
//  Created by ice on 2021/6/15.
//

import Foundation

public class SWNetMonitorModel: NSObject {
    // Request Featch Time,单位ms
    public var requestFeatchTime: Int64?
    // Request Start Time,单位ms
    public var requestStartTime: Int64?
    // Request End Time,单位ms
    public var requestStartEndTime: Int64?
    // Response Start Time,单位ms
    public var responseStartTime: Int64?
    // Response End Time,单位ms
    public var responseEndTime: Int64?
    // 一个完整请求的耗时
    public var durationTime: Int?
    
    // 客户端开始请求到开始dns解析的等待时间,单位ms
    public var waitDNSTime: Int64?
    // DNS 解析耗时,单位ms
    public var dnsLookupTime: Int64?
    // tcp 三次握手耗时,单位ms
    public var tcpTime: Int64?
    // ssl 握手耗时,单位ms
    public var sslTime: Int64?
    
    /*
     *  <=== Request Featch Time ===>: 2021-06-18 11:38:02
     *  <=== Request Start Time  ===>: 2021-06-18 11:38:02
     *  <=== Request End Time    ===>: 2021-06-18 11:38:02
     *  <=== Response Start Time ===>: 2021-06-18 11:38:02
     *  <=== Response End Time   ===>: 2021-06-18 11:38:02
     */
    public override var description: String {
        var des: String = ""
        
        let featchTimeStr = timeToStr(requestFeatchTime)
        if featchTimeStr.count > 0 {
            des += " <=== Request Featch Time ===>: \(featchTimeStr)\n"
        }
        
        let requestStartTimeStr = timeToStr(requestStartTime)
        if requestStartTimeStr.count > 0 {
            des += " <=== Request Start Time  ===>: \(requestStartTimeStr)\n"
        }
        
        let requestStartEndTimeStr = timeToStr(requestStartEndTime)
        if requestStartEndTimeStr.count > 0 {
            des += " <=== Request End Time    ===>: \(requestStartEndTimeStr)\n"
        }
        
        let responseStartTimeStr = timeToStr(responseStartTime)
        if responseStartTimeStr.count > 0 {
            des += " <=== Response Start Time ===>: \(responseStartTimeStr)\n"
        }
        
        let responseEndTimeStr = timeToStr(responseEndTime)
        if responseEndTimeStr.count > 0 {
            des += " <=== Response End Time   ===>: \(responseEndTimeStr)\n"
        }
        
        if let durTime = durationTime {
            des += " <=== DurationTime        ===>: \(durTime)\n"
        }
        
        if let dnsTime = waitDNSTime {
            des += " <=== DNS Time            ===>: \(dnsTime)ms\n"
        }

        if let dnsLookTime = dnsLookupTime {
            des += " <=== DNS LookUp Time     ===>: \(dnsLookTime)ms\n"
        }

        if let tcpTimeStr = tcpTime {
            des += " <=== TCP Time            ===>: \(tcpTimeStr)ms\n"
        }
        
        if let sslTimeStr = sslTime {
            des += " <=== SSL Time            ===>: \(sslTimeStr)ms\n"
        }
        
        return des
    }
    
    /// 时间戳转字符串日期
    /// - Parameter time: 时间戳
    /// - Returns: 字符串日期
    public func timeToStr(_ time: Int64?, format: String = "yyyy-MM-dd HH:mm:ss:ms") -> String {
        if let oldTime = time {
            return TimeInterval(oldTime/1000).toString(format: format, locale: nil)
        }
        return ""
    }
}
