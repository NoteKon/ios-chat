//
//  Double+Ex.swift
//  VVLife
//
//  Created by huangxianhui on 2020/10/19.
//  Copyright © 2020 vv. All rights reserved.
//

import Foundation

public extension Double {
    
    /// 将浮点数四舍五入截断保留n位小数
    /// - Parameter places: 小数点后面保留几位数
    /// - Returns: 四舍五入后的新浮点数
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

public extension Float {
    
    /// 将浮点数四舍五入截断保留n位小数
    /// - Parameter places: 小数点后面保留几位数
    /// - Returns: 四舍五入后的新浮点数
    func roundTo(places: Int) -> Float {
        let divisor = Float(pow(10.0, Double(places)))
        return (self * divisor).rounded() / divisor
    }
}
