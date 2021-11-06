//
//  SWEncryptEncoding.swift
//  SWBusinessKit
//
//  Created by ice on 2019/9/9.
//

import Foundation
import Alamofire

enum SWEncryptEncodingError: Error {
    case invalid
}

public struct SWEncryptEncoding: ParameterEncodingWithUserInfo {
    private var wrappedEncoding: ParameterEncoding
    
    public init(_ wrappedEncoding: ParameterEncoding) {
        self.wrappedEncoding = wrappedEncoding
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?, userInfo: [String: Any]?) throws -> URLRequest {
        let encodeRequest = try self.wrappedEncoding.encode(urlRequest, with: parameters)
        var urlRequest = try encodeRequest.asURLRequest()
        
        if !SWNetworking.isEncrypt(userInfo) {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: SWEncryptEncodingError.invalid))
        }
        
        guard let apiKey = userInfo?["apiKey"] as? String,
            let key = userInfo?["key"] as? String,
            let iv = userInfo?["iv"] as? String else {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: SWEncryptEncodingError.invalid))
        }
        
        var jsonStr: String
        if let data = urlRequest.httpBody {
            jsonStr = String(data: data, encoding: .utf8) ?? "{}"
        } else {
            jsonStr = "{}"
        }
        
//        #if DEBUG
//        SWLogger.debug("--- 原始BODY --- \(urlRequest.url?.description ?? "") \n \(jsonStr) \n")
//        #endif
        
        let data = SWEncryptEncoding.resetBody(bodyJson: jsonStr, apiKey: apiKey, key: key, iv: iv)
        urlRequest.httpBody = data
        
//        #if DEBUG
//        if let data = data, let encryString = String(data: data, encoding: .utf8) {
//            SWLogger.debug("--- 加密BODY --- \(urlRequest.url?.description ?? "") \n \(encryString)\n")
//        }
//        #endif
        
        return urlRequest
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        return try encode(urlRequest, with: parameters, userInfo: nil)
    }
}

extension SWEncryptEncoding {
    static func resetBody(bodyJson: String, apiKey: String, key: String, iv: String) -> Data? {
        let signStr = signParameters(params: bodyJson, key: key, iv: iv)
        var bodyDict = [String: String]()
        bodyDict["params"] = signStr
        for (k, v) in configHeader(apiKey: apiKey, entryptStr: signStr) {
            bodyDict[k] = v
        }
        
        let jsonStr = bodyDict.toJSONString()
        let postData = jsonStr?.data(using: .utf8)
        
        return postData
    }
    
    static func signParameters(params: String, key: String, iv: String) -> String {
        let encryStr = SWAES128.encrypt(str: params, key: key, iv: iv)
        return encryStr
    }
    
    static func configHeader(apiKey: String, entryptStr: String) -> [String: String] {
        let date = Date()
        let timeInterval = date.timeIntervalSince1970 * 1000
        let timeStr = String(format: "%.0lf", timeInterval)
        let originStr = String(format: "%@%@%@", timeStr, apiKey, entryptStr)
        let signStr = originStr.md5().uppercased()
        let header = ["timeStamp": "\(timeStr)", "sign": signStr]
        
        return header
    }
    
    static func decrypt(str: String?, key: String, iv: String) -> String {
        let jsonStr = SWAES128.decrypt(str: str, key: key, iv: iv)
        return jsonStr
    }
}
