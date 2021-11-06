//
//  SWTableCell.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/6/2.
//

import Foundation
import UIKit

open class SWTableCellOf<T>: SWTableCell, SWTypedTableCellType where T: Equatable {
    // cell 关联的 SWRow
    public var row: SWTableBaseRowOf<T>?
    
    public typealias Value = T

    public var value: T? {
        guard let v = row?.value else {
            return nil
        }
        return v
    }

    /// 用来展示此行值的转换方法
    public var displayValueFor: ((T?) -> String?)? = {
        return $0.map { String(describing: $0) }
    }
    
    /// 获取SWTableViewHandler
    override func tableHandler() -> SWTableViewHandler? {
        guard let handler = row?.section?.form?.delegate as? SWTableViewHandler else {
            return nil
        }
        return handler
    }
    
    /// 获取tableview
    public var tableView: UITableView? {
        return tableHandler()?.tableView
    }
    
    /// 更新cell的高度
    public func updateHeight(_ newHeight: CGFloat, animation: Bool = true) {
        row?.cellHeight = newHeight
        if animation {
            tableView?.beginUpdates()
            self.layoutIfNeeded()
            tableView?.endUpdates()
        } else {
            UIView.performWithoutAnimation {
                tableView?.beginUpdates()
                self.layoutIfNeeded()
                tableView?.endUpdates()
            }
        }
    }

    open override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            tableHandler()?.beginEditing(of: self)
        }
        return result
    }
    
    open override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            tableHandler()?.endEditing(of: self)
        }
        return result
    }
}

open class SWTableCell: UITableViewCell {
    
    // Block方式返回高度（可以在Block中根据情况动态计算高度）
    public var cellHeight: (() -> CGFloat)?
    
    // 获取所在的SWTableViewHandler
    func tableHandler() -> SWTableViewHandler? {
        return nil
    }
    
    // MARK:- 事件
    // 是否已经setUp
    public var isSetup: Bool = false
    
    /** setUp, 子类中重写进行布局和一些永久性的配置, 建议使用如下方式调用：
    open override func setup() {
        super.setup()
        // ...
    }
    */
    open func setup() {
        isSetup = true
        clipsToBounds = true
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    // 刷新cell
    open func update() {
    }
    
    // cell 选中时调用，子类中可重写该方法做改变样式等操作
    open func didSelect() {}
    
    // MARK:- Responder
    // 是否可以成为第一响应者
    open func cellCanBecomeFirstResponder() -> Bool {
        return canBecomeFocused
    }
    
    // 成为第一响应者
    @discardableResult
    open func cellBecomeFirstResponder(withDirection: Direction = .down) -> Bool {
        return becomeFirstResponder()
    }
    
    // 取消第一响应者
    @discardableResult
    open func cellResignFirstResponder() -> Bool {
        return resignFirstResponder()
    }
    
    // MARK:- Init
    public required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


public protocol SWTypedTableCellType: class {

    associatedtype Value: Equatable

    /// 关联的Row
    var row: SWTableBaseRowOf<Value>? { get set }
}

public extension SWScrollObserverCellType where Self: UITableViewCell {
    /// 所在的Scrollview是否正在滚动
    func isScrolling() -> Bool {
        var superView = superview
        while superView != nil {
            if let tableView = superView as? UITableView {
                if let handler = tableView.delegate as? SWTableViewHandler {
                    return handler.isScrolling
                }
                return false
            }
            superView = superView?.superview
        }
        return false
    }
}
