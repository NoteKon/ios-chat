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
