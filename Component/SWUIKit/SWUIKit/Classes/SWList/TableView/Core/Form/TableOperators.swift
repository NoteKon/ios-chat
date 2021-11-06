//
//  TableOperators.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/4.
//

import Foundation

// MARK:- +++
/**
 添加 SWSection 到 SWForm
 
 - parameter left:  form
 - parameter right: 需要添加的 section
 
 - returns: 添加后的 form
 */
@discardableResult
public func +++ (left: SWTableForm, right: SWTableSection) -> SWTableForm {
    return ListOperatorsHelper.add(right, to: left)
}
/**
 添加 SWRow 到 SWForm 的最后一个 SWSection
 
 - parameter left:  form
 - parameter right: row
 */
@discardableResult
public func +++ (left: SWTableForm, right: SWTableRow) -> SWTableForm {
    if let section = left.allSections.last as? SWTableSection {
        ListOperatorsHelper.add(right, to: section)
    } else {
        let section = SWTableSection()
        ListOperatorsHelper.add(right, to: section)
        ListOperatorsHelper.add(section, to: left)
    }
    return left
}
/**
 用两个Section相加创建SWForm
 
 - parameter left:  第一个 section
 - parameter right: 第二个 section
 
 - returns: 创建好的SWForm
 */
@discardableResult
public func +++ (left: SWTableSection, right: SWTableSection) -> SWTableForm {
    let form = SWTableForm()
    ListOperatorsHelper.add(left, to: form)
    ListOperatorsHelper.add(right, to: form)
    return form
}
/**
 用两个Section相加创建SWTableForm, 每个Section中包含一个Row
 
 - parameter left:  第一个Section中的Row
 - parameter right: 第二个Section中的Row
 
 - returns: 创建好的SWForm
 */
@discardableResult
public func +++ (left: SWTableRow, right: SWTableRow) -> SWTableForm {
    let section1 = SWTableSection()
    ListOperatorsHelper.add(left, to: section1)
    let section2 = SWTableSection()
    ListOperatorsHelper.add(right, to: section2)
    let form = SWTableForm()
    ListOperatorsHelper.add(section1, to: form)
    ListOperatorsHelper.add(section2, to: form)
    return form
}

// MARK:- +++!
/**
 添加 SWSection 到 SWTableForm, 并通知到代理
 
 - parameter left:  form
 - parameter right: 需要添加的 section
 
 - returns: 添加后的 form
 */
@discardableResult
public func +++! (left: SWTableForm, right: SWTableSection) -> SWTableForm {
    return ListOperatorsHelper.addAndUpdate(right, to: left)
}
/**
 添加 SWRow 到 SWForm 的最后一个 SWSection, 并通知到代理
 
 - parameter left:  form
 - parameter right: row
 */
@discardableResult
public func +++! (left: SWTableForm, right: SWTableRow) -> SWTableForm {
    if let section = left.allSections.last as? SWTableSection {
        ListOperatorsHelper.addAndUpdate(right, to: section)
    } else {
        let section = SWTableSection()
        ListOperatorsHelper.add(right, to: section)
        ListOperatorsHelper.addAndUpdate(section, to: left)
    }
    return left
}

// MARK:- <<<
/**
 添加Row到Section
 
 - parameter left:  section
 - parameter right: row
 
 - returns: section
 */
@discardableResult
public func <<< (left: SWTableSection, right: SWTableRow) -> SWTableSection {
    return ListOperatorsHelper.add(right, to: left)
}

/**
 两个Row创建Section
 
 - parameter left:  第一个 row
 - parameter right: 第二个 row
 
 - returns: 创建好的 section
 */
@discardableResult
public func <<< (left: SWTableRow, right: SWTableRow) -> SWTableSection {
    let section = SWTableSection()
    ListOperatorsHelper.add(left, to: section)
    ListOperatorsHelper.add(right, to: section)
    return section
}

// MARK:- <<<!
/**
 添加Row到Section, 并通知到代理
 使用 <<<!前，
 ***如果section已经被添加到form中***，请确认tableView已经刷新过（section的信息已经在tableView上，否则会闪退）
 ***如果section还没有被添加到form中***，就没关系
 
 - parameter left:  section
 - parameter right: row
 
 - returns: section
 */
@discardableResult
public func <<<! (left: SWTableSection, right: SWTableRow) -> SWTableSection {
    return ListOperatorsHelper.addAndUpdate(right, to: left)
}

/**
 添加Row数组到Section, 并通知到代理
 使用 <<<!前，
 ***如果section已经被添加到form中***，请确认tableView已经刷新过（section的信息已经在tableView上，否则会闪退）
 ***如果section还没有被添加到form中***，就没关系
 
 - parameter left:  section
 - parameter right: row
 
 - returns: section
 */
@discardableResult
public func <<<! (left: SWTableSection, right: [SWTableRow]) -> SWTableSection {
    return ListOperatorsHelper.addAndUpdate(right, to: left)
}


// MARK:- >>>
/**
 替换SWForm的所有Section, 并通知到代理

- parameter left:  form
- parameter right: 要替换的Section数组

- returns: form
*/
@discardableResult
public func >>>(left: SWTableForm, right: [SWTableSection]) -> SWTableForm {
    return ListOperatorsHelper.replace(right, to: left)
}
/**
 替换Section数组到指定范围, 并通知到代理

- parameter left:  form
- parameter right: 元组，( 范围 ，要替换的Section数组 )

- returns: form
*/
@discardableResult
public func >>>(left: SWTableForm, right: (Range<Int>, [SWTableSection])) -> SWTableForm {
    return ListOperatorsHelper.replace(right, to: left)
}
/**
 替换Section的所有Row，并通知到代理

- parameter left:  section
- parameter right: 要替换的Row数组

- returns: section
*/
@discardableResult
public func >>>(left: SWTableSection, newRows: [SWTableRow]) -> SWTableSection {
    return ListOperatorsHelper.replace(newRows, to: left)
}
/**
 替换Row数组到指定范围, 并通知到代理

- parameter left:  section
- parameter right: 元组，( 范围 ，要替换的Row数组 )

- returns: section
*/
@discardableResult
public func >>>(left: SWTableSection, right: (Range<Int>, [SWTableRow])) -> SWTableSection {
    return ListOperatorsHelper.replace(right, to: left)
}

/**
 添加 SWRow 的集合到 SWTableSection
 
 - parameter lhs: section
 - parameter rhs: rows 的集合
 */
public func += <C: Collection>(lhs: inout SWTableSection, rhs: C) where C.Iterator.Element == SWBaseRow {
    lhs.append(contentsOf: rhs)
}

/**
 添加 SWSection 的集合到 SWTableForm
 
 - parameter lhs: form
 - parameter rhs: sections 的集合
 */
public func += <C: Collection>(lhs: inout SWTableForm, rhs: C) where C.Iterator.Element == SWBaseSection {
    lhs.append(contentsOf: rhs)
}
