//
//  SWRequestConvertible.swift
//  SWBusinessKit
//
//  Created by ice on 2019/9/19.
//

import Foundation
import Alamofire

private let kTimeoutIntervalForRequest = 30.0

public struct SWRequestConvertible: URLRequestConvertible {
    let url: URLConvertible
    let method: HTTPMethod
    let parameters: Parameters?
    let encoding: ParameterEncoding
    let headers: HTTPHeaders?
    let userInfo: [String: String]?
    
    public func asURLRequest() throws -> URLRequest {
        let request = try URLRequest(url: url, method: method, headers: headers)
        var urlRequest: URLRequest
        switch encoding {
        case let encoding as ParameterEncodingWithUserInfo:
            urlRequest = try encoding.encode(request, with: parameters, userInfo: self.userInfo)
        default:
            urlRequest = try encoding.encode(request, with: parameters)
        }
        urlRequest.timeoutInterval = kTimeoutIntervalForRequest
        return urlRequest
    }
}
