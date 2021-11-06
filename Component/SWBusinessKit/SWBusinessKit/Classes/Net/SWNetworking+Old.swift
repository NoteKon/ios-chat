//
//  SWNetworking+Old.swift
//  Pods
//
//  Created by ice on 2020/5/7.
//

import Foundation
import Alamofire

extension SWNetworking {
    public static func getWithUrlString(_ url: URLConvertible,
                                        parameters: Parameters? = nil,
                                        encoding: ParameterEncoding = URLEncoding.default,
                                        headers: [String: String]? = nil,
                                        foreground: Bool = false,
                                        successComplete: ((SWRequestResponse) -> Void)? = nil,
                                        failureComplete: ((SWRequestResponse) -> Void)? = nil) {
        SWNetworking.request1(url,
                              method: .get,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers,
                              foreground: foreground,
                              successComplete: successComplete,
                              failureComplete: failureComplete)
    }
    
    public static func postWithUrlString(_ url: URLConvertible,
                                         parameters: Parameters? = nil,
                                         encoding: ParameterEncoding = JSONEncoding.default,
                                         headers: [String: String]? = nil,
                                         foreground: Bool = false,
                                         successComplete: ((SWRequestResponse) -> Void)? = nil,
                                         failureComplete: ((SWRequestResponse) -> Void)? = nil) {
        SWNetworking.request1(url,
                              method: .post,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers,
                              foreground: foreground,
                              successComplete: successComplete,
                              failureComplete: failureComplete)
        
    }
    
    public static func putWithUrlString(_ url: URLConvertible,
                                        parameters: Parameters? = nil,
                                        encoding: ParameterEncoding = JSONEncoding.default,
                                        headers: [String: String]? = nil,
                                        foreground: Bool = false,
                                        successComplete: ((SWRequestResponse) -> Void)? = nil,
                                        failureComplete: ((SWRequestResponse) -> Void)? = nil) {
        SWNetworking.request1(url,
                              method: .put,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers,
                              foreground: foreground,
                              successComplete: successComplete,
                              failureComplete: failureComplete)
    }
    
    public static func deleteWithUrlString(_ url: URLConvertible,
                                           parameters: Parameters? = nil,
                                           encoding: ParameterEncoding = JSONEncoding.default,
                                           headers: [String: String]? = nil,
                                           foreground: Bool = false,
                                           successComplete: ((SWRequestResponse) -> Void)? = nil,
                                           failureComplete: ((SWRequestResponse) -> Void)? = nil) {
        SWNetworking.request1(url,
                              method: .delete,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers,
                              foreground: foreground,
                              successComplete: successComplete,
                              failureComplete: failureComplete)
    }
    
    public static func downloadWithUrlString(_ url: URLConvertible,
                                             parameters: Parameters? = nil,
                                             encoding: ParameterEncoding = JSONEncoding.default,
                                             headers: [String: String]? = nil,
                                             foreground: Bool = false,
                                             to destination: DownloadRequest.Destination? = nil,
                                             successComplete: ((SWRequestResponse) -> Void)? = nil,
                                             failureComplete: ((SWRequestResponse) -> Void)? = nil) {
        SWNetworking.download1(url,
                               method: .get,
                               parameters: parameters,
                               encoding: encoding,
                               headers: headers,
                               to: destination,
                               foreground: foreground,
                               successComplete: successComplete,
                               failureComplete: failureComplete)
    }
    
    public static func uploadWithUrlString(_ url: URLConvertible,
                                           parameters: Parameters? = nil,
                                           encoding: ParameterEncoding = JSONEncoding.default,
                                           headers: [String: String]? = nil,
                                           foreground: Bool = false,
                                           multipartFormData: @escaping (MultipartFormData) -> Void,
                                           successComplete: ((SWRequestResponse) -> Void)? = nil,
                                           failureComplete: ((SWRequestResponse) -> Void)? = nil) {
        SWNetworking.upload1(url,
                             method: .post,
                             parameters: parameters,
                             encoding: encoding,
                             headers: headers,
                             multipartFormData: multipartFormData,
                             foreground: foreground,
                             successComplete: successComplete,
                             failureComplete: failureComplete)
    }
    
