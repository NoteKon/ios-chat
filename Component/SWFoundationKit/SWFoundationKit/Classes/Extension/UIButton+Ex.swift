//
//  UIButton+Ex.swift
//  SWFoundationKit
//
//  Created by ice on 2021/10/16.
//

import Foundation
public typealias ActionBlock = ((UIButton)->Void)

public extension UIButton {
    private struct AssociatedKeys {
        static var ActionBlock = "ActionBlock"
        static var ActionDelay = "ActionDelay"
    }
    
    /// 运行时关联
    var actionBlock: ActionBlock? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ActionBlock, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ActionBlock) as? ActionBlock
        }
    }
    
    var actionDelay: TimeInterval {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ActionDelay, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ActionDelay) as? TimeInterval ?? 0
        }
    }
    
    /// 点击回调
    @objc private func btnDelayClick(_ button: UIButton) {
        actionBlock?(button)
        isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + actionDelay) { [weak self] in
            print("恢复时间\(Date())")
            self?.isEnabled = true
        }
    }
    
    /// 添加点击事件
    func addAction(_ delay: TimeInterval = 0, action: @escaping ActionBlock) {
        addTarget(self, action: #selector(btnDelayClick(_:)) , for: .touchUpInside)
        actionDelay = delay
        actionBlock = action
    }
}
