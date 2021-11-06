//
//  SWNetworking+VV.swift
//  SWBusinessKit
//
//  Created by ice on 2019/9/10.
//

import Foundation
import Alamofire
import SWFoundationKit
import RxSwift
import HandyJSON

public let SWNotAuthorizedNotification = Notification.Name("SWNotAuthorizedNotification")

private let kEncryptKey = "smode"
private let kEncryptInfo = [
    kEncryptKey: "0",
    "apiKey": "VVuucskey201906",
    "key": "VVuucs_sec201906",
    "iv": "VVuucs_sec201906"
]

private var _channel: String?
private let _lock = NSRecursiveLock()

extension SWNetworking: SWNetworkingFilter {
    static func shouldProcessRequest(url: URLConvertible?) -> Bool {
        return EnvironmentManager.default.isVVHost(try? url?.asURL())
    }
    
    static func getPlatformHeaders() -> [String: String]? {
        let imei = SWKeyChain.getUUID()
        var params = [String: String]()
        
        params["User-Agent"] = getCurrentUserAgent()
        params["X-Udid"] = imei
        params["X-Channel"] = getChannel()
        params["Accept-Language"] = generateAcceptLanguage()
        params["appName"] = SWApp.bundleDisplayName
        params["platform"] = "iOS"
        
        return params
    }
    
    private static func getChannel() -> String {
        return _lock.calculateLocked { () -> String in
            if let channel = _channel {
                return channel
            }
            let channel = readConfiguredChannel() ?? "AppStore"
            _channel = channel
            return channel
        }
    }
    
    private static func readConfiguredChannel() -> String? {
        if let plistPath = Bundle.main.path(forResource: "vvmodule", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: plistPath) as? [String: Any],
            let channel = dict["channel"] as? String {
            return channel
        }
        return nil
    }
    
    /// i.e.: zh-CN,zh;q=0.9,en;q=0.5
    private static func generateAcceptLanguage() -> String {
        let locale = UIDevice.currentLocale()
        let generic = locale.genericIdentifier
        var result: String
        if let languageCode = locale.languageCode {
            result = "\(generic),\(languageCode);q=0.9"
        } else {
            result = "\(generic)"
        }
        if !generic.hasPrefix("en") {
            result += ",en;q=0.8"
        }
        return result
    }
    
    static func isEncrypt(_ dict: [String: Any]?) -> Bool {
        if let encry = dict?[kEncryptKey] as? String, encry == "1" {
            return true
        }
        return false
    }
    
    static func processHeaders(url: URLConvertible, headers: [String: String]?) -> HTTPHeaders? {
        guard shouldProcessRequest(url: url) else {
            if let headers = headers {
                return HTTPHeaders(headers)
            }
            return nil
        }
        
        var newHeaders = [String: String]()
        headers?.forEach { newHeaders[$0] = $1 }
        
        if newHeaders["Content-Type"] == nil {
            newHeaders["Content-Type"] = "application/json"
        }
        
        if let author = self.authorization {
            newHeaders["Authorization"] = author
            newHeaders["token"] = author
        }
        
        getPlatformHeaders()?.forEach { newHeaders[$0] = $1 }
        
        return HTTPHeaders(newHeaders)
    }
    
    public static func requestProcess(request: SWRequestConvertible) -> SWRequestConvertible {
        guard shouldProcessRequest(url: request.url) else { return request }
        
        var encoding = request.encoding
        var userInfo = [String: String]()
        request.userInfo?.forEach { userInfo[$0] = $1 }
        
        ///默认不加密，除非显式指定
        for (k, v) in kEncryptInfo where userInfo[k] == nil {
            userInfo[k] = v
        }
        
        //NOTE: 只有POST需要加密，但这里只判断非GET
        if request.method != .get && isEncrypt(userInfo) {
            encoding = SWEncryptEncoding(encoding)
        }
        
        return SWRequestConvertible(url: request.url,
                                    method: request.method,
                                    parameters: request.parameters,
                                    encoding: encoding,
                                    headers: request.headers,
                                    userInfo: userInfo)
    }
    
