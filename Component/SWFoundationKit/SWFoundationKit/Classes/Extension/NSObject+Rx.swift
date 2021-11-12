//
//  NSObject+Rx.swift
//  Pods
//
//  Created by ice on 2020/5/13.
//

import Foundation
import ObjectiveC

extension NSObject {
    public func synchronizedSelf<T>(_ block: () -> T) -> T {
        objc_sync_enter(self)
        let result = block()
        objc_sync_exit(self)
        return result
    }
}

extension NSObject {
    /// 获取命名空间加类名称 eg: VVLife.UIRemoteKeyboardWindow
    public func className() -> String {
        guard let spaceName = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String else {
            print("获取命名空间失败")
            return ""
        }
        
        let name =  type(of: self).description()
        if name.contains(".") {
            return spaceName + "." + name.components(separatedBy: ".")[1]
        } else {
            return spaceName + "." + name
        }
    }
}
