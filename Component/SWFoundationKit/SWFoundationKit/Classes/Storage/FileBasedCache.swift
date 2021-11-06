//
//  FileBasedCache.swift
//  Swiften
//

import Foundation

fileprivate let RAW_EXT = "raw"

open class FileBasedCacheManager: CacheManager {

    public typealias Value = DefaultCacheValue

    public init() {

    }
    
    /// 缓存文件根路径
    public let cacheDir = SWPath.caches.resolve("CacheData")
    
    /// 读取缓存（返回Data）
    /// - Parameter key: 缓存键名
    public func data(for key: String) -> Data? {
        let path = getCachePath(for: key)
        if path.isExists, let data = path.readData() {
            if let value = Value.deserialize(from: data.string), value.isValid {
                return SWFileHelper.read(from: path.url.appendingPathExtension(RAW_EXT))
            }
        }
        return nil
    }
    
    /// 写入缓存
    /// - Parameters:
    ///   - value: 缓存值
    ///   - key: 缓存键名
    ///   - expires: 过期时间
    public func set(data: Data, for key: String, expires: TimeInterval) {
        let value = Value(key: key, value: "", expires: expires)
        if let jsonString = value.toJSONString() {
            let path = getCachePath(for: value.key)
            path.write(data: jsonString.data)
            SWFileHelper.write(data, to: path.url.appendingPathExtension(RAW_EXT))
        }
    }
    
    /// 读取缓存（返回`CacheValue`类型）
    /// - Parameter key: 缓存键名
    public func value(for key: String) -> Value? {
        let path = getCachePath(for: key)
        if path.isExists, let data = path.readData() {
            if let value = Value.deserialize(from: data.string), value.isValid {
                return value
            }
        }
        return nil
    }
    
    /// 写入缓存
    /// - Parameter value: 缓存值
    public func set(value: Value) {
        if let jsonString = value.toJSONString() {
            getCachePath(for: value.key).write(data: jsonString.data)
        }
    }
    
    /// 删除指定缓存
    /// - Parameter key: 缓存键名
    public func remove(for key: String) {
        let path = getCachePath(for: key)
        path.removeFile()
        let rawFile = path.url.appendingPathExtension(RAW_EXT)
        if rawFile.fileExists {
            SWFileHelper.remove(rawFile)
        }
    }
    
    /// 删除所有缓存
    public func removeAll() {
        cacheDir.walk { SWFileHelper.remove($0) }
    }
    
    /// 根据缓存键名生成缓存文件存放路径
    /// - Parameter key: 键名
    /// - Returns: 缓存文件存放路径
    private func getCachePath(for key: String) -> SWPath {
//        let md5 = key.md5()
//        let path = "\(md5[0...1]!)/\(md5[2...3]!)/\(md5[4...]!)"
//        return cacheDir.resolve(path)
        return cacheDir.resolve(key.md5())
    }

}
