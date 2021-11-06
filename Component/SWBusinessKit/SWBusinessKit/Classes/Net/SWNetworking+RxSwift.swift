//
//  SWNetworking+RxSwift.swift
//  Pods
//
//  Created by ice on 2020/5/7.
//

import Foundation
import Alamofire
import RxSwift

extension SWNetworking {
    public static func get(_ url: URLConvertible,
                           parameters: Parameters? = nil,
                           encoding: ParameterEncoding = URLEncoding.default,
                           headers: [String: String]? = nil) -> Single<SWRequestResponse> {
        return SWNetworking.request2(url,
                                     method: .get,
                                     parameters: parameters,
                                     encoding: encoding,
                                     headers: headers)
    }
    
    public static func post(_ url: URLConvertible,
                            parameters: Parameters? = nil,
                            encoding: ParameterEncoding = JSONEncoding.default,
                            headers: [String: String]? = nil) -> Single<SWRequestResponse> {
        return SWNetworking.request2(url,
                                     method: .post,
                                     parameters: parameters,
                                     encoding: encoding,
                                     headers: headers)
        
    }
    
    public static func put(_ url: URLConvertible,
                           parameters: Parameters? = nil,
                           encoding: ParameterEncoding = JSONEncoding.default,
                           headers: [String: String]? = nil) -> Single<SWRequestResponse> {
        return SWNetworking.request2(url,
                                     method: .put,
                                     parameters: parameters,
                                     encoding: encoding,
                                     headers: headers)
    }
    
    public static func delete(_ url: URLConvertible,
                              parameters: Parameters? = nil,
                              encoding: ParameterEncoding = JSONEncoding.default,
                              headers: [String: String]? = nil) -> Single<SWRequestResponse> {
        return SWNetworking.request2(url,
                                     method: .delete,
                                     parameters: parameters,
                                     encoding: encoding,
                                     headers: headers)
    }
    
    public static func download(_ url: URLConvertible,
                                parameters: Parameters? = nil,
                                encoding: ParameterEncoding = JSONEncoding.default,
                                headers: [String: String]? = nil,
                                to destination: DownloadRequest.Destination? = nil) -> Single<SWRequestResponse> {
        return SWNetworking.download2(url,
                                      method: .get,
                                      parameters: parameters,
                                      encoding: encoding,
                                      headers: headers,
                                      to: destination)
    }
    
    public static func upload(_ url: URLConvertible,
                              parameters: Parameters? = nil,
                              encoding: ParameterEncoding = JSONEncoding.default,
                              headers: [String: String]? = nil,
                              multipartFormData: @escaping (MultipartFormData) -> Void) -> Single<SWRequestResponse> {
        return SWNetworking.upload2(url,
                                    method: .post,
                                    parameters: parameters,
                                    encoding: encoding,
                                    headers: headers,
                                    multipartFormData: multipartFormData)
    }
    
    static func request2(_ url: URLConvertible,
                         method: HTTPMethod,
                         parameters: Parameters? = nil,
                         encoding: ParameterEncoding = JSONEncoding.default,
                         headers: [String: String]? = nil) -> Single<SWRequestResponse> {
        return Single.create { (observer) -> Disposable in
            let pair = getUserInfoAndHeadersPair(headers)
            let headers = processHeaders(url: url, headers: pair.headers)
            
            var convertible = SWRequestConvertible(url: url,
                                                   method: method,
                                                   parameters: parameters,
                                                   encoding: encoding,
                                                   headers: headers,
                                                   userInfo: pair.userInfo)
            
            convertible = requestProcess(request: convertible)
            
            let request = AF.request(convertible).validate().responseString(completionHandler: { (response) in
                
                switch response.result {
                case .success(let jsonStr):
                    let result = SWRequestResponse(response: response,
                                                   error: nil,
                                                   result: jsonStr,
                                                   requestHeader: convertible.headers,
                                                   requestBody: convertible.parameters,
                                                   userInfo: convertible.userInfo)
                    
                    successProcess(response: result)
                    observer(.success(result))
                case .failure(let error):
                    let result = SWRequestResponse(response: response,
                                                   error: error,
                                                   result: nil,
                                                   requestHeader: convertible.headers,
                                                   requestBody: convertible.parameters,
                                                   userInfo: convertible.userInfo)
                    
                    failureProcess(response: result)
                    observer(.error(SWError.responseError(result.error, result.result, result.userInfo)))
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        }.filterVVError()
    }
    
    static func download2(_ url: URLConvertible,
                          method: HTTPMethod = .get,
                          parameters: Parameters? = nil,
                          encoding: ParameterEncoding = JSONEncoding.default,
                          headers: [String: String]? = nil,
                          to destination: DownloadRequest.Destination? = nil) -> Single<SWRequestResponse> {
        return Single.create { (observer) -> Disposable in
            let pair = getUserInfoAndHeadersPair(headers)
            let headers = processHeaders(url: url, headers: pair.headers)
            
            let request = AF.download(url, method: method, parameters: parameters, headers: headers, to: destination).validate().responseString { (response) in
                switch response.result {
                case .success(let jsonStr):
                    let result = SWRequestResponse(download: response,
                                                   error: nil,
                                                   result: jsonStr,
                                                   userInfo: pair.userInfo)
                    
                    successProcess(response: result)
                    observer(.success(result))
                case .failure(let error):
                    let result = SWRequestResponse(download: response,
                                                   error: error,
                                                   result: nil,
                                                   userInfo: pair.userInfo)
                    
                    failureProcess(response: result)
                    observer(.error(SWError.responseError(result.error, result.result, result.userInfo)))
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }.filterVVError()
    }
    
    static func upload2(_ url: URLConvertible,
                        method: HTTPMethod = .post,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = JSONEncoding.default,
                        headers: [String: String]? = nil,
                        multipartFormData: @escaping (MultipartFormData) -> Void) -> Single<SWRequestResponse> {
        return Single.create { (observer) -> Disposable in
            let pair = getUserInfoAndHeadersPair(headers)
            let headers = processHeaders(url: url, headers: pair.headers)
            
            let request = AF.upload(multipartFormData: multipartFormData, to: url, method: method, headers: headers).validate().responseString { (response) in
                switch response.result {
                case .success(let jsonStr):
                    let result = SWRequestResponse(response: response,
                                                   error: nil,
                                                   result: jsonStr,
                                                   userInfo: pair.userInfo)
                    
                    successProcess(response: result)
                    observer(.success(result))
                case .failure(let error):
                    let result = SWRequestResponse(response: response,
                                                   error: error,
                                                   result: nil,
                                                   userInfo: pair.userInfo)
                    
                    failureProcess(response: result)
                    observer(.error(SWError.responseError(result.error, result.result, result.userInfo)))
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }.filterVVError()
    }
}
