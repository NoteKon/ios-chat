//
//  SWNetCommon.swift
//  SWUIKit
//
//  Created by ice on 2019/9/20.
//

import Foundation
import Alamofire

public protocol ParameterEncodingWithUserInfo: ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?, userInfo: [String: Any]?) throws -> URLRequest
}

public protocol SWNetworkingFilter {
    static func requestProcess(request: SWRequestConvertible) -> SWRequestConvertible
    static func successProcess(response: SWRequestResponse)
    static func failureProcess(response: SWRequestResponse)
}
