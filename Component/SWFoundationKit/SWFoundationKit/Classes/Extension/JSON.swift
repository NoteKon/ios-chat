//
//  JSON.swift
//  SWFoundationKit
//
//  Created by ice on 2019/9/26.
//

import Foundation
import HandyJSON

public typealias JSONObject = HandyJSON

/// 将对象转化成JSON字符串
/// The object must have the following properties:
/// - Top level object is an NSArray or NSDictionary
/// - All objects are NSString, NSNumber, NSArray, NSDictionary, or NSNull
/// - All dictionary keys are NSStrings
/// - NSNumbers are not NaN or infinity
///
/// - Parameter jsonObject: 要转化的对象
/// - Returns: JSON字符串
fileprivate func objectToJSONString(jsonObject: Any) -> String? {
    do {
        let data = try JSONSerialization.data(withJSONObject: jsonObject)
        return String(data: data, encoding: .utf8)
    } catch let error as NSError {
        print(error)
    }
    return nil
}

extension Array {
    /// 将当前数组转化成JSON字符串
    /// - Returns: JSON字符串
    public func toJSONString() -> String? {
        return objectToJSONString(jsonObject: self)
    }
}

extension Dictionary {
    /// 将当前字典转化成JSON字符串
    /// - Returns: JSON字符串
    public func toJSONString() -> String? {
        return objectToJSONString(jsonObject: self)
    }
}

extension String {
    /// 将当前字符串转化成字典
    /// - Returns: 字典对象
    public func toDictionary() -> [String: Any]? {
        return toJSONObject() as? [String: Any]
    }
    
    /// 将当前字符串转化成数组
    /// - Returns: 数组对象
    public func toArray() -> [Any]? {
        return toJSONObject() as? [Any]
    }
    
    /// 将当前字符串转化成JSON对象
    /// - Returns: JSON对象
    public func toJSONObject() -> Any? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}
