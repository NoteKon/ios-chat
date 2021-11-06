//
//  SWForm.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/6/2.
//

import Foundation

open class SWForm<T>: SWBaseForm where T: SWBaseSection {
}

public protocol SWFormDelegate : class {
    func sectionsHaveBeenAdded(_ sections: [SWBaseSection], at: IndexSet)
    func sectionsHaveBeenRemoved(_ sections: [SWBaseSection], at: IndexSet)
    func sectionsHaveBeenReplaced(oldSections: [SWBaseSection], newSections: [SWBaseSection], at: IndexSet)
    func rowsHaveBeenAdded(_ rows: [SWBaseRow], at: [IndexPath])
    func rowsHaveBeenRemoved(_ rows: [SWBaseRow], at: [IndexPath])
    func rowsHaveBeenReplaced(oldRows: [SWBaseRow], newRows: [SWBaseRow], at: [IndexPath])
    func valueHasBeenChanged(for row: SWBaseRow, oldValue: Any?, newValue: Any?)
}

open class SWBaseForm {
    /// form的delegate
    public weak var delegate: SWFormDelegate?
    
    /// 存储所有section的数组
    fileprivate var _allSections = [SWBaseSection]()
    /// 存储所有可见Section的数组
    fileprivate var _visibleSections = [SWBaseSection]()
    public var allSections: [SWBaseSection] {
        return _visibleSections
    }
    
    /// 获取所有可见的row
    public var allRows:[SWBaseRow] {
        return _allSections.map({ $0.allRows }).flatMap { $0 }
    }
    
    /// Tag-Row字典，用于快速查找
    var rowsByTag = [String: SWBaseRow]()
    /// 根据Tag获取Row
    public func rowBy(tag: String) -> SWBaseRow? {
        return rowsByTag[tag]
    }
    /// Tag-Value字典，用于快速查找
    var tagToValues = [String: Any]()
    /// 根据Tag获取Value
    public func valueBy(tag: String) -> Any? {
        return tagToValues[tag]
    }
    /// 当前SWForm中可见的Row
    public var rows: [SWBaseRow] { return flatMap { $0 } }
    
    // MARK:- 初始化
    /// 初始化
    public required init() {}
}

extension SWBaseForm: Collection {
    /// 根据indexPath获取Row
    public subscript(indexPath: IndexPath) -> SWBaseRow? {
        guard indexPath.underestimatedCount > 0, self.count > indexPath.section ,self[indexPath.section].count > indexPath.row else {
            return nil
        }
        return self[indexPath.section][indexPath.row]
    }
    
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return _visibleSections.count }
}

extension SWBaseForm: MutableCollection {
    // MARK: MutableCollectionType
    public subscript (_ position: Int) -> SWBaseSection {
        get { return _visibleSections[position] }
        set {
            if position > _visibleSections.count {
                assertionFailure("SWForm: Index out of bounds")
            }
            if position < _visibleSections.count {
                let oldSection = _visibleSections[position]
                let oldSectionIndex = _allSections.firstIndex(of: oldSection)!
                // form中移除旧Section
                _allSections[oldSectionIndex].willBeRemovedFromForm()
                _allSections[oldSectionIndex] = newValue
            } else {
                _allSections.append(newValue)
            }
            _visibleSections[position] = newValue
            newValue.wasAddedTo(form: self)
        }
    }
    public func index(after i: Int) -> Int {
        return i+1 <= endIndex ? i+1 : endIndex
    }
    public func index(before i: Int) -> Int {
        return i > startIndex ? i-1 : startIndex
    }
    public var last: SWBaseSection? {
        return reversed().first
    }
}

extension SWBaseForm : RangeReplaceableCollection {
    // MARK: RangeReplaceableCollectionType
    public func append(_ formSection: SWBaseSection) {
        _visibleSections.append(formSection)
        _allSections.append(formSection)
        formSection.wasAddedTo(form: self)
    }

    public func append<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == SWBaseSection {
        let firstIndex = _visibleSections.count
        _visibleSections.append(contentsOf: newElements)
        _allSections.append(contentsOf: newElements)
        var sections: [SWBaseSection] = []
        for section in newElements {
            section.wasAddedTo(form: self)
            sections.append(section)
        }
        sectionsHaveBeenAdded(sections, at: firstIndex ..< firstIndex + sections.count - 1)
    }
    
