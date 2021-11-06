//
//  ViewController.swift
//  SWFoundationKit
//
//  Created by 郭忠橙 on 02/03/2021.
//  Copyright (c) 2021 郭忠橙. All rights reserved.
//

import UIKit
import SWFoundationKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SWLogger.debug("999")
        
        if IS_IPHONE_4_0 {
            SWLogger.debug("IS_IPHONE_4_0")
        } else if IS_IPHONE_4_0 {
            SWLogger.debug("IS_IPHONE_4_0")
        } else if IS_IPHONE_4_7 {
            SWLogger.debug("IS_IPHONE_4_7")
        } else if IS_IPHONE_5_5 {
            SWLogger.debug("IS_IPHONE_5_5")
        } else if IS_IPHONE_X {
            SWLogger.debug("IS_IPHONE_X")
        } else if IS_IPHONE_XR {
            SWLogger.debug("IS_IPHONE_XR")
        } else if IS_IPHONE_XSMAX {
            SWLogger.debug("IS_IPHONE_XSMAX")
        }
        
        if IS_IPHONE_XSERIES {
            SWLogger.debug("IS_IPHONE_XSERIES")
        }
        
        self.testKeyChain()
        
        self.testAppInfo()
        
        self.testDocumentPath()
        
        self.testDevice()
        
        self.testString()
        
        self.testSWError()
    }
    
    func testKeyChain() {
//        let uuid = SWKeyChain.getUUID(key:"123")
//        print("uuid = \(uuid)")
//
//        SWKeyChain.saveValue(value: "90909099", key: "456")
//        if let value = SWKeyChain.getValue(key: "456") {
//            print("value =  \(value)")
//        }
    }
    
    func testAppInfo() {
        print("appDisplayName: \(SWAppInfo.appDisplayName)")
        print("bundleName: \(SWAppInfo.bundleName)")
        print("appVersion: \(SWAppInfo.appVersion)")
        print("appBuild: \(SWAppInfo.appBuild)")
        print("appBundleID: \(SWAppInfo.appBundleID)")
    }

    func testDocumentPath() {
        let homepath = SWDocumentPath.homePath()
        let fileHomepath = SWDocumentPath.homePath(withFileName: "test")
        let cachePath = SWDocumentPath.cachePath()
        let fileCachepath = SWDocumentPath.cachePath(withFileName: "test")
        let documentPath = SWDocumentPath.documentPath()
        let fileDocumentPath = SWDocumentPath.documentPath(withFileName: "test")
        let tmpPath = SWDocumentPath.tmpPath()
        let fileTmpPath = SWDocumentPath.tmpPath(withFileName: "test")
        
        print("homePath: \(String(describing: homepath))")
        print("fileHomepath: \(String(describing: fileHomepath))")
        print("cachePath: \(String(describing: cachePath))")
        print("fileCachepath: \(String(describing: fileCachepath))")
        print("documentPath: \(String(describing: documentPath))")
        print("fileDocumentPath: \(String(describing: fileDocumentPath))")
        print("tmpPath: \(String(describing: tmpPath))")
        print("fileTmpPath: \(String(describing: fileTmpPath))")
    }
    
    func testDevice() {
        print("systemName: \(String(describing: UIDevice.systemName()))")
        print("systemVersion: \(String(describing: UIDevice.systemVersion()))")
        print("systemFloatVersion: \(String(describing: UIDevice.systemFloatVersion()))")
        print("deviceName: \(String(describing: UIDevice.deviceName()))")
        print("deviceLanguage: \(String(describing: UIDevice.deviceLanguage()))")
        print("isPhone: \(String(describing: UIDevice.isPhone()))")
        print("isPad: \(String(describing: UIDevice.isPad()))")
        print("idfa: \(String(describing: UIDevice.idfa()))")
        print("idfv: \(String(describing: UIDevice.idfv()))")
        print("totalDiskSpace: \(String(describing: UIDevice.totalDiskSpace()))")
        print("totalDiskSpace: \(String(describing: UIDevice.totalDiskSpace()))")
        print("freeDiskSpace: \(String(describing: UIDevice.freeDiskSpace()))")
    }
    
    func testString() {
        let str = "Hello world"
        
        print(str.md5())
        print(str.sha1())
        
        print("yang@vv.cn".isEmail())
        print("yangvv.cn".isEmail())
        
        print("  ya  ng  ".deleteHeadAndTailWhiteSpace() ?? "")
        print(String.compareVersion("1.0.0", "0.0.9"))
        print(String.compareVersion("1.0.0", "1.0.0"))
        print(String.compareVersion("1.0.0", "1.0.9"))
    }
    
    func testSWError() {
//        let err = SWError.customError(100, "Error Message!!!")
//        if let str = err.localizedDescription {
//              print("\(str)")
//        }
    }
}

