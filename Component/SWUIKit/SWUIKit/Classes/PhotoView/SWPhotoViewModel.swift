//
//  VPPhotoViewModel.swift
//  VVPartner
//
//  Created by huang on 2019/11/14.
//  Copyright © 2019 vv. All rights reserved.
//

import Foundation

public class SWPhotoViewModel {
    public var photoUrl: String?
    public var isAddPhoto: Bool = true
    
    //添加图片后，会有加载服务端图片前，会有一个加载时间的闪一下。预留个属性，来解决加载成功之前使用本地图片
    public var placeholdUrl: String?
        
    public func getImage() -> UIImage? {
        return SWPhotoCache.loadImage(forKey: photoUrl)
    }
        
    public func getPlaceholdImage() -> UIImage? {
        return SWPhotoCache.loadImage(forKey: placeholdUrl)
    }
    
    public func removeImage() {
        SWPhotoCache.deleteImage(forKey: photoUrl)
    }
    
    public init() {}
}
