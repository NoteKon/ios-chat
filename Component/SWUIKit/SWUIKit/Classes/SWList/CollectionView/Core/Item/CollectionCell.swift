//
//  SWCollectionCell.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/15.
//

import Foundation
import UIKit

open class SWCollectionCellOf<T>: SWCollectionCell,  SWTypedCollectionCellType where T: Equatable {
    // cell 关联的 SWRow
    public var row:  SWCollectionBaseItemOf<T>?
    
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
    
    /// 获取collectionHandler
    override func collectionHandler() -> SWCollectionViewHandler? {
        guard let handler = row?.section?.form?.delegate as? SWCollectionViewHandler else {
            return nil
        }
        return handler
    }
}

open class SWCollectionCell: UICollectionViewCell {
    
    // Block方式返回高度/宽度（可以在Block中根据情况动态计算高度/宽度）
    public var cellHeightOrWidth: ((_ anOther: CGFloat,_ scrollDirection: UICollectionView.ScrollDirection) -> CGFloat)?
    
    // 获取所在的collectionHandler
    func collectionHandler() -> SWCollectionViewHandler? {
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
    }
    
    // 刷新cell
    open func update() {}
    
    // cell 选中时调用，子类中可重写该方法做改变样式等操作
    open func didSelect() {}
    
    // MARK:- Responder
    // 是否可以成为第一响应者
    open func cellCanBecomeFirstResponder() -> Bool {
        return false
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
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


public protocol  SWTypedCollectionCellType: class {

    associatedtype Value: Equatable

    /// 关联的Row
    var row:  SWCollectionBaseItemOf<Value>? { get set }
}

public extension SWScrollObserverCellType where Self: UICollectionViewCell {
    /// 所在的Scrollview是否正在滚动
    func isScrolling() -> Bool {
        var superView = superview
        while superView != nil {
            if let collectionView = superView as? UICollectionView {
                if let handler = collectionView.delegate as? SWCollectionViewHandler {
                    return handler.isScrolling
                }
                return false
            }
            superView = superView?.superview
        }
        return false
    }
}
