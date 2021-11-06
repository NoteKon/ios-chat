//
//  VPPhotoCache.swift
//  VVPartner
//
//  Created by huang on 2019/11/13.
//  Copyright © 2019 vv. All rights reserved.
//

import UIKit
import Kingfisher

public class SWPhotoCache {
    public static func saveImage(data: Data, forKey: String?) {
        guard let key = forKey else { return }
        KingfisherManager.shared.cache.storeToDisk(data, forKey: key)
    }
    
    public static func loadImage(forKey: String?) -> UIImage? {
        guard let key = forKey else { return nil }

        if let matchKey = String.matchCacheKey(for: key) {
//            return KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: matchKey) { result in
//                switch result {
//                case let .success(image): {
//                    return image
//                }
//                default:
//                    return nil
//                }
            print("TODO: XXXX")
        }
        return nil
    }
    
    public static func deleteImage(forKey: String?) {
        guard let key = forKey else { return }
        KingfisherManager.shared.cache.removeImage(forKey: key)
    }
}
