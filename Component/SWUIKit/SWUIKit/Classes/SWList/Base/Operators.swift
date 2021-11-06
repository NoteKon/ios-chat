//
//  Operators.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/6/2.
//

// MARK:- 自定义运算符
/// 定义优先级组
precedencegroup SWFormPrecedence {
    associativity: left                      // 结合方向:left, right or none
    higherThan: LogicalConjunctionPrecedence // 优先级,比&&运算高
//    assignment: false                   // true=赋值运算符,false=非赋值运算符
}

precedencegroup  SWSectionPrecedence {
    associativity: left             // 结合方向:left
    higherThan: SWFormPrecedence      // 优先级,比SWForm高
}

// MARK:- 声明操作符
// 增加
/// +++  返回结果为 SWForm
infix operator +++ : SWFormPrecedence
/// +++! 返回结果为 SWForm，并通知代理
infix operator +++! : SWFormPrecedence
/// <<< 返回结果为 SWSection
infix operator <<< :  SWSectionPrecedence
/// <<< 返回结果为 SWSection，并通知代理
infix operator <<<! :  SWSectionPrecedence

// 替换
/// >>> 替换 元素 并通知代理
infix operator >>> : SWFormPrecedence

// 移除
/// ---- 移除所有元素并通知代理
postfix operator ---

// MARK:- ---
/**
 移除SWForm的所有元素, 并通知到代理

- parameter right: SWForm

- returns: SWForm
*/
@discardableResult
public postfix func ---(right: SWBaseForm) -> SWBaseForm {
    let sections = right.allSections
    right.removeAll()
    if let delegate = right.delegate {
        delegate.sectionsHaveBeenRemoved(sections, at: IndexSet(integersIn: 0 ..< sections.count))
    }
    return right
}
/**
 移除Section的所有元素, 并通知到代理

- parameter right: SWForm

- returns: SWForm
*/
@discardableResult
public postfix func ---(right: SWBaseSection) -> SWBaseSection {
    let rows = right.allRows
    right.removeAll()
    if
        let form = right.form,
        let delegate = form.delegate
    {
        guard let section = form.allSections.firstIndex(of: right) else { return right }
        var indexPaths = [IndexPath]()
        for i in 0 ..< rows.count {
            indexPaths.append(IndexPath(row: i, section: section))
        }
        delegate.rowsHaveBeenRemoved(rows, at: indexPaths)
    }
    return right
}

// MARK:- +=
/**
 添加 元素 到 数组
 
 - parameter lhs: 数组
 - parameter rhs: 新的元素
 */
public func += <C: Any>(lhs: inout Array<C>, rhs: C) {
    lhs.append(rhs)
}

/**
 添加 SWRow 的集合到 SWSection
 
 - parameter lhs: section
 - parameter rhs: rows 的集合
 */
public func += <C: Collection>(lhs: inout SWBaseSection, rhs: C) where C.Iterator.Element == SWBaseRow {
    lhs.append(contentsOf: rhs)
}

/**
 添加 SWSection 的集合到 SWForm
 
 - parameter lhs: form
 - parameter rhs: sections 的集合
 */
public func += <C: Collection>(lhs: inout SWBaseForm, rhs: C) where C.Iterator.Element == SWBaseSection {
    lhs.append(contentsOf: rhs)
}

// 运算符帮助泛型类
public class ListOperatorsHelper<SWForm: SWBaseForm, SWSection: SWBaseSection, SWRow: SWBaseRow>: NSObject {
    // MARK:- 添加section
    /**
     添加 SWSection 到 SWForm
     */
    @discardableResult
    public static func add (_ section: SWSection, to form: SWForm) -> SWForm {
        form.append(section)
        return form
    }

    // MARK:- 添加section并更新
    /**
     添加 SWSection 到 SWForm, 并通知到代理
     */
    @discardableResult
    public static func addAndUpdate(_ section: SWSection, to form: SWForm) -> SWForm {
        form.append(section)
        if let delegate = form.delegate {
            delegate.sectionsHaveBeenAdded([section], at: IndexSet(integersIn: form.allSections.count - 1 ..< form.allSections.count))
        }
        return form
    }

    // MARK:- 添加row
    /**
     添加Row到Section
     */
    @discardableResult
    public static func add(_ row: SWRow, to section: SWSection) -> SWSection {
        section.append(row)
        return section
    }

