//
//  SWBundleImage.swift
//  SWBundleImage
//
//  Created by Guo ZhongCheng on 2020/12/9.
//

import UIKit

public class SWBundleImage {
    /// 最大缓存的图片大小 ( 默认为200M )
    public var totalCostLimit: Int = 200 * 1000 * 1000 {
        didSet {
            imageCache.totalCostLimit = totalCostLimit
        }
    }
    
    /// 图片bundle
    public var bundle: Bundle!
    
    /// 图片缓存
    var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 200 * 1000 * 1000
        return cache
    }()
    
    /// 初始化
    private init() {
    }
    
    public init(resource: String, customClass: AnyClass) {
        bundle = Bundle.bundle(resource: resource, customClass: customClass)
    }
    
    /// 根据路径获取图片
    /// - Parameters:
    ///   - keyPath: 相对路径（相对于bundle）
    ///   - type: 图片文件类型
    ///   - useScale: 是否需要自动拼接@2x和@3x
    /// - Returns: UIImage
    public func bundleImage(_ keyPath: String, type: String = "png", useScale: Bool = true) -> UIImage? {
        if let image: UIImage = imageCache.object(forKey: keyPath as NSString) {
            return image
        }
        guard let image: UIImage = bundle.bundleImage(path: keyPath, type: type, useScale: useScale) else {
            return nil
        }
        let cost: Int = image.cgImage!.height * image.cgImage!.bytesPerRow
        imageCache.setObject(image, forKey: keyPath as NSString, cost: cost)
        return image
    }
    
    /// 清除所有缓存
    public func cleanMemory() {
        imageCache.removeAllObjects()
    }
}
