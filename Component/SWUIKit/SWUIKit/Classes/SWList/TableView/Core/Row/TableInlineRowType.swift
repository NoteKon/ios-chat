//
//  TableInlineRowType.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/7.
//

// MARK:- 内联Row相关协议
import Foundation

// 每个内联Row类型都必须遵守的协议
public protocol  SWInlineTableRowType:  SWBaseInlineRowType, SWTypedTableRowType {

    associatedtype InlineRow: SWTableRow, SWTypedTableRowType

    // 首次显示内联Row之前配置这个Row
    func setupInlineRow(_ inlineRow: InlineRow)
}

extension  SWInlineTableRowType where Self: SWTableRow, Self.Cell.Value ==  Self.InlineRow.Cell.Value {
    /// 回调
    typealias SWTableInlineClosure = ((InlineRow) -> Void)

    /// 当前行被选中后将在其下方插入(展开)的行
    public var inlineRow: Self.InlineRow? { return _inlineRow as? Self.InlineRow }

    /// 展开（打开）内联行。
    public func expandInlineRow() {
        guard inlineRow == nil else {
            return
        }
        if let section = section, let form = section.form as? SWTableForm {
            let inline = InlineRow.init(title: nil, tag: nil)
            inline.value = value
            setupInlineRow(inline)
            let options = form.inlineRowHideOptions ?? SWTableForm.defaultInlineRowHideOptions
            if options.contains(.AnotherInlineRowIsShown) {
                for row in form.allRows {
                    if let inlineRow = row as?  SWBaseInlineRowType {
                        inlineRow.collapseInlineRow()
                    }
                }
            }
            if let block = callbackOnExpandInlineRow as? SWTableInlineClosure {
                block(inline)
            }
            if let indexPath = indexPath {
                _inlineRow = inline
                section.insert(inline, at: indexPath.row + 1)
                cell?.tableHandler()?.rowsHaveBeenAdded([inline], at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)])
                cell?.tableHandler()?.makeRowVisible(inline, destinationScrollPosition: destinationScrollPosition)
            }
        }
    }

    /// 折叠（关闭）内联行
    public func collapseInlineRow() {
        if let selectedRowPath = indexPath, let inlineRow = _inlineRow as? InlineRow {
            if let block = callbackOnCollapseInlineRow as? SWTableInlineClosure {
                block(inlineRow)
            }
            _inlineRow = nil
            section?.remove(at: selectedRowPath.row + 1)
            cell?.tableHandler()?.rowsHaveBeenRemoved([inlineRow], at: [IndexPath(row: selectedRowPath.row + 1, section: selectedRowPath.section)])
        }
    }

    /// 更改内联行的状态（展开/折叠）
    public func toggleInlineRow() {
        if let _ = inlineRow {
            collapseInlineRow()
        } else {
            expandInlineRow()
        }
    }

    /// 设置扩展行时要执行的Block
    @discardableResult
    public func onExpandInlineRow(_ closure: @escaping (Self.Cell, Self, InlineRow) -> Void) -> Self {
        let callBack: SWTableInlineClosure = { [weak self] (inLineRow) in
            guard
                let c = self?._cell as? Self.Cell,
                let r = self
            else {
                return
            }
            closure(c, r, inLineRow)
        }
        callbackOnExpandInlineRow = callBack
        return self
    }

    /// 设置折叠行时要执行的Block
    @discardableResult
    public func onCollapseInlineRow(_ closure: @escaping (Self.Cell, Self, InlineRow) -> Void) -> Self {
        let callBack: SWTableInlineClosure = { [weak self] (inLineRow) in
            guard
                let c = self?._cell as? Self.Cell,
                let r = self
            else {
                return
            }
            closure(c, r, inLineRow)
        }
        callbackOnCollapseInlineRow = callBack
        return self
    }

    public var isExpanded: Bool { return _inlineRow != nil }
    public var isCollapsed: Bool { return !isExpanded }
}
