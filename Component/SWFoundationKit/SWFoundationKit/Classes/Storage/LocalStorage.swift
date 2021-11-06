//
//  LocalStorage.swift
//  Swiften
//

import Foundation

/// 基于UserDefaults的本地存储封装
open class LocalStorage {
    private let defaults: UserDefaults
    private var autoCommit: Bool
    
    public init() {
        defaults = UserDefaults.standard
        autoCommit = true
    }
    
    open func set(_ value: Any?, forKey key: String) {
        defaults.set(value, forKey: key)
        if autoCommit {
            defaults.synchronize()
        }
    }
    
    open func object(forKey key: String) -> Any? {
        return defaults.object(forKey: key)
    }
    
    open func string(forKey key: String) -> String? {
        return defaults.string(forKey: key)
    }
    
    open func data(forKey key: String) -> Data? {
        return defaults.data(forKey: key)
    }
    
    open func int(forKey key: String) -> Int {
        return defaults.integer(forKey: key)
    }
    
    open func float(forKey key: String) -> Float {
        return defaults.float(forKey: key)
    }
    
    open func double(forKey key: String) -> Double {
        return defaults.double(forKey: key)
    }
    
    open func bool(forKey key: String) -> Bool {
        return defaults.bool(forKey: key)
    }
    
    open func url(forKey key: String) -> URL? {
        return defaults.url(forKey: key)
    }
    
    open func array(forKey key: String) -> [Any]? {
        return defaults.array(forKey: key)
    }
    
    open func dictionary(forKey key: String) -> [String: Any]? {
        return defaults.dictionary(forKey: key)
    }
    
    open func date(forKey key: String) -> Date? {
        return defaults.object(forKey: key) as? Date
    }
    
    open func removeObject(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    /// 清除所有存储的内容
    open func reset() {
        if let bundleId = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleId)
        }
    }
    
    /// 批量写入值（为了提高效率）
    /// - Parameter callback: 处理写入值的代码块
    open func write(callback: () -> Void) {
        let lastAutoCommit = autoCommit
        autoCommit = false
        callback()
        defaults.synchronize()
        autoCommit = lastAutoCommit
    }
    
}
