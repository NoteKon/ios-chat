//
//  SWBase.swift
//  Pods
//
//  Created by ice on 2019/8/5.
//

import Foundation
import HandyJSON

/// 业务请求Code状态码
public enum SWResponseCode: Int {
    case success = 10000
}

open class SWBaseModel: HandyJSON {
    public required init() {}
}

open class SWBaseRequestModel: HandyJSON {
    public required init() {}
    
    open func willStartMapping() {
        
    }
    
    open func mapping(mapper: HelpingMapper) {
        
    }
    
    open func didFinishMapping() {
        
    }
}

open class SWBaseResponseModel<T>: HandyJSON {
    public var code: Int = 0
    public var msg: String?
    public var timeStamp: TimeInterval?
    public var data: T?
    
    public required init() {}
}

open class SWBasePageModel<T>: SWBaseModel {
    /// 当前请求第几页数据
    public var current: Int?
    /// 每页请求的数据条数
    public var pageSize: Int?
    /// 数据总页数
    public var pages: Int?
    /// 数据总数
    public var total: Int?
    ///数据内容
    public var rows: [T]? = []
}

open class SWBaseImageModel: SWBaseModel {
    
    public var keyName: String?
    public var originName: String?
    public var url: String?
    
    public required init() {}
    
    public init(keyName: String?, originName: String?, url: String?) {
        self.keyName = keyName
        self.originName = originName
        self.url = url
    }
}
