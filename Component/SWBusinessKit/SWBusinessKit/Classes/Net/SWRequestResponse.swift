//
//  SWRequestResponse.swift
//  Pods
//
//  Created by ice on 2019/7/3.
//

import Foundation
import Alamofire

/// 网络统一回调
public typealias SWCompleteClosure = (Any?, SWError?) -> Void  // 废弃不使用
public typealias SWSuccessClosure = (Any?) -> Void
public typealias SWFailureClosure = (SWError) -> Void

public enum SWError: Error {
    case error(Error?)
    case customError(Int?, String?)
    case responseError(Error?, String?, [String: String]?)
    
    public var code: Int? {
        switch self {
        case let .error(err):
            return getErrorCode(err)
        case let .customError(code, _):
            return code
        case let .responseError(err, _, _):
            return getErrorCode(err)
        }
    }
    
    public var localizedDescription: String? {
        switch self {
        case let .error(err):
            return getErrorDescription(err)
        case let .customError(_, str):
            return str
        case let .responseError(err, _, _):
            return getErrorDescription(err)
        }
    }
    
    public var result: String? {
        switch self {
        case .error(_), .customError(_, _):
            return nil
        case let .responseError(_, result, _):
            return result
        }
    }
    
    public var userInfo: [String: String]? {
        switch self {
        case .error(_), .customError(_, _):
            return nil
        case let .responseError(_, _, userInfo):
            return userInfo
        }
    }
    
    private func getErrorCode(_ err: Error?) -> Int? {
        if let afError = err?.asAFError {
            return afError.responseCode
        } else {
            let nsError = err as NSError?
            return nsError?.code
        }
    }
    
    private func getErrorDescription(_ err: Error?) -> String? {
        if let afError = err?.asAFError {
            return afError.errorDescription
        } else {
            let nsError = err as NSError?
            return nsError?.localizedDescription
        }
    }
}

public class SWRequestResponse: NSObject {
    // 是否收集网络性能数据
    public static var shouldMonitor: Bool = false
    // 请求地址
    public var url: String?
    // 请求Header
    public var requestHeader: [String: String]?
    // 请求返回Header
    public var responseHeader: [AnyHashable: Any]?
    // 请求方法
    public var method: String?
    // 请求返回结果状态
    public var httpCode: Int?
    // 请求入参（Get请求为空）
    public var requestParams: Parameters?
    // 请求错误信息
    public var error: SWError
    // 请求返回结果
    public var result: String?
    // 重要信息
    public var userInfo: [String: String]?
    // 网络性能数据
    public var netMonitorInfo: SWNetMonitorModel?
    
