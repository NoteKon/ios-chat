//
//  UIImageView.swift
//  SWBusinessKit
//
//  Created by ice on 2019/7/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreFoundation
import Kingfisher
import KingfisherWebP

extension UIImageView {
    
    /// 加载图片资源
    /// - Parameters:
    ///   - imageUrl: 图片链接
    ///   - placeholder: 占位图片
    ///   - shouldDecode: 是否对图片Url进行解码
    ///   - completionHandler: 图片加载成功回调
    public func loadImage(imageUrl: String?,
                          keyName: String? = nil,
                          placeholder: KFCrossPlatformImage? = nil,
                          shouldDecode: Bool = true,
                          completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        guard let imageUrl = imageUrl else {
            self.image = placeholder
            return
        }
        
        var url: URL? = URL(string: imageUrl)
        ///如果无法直接转换为URL，需要进行转码操作
        if url == nil {
            let decodeUrlString: String? = imageUrl.removingPercentEncoding
            let urlString = decodeUrlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            guard let urlStr = urlString else {
                self.image = placeholder
                return
            }
            
            url = URL(string: urlStr)
        }
                
        guard url != nil else {
            self.image = placeholder
            return
        }
        
        var cacheKey = imageUrl
        if !String.isEmpty(keyName) {
            cacheKey = keyName!
        } else if let key = String.matchCacheKey(for: imageUrl), !key.isEmpty {
            cacheKey = key
        }
        
        let resource = ImageResource(downloadURL: url!, cacheKey: cacheKey)
        self.kf.setImage(with: resource, placeholder: placeholder, options: [.transition(.fade(0.2)), .backgroundDecode], completionHandler: { (result) in
            completionHandler?(result)
        })
//        self.kf.setImage(with: resource, placeholder: placeholder, options: [.transition(.fade(0.2)), .backgroundDecode,  .processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)], completionHandler: { (result) in
//            completionHandler?(result)
//        })
    }
    
    /// 全局添加webP格式解析
    public static func addWebPParsing() {
        KingfisherManager.shared.defaultOptions += [
            .processor(WebPProcessor.default),
            .cacheSerializer(WebPSerializer.default)
        ]
    }
}