    private static func removeInternalUserInfo(response: SWRequestResponse) {
        guard var userInfo = response.userInfo else { return }
        for (k, _) in kEncryptInfo {
            userInfo[k] = nil
        }
        response.userInfo = userInfo
    }
    
    public static func successProcess(response: SWRequestResponse) {
        defer {
            removeInternalUserInfo(response: response)
        }
        
        guard let str = response.result else { return }
        
        if shouldProcessRequest(url: response.url),
            let userInfo = response.userInfo, isEncrypt(userInfo),
            let key = userInfo["key"], let iv = userInfo["iv"],
            var origDict = str.toDictionary(), let dataStr = origDict["data"] as? String {
            
            let decryStr = SWEncryptEncoding.decrypt(str: dataStr, key: key, iv: iv)
            
            if let decryDict = decryStr.toJSONObject() {
                origDict["data"] = decryDict
            } else {
                origDict["data"] = decryStr
            }
            
            let resultStr = origDict.toJSONString()
            response.result = resultStr
        }
        
        #if DEBUG
        let logtext = "\n<--- 网络请求成功抓包数据 --->: \n\(response.description)\n"
        SWLogger.debug(logtext)
        //SWLogger.logan(logtext)
        NetMonitorManager.postNetLog(objc: response)
        #endif
    }
    
    public static func failureProcess(response: SWRequestResponse) {
        defer {
            removeInternalUserInfo(response: response)
        }
        
        if response.error.code == 401 {
            let noauth = response.userInfo?["_noauth"]?.intValue ?? 0
            if noauth == 0 {
                executeMainBlock {
                    NotificationCenter.default.post(name: SWNotAuthorizedNotification, object: nil)
                }
            }
        }
        
//        let description = response.error.localizedDescription ?? ""
//        let result = response.result ?? ""
//        let code = response.error.code ?? 0

        #if DEBUG
        let logtext = "\n<--- 网络请求失败抓包数据 --->: \n\(response.description)\n"
        SWLogger.debug(logtext)
        //SWLogger.logan(logtext)
        NetMonitorManager.postNetLog(objc: response)
        #endif
    }
}

extension SWNetworking {
    private static let kAuthorizationKey = "Authorization"
    private static let kUserCodeKey = "UserCode"
    
    public static var authorization: String? {
        get {
            return UserDefaults.standard.string(forKey: kAuthorizationKey)
        }
        set {
            if newValue == nil || newValue == "" {
                UserDefaults.standard.removeObject(forKey: kAuthorizationKey)
            } else {
                UserDefaults.standard.setValue(newValue, forKey: kAuthorizationKey)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    public static var userCode: String? {
        get {
            return UserDefaults.standard.string(forKey: kUserCodeKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: kUserCodeKey)
            UserDefaults.standard.synchronize()
        }
    }
}

extension SWNetworking {
    public static func getCurrentUserAgent() -> String? {
        let original = systemUserAgent ?? ""
        let appVer = SWAppInfo.appVersion
        let appBuild = SWAppInfo.appBuild
        let appName = SWAppHelper.getAppUAName()
        let model = UIDevice.deviceModel()
        let netType = SWNetworking.reachabilityStatus()
        let locale = UIDevice.currentLocale()
        let language = locale.genericIdentifier
        
        return "\(original) \(appName)/\(appVer) (\(appBuild)) Model/\(model) NetType/\(netType) Language/\(language)"
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait, Element == SWRequestResponse {
    public func filterVVError() -> Single<SWRequestResponse> {
        return flatMap { (response) -> Single<SWRequestResponse> in
            if SWNetworking.shouldProcessRequest(url: response.url),
                let object = SWBaseResponseModel<Any>.deserialize(from: response.result),
                object.code != SWResponseCode.success.rawValue {
                /// 业务错误
                let error = SWError.customError(object.code, object.msg)
                return Single.error(SWError.responseError(error, response.result, response.userInfo))
            }
            
            return Single.just(response)
        }
    }
}
