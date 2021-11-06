//
//  GZCTableViewSection.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/3.
//

import Foundation

open class SWTableSection: SWSection<SWTableRow> {
    
    // MARK:- 初始化
    required public init() {
        super.init()
    }
    
    required public init<S>(_ elements: S) where S : Sequence, S.Element == SWTableRow {
        super.init(elements)
    }
    /// 初始化并在完成时回调
    public init(_ initializer: ( SWTableSection) -> Void) {
        super.init()
        initializer(self)
    }
    public init(_ header: String?,_ initializer: ( SWTableSection) -> Void = { _ in }) {
        super.init()
        if let header = header {
            self.header = TableHeaderFooterView(stringLiteral: header)
        }
        initializer(self)
    }
    public init(footer: String?, _ initializer: ( SWTableSection) -> Void = { _ in }) {
        super.init()
        if let footer = footer {
            self.footer = TableHeaderFooterView(stringLiteral: footer)
        }
        initializer(self)
    }
    public init(header: String?, footer: String?, _ initializer: ( SWTableSection) -> Void = { _ in }) {
        super.init()
        if let header = header {
            self.header = TableHeaderFooterView(stringLiteral: header)
        }
        if let footer = footer {
            self.footer = TableHeaderFooterView(stringLiteral: footer)
        }
        initializer(self)
    }
    
    // MARK:- row的隐藏与显示
    /// 隐藏指定row
    /// - Parameter row: row
    func hide(row: SWTableRow) {
        row._cell?.cellResignFirstResponder()
        (row as?  SWBaseInlineRowType)?.collapseInlineRow()
        guard let rowIndex = _visibleRows.firstIndex(of: row) else {
            return
        }
        _visibleRows.remove(at: rowIndex)
        guard
            let delegate = form?.delegate,
            let sectionIndex = form?.firstIndex(of: self)
        else {
            return
        }
        delegate.rowsHaveBeenRemoved([row], at: [IndexPath(row: rowIndex, section: sectionIndex)])
    }

    /// 显示指定row
    /// - Parameter row: row
    func show(row: SWTableRow) {
        guard !_visibleRows.contains(row) else { return }
        guard var index = _allRows.firstIndex(of: row) else { return }
        var formIndex = NSNotFound
        while formIndex == NSNotFound && index > 0 {
            index = index - 1
            let previous = _allRows[index]
            formIndex = _visibleRows.firstIndex(of: previous) ?? NSNotFound
        }
        let rowIndex = formIndex == NSNotFound ? 0 : formIndex + 1
        _visibleRows.insert(row, at: rowIndex)
        guard
            let delegate = form?.delegate,
            let sectionIndex = form?.firstIndex(of: self)
        else {
            return
        }
        delegate.rowsHaveBeenAdded([row], at: [IndexPath(row: rowIndex, section: sectionIndex)])
        row._cell?.tableHandler()?.makeRowVisible(row)
    }
    
    /// 移除指定row
    /// - Parameter row: row
    func remove(row: SWTableRow) {
        if let visibleIndex = _visibleRows.firstIndex(of: row) {
            _visibleRows.remove(at: visibleIndex)
            guard
                let delegate = form?.delegate,
                let sectionIndex = form?.firstIndex(of: self)
            else {
                return
            }
            delegate.rowsHaveBeenRemoved([row], at: [IndexPath(row: visibleIndex, section: sectionIndex)])
        }
        if let allIndex = _allRows.firstIndex(of: row) {
            _allRows.remove(at: allIndex)
            row.willBeRemovedFromSection()
        }
    }

    /// 移除指定位置的row
    @discardableResult
    public override func remove(at position: Int, updateUI: Bool = true) -> SWBaseRow? {
        let allIndex = indexForInsertion(at: position)
        guard _allRows.count > allIndex else {
            return nil
        }
        _allRows.remove(at: indexForInsertion(at: position))
        let row = _visibleRows[position]
        row.willBeRemovedFromSection()
        _visibleRows.remove(at: position)
        guard
            updateUI,
            let delegate = form?.delegate,
            let sectionIndex = form?.firstIndex(of: self)
        else {
            return row
        }
        delegate.rowsHaveBeenRemoved([row], at: [IndexPath(row: position, section: sectionIndex)])
        return row
    }
    
