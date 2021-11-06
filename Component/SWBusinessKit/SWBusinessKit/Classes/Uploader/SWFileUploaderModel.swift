//
//  SWFileUploaderModel.swift
//  SWBusinessKit
//
//  Created by ice on 2019/11/9.
//

import Foundation
import HandyJSON

public enum SWS3Type: String, HandyJSONEnum {
    case AMAZON
    case MINIO
    case OSS
    case QINIU
}

public class SWFileUploaderObject {
    public var fileData: Data?
    public var fileType: String?
}

public class SWFileUploaderModel {
    public var sysCode: String?
    public var categoryCode: String?
    public var businessCode: String?
    public var fileObjects: [SWFileUploaderObject]?
}

class SWPresignUrlRequestModel: HandyJSON {
    public var sysCode: String?
    public var businessCode: String?
    public var fileNames: [String]?
    
    required init() {}
}

public class SWResourceRelation: SWBaseModel {
    public var categoryCode: String?
    public var keyNameAndOpt: [String]? = []
    public var s3Type: SWS3Type?
}

public class SWPresignUrlResponseModel: HandyJSON, CustomStringConvertible {
    public var keyName: String?
    public var preUrl: String?
    public var s3Type: SWS3Type?
    
    public required init() {}
    
    public var description: String {
        return "{keyName: \(keyName ?? ""), preUrl: \(preUrl ?? "")}"
    }
}

public typealias SWFileUploaderCompletion = (SWFileUploaderResult) -> Void

public class SWFileUploaderResult: CustomStringConvertible {
    /// 文件总数
    public var total: Int = 0
    /// 上传成功的文件
    public var successIndexes: [Int] = [Int]()
    /// 上传失败的文件
    public var failureIndexes: [Int] = [Int]()
    /// 预签名地址
    public var presignUrls: [SWPresignUrlResponseModel]?
    
    var lock: NSRecursiveLock
    
    public init(total: Int) {
        self.lock = NSRecursiveLock()
        self.total = total
    }
    
    public var description: String {
        return "{total: \(total), successIndexes: \(successIndexes), failureIndexes: \(failureIndexes), urls: \(presignUrls ?? [])}"
    }
}
