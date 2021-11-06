//
//  Int+Ex.swift
//  VVLife
//
//  Created by 黄泳东 on 2020/8/18.
//  Copyright © 2020 vv. All rights reserved.
//

import Foundation

extension Int {
    /// 发现模块数值展示逻辑
    public var discoverCount: String {
        return Int64(self).discoverCount
    }
    
    /// 生活计划提醒卡是否跨年
    public var isThisYear: Bool {
        switch self {
        case 0:
            return true
        case 1:
            return false
        default:
            return true
        }
    }
    
    public var getMinutesAndSecond: String {
        let second = self % 60
        let minutes = ((self - second) / 60) % 60
        return "\(minutes):\(second)"
    }
}

extension Int32 {
    /// 发现模块数值展示逻辑
    public var discoverCount: String {
        return Int64(self).discoverCount
    }
}

extension Int64 {
    /// 发现模块数值展示逻辑
    public var discoverCount: String {
        var string = "0"
        if UIDevice.isChineseLocale {
            switch self {
            case 0..<10000:
                string = "\(self)"
            case 10000..<100000:
                string = String(format: "%.1f", floor(Double(self) / 1000) / 10) + "万"
            case 100000..<100000000:
                string = "\(self / 10000)万"
            case 100000000..<1000000000:
                string = String(format: "%.1f", floor(Double(self) / 10000000) / 10) + "亿"
            case 1000000000...:
                string = "10亿+"
            default:
                break
            }
        } else {
            switch self {
            case 0..<10000:
                string = "\(self)"
            case 10000..<100000:
                string = String(format: "%.1f", floor(Double(self) / 100) / 10) + "K"
            case 100000..<1000000:
                string = "\(self / 1000)K"
            case 1000000..<10000000:
                string = String(format: "%.1f", floor(Double(self) / 100000) / 10) + "M"
            case 10000000..<1000000000:
                string = "\(self / 1000000)M"
            case 1000000000..<10000000000:
                string = String(format: "%.1f", floor(Double(self) / 100000000) / 10) + "B"
            case 10000000000...:
                string = "10B+"
            default:
                break
            }
        }
        return string
    }
}
