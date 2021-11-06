//
//  SWAtomicInt.swift
//  Pods
//
//  Created by ice on 2020/4/16.
//

import class Foundation.NSLock

public final class SWAtomicInt: NSLock {
    fileprivate var value: Int32
    public init(_ value: Int32 = 0) {
        self.value = value
    }
}

@discardableResult
@inline(__always)
public func add(_ this: SWAtomicInt, _ value: Int32) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.value += value
    this.unlock()
    return oldValue
}

@discardableResult
@inline(__always)
public func sub(_ this: SWAtomicInt, _ value: Int32) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.value -= value
    this.unlock()
    return oldValue
}

@discardableResult
@inline(__always)
public func fetchOr(_ this: SWAtomicInt, _ mask: Int32) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.value |= mask
    this.unlock()
    return oldValue
}

@discardableResult
@inline(__always)
public func fetchAnd(_ this: SWAtomicInt, _ mask: Int32) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.value &= mask
    this.unlock()
    return oldValue
}

@inline(__always)
public func load(_ this: SWAtomicInt) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.unlock()
    return oldValue
}

@discardableResult
@inline(__always)
public func increment(_ this: SWAtomicInt) -> Int32 {
    return add(this, 1)
}

@discardableResult
@inline(__always)
public func decrement(_ this: SWAtomicInt) -> Int32 {
    return sub(this, 1)
}

@inline(__always)
public func isFlagSet(_ this: SWAtomicInt, _ mask: Int32) -> Bool {
    return (load(this) & mask) != 0
}
