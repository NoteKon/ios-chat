//
//  SWImageUploader.swift
//  SWBusinessKit
//
//  Created by ice on 2019/11/9.
//

import Foundation
import SWFoundationKit

public class SWImageUploader {
    /// 上传图片（一张或多张）
    /// - NOTE: 回调总是在主线程
    public static func uploadImages(images: [UIImage]?,
                                    sysCode: String,
                                    categoryCode: String,
                                    businessCode: String = "",
                                    retry: Int = 0,
                                    completion: SWFileUploaderCompletion?) {
        
        guard let images = images, images.count > 0 else {
            executeMainBlock {
                completion?(SWFileUploaderResult(total: 0))
            }
            return
        }
        
        DispatchQueue.global().async {
            let fileObjects = images.map { (image) -> SWFileUploaderObject in
                let imageData = image.jpegData(compressionQuality: 0.3)
                let fileObject = SWFileUploaderObject()
                fileObject.fileData = imageData
                fileObject.fileType = "jpg"
                return fileObject
            }
            
            let fileModel = SWFileUploaderModel()
            fileModel.sysCode = sysCode
            fileModel.categoryCode = categoryCode
            fileModel.fileObjects = fileObjects
            fileModel.businessCode = businessCode
            
            SWFileUploader.upload(fileModel: fileModel, retry: retry, completion: completion)
        }
    }
    
    /// 上传图片（一张或多张）
    /// - NOTE: 回调总是在主线程
    public static func uploadImages(filePaths: [String]?,
                                    sysCode: String,
                                    categoryCode: String,
                                    businessCode: String = "",
                                    retry: Int = 0,
                                    completion: SWFileUploaderCompletion?) {
        guard let filePaths = filePaths, filePaths.count > 0 else {
            executeMainBlock {
                completion?(SWFileUploaderResult(total: 0))
            }
            return
        }
        
        DispatchQueue.global().async {
            var images = [UIImage]()
            for path in filePaths {
                guard let image = UIImage(contentsOfFile: path) else {
                    completion?(SWFileUploaderResult(total: filePaths.count).allFailure())
                    return
                }
                images.append(image)
            }
            
            uploadImages(images: images, sysCode: sysCode, categoryCode: categoryCode, businessCode: businessCode, completion: completion)
        }
    }
    
    public static func formatCategoryCode(cateCode: String?,
                                          addFilesArray: [String],
                                          deleteFilesArray: [String],
                                          s3Type: SWS3Type?) -> SWResourceRelation? {
        
        /// 头像需要替换图片，上传菜谱只要有新图片就行了
//        switch uploadImageType {
//        case .headImage:
//            guard !addFilesArray.isEmpty && !deleteFilesArray.isEmpty else {
//                return nil
//            }
//        case .recipeImage:
//            guard !addFilesArray.isEmpty else {
//                return nil
//            }
//        }
        
        let resourceRelation = SWResourceRelation()
        resourceRelation.categoryCode = cateCode
        
        var fileStringArray = [String]()
        for obj in addFilesArray {
            fileStringArray.append("ADD:\(obj)")
        }
        for obj in deleteFilesArray {
            fileStringArray.append("DELETE:\(obj)")
        }
        
        resourceRelation.keyNameAndOpt = fileStringArray
        resourceRelation.s3Type = s3Type
        return resourceRelation
    }
}
