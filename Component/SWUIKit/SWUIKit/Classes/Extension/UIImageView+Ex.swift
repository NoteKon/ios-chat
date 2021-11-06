//
//  UIImageView+Ex.swift
//  SWUIKit
//
//  Created by Guo ZhongCheng on 2020/12/16.
//

import Kingfisher
import KingfisherWebP

private var imageDownloadUrlKey: Void?
private var imageCacheKeyKey: Void?
private var originImageCacheKeyKey: Void?

public typealias SWImageDownloadProgressCallBack = (String, Int64, Int64) -> Void
public typealias SWImageDownloadFinishCallBack = (String, Result<ImageLoadingResult, KingfisherError>) -> Void

public class SWImageDownloadManager {
    /** 单例 */
    public static let shared: SWImageDownloadManager = SWImageDownloadManager()
    
    var group: DispatchGroup = DispatchGroup()
    var queue: DispatchQueue = DispatchQueue(label: "SWImageDownloadManager")
    // 最大并发数
    let semaphore = DispatchSemaphore.init(value: 5)
    
    public func addTask(
        url: URL,
        options: KingfisherOptionsInfo = [], //.backgroundDecode,.fromMemoryCacheOrRefresh
        progressBlock: SWImageDownloadProgressCallBack? = nil,
        completionHandler: SWImageDownloadFinishCallBack? = nil
    ) {
        let key: String = url.absoluteString
        group.enter()
        queue.async(group: group, execute: DispatchWorkItem.init(block: {
            SWImageDownloadManager.shared.semaphore.wait()
            ImageDownloader.default.downloadImage(with: url, options: options) { (p, t) in
                if let callback = progressBlock {
                    callback(key, p, t)
                }
            } completionHandler: { (result) in
                if let callback = completionHandler {
                    callback(key, result)
                }
                SWImageDownloadManager.shared.semaphore.signal()
                SWImageDownloadManager.shared.group.leave()
            }
        }))
    }
}

public extension UIImageView {
    
