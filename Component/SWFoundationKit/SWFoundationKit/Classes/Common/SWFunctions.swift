//
//  SWFunctions.swift
//  SWFoundationKit
//
//  Created by ice on 2020/6/3.
//

import Foundation

/// 在主线程执行代码块
/// - Parameter block: 代码块
public func executeMainBlock(_ block: @escaping () -> Void) {
    Thread.isMainThread ? block() : DispatchQueue.main.sync(execute: block)
}