    /// 移除指定位置数组的row
    public override func remove(at positions: [Int]) {
        var rowShouldRemove = [SWBaseRow]()
        var indexShouldRemove = [Int]()
        for position in positions {
            if _visibleRows.count > position {
                let row = _visibleRows[position]
                row.willBeRemovedFromSection()
                rowShouldRemove.append(row)
                indexShouldRemove.append(position)
            }
        }
        _allRows.removeAll { (r) -> Bool in
            rowShouldRemove.contains(r)
        }
        _visibleRows.removeAll { (r) -> Bool in
            rowShouldRemove.contains(r)
        }
        guard
            let delegate = form?.delegate,
            let sectionIndex = form?.firstIndex(of: self),
            rowShouldRemove.count > 0
        else {
            return
        }
        let indexPaths = indexShouldRemove.map { (index) -> IndexPath in
            return IndexPath(row: index, section: sectionIndex)
        }
        delegate.rowsHaveBeenRemoved(rowShouldRemove, at: indexPaths)
    }
    
    // MARK:- header 和 footer
    /// section的header
    public var header: TableHeaderFooterViewRepresentable? {
        willSet {
            headerView = nil
        }
    }
    public var headerView: UIView?

    /// section的footer
    public var footer: TableHeaderFooterViewRepresentable? {
        willSet {
            footerView = nil
        }
    }
    public var footerView: UIView?
    
    // 刷新UI
    public func reload(animation: Bool = false) {
        guard
            let delegate = form?.delegate,
            let sectionIndex = form?.firstIndex(of: self)
        else {
            return
        }
        if !animation {
            UIView.performWithoutAnimation {
                delegate.sectionsHaveBeenReplaced(oldSections: [self], newSections: [self], at: IndexSet(integer: sectionIndex))
            }
        } else {
            delegate.sectionsHaveBeenReplaced(oldSections: [self], newSections: [self], at: IndexSet(integer: sectionIndex))
        }
    }
}

// MARK:- 可编辑的section
open class TableMultivalusedSection: SWTableSection {
    // 编辑模式
    public var multivaluedOptions: MultivaluedOptions
    // 是否添加+号到AddRow
    public var showInsertIconInAddButton = false
    // 创建新的row的block，触发添加时会调用
    public var multivaluedRowToInsertAt: ((Int) -> SWTableRow)?
    // 创建新建按钮的row的block，调用这个block来获取添加行的row
    public var addButtonProvider: ((TableMultivalusedSection) -> SWTableRow)?
    // row拖动结束的回调
    public var moveFinishClosure: ((_ moveRow: SWTableRow, _ from: IndexPath,_ to: IndexPath) -> Void)?
    
    public required init(multivaluedOptions: MultivaluedOptions = MultivaluedOptions.Insert.union(.Delete),
                         header: String? = nil,
                         footer: String? = nil,
                         _ initializer: (TableMultivalusedSection) -> Void = { _ in }) {
        self.multivaluedOptions = multivaluedOptions
        super.init(header: header, footer: footer, {section in initializer(section as! TableMultivalusedSection) })
        guard multivaluedOptions.contains(.Insert) else { return }
        initialize()
    }

    public required init() {
        self.multivaluedOptions = MultivaluedOptions.Insert.union(.Delete)
        super.init()
        initialize()
    }

    public required init<S>(_ elements: S) where S : Sequence, S.Element == SWTableRow {
        self.multivaluedOptions = MultivaluedOptions.Insert.union(.Delete)
        super.init(elements)
        initialize()
    }

    func initialize() {
        guard let provider = addButtonProvider else {
            return
        }
        let addRow = provider(self)
        addRow.callbackCellOnSelection = { [weak addRow] in
            guard
                !(addRow?.isDisabled ?? true),
                let cell = addRow?._cell,
                let tableView = cell.tableHandler()?.tableView,
                let indexPath = addRow?.indexPath
            else { return }
            cell.tableHandler()?.tableView(tableView, commit: .insert, forRowAt: indexPath)
        }
        self <<< addRow
    }
}

