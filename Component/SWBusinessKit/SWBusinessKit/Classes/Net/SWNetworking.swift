//
//  SWNetworking.swift
//  SWBusinessKit
//
//  Created by ice on 2019/9/10.
//

import Foundation
import WebKit

public typealias SWNetWorking = SWNetworking

@objcMembers
public class SWNetworking: NSObject {
    
}

extension SWNetWorking {
    typealias UserInfoAndHeadersPair = (headers: [String: String]?, userInfo: [String: String]?)
    
    /// - Note: 以下划线 `_` 开头的 HTTP 头部参数当作 UserInfo 处理
    static func getUserInfoAndHeadersPair(_ headers: [String: String]?) -> UserInfoAndHeadersPair {
        guard let headers = headers else { return (nil, nil) }
        
        var headerPair = [String: String]()
        var userInfoPair = [String: String]()
        
        for (key, value) in headers {
            if key.hasPrefix("_") {
                userInfoPair[key] = value
            } else {
                headerPair[key] = value
            }
        }
       
        return (headerPair, userInfoPair)
    }
}

extension SWNetworking {
    public static func initSystemUserAgent() {
        let block = { () -> String? in
            var agent: String?
            let webView = WKWebView()
            if let userAgent = webView.value(forKey: "userAgent") as? String {
                agent = userAgent
            } else {
                webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
                    _ = webView.description
                    if let userAgent = result as? String {
                        agent = userAgent
                    }
                }
            }
            return agent
        }
        
        systemUserAgent = block()
    }
    
    public static var systemUserAgent: String?
}
