//
//  SWSection.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/6/2.
//

import UIKit

open class SWSection<T>: SWBaseSection where T: SWBaseRow {
    /// 数组初始化
    public required init<S>(_ elements: S) where S: Sequence, S.Element == T {
        super.init()
        self.append(contentsOf: elements as! [SWBaseRow])
    }
    
    public required init() {
        super.init()
    }
}

open class SWBaseSection: NSObject {
    /// 标记Section的唯一标识，同一个SWForm中的section的tag一定不能相同（否则可能导致某些方法获取的section不正确）
    public var tag: String?
    
    /// SWSection所在的SWForm
    public internal(set) weak var form: SWBaseForm?
    
    /// 存储所有Row的数组
    var _allRows = [SWBaseRow]()
    /// 存储所有可见Row的数组
    var _visibleRows = [SWBaseRow]()
    /// 外部获取时，只返回可见的row数组
    public var allRows: [SWBaseRow] {
        return _visibleRows
    }
    
    /// 获取所有value
    public func values() -> [Any?] {
        return _visibleRows.filter({ $0.baseValue != nil }).map({ $0.baseValue })
    }
    
    /// 获取在form的index
    public var index: Int? { return form?.firstIndex(of: self) }
    
    // MARK:- 初始化
    /// 初始化
    public required override init() {}
    
    // MARK:- 添加/移除事件
    /// 移除section时调用的内部函数
    func willBeRemovedFromForm() {
        for row in _allRows {
            row.willBeRemovedFromForm()
        }
        self.form = nil
    }
    
    /// 添加到form时调用的内部函数
    func wasAddedTo(form: SWBaseForm) {
        self.form = form
        for row in _allRows {
            row.wasAddedTo(section: self)
        }
    }
    
    /// SWRow数组被添加会调用
    open func rowsHaveBeenAdded(_ rows: [SWBaseRow], at: Range<Int>) {
        guard
            let delegate = form?.delegate,
            let sectionIndex = form?.firstIndex(of: self)
        else {
            return
        }
        var indexPaths: [IndexPath] = []
        for i in at.startIndex ... at.endIndex {
            indexPaths.append(IndexPath(row: i, section: sectionIndex))
        }
        delegate.rowsHaveBeenAdded(rows, at: indexPaths)
    }
    
    /// 移除所有row
    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        for row in _allRows {
            row.willBeRemovedFromSection()
        }
        _allRows.removeAll()
        _visibleRows.removeAll()
    }

    /// 移除指定位置的row
    @discardableResult
    open func remove(at position: Int, updateUI: Bool = true) -> SWBaseRow? {
        fatalError("remove(at position)必须重写")
    }
    
    /// 移除指定位置的row
    open func remove(at positions: [Int]) {
        fatalError("remove(at positions)必须重写")
    }
}

// MARK:- 集合协议
extension SWBaseSection: MutableCollection,BidirectionalCollection {
    // MARK:- MutableCollectionType
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return _visibleRows.count }
    
    /// 通过下标设置/获取元素
    public subscript (position: Int) -> SWBaseRow {
        get {
            if position >= _visibleRows.count {
                assertionFailure("Section: Index out of bounds")
            }
            return _visibleRows[position]
        }
        set {
            if position > _visibleRows.count {
                assertionFailure("Section: Index out of bounds")
            }
            if position < _visibleRows.count {
                let oldRow = _visibleRows[position]
                let oldRowIndex = _allRows.firstIndex(of: oldRow)!
                // 旧的Row从Form中移除
                _allRows[oldRowIndex].willBeRemovedFromSection()
                _allRows[oldRowIndex] = newValue
            } else {
                _allRows.append(newValue)
            }
            _visibleRows[position] = newValue
            newValue.wasAddedTo(section: self)
        }
    }
    
    public subscript (range: Range<Int>) -> ArraySlice<SWBaseRow> {
        get { return _visibleRows.map { $0 }[range] }
        set { replaceSubrange(range, with: newValue) }
    }
    
    public func index(after i: Int) -> Int { return i + 1 }
    public func index(before i: Int) -> Int { return i - 1 }
}

extension SWBaseSection: RangeReplaceableCollection {
    public func insert(_ newElement: SWBaseRow, at i: Int) {
        _visibleRows.insert(newElement, at: i)
        _allRows.insert(newElement, at: indexForInsertion(at: i))
        newElement.wasAddedTo(section: self)
    }

    // MARK:- RangeReplaceableCollectionType
    public func append(_ formRow: SWBaseRow) {
        _allRows.append(formRow)
        formRow.wasAddedTo(section: self)
        if formRow.isHidden == false {
            _visibleRows.append(formRow)
        }
    }

    open func append<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == SWBaseRow {
        _allRows.append(contentsOf: newElements)
        var addedRows = [SWBaseRow]()
        for row in newElements {
            row.wasAddedTo(section: self)
            if row.isHidden == false {
                _visibleRows.append(row)
                addedRows.append(row)
            }
        }
        rowsHaveBeenAdded(addedRows, at: (_visibleRows.count - addedRows.count) ..< _visibleRows.count - 1)
    }

    public func replaceSubrange<C>(_ subRange: Range<Int>, with newElements: C) where C : Collection, C.Element == SWBaseRow {
        var rowToRemove = [SWBaseRow]()
        let lower = Swift.max(0, Swift.min(subRange.lowerBound, _visibleRows.count - 1))
        let upper = Swift.min(subRange.upperBound, _visibleRows.count)
        for i in indexForInsertion(at: lower)..<indexForInsertion(at: upper) {
            rowToRemove.append(_allRows[i])
            _allRows[i].willBeRemovedFromSection()
        }
        _allRows.removeAll { (row) -> Bool in
            return rowToRemove.contains(row)
        }
        _visibleRows.replaceSubrange(lower..<upper, with: newElements)
        _allRows.insert(contentsOf: newElements, at: indexForInsertion(at: lower))
        for row in newElements {
            row.wasAddedTo(section: self)
        }
    }

    func indexForInsertion(at index: Int) -> Int {
        guard index > 0 else {
            if let row = _visibleRows.first {
                return _allRows.firstIndex(of: row) ?? 0
            }
            return 0
        }
        guard index < _visibleRows.count else {
            return _allRows.count - 1
        }
        /// 由于隐藏行的存在，所以要找的位置是目标的上一可见行的下一行
        let row = _visibleRows[index-1]
        if let i = _allRows.firstIndex(of: row) {
            return i + 1
        }
        return _allRows.count - 1
    }
}