// MARK:- 单选/多选列表section
/// SelectableSection中所有的row都需要遵循的协议
public protocol SelectableTableRowType: SWTypedTableRowType {
    var selectableValue: Cell.Value? { get set }
}

/// SelectableSection实现的协议，方便定制
public protocol SelectableTableSectionType: Collection {
    associatedtype SelectableRow: SWTableRow, SelectableTableRowType, SWRowType
    /// 单选还是多选
    var selectionType: SelectionType { get set }

    /// 选中某一行的回调
    var onSelectSelectableRow: ((SelectableRow.Cell, SelectableRow) -> Void)? { get set }

    /// 已选择的Row
    func selectedRow() -> SelectableRow?
    func selectedRows() -> [SelectableRow]
}

extension SelectableTableSectionType where Self: SWTableSection {
    /// 获取单选的选中Row（SingleSelection使用）
    public func selectedRow() -> SelectableRow? {
        return selectedRows().first
    }

    /// 获取多选的所有选中Row（multipleSelection使用）
    public func selectedRows() -> [SelectableRow] {
        var findRows: [SelectableRow] = []
        for row in self._visibleRows {
            if let r = row as? SelectableRow,
               r.value != nil {
                findRows.append(r)
            }
        }
        return findRows
    }

    /// SWRows添加到section之前调用的函数
    func prepare(selectableRows rows: [SWTableRow]) {
        for row in rows {
            if let sRow = row as? SelectableRow {
                sRow.onCellSelection { [weak self] cell, row in
                    guard let s = self, !row.isDisabled else { return }
                    switch s.selectionType {
                        case .multipleSelection:
                            sRow.value = sRow.value == nil ? sRow.selectableValue : nil
                        case let .singleSelection(enableDeselection):
                            for r in s._visibleRows {
                                guard
                                    let selectableRow = r as? SelectableRow,
                                    selectableRow.value != nil,
                                    selectableRow != row
                                else { return }
                                r.baseValue = nil
                                r.updateCell()
                            }
                            // 检查是否已选中
                            if sRow.value == nil {
                                sRow.value = sRow.selectableValue
                            } else if enableDeselection {
                                sRow.value = nil
                        }
                    }
                    sRow.updateCell()
                    s.onSelectSelectableRow?(cell as! Self.SelectableRow.Cell, sRow)
                }
            }
        }
    }

}

/// A subclass of SWSection that serves to create a section with a list of selectable options.
open class SelectableTableSection<Row>: SWTableSection, SelectableTableSectionType where Row: SelectableTableRowType, Row: SWTableRow, Row: SWRowType {

    public typealias SelectableRow = Row

    /// Defines how the selection works (single / multiple selection)
    public var selectionType = SelectionType.singleSelection(enableDeselection: true)

    /// A closure called when a row of this section is selected.
    public var onSelectSelectableRow: ((Row.Cell, Row) -> Void)?

    public override init(_ initializer: (SelectableTableSection<Row>) -> Void) {
        super.init({ _ in })
        initializer(self)
    }

    public init(_ header: String?, selectionType: SelectionType, _ initializer: (SelectableTableSection<Row>) -> Void = { _ in }) {
        self.selectionType = selectionType
        super.init(header, { _ in })
        initializer(self)
    }

    public init(header: String?, footer: String?, selectionType: SelectionType, _ initializer: (SelectableTableSection<Row>) -> Void = { _ in }) {
        self.selectionType = selectionType
        super.init(header: header, footer: footer, { _ in })
        initializer(self)
    }

    public required init() {
        super.init()
    }

    public required init<S>(_ elements: S) where S : Sequence, S.Element == SWTableRow {
        super.init(elements)
    }

    open override func rowsHaveBeenAdded(_ rows: [SWBaseRow], at: Range<Int>) {
        prepare(selectableRows: rows as! [SWTableRow])
        super.rowsHaveBeenAdded(rows, at: at)
    }
}
