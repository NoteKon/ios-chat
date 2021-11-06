//
//  SWCollectionSection.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/15.
//

import UIKit

public enum SWCollectionError: Error {
    case duplicatedTag(tag: String)
    case rowNotInSection(row: SWCollectionItem)
}

open class SWCollectionSection: SWSection<SWCollectionItem> {
    /// 列数
    public var column: Int?
    /// 行间距
    public var lineSpace: CGFloat?
    /// 列间距
    public var itemSpace: CGFloat?
    /// 内容边距
    public var contentInset: UIEdgeInsets = .zero
    /// 内容排列方式，仅在CollectionArrangement为.blend时生效
    public var arrangement: SWBlendLayoutArrangement = .flow
    // 下面三个仅在CollectionArrangement或SWBlendLayoutArrangement为.align时生效
    /// 行高
    public var lineHeight: CGFloat?
    /// 与滚动方向垂直轴方向的排列方式
    var crossAxisAligment: SWCollectionCrossAxisAligment?
    var crossAxisDirection: SWCollectionCrossAxisDirection?
    
    // MARK:- 初始化
    required public init() {
        super.init()
    }
    
    required public init<S>(_ elements: S) where S : Sequence, S.Element == SWCollectionItem {
        super.init(elements)
    }
    /// 初始化并在完成时回调
    public init(_ initializer: (SWCollectionSection) -> Void) {
        super.init()
        initializer(self)
    }
    public init(_ header: String?,_ initializer: (SWCollectionSection) -> Void = { _ in }) {
        super.init()
        if let header = header {
            setTitleHeader(header)
        }
        initializer(self)
    }
    public init(footer: String?, _ initializer: (SWCollectionSection) -> Void = { _ in }) {
        super.init()
        if let footer = footer {
            setTitleFooter(footer)
        }
        initializer(self)
    }
    public init(header: String?, footer: String?, _ initializer: (SWCollectionSection) -> Void = { _ in }) {
        super.init()
        if let header = header {
            setTitleHeader(header)
        }
        if let footer = footer {
            setTitleFooter(footer)
        }
        initializer(self)
    }
    
    /// 设置系统样式header
    func setTitleHeader(_ title: String) {
        self.header =  SWCollectionHeaderFooterView<CollectionStringHeaderFooterView>.init({ [weak self] (view) in
            view.title = title
            guard
                let handler = self?.form?.delegate as? SWCollectionViewHandler
            else {
                return
            }
            view.scrollDirection = handler.scrollDirection
        })
        self.header?.height = { 30 }
    }
    /// 设置系统样式footer
    func setTitleFooter(_ title: String) {
        self.footer =  SWCollectionHeaderFooterView<CollectionStringHeaderFooterView>.init({ [weak self] (view) in
            view.title = title
            guard
                let handler = self?.form?.delegate as? SWCollectionViewHandler
            else {
                return
            }
            view.scrollDirection = handler.scrollDirection
        })
        self.footer?.height = { 30 }
    }
    
