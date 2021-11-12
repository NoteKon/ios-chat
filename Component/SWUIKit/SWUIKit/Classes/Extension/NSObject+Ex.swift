//
//  NSObject.swift
//  VVLife
//
//  Created by ice on 2020/2/12.
//  Copyright © 2020 vv. All rights reserved.
//

import Foundation
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
