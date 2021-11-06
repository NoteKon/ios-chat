//
//  CollectionInlineItemType.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/18.
//

import Foundation

public protocol InlineCollectionItemType:  SWBaseInlineRowType,  SWTypedCollectionItemType {

    associatedtype InlineItem: SWCollectionItem,  SWTypedCollectionItemType

    // 首次显示内联Item之前配置这个Item
    func setupInlineRow(_ inlineRow: InlineItem)
}

extension InlineCollectionItemType where Self: SWCollectionItem, Self.Cell.Value ==  Self.InlineItem.Cell.Value {
    /// 回调
    typealias SWCollectionInlineClosure = ((InlineItem) -> Void)
    
    /// 当前行被选中后将在其下一个位置插入(展开)的item
    public var inlineItem: Self.InlineItem? { return _inlineItem as? Self.InlineItem }

    /// 展开（打开）内联行。
    public func expandInlineRow() {
        guard inlineItem == nil else {
            return
        }
        if let section = section, let form = section.form as? SWCollectionForm {
            let inline = InlineItem.init(title: nil, tag: nil)
            inline.value = value
            setupInlineRow(inline)
            if (form.inlineRowHideOptions ?? SWCollectionForm.defaultInlineRowHideOptions).contains(.AnotherInlineRowIsShown) {
                for row in  form.allRows {
                    if let inlineRow = row as?  SWBaseInlineRowType {
                        inlineRow.collapseInlineRow()
                    }
                }
            }
            if
                let callback = callbackOnExpandInlineRow  as? SWCollectionInlineClosure
            {
                    callback(inline)
            }
            if let indexPath = indexPath {
                _inlineItem = inline
                section.insert(inline, at: indexPath.row + 1)
                cell?.collectionHandler()?.rowsHaveBeenAdded([inline], at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)])
//                cell?.collectionHandler()?.makeRowVisible(inline)
            }
        }
    }

    /// 折叠（关闭）内联行
    public func collapseInlineRow() {
        if let selectedRowPath = indexPath, let inlineRow = _inlineItem as? InlineItem, let inlineRowIndex = inlineRow.indexPath {
            if
                let callback = callbackOnCollapseInlineRow as? SWCollectionInlineClosure
            {
                callback(inlineRow)
            }
            
            _inlineItem = nil
            section?.remove(at: inlineRowIndex.row)
            cell?.collectionHandler()?.rowsHaveBeenRemoved([inlineRow], at: [IndexPath(row: inlineRowIndex.row, section: selectedRowPath.section)])
        }
    }

    /// 更改内联行的状态（展开/折叠）
    public func toggleInlineRow() {
        if let _ = inlineItem {
            collapseInlineRow()
        } else {
            expandInlineRow()
        }
    }

    /// 设置扩展行时要执行的Block
    @discardableResult
    public func onExpandInlineRow(_ closure: @escaping (Cell, Self, InlineItem) -> Void) -> Self {
        let callBack: SWCollectionInlineClosure = { [weak self] (inLineItem) in
            guard
                let c = self?._cell as? Self.Cell,
                let r = self
            else {
                return
            }
            closure(c, r, inLineItem)
        }
        callbackOnExpandInlineRow = callBack
        return self
    }

    /// 设置折叠行时要执行的Block
    @discardableResult
    public func onCollapseInlineRow(_ closure: @escaping (Cell, Self, InlineItem) -> Void) -> Self {
        let callBack: SWCollectionInlineClosure = { [weak self] (inLineItem) in
            guard
                let c = self?._cell as? Self.Cell,
                let r = self
            else {
                return
            }
            closure(c, r, inLineItem)
        }
        callbackOnCollapseInlineRow = callBack
        return self
    }

    public var isExpanded: Bool { return _inlineItem != nil }
    public var isCollapsed: Bool { return !isExpanded }
}
