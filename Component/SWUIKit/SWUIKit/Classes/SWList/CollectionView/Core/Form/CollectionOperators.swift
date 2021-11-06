//
//  CollectionOperators.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/15.
//

// MARK:- +++
/**
 添加 SWSection 到 SWForm
 
 - parameter left:  form
 - parameter right: 需要添加的 section
 
 - returns: 添加后的 form
 */
@discardableResult
public func +++ (left: SWCollectionForm, right: SWCollectionSection) -> SWCollectionForm {
    return ListOperatorsHelper.add(right, to: left)
}
/**
 添加 SWRow 到 SWForm 的最后一个 SWSection
 
 - parameter left:  form
 - parameter right: row
 */
@discardableResult
public func +++ (left: SWCollectionForm, right: SWCollectionItem) -> SWCollectionForm {
    if let section = left.allSections.last as? SWCollectionSection {
        ListOperatorsHelper.add(right, to: section)
    } else {
        let section = SWCollectionSection()
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
public func +++ (left: SWCollectionSection, right: SWCollectionSection) -> SWCollectionForm {
    let form = SWCollectionForm()
    ListOperatorsHelper.add(left, to: form)
    ListOperatorsHelper.add(right, to: form)
    return form
}

/**
 用两个Section相加创建SWCollectionForm, 每个Section中包含一个Row
 
 - parameter left:  第一个Section中的Row
 - parameter right: 第二个Section中的Row
 
 - returns: 创建好的SWForm
 */
@discardableResult
public func +++ (left: SWCollectionItem, right: SWCollectionItem) -> SWCollectionForm {
    let section1 = SWCollectionSection()
    ListOperatorsHelper.add(left, to: section1)
    let section2 = SWCollectionSection()
    ListOperatorsHelper.add(right, to: section2)
    let form = SWCollectionForm()
    ListOperatorsHelper.add(section1, to: form)
    ListOperatorsHelper.add(section2, to: form)
    return form
}

// MARK:- +++!
/**
 添加 SWSection 到 SWCollectionForm, 并通知到代理
 
 - parameter left:  form
 - parameter right: 需要添加的 section
 
 - returns: 添加后的 form
 */
@discardableResult
public func +++! (left: SWCollectionForm, right: SWCollectionSection) -> SWCollectionForm {
    return ListOperatorsHelper.addAndUpdate(right, to: left)
}
/**
 添加 SWRow 到 SWForm 的最后一个 SWSection, 并通知到代理
 
 - parameter left:  form
 - parameter right: row
 */
@discardableResult
public func +++! (left: SWCollectionForm, right: SWCollectionItem) -> SWCollectionForm {
    if let section = left.allSections.last as? SWCollectionSection {
        ListOperatorsHelper.addAndUpdate(right, to: section)
    } else {
        let section = SWCollectionSection()
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
public func <<< (left: SWCollectionSection, right: SWCollectionItem) -> SWCollectionSection {
    return ListOperatorsHelper.add(right, to: left)
}

/**
 两个Row创建Section
 
 - parameter left:  第一个 row
 - parameter right: 第二个 row
 
 - returns: 创建好的 section
 */
@discardableResult
public func <<< (left: SWCollectionItem, right: SWCollectionItem) -> SWCollectionSection {
    let section = SWCollectionSection()
    ListOperatorsHelper.add(left, to: section)
    ListOperatorsHelper.add(right, to: section)
    return section
}

// MARK:- <<<!
/**
 添加Row到Section, 并通知到代理
 使用 <<<!前，
 ***如果section已经被添加到form中***，请确认collectionView已经刷新过（section的信息已经在collectionView上，否则会闪退）
 ***如果section还没有被添加到form中***，就没关系
 
 - parameter left:  section
 - parameter right: row
 
 - returns: section
 */
@discardableResult
public func <<<! (left: SWCollectionSection, right: SWCollectionItem) -> SWCollectionSection {
    return ListOperatorsHelper.addAndUpdate(right, to: left)
}

/**
 添加Row数组到Section, 并通知到代理
 使用 <<<!前，
 ***如果section已经被添加到form中***，请确认collectionView已经刷新过（section的信息已经在collectionView上，否则会闪退）
 ***如果section还没有被添加到form中***，就没关系
 
 - parameter left:  section
 - parameter right: row
 
 - returns: section
 */
@discardableResult
public func <<<! (left: SWCollectionSection, right: [SWCollectionItem]) -> SWCollectionSection {
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
public func >>>(left: SWCollectionForm, right: [SWCollectionSection]) -> SWCollectionForm {
    let oldSections = left.allSections
    left.replaceSubrange(0 ..< oldSections.count, with: right)
    guard let handler = left.delegate as? SWCollectionViewHandler else {
        return left
    }
    handler.reloadCollection()
    return left
}
/**
 替换Section数组到指定范围, 并通知到代理

- parameter left:  form
- parameter right: 元组，( 范围 ，要替换的Section数组 )

- returns: form
*/
@discardableResult
public func >>>(left: SWCollectionForm, right: (Range<Int>, [SWCollectionSection])) -> SWCollectionForm {
    left.replaceSubrange(right.0, with: right.1)
    guard let handler = left.delegate as? SWCollectionViewHandler else {
        return left
    }
    handler.reloadCollection()
    return left
}
/**
 替换Section的所有Row，并通知到代理

- parameter left:  section
- parameter right: 要替换的Row数组

- returns: section
*/
@discardableResult
public func >>>(left: SWCollectionSection, newRows: [SWCollectionItem]) -> SWCollectionSection {
    return ListOperatorsHelper.replace(newRows, to: left, useAnimation: false)
}
/**
 替换Row数组到指定范围, 并通知到代理

- parameter left:  section
- parameter right: 元组，( 范围 ，要替换的Row数组 )

- returns: section
*/
@discardableResult
public func >>>(left: SWCollectionSection, right: (Range<Int>, [SWCollectionItem])) -> SWCollectionSection {
    left.replaceSubrange(right.0, with: right.1)
    guard let handler = left.form?.delegate as? SWCollectionViewHandler else {
        return left
    }
    handler.reloadCollection()
    return left
}

/**
 添加 SWRow 的集合到 SWCollectionSection
 
 - parameter lhs: section
 - parameter rhs: rows 的集合
 */
public func += <C: Collection>(lhs: inout SWCollectionSection, rhs: C) where C.Iterator.Element == SWBaseRow {
    lhs.append(contentsOf: rhs)
}

/**
 添加 SWSection 的集合到 SWCollectionForm
 
 - parameter lhs: form
 - parameter rhs: sections 的集合
 */
public func += <C: Collection>(lhs: inout SWCollectionForm, rhs: C) where C.Iterator.Element == SWBaseSection {
    lhs.append(contentsOf: rhs)
}
