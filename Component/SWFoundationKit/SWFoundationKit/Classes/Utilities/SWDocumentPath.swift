//
//  SWDocumentPath.swift
//  SWFoundationKit
//
//  Created by ice on 2019/8/13.
//

import UIKit

public class SWDocumentPath: NSObject {
    
    @available(*, deprecated, message: "使用`SWPath.home`代替")
    @objc public class func homePath() -> String? {
        return NSHomeDirectory()
    }
    
    @available(*, deprecated, message: "使用`SWPath.document`代替")
    @objc public class func documentPath() -> String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    }
    
    @available(*, deprecated, message: "使用`SWPath.temporary`代替")
    @objc public class func tmpPath() -> String? {
        return NSTemporaryDirectory()
    }
    
    @available(*, deprecated, message: "使用`SWPath.caches`代替")
    @objc public class func cachePath() -> String? {
        if SWAppInfo.isSimulator {
            return "/tmp"
        }
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    }
    
    @available(*, deprecated, message: "使用`SWPath.resolve(_:)`代替")
    @objc public class func homePath(withFileName fileName: String?) -> String? {
        return self.rootPath(self.homePath(), withFileName: fileName)
    }
    
    @available(*, deprecated, message: "使用`SWPath.resolve(_:)`代替")
    @objc public class func documentPath(withFileName fileName: String?) -> String? {
        return self.rootPath(self.documentPath(), withFileName: fileName)
    }
    
    @available(*, deprecated, message: "使用`SWPath.resolve(_:)`代替")
    @objc public class func tmpPath(withFileName fileName: String?) -> String? {
        return self.rootPath(self.tmpPath(), withFileName: fileName)
    }
    
    @available(*, deprecated, message: "使用`SWPath.resolve(_:)`代替")
    @objc public class func cachePath(withFileName fileName: String?) -> String? {
        return self.rootPath(self.cachePath(), withFileName: fileName)
    }
    
    @available(*, deprecated, message: "使用`SWPath.resolve(_:)`代替")
    @objc public class func rootPath(_ rootPath: String?, withFileName fileName: String?) -> String? {
        if let root = rootPath, let name = fileName {
            return root + "/" + "\(name)"
        }
        return ""
    }

}