    /// 最新一次图片下载地址
    private var imageDownloadUrl: String? {
        get { return objc_getAssociatedObject(self, &imageDownloadUrlKey) as? String }
        set { objc_setAssociatedObject(self, &imageDownloadUrlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    /// 最新一次原图缓存Key
    private var originImageCacheKey: String? {
        get { return objc_getAssociatedObject(self, &originImageCacheKeyKey) as? String }
        set { objc_setAssociatedObject(self, &originImageCacheKeyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    /// 最新一次小图缓存Key
    private var imageCacheKey: String? {
        get { return objc_getAssociatedObject(self, &imageCacheKeyKey) as? String }
        set { objc_setAssociatedObject(self, &imageCacheKeyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    /// 下载完成结果回调
    typealias SWImageLoadResult = (Result<KFCrossPlatformImage?, KingfisherError>) -> Void
    
    /// 为减少列表加载图片的卡顿，加载网络图片时使用自己的缓存策略，限制图片的最大宽高进行缓存（宽高超过的话会先压缩再缓存压缩后的图片，并且设置独立的缓存Key）
    /// - Parameters:
    ///   - urlString: 图片地址，可为空，传cacheKey来获取已缓存的图片
    ///   - placeholderImage: 加载中的图片
    ///   - indicatorType: 加载时展示的加载动画，默认为无
    ///   - loadFaildImage: 加载失败展示的图片
    ///   - cacheOriginImage: 是否缓存原图，默认为true
    ///   - cacheKey: 缓存key，不传则对压缩的图片采用原地址+_resize_+限制的宽度/高度 格式进行缓存
    ///   - maxWidth: 限制的最大宽度，可不传，内部会自动乘上屏幕的scale
    ///   - maxHeight: 限制的最大高度，可不传，内部会自动乘上屏幕的scale
    ///   - options: 下载图片时用到，默认为 backgroundDecode + fromMemoryCacheOrRefresh，如出现闪退，可将 backgroundDecode 去掉
    ///   - progressBlock: 进度回调
    ///   - completionHandler: 加载完成回调
    func loadWebImage(
        _ urlString: String? = nil,
        placeholderImage: UIImage? = nil,
        indicatorType: IndicatorType? = nil,
        loadFaildImage: UIImage? = nil,
        cacheOriginImage: Bool = true,
        cacheKey: String? = nil,
        maxWidth: CGFloat? = nil,
        maxHeight: CGFloat? = nil,
        options: KingfisherOptionsInfo = [.processor(WebPProcessor.default),.fromMemoryCacheOrRefresh], //.backgroundDecode
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: SWImageLoadResult? = nil
    ) {
        DispatchQueue.main.async {
            self.image = placeholderImage
        }
        /// 记录当前请求地址
        imageDownloadUrl = urlString
        ///如果无法直接转换为URL，需要进行转码操作
        if URL(string: imageDownloadUrl ?? "") == nil {
            let decodeUrlString: String? = imageDownloadUrl?.removingPercentEncoding
            if let finalUrlString = decodeUrlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                /// 记录当前请求地址
                imageDownloadUrl = finalUrlString
            }
        }
        
        /// 拼装Key
        /// 小图的key
        var key: String!
        /// 原图的key
        var originKey: String!
        
        /// 为减少缓存图片的数量，将图片向上使用 divPoint 取整进行缓存
        let divPoint: Int = 50
        var width: Int? = maxWidth != nil ? Int(maxWidth!) : nil
        var height: Int? = maxHeight != nil ? Int(maxHeight!) : nil
        var reizeString = "_resize_"
        if width != nil {
            let remainder = width! % divPoint
            width = width! - (remainder > 0 ? (remainder - divPoint) : 0)
            reizeString += "width_\(width!)"
        }
        if height != nil {
            let remainder = height! % divPoint
            height = height! - (remainder > 0 ? (remainder - divPoint) : 0)
            reizeString += "height_\(height!)"
        }
        
        if cacheKey != nil {
            originKey = cacheKey
            if width != nil || height != nil {
                key = cacheKey! + reizeString
            } else {
                key = cacheKey
            }
        } else if imageDownloadUrl != nil {
            originKey = imageDownloadUrl
            if width != nil || height != nil {
                key = imageDownloadUrl! + reizeString
            } else {
                key = imageDownloadUrl
            }
        } else {
            /// urlString和cacheKey都没有传
            self.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: KingfisherError.imageSettingError(reason: KingfisherError.ImageSettingErrorReason.emptySource))
            return
        }
        originImageCacheKey = originKey
        imageCacheKey = key
        /// 查看是否已缓存小图
        if ImageCache.default.imageCachedType(forKey: key) == .none {
            /// 未缓存
            /// 查看是否有原图的缓存
            if ImageCache.default.imageCachedType(forKey: originKey) == .none {
                /// 未缓存，从web下载图片，并缓存
                guard let urlStr = imageDownloadUrl else {
                    /// urlString未正确设置，且缓存中不存在cacheKey
                    self.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: KingfisherError.imageSettingError(reason: KingfisherError.ImageSettingErrorReason.emptySource))
                    return
                }
                
                guard let finalUrl = URL(string: urlStr) else {
                    /// url创建失败
                    self.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: KingfisherError.imageSettingError(reason: KingfisherError.ImageSettingErrorReason.emptySource))
                    return
                }
                /// 未缓存，开始下载
                /// 显示加载控件
                self.kf.indicatorType = indicatorType ?? .none
                DispatchQueue.main.async {
                    self.kf.indicator?.startAnimatingView()
                }
                SWImageDownloadManager.shared.addTask(url: finalUrl, options: options) {[weak self] (url, current, total) in
                    if let progressCallBack = progressBlock,
                       self?.imageDownloadUrl == finalUrl.absoluteString {
                        progressCallBack(current, total)
                    }
                } completionHandler: {[weak self] (url, result) in
                    guard self?.imageDownloadUrl == finalUrl.absoluteString else {
                        /// 请求地址与当前回调不一致，不做处理
                        return
                    }
                    DispatchQueue.main.async {
                        self?.kf.indicator?.stopAnimatingView()
                    }
                    switch result {
                        case .success(let loadingResult): // ImageLoadingResult
                            let originData = loadingResult.originalData
                            let originImage = loadingResult.image
                            var resultImage: UIImage?
                            var isGif: Bool = false
                            /// 取大的倍数缩放
                            var scale: CGFloat?
                            if width != nil {
                                scale = CGFloat(width!) / originImage.size.width
                            }
                            if height != nil {
                                let heightScale = CGFloat(height!) / originImage.size.height
                                scale = scale == nil ? heightScale : max(scale!, heightScale)
                            }
                            if scale != nil {
                                (resultImage, isGif) = originImage.reSizeWithJudgment(scale: scale!, originData: originData)
                            } else {
                                resultImage = originImage
                            }
                            /// 缓存图片
                            if resultImage != nil {
                                if isGif {
                                    ImageCache.default.store(resultImage!, original: resultImage?.kf.data(format: .GIF), forKey: key)
                                } else {
                                    ImageCache.default.store(resultImage!, forKey: key)
                                }
                            }
                            if cacheOriginImage {
                                ImageCache.default.store(originImage, original: loadingResult.originalData, forKey: originKey)
                            }
                            DispatchQueue.main.async {
                                self?.image = resultImage
                                completionHandler?(.success(resultImage))
                            }
                            return
                        case .failure(let error): // KingfisherError
                            self?.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: error)
                            return
                    }
                }
            } else {
                /// 已缓存原图，从缓存中获取原图图片展示
                // 直接获取图片（获取后才知道是 memory 还是 disk）
                ImageCache.default.retrieveImage(forKey: originKey) {[weak self] (result) in
                    if self?.originImageCacheKey != originKey {
                        /// print("图片与目标key不一致")
                        return
                    }
                    switch result {
                        case .success(let loadingResult): // ImageLoadingResult
                            guard let imageData = loadingResult.image else {
                                completionHandler?(.failure(.cacheError(reason: .imageNotExisting(key: originKey))))
                                return
                            }
                            var resultImage: UIImage?
                            var isGif: Bool = false
                            /// 取大的倍数缩放
                            var scale: CGFloat?
                            if width != nil {
                                scale = CGFloat(width!) / imageData.size.width
                            }
                            if height != nil {
                                let heightScale = CGFloat(height!) / imageData.size.height
                                scale = scale == nil ? heightScale : max(scale!, heightScale)
                            }
                            if scale != nil {
                                let cacheImagePath = ImageCache.default.cachePath(forKey: originKey)
                                if let data = try? Data(contentsOf: URL(fileURLWithPath: cacheImagePath)) {
                                    (resultImage, isGif) = imageData.reSizeWithJudgment(scale: scale!, originData: data)
                                }
                            } else {
                                resultImage = imageData
                            }
                            /// 缓存图片
                            if resultImage != nil {
                                if isGif {
                                    ImageCache.default.store(resultImage!, original: resultImage?.kf.data(format: .GIF), forKey: key)
                                } else {
                                    ImageCache.default.store(resultImage!, forKey: key)
                                }
                            }
                            DispatchQueue.main.async {
                                self?.image = resultImage
                                completionHandler?(.success(resultImage))
                            }
                            return
                        case .failure(let error): // KingfisherError
                            self?.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: error)
                            return
                    }
                }
            }
        } else {
            /// 已缓存小图，从缓存中获取图片展示
            // 直接获取图片（获取后才知道是 memory 还是 disk）
            ImageCache.default.retrieveImage(forKey: key) { [weak self] (result) in
                if key != self?.imageCacheKey {
                    /// print("图片与目标key不一致")
                    return
                }
                switch result {
                    case .success(let loadingResult): // ImageLoadingResult
                        guard let imageData = loadingResult.image else {
                            completionHandler?(.failure(.cacheError(reason: .imageNotExisting(key: key))))
                            return
                        }
                        DispatchQueue.main.async {
                            self?.image = imageData
                            completionHandler?(.success(imageData))
                        }
                        return
                    case .failure(let error): // KingfisherError
                        self?.noticeLoadImageFaild(faildImage: loadFaildImage ?? placeholderImage, error: error)
                        return
                }
            }
        }
    }
    
    /// 展示加载失败并回调
    /// - Parameters:
    ///   - faildImage: 加载失败图片
    ///   - error: 失败信息
    ///   - completionHandler: 回调函数
    private func noticeLoadImageFaild(faildImage: UIImage?, error: KingfisherError, completionHandler: SWImageLoadResult? = nil) {
        DispatchQueue.main.async {
            self.image = faildImage
            completionHandler?(.failure(error))
        }
    }
}
