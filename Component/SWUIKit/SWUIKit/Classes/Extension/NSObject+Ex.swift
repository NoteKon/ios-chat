//
//  NSObject.swift
//  VVLife
//
//  Created by ice on 2020/2/12.
//  Copyright © 2020 vv. All rights reserved.
//

import Foundation
extension NSObject {
    /// 获取命名空间加类名称 eg: VVLife.UIRemoteKeyboardWindow
    public func className() -> String {
        guard let spaceName = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String else {
            print("获取命名空间失败")
            return ""
        }
        
        let name =  type(of: self).description()
        if name.contains(".") {
            return spaceName + "." + name.components(separatedBy: ".")[1]
        } else {
            return spaceName + "." + name
        }
    }
}

extension Dictionary where Value: Any {
    static func != (left: [Key: Value], right: [Key: Value]) -> Bool { return !(left == right) }
    static func == (left: [Key: Value], right: [Key: Value]) -> Bool {
        if left.count != right.count { return false }
        for element in left {
            guard let rightValue = right[element.key],
                  areEqual(rightValue, element.value) else { return false }
        }
        return true
    }
}

func areEqual (_ left: Any, _ right: Any) -> Bool {
    if  type(of: left) == type(of: right) &&
            String(describing: left) == String(describing: right) { return true }
    //    if let left = left as? [Any], let right = right as? [Any] {
    //        return left == right
    //    }
    if let left = left as? [AnyHashable: Any], let right = right as? [AnyHashable: Any] { return left == right }
    return false
}
