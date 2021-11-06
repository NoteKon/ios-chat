//
//  SWFileUploader.swift
//  SWBusinessKit
//
//  Created by ice on 2019/11/9.
//

import Foundation
import HandyJSON
import Alamofire
import SWFoundationKit

let kPresignUrl = vdc_vv_com_sg + "/vvgw/VV-RESOURCE-SERVICE" + "/api/resource/producePutPreSignUrls"

public class SWFileUploader {
    static let `default` = SWFileUploader()
    
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        return queue
    }()
    
    private init() {}
    
    public var maxConcurrentOperationCount: Int {
        set {
            operationQueue.maxConcurrentOperationCount = newValue
        }
        get {
            return operationQueue.maxConcurrentOperationCount
        }
    }
    
    /// 上传文件（一个或多个）
    /// - NOTE: 回调总是在主线程
    public static func upload(fileModel: SWFileUploaderModel,
                              retry: Int = 0,
                              completion: SWFileUploaderCompletion?) {
        let result = SWFileUploaderResult(total: fileModel.fileObjects?.count ?? 0)
        upload(fileModel: fileModel, result: result, retry: retry, completion: { (result) in
            executeMainBlock {
                completion?(result)
            }
        })
    }
    
    private static func upload(fileModel: SWFileUploaderModel,
                               result: SWFileUploaderResult,
                               retry: Int,
                               completion: SWFileUploaderCompletion?) {
        doUpload(fileModel: fileModel, result: result) { result in
            if result.failureIndexes.count > 0, retry > 0 {
                #if DEBUG
                SWLogger.debug("rety: \(result)")
                #endif
                // 清除失败列表
                result.clearFailure()
                upload(fileModel: fileModel, result: result, retry: retry-1, completion: completion)
            } else {
                completion?(result)
            }
        }
    }
    
    /// 上传文件（单个或多个）
    ///
    /// - Parameter fileModel: 文件模型
    /// - Parameter completion: 完成回调（成功或失败）
    private static func doUpload(fileModel: SWFileUploaderModel,
                                 result: SWFileUploaderResult,
                                 completion: SWFileUploaderCompletion?) {
        guard let fileObjects = fileModel.fileObjects else {
            completion?(result.allFailure())
            return
        }
        
        if result.presignUrls == nil {
            requestPresignUrl(fileModel: fileModel, success: { (object) in
                guard let object = object as? SWBaseResponseModel<[SWPresignUrlResponseModel]>,
                    object.code == SWResponseCode.success.rawValue,
                    let presignArray = object.data, presignArray.count == fileObjects.count else {
                        completion?(result.allFailure())
                        return
                }
                
                result.presignUrls = presignArray
                uploadFiles(fileModel: fileModel, result: result, completion: completion)
            }) { (error) in
                completion?(result.allFailure())
            }
        } else {
            uploadFiles(fileModel: fileModel, result: result, completion: completion)
        }
    }
    
    /// 上传多个文件
    private static func uploadFiles(fileModel: SWFileUploaderModel,
                                    result: SWFileUploaderResult,
                                    completion: SWFileUploaderCompletion?) {
        
        guard let presignArray = result.presignUrls, let fileObjects = fileModel.fileObjects,
            presignArray.count == fileObjects.count else {
                completion?(result.allFailure())
                return
        }
        
        for (i, tuple) in Array(zip(fileObjects, presignArray)).enumerated() {
            if result.successIndexes.contains(i) {
                continue
            }
            
            guard let fileData = tuple.0.fileData, let preUrl = tuple.1.preUrl, let _ = URL(string: preUrl) else {
                result.addFailure(indexes: [i])
                if result.fullfill() {
                    completion?(result)
                    return
                }
                continue
            }
            
            let operation = BlockOperation {
                uploadFile(fileData: fileData, to: preUrl, success: { (response) in
                    result.addSuccess(indexes: [i])
                    if result.fullfill() {
                        completion?(result)
                    }
                }) { (error) in
                    result.addFailure(indexes: [i])
                    if result.fullfill() {
                        completion?(result)
                    }
                }
            }
            
            SWFileUploader.default.operationQueue.addOperation(operation)
        }
    }
        
    /// 上传单个文件
    @discardableResult
    private static func uploadFile(fileData: Data,
                                   to url: String,
                                   success: SWSuccessClosure?,
                                   failure: SWFailureClosure?) -> UploadRequest {
        let uploadRequest = AF.upload(fileData, to: URL(string: url)!, method: .put, headers: ["Content-Type": "application/octet-stream"])
        uploadRequest.response { (response) in
            if response.error == nil {
                success?(response as AnyObject)
            } else {
                failure?(SWError.error(response.error))
            }
        }
        return uploadRequest
    }
    
    /// 请求预签名
    ///
    /// - Parameter model: 请求模型
    /// - Parameter success: 请求成功
    /// - Parameter failure: 请求失败
    private static func requestPresignUrl(fileModel: SWFileUploaderModel,
                                          success: SWSuccessClosure?,
                                          failure: SWFailureClosure?) {
        guard let fileObjects = fileModel.fileObjects else {
            failure?(SWError.customError(-1, "invalid parameter"))
            return
        }
        
        // 组装文件名
        var fileNames = [String]()
        for (i, object) in fileObjects.enumerated() {
            let filename = String(format: "%@_iOS_%d.%@", fileModel.categoryCode ?? "", i, object.fileType ?? "")
            fileNames.append(filename)
        }
        
        // 获取预签名
        let perSignRequestModel = SWPresignUrlRequestModel()
        perSignRequestModel.sysCode = fileModel.sysCode
        perSignRequestModel.fileNames = fileNames
        perSignRequestModel.businessCode = fileModel.businessCode
        
        let params = perSignRequestModel.toJSON()
        
        SWNetworking.postWithUrlString(kPresignUrl, parameters: params, headers: nil, foreground: false, successComplete: { (response) in
            let object = SWBaseResponseModel<[SWPresignUrlResponseModel]>.deserialize(from: response.result)
            success?(object)
        }) { (response) in
            failure?(response.error)
        }
    }
}

extension SWFileUploaderResult {
    @discardableResult
    func addFailure(indexes: [Int]) -> Self {
        lock.lock()
        defer { lock.unlock() }
        for i in indexes {
            if !failureIndexes.contains(i) {
                failureIndexes.append(i)
            }
            successIndexes.removeAll { $0 == i }
        }
        return self
    }
    
    @discardableResult
    func addSuccess(indexes: [Int]) -> Self {
        lock.lock()
        defer { lock.unlock() }
        for i in indexes {
            if !successIndexes.contains(i) {
                successIndexes.append(i)
            }
            failureIndexes.removeAll { $0 == i }
        }
        return self
    }
    
    @discardableResult
    func allFailure() -> Self {
        lock.lock()
        defer { lock.unlock() }
        successIndexes.removeAll()
        failureIndexes.removeAll()
        for i in 0..<total {
            failureIndexes.append(i)
        }
        return self
    }
    
    @discardableResult
    func clearFailure() -> Self {
        lock.lock()
        defer { lock.unlock() }
        failureIndexes.removeAll()
        return self
    }
    
    func fullfill() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let count = successIndexes.count + failureIndexes.count
        let total = self.total
        return count >= total
    }
}
