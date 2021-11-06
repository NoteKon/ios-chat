//
//  SWCache.swift
//  Pods
//
//  Created by ice on 2019/8/22.
//

import Foundation
import Alamofire

/// 统一缓存管理类，数据保存至Cache目录中
public class SWCacheManager {
    /// URL + 请求参数 + md5 转成缓存唯一标识符
    public static func cacheKey(url: String, parameters: [String: Any]?) -> String {
        
        if let requestUrl = URL(string: url) {
            let request = URLRequest(url: requestUrl)
            do {
                let encodeRequest = try URLEncoding.default.encode(request, with: parameters)
                if let newUrl = encodeRequest.url {
                    return newUrl.absoluteString
                }
                if let newUrl = request.url {
                    return newUrl.absoluteString
                }
            } catch {
                if let newUrl = request.url {
                    return newUrl.absoluteString
                }
                return url
            }
        }
        
        return url
    }
    
    /// 根据Key缓存数据
    /// - Parameter key: 缓存Key
    /// - Parameter json: 被缓存数据
    /// @available(*, deprecated, message: "使用`Cache.set(_:for:expires)`或`Cache[key] = value`代替")
    public static func saveCache(key: String, json: String?) {
        SWCacheManager.deleteCache(key: key)
        if let json = json, let path = SWCacheManager.cachePath(key: key) {
            let data = json.data(using: String.Encoding.utf8)
            do {
                try data?.write(to: URL(fileURLWithPath: path), options: Data.WritingOptions.atomic)
            } catch {
                print(error)
            }
        }
    }
    
    /// 根据Key加载缓存数据
    /// - Parameter key: 缓存Key
    /// - Returns: 被缓存的数据
    /// @available(*, deprecated, message: "使用`Cache[key]`代替")
    public static func loadCache(key: String) -> String? {
        if let path = SWCacheManager.cachePath(key: key), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            let json = String(data: data, encoding: String.Encoding.utf8)
            return json
        }
        return nil
    }
    
    /// 根据Key删除缓存数据
    /// - Parameter key: 缓存Key
    /// @available(*, deprecated, message: "使用`Cache.remove(for:)`代替")
    public static func deleteCache(key: String) {
        if let path = SWCacheManager.cachePath(key: key) {
            if FileManager.default.fileExists(atPath: path) {
                try? FileManager.default.removeItem(atPath: path)
            }
        }
    }
}

extension SWCacheManager {
    /// 缓存数据的路径
    /// - Parameter key: 缓存Key
    private static func cachePath(key: String) -> String? {
        if var path = SWDocumentPath.cachePath(withFileName: "CacheData") {
            if !FileManager.default.fileExists(atPath: path) {
                try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }
            path.append(contentsOf: "/")
            path.append(contentsOf: key.md5())
            return path
        }
        return nil
    }
}
