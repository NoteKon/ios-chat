//
//  NetMonitorManager.swift
//  VVWork
//
//  Created by ice on 2021/6/16.
//  Copyright © 2021 vv. All rights reserved.
//

import Foundation
import HandyJSON
import SWFoundationKit

// 网络抓包信息上传ELK系统
public struct NetMonitorInfo: HandyJSON {
    var versionName: String?
    var deviceName: String?
    var platform: String?
    var projectName: String?
    var userFrom: String?
    
    var apiPath: String?
    var requestTime: String?
    var responseTime: String?
    var requestMethod: String?
    var agent: String?
    var duration: Int?
    var params: Dictionary<String, Any>?
    var response: Dictionary<String, Any>?
    var responseCode: Int?
    
    public init() {}
    init(objc: SWRequestResponse? = nil) {
        versionName = SWApp.version
        deviceName = UIDevice.deviceName()
        platform = "ios"
        agent = SWNetworking.getCurrentUserAgent()
        projectName = SWApp.displayName
        
        
        userFrom = UserDefaults.standard.string(forKey: "sign_in_with_apple_email") ?? ""
        apiPath = objc?.url
        requestTime = "\(objc?.netMonitorInfo?.requestFeatchTime)"
        responseTime = "\(objc?.netMonitorInfo?.responseEndTime)"
        requestMethod = objc?.method
        responseCode = objc?.httpCode
        duration = objc?.netMonitorInfo?.durationTime
        params = objc?.requestParams
        response = objc?.result?.toDictionary()
    }
}

public class NetMonitorManager {
    public static let `default` = NetMonitorManager()
    public var monitorArr: [SWRequestResponse]? = [SWRequestResponse]()
    private static let arrayQueue = DispatchQueue(label: "array", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
    public static var logHost: String = "http://172.16.3.55:8081/log"
    
    public static func saveMonitor(objc: SWRequestResponse?) {
        removeItem(objc: objc)
        appendItem(objc: objc)
    }
    
    static func postNetLog(objc: SWRequestResponse?) {
        if SWRequestResponse.shouldMonitor == false {
            return
        }
        
        if let objc = objc {
            if let flag = objc.url?.hasPrefix(NetMonitorManager.logHost), flag {
                return
            }
            
            NetMonitorManager.saveMonitor(objc: objc)
//            let params = NetMonitorInfo.init(objc: objc).toJSON()
//            SWNetworking.postWithUrlString(NetMonitorManager.logHost,
//                                           parameters: params,
//                                           foreground: false) { (response) in
//                SWLogger.debug("ELK上传成功")
//            } failureComplete: { (response) in
//                SWLogger.debug("ELK上传失败")
//            }
        }
    }
}

extension NetMonitorManager {
    private static func appendItem(objc: SWRequestResponse?) {
        if let objc = objc {
            let workItem = DispatchWorkItem(qos: DispatchQoS.default, flags: DispatchWorkItemFlags.barrier) {
                NetMonitorManager.default.monitorArr?.append(objc)
            }
            arrayQueue.async(execute: workItem)
        }
    }
    
    public static func getAllItem() -> [SWRequestResponse]? {
        arrayQueue.sync { () -> [SWRequestResponse]? in
            return NetMonitorManager.default.monitorArr
        }
    }
    
    private static func removeItem(objc: SWRequestResponse?) {
        if objc != nil {
            let workItem = DispatchWorkItem(qos: DispatchQoS.default, flags: DispatchWorkItemFlags.barrier) {
                if NetMonitorManager.default.monitorArr?.count ?? 0 >= 50 {
                    NetMonitorManager.default.monitorArr?.removeFirst()
                }
            }
            arrayQueue.async(execute: workItem)
        }
    }
}
