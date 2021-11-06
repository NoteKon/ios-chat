//
//  NSRecursiveLock+Ex.swift
//  Pods
//
//  Created by ice on 2020/4/24.
//

import Foundation

extension NSRecursiveLock {
    @inline(__always)
    public final func performLocked(_ action: () -> Void) {
        self.lock(); defer { self.unlock() }
        action()
    }

    @inline(__always)
    public final func calculateLocked<T>(_ action: () -> T) -> T {
        self.lock(); defer { self.unlock() }
        return action()
    }

    @inline(__always)
    public final func calculateLockedOrFail<T>(_ action: () throws -> T) throws -> T {
        self.lock(); defer { self.unlock() }
        let result = try action()
        return result
    }
}