    // MARK:- 添加row并更新
    /**
     添加Row到Section, 并通知到代理
     */
    @discardableResult
    public static func addAndUpdate(_ row: SWRow, to section: SWSection) -> SWSection {
        section.append(row)
        if
            let form = section.form,
            let delegate = form.delegate
        {
            guard let sectionIndex = form.allSections.firstIndex(of: section) else {
                return section
            }
            delegate.rowsHaveBeenAdded([row], at: [IndexPath(row: section.allRows.count - 1, section: sectionIndex)])
        }
        return section
    }
    /**
     添加Row数组到Section, 并通知到代理
     */
    @discardableResult
    public static func addAndUpdate(_ rows: [SWRow], to section: SWSection) -> SWSection {
        
        if
            let form = section.form,
            let delegate = form.delegate
        {
            guard let sectionIndex = form.allSections.firstIndex(of: section) else {
                section.append(contentsOf: rows)
                return section
            }
            var index = section.allRows.count
            var indexPaths = [IndexPath]()
            for row in rows {
                section.append(row)
                indexPaths.append(IndexPath(row: index, section: sectionIndex))
                index += 1
            }
            delegate.rowsHaveBeenAdded(rows, at: indexPaths)
        } else {
            section.append(contentsOf: rows)
        }
        return section
    }

    // MARK:- 替换
    /**
     替换SWForm的所有Section, 并通知到代理
    - parameter newSections: 要替换的Section数组
    */
    @discardableResult
    public static func replace(_ newSections: [SWSection], to form: SWForm) -> SWForm {
        let oldSections = form.allSections
        form.replaceSubrange(0 ..< oldSections.count, with: newSections)
        if let delegate = form.delegate {
            delegate.sectionsHaveBeenReplaced(oldSections: oldSections, newSections: newSections, at: IndexSet(integersIn: 0 ..< oldSections.count))
        }
        return form
    }
    
    /**
     替换Section数组到指定范围, 并通知到代理
    - parameter rangeSection: 元组，( 范围 ，要替换的Section数组 )
    */
    @discardableResult
    public static func replace(_ rangeSection: (Range<Int>, [SWSection]), to form: SWForm) -> SWForm {
        var oldSections = [SWSection]()
        for i in min(rangeSection.0.lowerBound, form.allSections.count - 1) ..< min(rangeSection.0.upperBound, form.allSections.count) {
            oldSections.append(form[i] as! SWSection)
        }
        form.replaceSubrange(rangeSection.0, with: rangeSection.1)
        if let delegate = form.delegate {
            delegate.sectionsHaveBeenReplaced(oldSections: oldSections, newSections: rangeSection.1, at: IndexSet(integersIn: 0 ..< oldSections.count))
        }
        return form
    }
    
    /**
     替换Section的所有Row，并通知到代理
    - parameter newRows: 要替换的Row数组
    */
    @discardableResult
    public static func replace(_ newRows: [SWRow], to section: SWSection, useAnimation: Bool = true) -> SWSection {
        let oldRows = section.allRows
        var replaceIndexPaths = [IndexPath]()
        for i in 0 ..< oldRows.count {
            let row = oldRows[i] as! SWRow
            if let indexPath = row.indexPath {
                replaceIndexPaths.append(indexPath)
            }
        }
        section.replaceSubrange(0 ..< oldRows.count, with: newRows)
        if
            let form = section.form,
            let delegate = form.delegate
        {
            if useAnimation {
                delegate.rowsHaveBeenReplaced(oldRows: oldRows, newRows: newRows, at: replaceIndexPaths)
            } else {
                UIView.performWithoutAnimation {
                    delegate.rowsHaveBeenReplaced(oldRows: oldRows, newRows: newRows, at: replaceIndexPaths)
                }
            }
        }
        return section
    }
    
    /**
     替换Row数组到指定范围, 并通知到代理
    - parameter ramgeRows: 元组，( 范围 ，要替换的Row数组 )
    */
    @discardableResult
    public static func replace(_ ramgeRows: (Range<Int>, [SWRow]), to section: SWSection, useAnimation: Bool = true) -> SWSection {
        var oldRows = [SWRow]()
        let newRows = ramgeRows.1
        var replaceIndexPaths = [IndexPath]()
        for i in min(ramgeRows.0.lowerBound, section.allRows.count - 1) ..< min(ramgeRows.0.upperBound, section.allRows.count) {
            let row = section[i] as! SWRow
            oldRows.append(row)
            if let indexPath = row.indexPath {
                replaceIndexPaths.append(indexPath)
            }
        }
        section.replaceSubrange(ramgeRows.0, with: ramgeRows.1)
        if
            let form = section.form,
            let delegate = form.delegate
        {
            if useAnimation {
                delegate.rowsHaveBeenReplaced(oldRows: oldRows, newRows: newRows, at: replaceIndexPaths)
            } else {
                UIView.performWithoutAnimation {
                    delegate.rowsHaveBeenReplaced(oldRows: oldRows, newRows: newRows, at: replaceIndexPaths)
                }
            }
        }
        return section
    }
}