    /// SWSection数组被添加会调用
    func sectionsHaveBeenAdded(_ sections: [SWBaseSection], at: Range<Int>) {
        guard
            let delegate = self.delegate
        else {
            return
        }
        delegate.sectionsHaveBeenAdded(sections, at: IndexSet(integersIn: at.startIndex ... at.endIndex))
    }

    public func replaceSubrange<C: Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == SWBaseSection {
        let lower = Swift.max(0, Swift.min(subRange.lowerBound, _visibleSections.count - 1))
        let upper = Swift.min(subRange.upperBound, _visibleSections.count)
        var sectionToRemove = [SWBaseSection]()
        for i in indexForInsertion(at: lower)..<indexForInsertion(at: upper) {
            sectionToRemove.append(_allSections[i])
            _allSections[i].willBeRemovedFromForm()
        }
        _allSections.removeAll { (section) -> Bool in
            return sectionToRemove.contains(section)
        }
        _visibleSections.replaceSubrange(lower..<upper, with: newElements)
        _allSections.insert(contentsOf: newElements, at: indexForInsertion(at: lower))
        for section in newElements {
            section.wasAddedTo(form: self)
        }
    }

    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        for section in _allSections {
            section.willBeRemovedFromForm()
        }
        _allSections.removeAll()
        _visibleSections.removeAll()
    }

    private func indexForInsertion(at index: Int) -> Int {
        guard index != 0 else {
            if let row = _visibleSections.first {
                return _allSections.firstIndex(of: row) ?? 0
            }
            return 0
        }
        guard index < _visibleSections.count else {
            return _allSections.count - 1
        }
        let section = _visibleSections[index - 1]
        if let i = _allSections.firstIndex(of: section) {
            return i + 1
        }
        return _allSections.count - 1
    }

}

extension SWBaseForm {

    // MARK: Private Helpers
    func nextRow(for row: SWBaseRow) -> SWBaseRow? {
        let allRows = rows
        guard let index = allRows.firstIndex(of: row) else { return nil }
        guard index < allRows.count - 1 else { return nil }
        return allRows[index + 1]
    }

    func previousRow(for row: SWBaseRow) -> SWBaseRow? {
        let allRows = rows
        guard let index = allRows.firstIndex(of: row) else { return nil }
        guard index > 0 else { return nil }
        return allRows[index - 1]
    }
    
    /// 隐藏指定section
    /// - Parameter section: section
    public func hide(_ section: SWBaseSection) {
        guard let visibleIndex = _visibleSections.firstIndex(of: section) else {
            return
        }
        _visibleSections.remove(at: visibleIndex)
        delegate?.sectionsHaveBeenRemoved([section], at: [visibleIndex])
    }

    /// 显示指定section
    /// - Parameter section: section
    public func show(_ section: SWBaseSection) {
        guard !_visibleSections.contains(section) else { return }
        guard var index = _allSections.firstIndex(of: section) else { return }
        var formIndex = NSNotFound
        while formIndex == NSNotFound && index > 0 {
            index = index - 1
            let previous = _allSections[index]
            formIndex = _visibleSections.firstIndex(of: previous) ?? NSNotFound
        }
        let sectionIndex = formIndex == NSNotFound ? 0 : formIndex + 1
        _visibleSections.insert(section, at: sectionIndex)
        delegate?.sectionsHaveBeenAdded([section], at: [sectionIndex])
    }
    
    /// 移除指定section
    /// - Parameter section: section
    public func remove(_ section: SWBaseSection) {
        guard let allIndex = _allSections.firstIndex(of: section) else{
            return
        }
        _allSections.remove(at: allIndex)
        guard let visibleIndex = _visibleSections.firstIndex(of: section) else {
            return
        }
        _visibleSections.remove(at: visibleIndex)
        delegate?.sectionsHaveBeenRemoved([section], at: [visibleIndex])
        section.willBeRemovedFromForm()
    }

    func getValues(for rows: [SWBaseRow]) -> [String: Any?] {
        return rows.reduce([String: Any?]()) {
            var result = $0
            result[$1.tag!] = $1.baseValue
            return result
        }
    }

    func getValues(for sections: [SWBaseSection]?) -> [String: [Any?]] {
        return sections?.reduce([String: [Any?]]()) {
            var result = $0
            result[$1.tag!] = $1.values()
            return result
            } ?? [:]
    }

}
