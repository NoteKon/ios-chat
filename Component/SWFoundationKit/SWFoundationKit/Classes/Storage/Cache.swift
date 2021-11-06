//
//  Cache.swift
//  Swiften
//

import Foundation
import HandyJSON

// MARK: - CacheValue

/// 缓存存储的值类型
public protocol CacheValue {
    /// 缓存键名
    var key: String { get set }
    /// 缓存值
    var value: String { get set }
    /// 过期时间
    var expires: TimeInterval { get set }
    /// 值是否有效（读取缓存时有效）
    var isValid: Bool { get }
    
    init(key: String, value: String, expires: TimeInterval)
}

extension CacheValue {
    public var isValid: Bool {
        return expires >= 0 && (expires < 0.000001 || expires > Date.timeInterval)
    }
}

/// `CacheValue`的默认实现
open class DefaultCacheValue: CacheValue, HandyJSON {
    open var key: String
    open var value: String
    open var expires: TimeInterval
    
    required public init() {
        self.key = ""
        self.value = ""
        self.expires = -1
    }
    
    required public init(key: String, value: String, expires: TimeInterval = 0.0) {
        self.key = key
        self.value = value
        self.expires = expires
    }
}

// MARK: - CacheManager

/// 缓存存储实现的协议
public protocol CacheManager {

    associatedtype Value: CacheValue
    
    /// 读取缓存（返回Data）
    /// - Parameter key: 缓存键名
    func data(for key: String) -> Data?
    /// 写入缓存
    /// - Parameters:
    ///   - value: 缓存值
    ///   - key: 缓存键名
    ///   - expires: 过期时间
    func set(data: Data, for key: String, expires: TimeInterval)
    
    /// 读取缓存（返回`CacheValue`类型）
    /// - Parameter key: 缓存键名
    func value(for key: String) -> Value?
    /// 写入缓存
    /// - Parameter value: 缓存值
    func set(value: Value)
    
    /// 读取缓存（返回字符串）
    /// - Parameter key: 缓存键名
    func string(for key: String) -> String?
    /// 写入缓存
    /// - Parameters:
    ///   - value: 缓存值
    ///   - key: 缓存键名
    ///   - expires: 过期时间
    func set(string: String, for key: String, expires: TimeInterval)
    
    /// 删除指定缓存
    /// - Parameter key: 缓存键名
    func remove(for key: String)
    /// 删除所有缓存
    func removeAll()
}

extension CacheManager {

    /// 读取缓存（返回字符串）
    /// - Parameter key: 缓存键名
    public func string(for key: String) -> String? {
        if let value = value(for: key), value.isValid {
            return value.value
        }
        return nil
    }

    /// 写入缓存
    /// - Parameters:
    ///   - value: 缓存值
    ///   - key: 缓存键名
    ///   - expires: 过期时间
    public func set(string: String, for key: String, expires: TimeInterval) {
        set(value: Value(key: key, value: string, expires: expires))
    }
}

// MARK: - Cache

/// 缓存操作对象
public class Cache<M: CacheManager> {

    public let manager: M

    public init(manager: M) {
        self.manager = manager
    }

    // MARK: - Methods
    
    /// 写入缓存（字符串值）
    /// - Parameters:
    ///   - data: 缓存数据
    ///   - key: 缓存键名
    ///   - expires: 过期时间
    public func set(_ data: Data?, for key: String, expires: TimeInterval = 0.0) {
        if let data = data {
            manager.set(data: data, for: key, expires: expires)
        } else {
            manager.remove(for: key)
        }
    }
    
    /// 写入缓存（字符串值）
    /// - Parameters:
    ///   - string: 字符串值
    ///   - key: 缓存键名
    ///   - expires: 过期时间
    public func set(_ string: String?, for key: String, expires: TimeInterval = 0.0) {
        if let string = string {
            manager.set(string: string, for: key, expires: expires)
        } else {
            manager.remove(for: key)
        }
    }
    
    /// 写入缓存（`Int`值）
    /// - Parameters:
    ///   - value: 缓存值
    ///   - key: 缓存键名
    ///   - expires: 过期时间
    public func set(_ value: Int?, for key: String, expires: TimeInterval = 0.0) {
        set(value == nil ? nil : String(value!), for: key, expires: expires)
    }
    
    /// 写入缓存（`Double`值）
    /// - Parameters:
    ///   - value: 缓存值
    ///   - key: 缓存键名
    ///   - expires: 过期时间
    public func set(_ value: Double?, for key: String, expires: TimeInterval = 0.0) {
        set(value == nil ? nil : String(value!), for: key, expires: expires)
    }
    
    /// 写入缓存（`Bool`值）
    /// - Parameters:
    ///   - value: 缓存值
    ///   - key: 缓存键名
    ///   - expires: 过期时间
    public func set(_ value: Bool?, for key: String, expires: TimeInterval = 0.0) {
        set(value == nil ? nil : String(value!), for: key, expires: expires)
    }

    /// 写入缓存（`HandyJSON`对象）
    /// - Parameters:
    ///   - value: 缓存值
    ///   - key: 缓存键名
    ///   - expires: 过期时间
    public func set<T: HandyJSON>(_ object: T?, for key: String, expires: TimeInterval = 0.0) {
        if let object = object {
            set(object.toJSONString(), for: key, expires: expires)
        } else {
            remove(for: key)
        }
    }
    
    /// 删除缓存
    /// - Parameter key: 缓存键名
    public func remove(for key: String) {
        manager.remove(for: key)
    }
    
    /// 删除所有缓存
    public func removeAll() {
        manager.removeAll()
    }

    // MARK: - Subscript

    public subscript(key: String) -> Data? {
        get {
            return manager.data(for: key)
        }
        set {
            set(newValue, for: key)
        }
    }

    public subscript(key: String) -> String? {
        get {
            return manager.string(for: key)
        }
        set {
            set(newValue, for: key)
        }
    }

    public subscript(key: String) -> Int? {
        get {
            return manager.string(for: key)?.intValue
        }
        set {
            set(newValue, for: key)
        }
    }

    public subscript(key: String) -> Double? {
        get {
            return manager.string(for: key)?.doubleValue
        }
        set {
            set(newValue, for: key)
        }
    }

    public subscript(key: String) -> Bool? {
        get {
            return manager.string(for: key)?.boolValue
        }
        set {
            set(newValue, for: key)
        }
    }

    public subscript<T: HandyJSON>(key: String) -> T? {
        get {
            guard let jsonString = manager.string(for: key) else { return nil }
            return T.deserialize(from: jsonString)
        }
        set {
            set(newValue, for: key)
        }
    }

}