    // MARK:- row的隐藏与显示
    /// 隐藏Row
    func hide(row: SWCollectionItem) {
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

    /// 显示Row
    func show(row: SWCollectionItem) {
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
//        row._cell?.collectionHandler()?.makeRowVisible(row)
    }
    
    /// 移除指定row
    /// - Parameter row: row
    func remove(row: SWCollectionItem) {
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
    public var header: SWCollectionHeaderFooterViewRepresentable?

    /// section的footer
    public var footer: SWCollectionHeaderFooterViewRepresentable?
    
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

extension SWCollectionSection /* Helpers */ {
    /**
     *  插入Row到指定Row之后
     *  如果要在当前隐藏的行之后插入行，使用这个方法，否则使用 `insert(at: Int)`.
     *  如果旧行不在此section中，会抛出错误
     */
    public func insert(row newRow: SWCollectionItem, after previousRow: SWCollectionItem, updateView: Bool = true) throws {
        guard let rowIndex = _allRows.firstIndex(of: previousRow) else {
            throw SWCollectionError.rowNotInSection(row: previousRow)
        }
        _allRows.insert(newRow, at: index(after: rowIndex))
        newRow.wasAddedTo(section: self)
        guard let visibleIndex = _visibleRows.firstIndex(of: previousRow) else {
            return
        }
        _visibleRows.insert(newRow, at: index(after: visibleIndex))
        if updateView {
            show(row: newRow)
        }
    }

    /**
     *  插入Row到指定Row之前
     */
    public func insert(row newRow: SWCollectionItem, before previousRow: SWCollectionItem, updateView: Bool = true) throws {
        guard let rowIndex = _allRows.firstIndex(of: previousRow) else {
            throw SWCollectionError.rowNotInSection(row: previousRow)
        }
        _allRows.insert(newRow, at: rowIndex)
        newRow.wasAddedTo(section: self)
        guard let visibleIndex = _visibleRows.firstIndex(of: previousRow) else {
            return
        }
        _visibleRows.insert(newRow, at: visibleIndex)
        if updateView {
            show(row: newRow)
        }
    }
}

// MARK:- 可编辑的section
open class SWCollectionMultivalusedSection: SWCollectionSection {
    public var multivaluedOptions: MultivaluedOptions
    public var showInsertIconInAddButton = true
    // 创建新的row的block，触发添加时会调用
    public var multivaluedRowToInsertAt: ((Int) -> SWCollectionItem)?
    // 创建新建按钮的row的block，调用这个block来获取添加行的row
    public var addButtonProvider: ((SWCollectionMultivalusedSection) -> SWCollectionItem)?
    // item拖动结束的回调
    public var moveFinishClosure: ((_ moveItem: SWCollectionItem, _ from: IndexPath,_ to: IndexPath) -> Void)?
    
    public required init(multivaluedOptions: MultivaluedOptions = MultivaluedOptions.Insert.union(.Delete),
                         header: String? = nil,
                         footer: String? = nil,
                         _ initializer: (SWCollectionMultivalusedSection) -> Void = { _ in }) {
        self.multivaluedOptions = multivaluedOptions
        super.init(header: header, footer: footer, {section in initializer(section as! SWCollectionMultivalusedSection) })
        guard multivaluedOptions.contains(.Insert) else { return }
        initialize()
    }

    public required init() {
        self.multivaluedOptions = MultivaluedOptions.Insert.union(.Delete)
        super.init()
        initialize()
    }

    public required init<S>(_ elements: S) where S : Sequence, S.Element == SWCollectionItem {
        self.multivaluedOptions = MultivaluedOptions.Insert.union(.Delete)
        super.init(elements)
        initialize()
    }

    func initialize() {
        guard let addButtonProvider = addButtonProvider else {
            return
        }
        let addRow = addButtonProvider(self)
        addRow.callbackCellOnSelection = {
            guard
                !addRow.isDisabled,
                let cell = addRow._cell,
                let collectionView = cell.collectionHandler()?.collectionView,
                let indexPath = addRow.indexPath
            else { return }
            cell.collectionHandler()?.collectionView(collectionView, addRowAt: indexPath)
        }
        self <<< addRow
    }
}

// MARK:- 单选/多选列表section
/// SelectableSection中所有的row都需要遵循的协议
public protocol SWSelectableCollectionItemType:  SWTypedCollectionItemType {
    var selectableValue: Cell.Value? { get set }
}

/// SelectableSection实现的协议，方便定制
public protocol  SWSelectableCollectionSectionType: Collection {
    associatedtype SelectableRow: SWCollectionItem, SWSelectableCollectionItemType, SWRowType
    /// 单选还是多选
    var selectionType: SelectionType { get set }

    /// 选中某一行的回调
    var onSelectSelectableRow: ((SelectableRow.Cell, SelectableRow) -> Void)? { get set }

    /// 已选择的Row
    func selectedRow() -> SelectableRow?
    func selectedRows() -> [SelectableRow]
}

extension  SWSelectableCollectionSectionType where Self: SWCollectionSection {
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
    func prepare(selectableRows rows: [SWCollectionItem]) {
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
open class  SWSelectableCollectionSection<Row>: SWCollectionSection,  SWSelectableCollectionSectionType where Row: SWSelectableCollectionItemType, Row: SWCollectionItem, Row: SWRowType {

    public typealias SelectableRow = Row

    /// Defines how the selection works (single / multiple selection)
    public var selectionType = SelectionType.singleSelection(enableDeselection: true)

    /// A closure called when a row of this section is selected.
    public var onSelectSelectableRow: ((Row.Cell, Row) -> Void)?

    public override init(_ initializer: (SWSelectableCollectionSection<Row>) -> Void) {
        super.init({ _ in })
        initializer(self)
    }

    public init(_ header: String?, selectionType: SelectionType, _ initializer: (SWSelectableCollectionSection<Row>) -> Void = { _ in }) {
        self.selectionType = selectionType
        super.init(header, { _ in })
        initializer(self)
    }

    public init(header: String?, footer: String?, selectionType: SelectionType, _ initializer: (SWSelectableCollectionSection<Row>) -> Void = { _ in }) {
        self.selectionType = selectionType
        super.init(header: header, footer: footer, { _ in })
        initializer(self)
    }

    public required init() {
        super.init()
    }

    public required init<S>(_ elements: S) where S : Sequence, S.Element == SWCollectionItem {
        super.init(elements)
    }

    open override func rowsHaveBeenAdded(_ rows: [SWBaseRow], at: Range<Int>) {
        prepare(selectableRows: rows as! [SWCollectionItem])
        super.rowsHaveBeenAdded(rows, at: at)
    }
}