    init(response: AFDataResponse<String>? = nil,
         error: Error? = nil,
         result: String?,
         requestHeader: HTTPHeaders? = nil,
         requestBody: Parameters? = nil,
         userInfo: [String: String]? = nil) {
        
        self.url = response?.request?.url?.absoluteString
        self.method = response?.request?.httpMethod
        self.httpCode = response?.response?.statusCode
        self.requestParams = requestBody
        self.requestHeader = requestHeader?.dictionary
        self.responseHeader = response?.response?.allHeaderFields as? [String: String]
        self.error = SWError.error(error)
        self.result = result
        self.userInfo = userInfo
        
        if let metrics = response?.metrics, metrics.transactionMetrics.count > 0, SWRequestResponse.shouldMonitor {
            netMonitorInfo = SWNetMonitorModel()
            for metric in metrics.transactionMetrics where metric.resourceFetchType == .networkLoad {
                if let requestFeatchDate = metric.fetchStartDate {
                    let millisecond = CLongLong(round(requestFeatchDate.timeIntervalSince1970 * 1000))
                    netMonitorInfo?.requestFeatchTime = millisecond
                }
                
                if let requestStartDate = metric.requestStartDate {
                    let millisecond = CLongLong(round(requestStartDate.timeIntervalSince1970 * 1000))
                    netMonitorInfo?.requestStartTime = millisecond
                }
                
                if let requestEndDate = metric.requestEndDate {
                    let millisecond = CLongLong(round(requestEndDate.timeIntervalSince1970 * 1000))
                    netMonitorInfo?.requestStartEndTime = millisecond
                }
                
                if let responseStartTime = metric.responseStartDate {
                    let millisecond = CLongLong(round(responseStartTime.timeIntervalSince1970 * 1000))
                    netMonitorInfo?.responseStartTime = millisecond
                }
                
                if let requestFeatchDate = metric.fetchStartDate, let responseEndDate = metric.responseEndDate {
                    let startTime = CLongLong(round(requestFeatchDate.timeIntervalSince1970 * 1000))
                    let endTime = CLongLong(round(responseEndDate.timeIntervalSince1970 * 1000))
                    
                    netMonitorInfo?.responseEndTime = endTime
                    let result = endTime - startTime
                    netMonitorInfo?.durationTime = Int(result)
                }
                
                if let domainLookupStartDate = metric.domainLookupStartDate, let domainLookupEndDate = metric.domainLookupEndDate, let requestFeatchDate = metric.fetchStartDate {
                    netMonitorInfo?.waitDNSTime = CLongLong(round(domainLookupStartDate.timeIntervalSince(requestFeatchDate) * 1000))
                    netMonitorInfo?.dnsLookupTime = CLongLong(round(domainLookupEndDate.timeIntervalSince(domainLookupStartDate) * 1000))
                }
                
                if let connectStartDate = metric.connectStartDate {
                    if let secureConnectionStartDate = metric.secureConnectionStartDate {
                        let startTime = CLongLong(round(connectStartDate.timeIntervalSince1970 * 1000))
                        let endTime = CLongLong(round(secureConnectionStartDate.timeIntervalSince1970 * 1000))
                        netMonitorInfo?.waitDNSTime = endTime - startTime
                    } else if let connectEndDate = metric.connectEndDate {
                        let startTime = CLongLong(round(connectStartDate.timeIntervalSince1970 * 1000))
                        let endTime = CLongLong(round(connectEndDate.timeIntervalSince1970 * 1000))
                        netMonitorInfo?.tcpTime = endTime - startTime
                    }
                }
                
                if let sslStartDate = metric.secureConnectionStartDate, let sslEndDate = metric.secureConnectionEndDate {
                    let startTime = CLongLong(round(sslStartDate.timeIntervalSince1970 * 1000))
                    let endTime = CLongLong(round(sslEndDate.timeIntervalSince1970 * 1000))
                    netMonitorInfo?.sslTime = endTime - startTime
                }
            }
        }
    }
    
    init(download response: AFDownloadResponse<String>? = nil,
         error: Error? = nil,
         result: String?,
         requestHeader: HTTPHeaders? = nil,
         requestBody: Parameters? = nil,
         userInfo: [String: String]? = nil) {
        
        self.url = response?.request?.url?.absoluteString
        self.requestHeader = requestHeader?.dictionary
        self.requestParams = requestBody
        self.responseHeader = response?.response?.allHeaderFields
        self.error = SWError.error(error)
        self.result = result
        self.userInfo = userInfo
    }
    
    /// 根据网络监控数据初始化网络请求返回
    /// - Parameters:
    ///   - info: RN页面网络监控数据
    public init(info: NetMonitorInfo? = nil) {
        self.url = info?.apiPath
        self.httpCode = info?.responseCode
        self.method = info?.requestMethod
        self.netMonitorInfo = SWNetMonitorModel()
        self.netMonitorInfo?.durationTime = info?.duration
        self.netMonitorInfo?.requestFeatchTime = Int64(info?.requestTime ?? "0")
        self.netMonitorInfo?.requestStartTime = Int64(info?.requestTime ?? "0")
        self.netMonitorInfo?.requestStartEndTime = Int64(info?.responseTime ?? "0")
        self.netMonitorInfo?.responseStartTime = Int64(info?.responseTime ?? "0")
        self.error = SWError.error(nil)
        self.requestParams = info?.params
        self.result = info?.response?.toJSONString()
    }
    
    public override var description: String {
        var time: String = ""
        var header: String = ""
        if SWRequestResponse.shouldMonitor {
            time = "\(netMonitorInfo?.description ?? "")"
            header = "<=== Request Header  ===>: \(requestHeader ?? [:])\n <=== Response Header ===>: \(responseHeader ?? [:])\n"
        }
        
        var params: String = ""
        if let oldParams = requestParams {
            params = " <=== Request Params  ===>: \(oldParams)\n"
        }
        
        var errStr: String = ""
        if let str = error.localizedDescription {
            errStr = " <=== Request Failed  ===>: \(str)\n"
        }
        var des = " <=== Url    ===>: \((url ?? ""))\n <=== Env    ===>: \(EnvironmentManager.default.env.description) \n <=== Method ===>: \((method ?? ""))\n <=== Status ===>: \((httpCode ?? -1))\n"
            + "\(time)"
            + "\(params)"
            + " <=== Response        ===>: \((result ?? ""))\n \(header)"
            + "\(errStr)"
        
        return des
    }
}
