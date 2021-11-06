//
//  GCD.swift
//  SWFoundationKit
//
//  Created by ice on 2020/6/5.
//

import Foundation

/// 延迟（秒）执行代码（在主线程执行）
/// - Parameters:
///   - seconds: 延迟的秒数
///   - execute: 执行的代码块
public func delay(seconds: Int, execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: execute)
}

/// 延迟（毫秒）执行代码（在主线程执行）
/// - Parameters:
///   - ms: 延迟的毫秒数
///   - task: 执行的代码块
public func delay(milliseconds ms: Int, execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(ms), execute: execute)
}

/// 异步执行代码块（先后台线程执行，再返回主线程执行）
/// - Parameters:
///   - backgroundTask: 在后台线程执行的代码块
///   - mainTask: 在主线程执行的代码块
public func async<T>(background backgroundTask: @escaping () -> T?, main mainTask: @escaping (T?) -> Void) {
    DispatchQueue.global(qos: .background).async {
        let result = backgroundTask()
        DispatchQueue.main.sync {
            mainTask(result)
        }
    }
}

/// 在主线程执行代码块
/// - Parameters:
///   - isAsync: 是否异步执行，默认为`true`
///   - execute: 在主线程执行的代码块
public func execute(isAsync: Bool = true, main execute: @escaping () -> Void) {
    if Thread.isMainThread {
        execute()
    } else if isAsync {
        DispatchQueue.main.async(execute: execute)
    } else {
        DispatchQueue.main.sync(execute: execute)
    }
}