    static func request1(_ url: URLConvertible,
                         method: HTTPMethod,
                         parameters: Parameters? = nil,
                         encoding: ParameterEncoding = JSONEncoding.default,
                         headers: [String: String]? = nil,
                         foreground: Bool = false,
                         successComplete: ((SWRequestResponse) -> Void)? = nil,
                         failureComplete: ((SWRequestResponse) -> Void)? = nil) {
        
        var queue = DispatchQueue.global(qos: .background)
        if foreground {
            queue = DispatchQueue.main
        }
        
        let pair = getUserInfoAndHeadersPair(headers)
        let headers = processHeaders(url: url, headers: pair.headers)
        
        var convertible = SWRequestConvertible(url: url,
                                               method: method,
                                               parameters: parameters,
                                               encoding: encoding,
                                               headers: headers,
                                               userInfo: pair.userInfo)

        convertible = requestProcess(request: convertible)
        
        AF.request(convertible).validate().responseString(queue: queue, encoding: String.Encoding.utf8 ,completionHandler: { (response) in
            
            switch response.result {
            case .success(let jsonStr):
                let result = SWRequestResponse(response: response,
                                               error: nil,
                                               result: jsonStr,
                                               requestHeader: convertible.headers,
                                               requestBody: convertible.parameters,
                                               userInfo: convertible.userInfo)
                
                successProcess(response: result)
                successComplete?(result)
            case .failure(let error):
                let result = SWRequestResponse(response: response,
                                               error: (error),
                                               result: nil,
                                               requestHeader: convertible.headers,
                                               requestBody: convertible.parameters,
                                               userInfo: convertible.userInfo)
                
                failureProcess(response: result)
                failureComplete?(result)
            }
        })
    }
    
    static func download1(_ url: URLConvertible,
                          method: HTTPMethod = .get,
                          parameters: Parameters? = nil,
                          encoding: ParameterEncoding = JSONEncoding.default,
                          headers: [String: String]? = nil,
                          to destination: DownloadRequest.Destination? = nil,
                          foreground: Bool = false,
                          successComplete: ((SWRequestResponse) -> Void)? = nil,
                          failureComplete: ((SWRequestResponse) -> Void)? = nil) {
        
        var queue = DispatchQueue.global(qos: .background)
        if foreground {
            queue = DispatchQueue.main
        }
        
        let pair = getUserInfoAndHeadersPair(headers)
        let headers = processHeaders(url: url, headers: pair.headers)
        
        AF.download(url, method: method, parameters: parameters, headers: headers, to: destination).validate().responseString(queue: queue) { (response) in
            switch response.result {
            case .success(let jsonStr):
                let result = SWRequestResponse(download: response,
                                               error: nil,
                                               result: jsonStr,
                                               userInfo: pair.userInfo)
                
                successProcess(response: result)
                successComplete?(result)
            case .failure(let error):
                let result = SWRequestResponse(download: response,
                                               error: (error),
                                               result: nil,
                                               userInfo: pair.userInfo)
                
                failureProcess(response: result)
                failureComplete?(result)
            }
        }
    }
    
    static func upload1(_ url: URLConvertible,
                        method: HTTPMethod = .post,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = JSONEncoding.default,
                        headers: [String: String]? = nil,
                        multipartFormData: @escaping (MultipartFormData) -> Void,
                        foreground: Bool = false,
                        successComplete: ((SWRequestResponse) -> Void)? = nil,
                        failureComplete: ((SWRequestResponse) -> Void)? = nil) {
        var queue = DispatchQueue.global(qos: .background)
        if foreground {
            queue = DispatchQueue.main
        }
        
        let pair = getUserInfoAndHeadersPair(headers)
        let headers = processHeaders(url: url, headers: pair.headers)
        
        AF.upload(multipartFormData: multipartFormData, to: url, method: method, headers: headers).validate().responseString(queue: queue) { (response) in
            switch response.result {
            case .success(let jsonStr):
                let result = SWRequestResponse(response: response,
                                               error: nil,
                                               result: jsonStr,
                                               userInfo: pair.userInfo)
                
                successProcess(response: result)
                successComplete?(result)
            case .failure(let error):
                let result = SWRequestResponse(response: response,
                                               error: (error),
                                               result: nil,
                                               userInfo: pair.userInfo)
                
                failureProcess(response: result)
                failureComplete?(result)
            }
        }
    }
}
