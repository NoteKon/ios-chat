//
//  JSONStringArrEncoding.swift
//  Pods
//
//  Created by ice on 2019/7/19.
//

import Foundation
import Alamofire

public struct JSONStringArrEncoding: ParameterEncoding {
    private let array: [Any]
    
    public init(array: [Any]) {
        self.array = array
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        if urlRequest.allHTTPHeaderFields?["Content-Type"] == nil {
            urlRequest.allHTTPHeaderFields?["Content-Type"] = "application/json;charset=utf-8"
        }
        
        let data = try JSONSerialization.data(withJSONObject: array, options: [])
        urlRequest.httpBody = data
        
        return urlRequest
    }
}
