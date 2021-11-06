//
//  SWTableViewHandler.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/3.
//

import UIKit

// MARK:- SWTableViewHandlerDelegate
public protocol SWTableViewHandlerAnimationDelegate: NSObject {
    // 返回row插入动画类型
    func insertAnimation(forRows rows: [SWTableRow]) -> UITableView.RowAnimation
    // 返回row移除动画类型
    func deleteAnimation(forRows rows: [SWTableRow]) -> UITableView.RowAnimation
    // 返回row替换动画类型
    func reloadAnimation(oldRows: [SWTableRow], newRows: [SWTableRow]) -> UITableView.RowAnimation
    
    // 返回section插入动画类型
    func insertAnimation(forSections sections: [SWTableSection]) -> UITableView.RowAnimation
    // 返回section移除动画类型
    func deleteAnimation(forSections sections: [SWTableSection]) -> UITableView.RowAnimation
    // 返回section替换动画类型
    func reloadAnimation(oldSections: [SWTableSection], newSections: [SWTableSection]) -> UITableView.RowAnimation
}

@objc public protocol SWTableViewHandlerDelegate: UIScrollViewDelegate {
    // row的value改变
    @objc optional func valueHasBeenChanged(for row: SWTableRow, oldValue: Any?, newValue: Any?)
}

// MARK:- SWTableViewHandler - Class
public class SWTableViewHandler: NSObject {
    deinit {
        #if DEBUG
        print("—————— 验证是否正确释放，如果返回时有输出这行，表示已经正确释放，没有循环引用 ——————")
        #endif
    }
    
    public lazy var form: SWTableForm = {
        let f = SWTableForm()
        f.delegate = self
        return f
    }()
    
    public weak var tableView: UITableView? {
        didSet {
            tableView?.delegate = self
            tableView?.dataSource = self
            tableView?.separatorStyle = .none
            tableView?.estimatedRowHeight = 0
            tableView?.estimatedSectionHeaderHeight = 0
            tableView?.estimatedSectionFooterHeight = 0
            tableView?.rowHeight = UITableView.automaticDimension
            tableView?.allowsSelectionDuringEditing = true
        }
    }
    public weak var animationDelegate: SWTableViewHandlerAnimationDelegate?
    public weak var delegate: SWTableViewHandlerDelegate?
    
    // 用于存储已注册的Cell对应的identifier
    var registedCellIdentifier = [String]()
    
    // 是否正在滚动
    public var isScrolling: Bool = false
    
    public override init() {
        super.init()
    }
    
    public init(_ tableView: UITableView? = nil, _ delegate: SWTableViewHandlerAnimationDelegate? = nil) {
        super.init()
        self.tableView = tableView
        self.animationDelegate = delegate
    }
    
    /** 计算header或footer的高度 */
    fileprivate func height(specifiedHeight: (() -> CGFloat)?, sectionView: UIView?, sectionTitle: String?) -> CGFloat {
        if let height = specifiedHeight {
            return height()
        }

        if let sectionView = sectionView {
            let height = sectionView.bounds.height

            if height == 0 {
                return UITableView.automaticDimension
            }

            return height
        }

        if let sectionTitle = sectionTitle,
            sectionTitle != "" {
            return UITableView.automaticDimension
        }

        // OS 11+修复。通过返回0，确保启用自调整大小时
        if tableView?.style == .plain {
            return 0
        }

        return UITableView.automaticDimension
    }
    
    // 滚动显示Row
    public func makeRowVisible(_ row: SWTableRow, destinationScrollPosition: UITableView.ScrollPosition? = UITableView.ScrollPosition.none) {
        guard
            let destinationScrollPosition = destinationScrollPosition,
            let indexPath = row.indexPath,
            let tableView = tableView
        else { return }
        tableView.scrollToRow(at: indexPath, at: destinationScrollPosition, animated: true)
    }
    
    /// cell成为第一响应者
    public final func beginEditing<T>(of cell: SWTableCellOf<T>) {
        cell.row?.isHighlighted = true
        cell.row?.updateCell()
        cell.row?.callbackOnCellHighlightChanged?()
        guard (form.inlineRowHideOptions ?? SWTableForm.defaultInlineRowHideOptions).contains(.FirstResponderChanges) else { return }
        let row = cell.row
        let inlineRow = row?._inlineRow
        for r in (form.allRows as! [SWTableRow]).filter({ $0 !== row && $0 !== inlineRow && $0._inlineRow != nil }) {
            if let inlineRow = r as?  SWBaseInlineRowType {
                inlineRow.collapseInlineRow()
            }
        }
    }
    
    /// cell失去第一响应者
    public final func endEditing<T>(of cell: SWTableCellOf<T>) {
        cell.row?.isHighlighted = false
        cell.row?.callbackOnCellHighlightChanged?()
        cell.row?.callbackOnCellEndEditing?()
        cell.row?.updateCell()
    }
}

// MARK:- SWFormDelegate
extension SWTableViewHandler: SWFormDelegate {
    public func sectionsHaveBeenAdded(_ sections: [SWBaseSection], at indexes: IndexSet) {
        tableView?.beginUpdates()
        tableView?.insertSections(indexes, with: insertAnimation(forSections: sections))
        tableView?.endUpdates()
    }
    
    public func sectionsHaveBeenRemoved(_ sections: [SWBaseSection], at indexes: IndexSet) {
        tableView?.beginUpdates()
        tableView?.deleteSections(indexes, with: deleteAnimation(forSections: sections))
        tableView?.endUpdates()
    }
    
    public func sectionsHaveBeenReplaced(oldSections: [SWBaseSection], newSections: [SWBaseSection], at indexes: IndexSet) {
        if oldSections.count == indexes.count, newSections.count == indexes.count {
            for i in 0 ..< oldSections.count {
                let oldSection = oldSections[i]
                let newSection = newSections[i]
                if oldSection.count != newSection.count {
                    tableView?.reloadData()
                    return
                }
            }
            tableView?.reloadSections(indexes, with: reloadAnimation(oldSections: oldSections, newSections: newSections))
        } else {
            tableView?.reloadData()
        }
    }
    
    public func rowsHaveBeenAdded(_ rows: [SWBaseRow], at indexes: [IndexPath]) {
        tableView?.beginUpdates()
        tableView?.insertRows(at: indexes, with: insertAnimation(forRows: rows))
        tableView?.endUpdates()
    }
    
    public func rowsHaveBeenRemoved(_ rows: [SWBaseRow], at indexes: [IndexPath]) {
        tableView?.beginUpdates()
        tableView?.deleteRows(at: indexes, with: deleteAnimation(forRows: rows))
        tableView?.endUpdates()
    }
    
    public func rowsHaveBeenReplaced(oldRows: [SWBaseRow], newRows: [SWBaseRow], at indexes: [IndexPath]) {
        if oldRows.count == indexes.count, newRows.count == indexes.count {
            tableView?.reloadRows(at: indexes, with: reloadAnimation(oldRows: oldRows, newRows: newRows))
        } else {
            tableView?.reloadData()
        }
    }
    
    public func valueHasBeenChanged(for row: SWBaseRow, oldValue: Any?, newValue: Any?) {
        if let t = row.tag {
            form.tagToValues[t] = newValue ?? NSNull()
        }
        guard let delegate = delegate, let row = row as? SWTableRow else {
            return
        }
        delegate.valueHasBeenChanged?(for: row, oldValue: oldValue, newValue: newValue)
    }
}

// MARK:- tableview刷新的动画类型
extension SWTableViewHandler {
    // 返回row插入动画类型
    func insertAnimation(forRows rows: [SWBaseRow]) -> UITableView.RowAnimation {
        guard let animationDelegate = animationDelegate, let rows = rows as? [SWTableRow] else {
            return .none
        }
        return animationDelegate.insertAnimation(forRows: rows)
    }

    // 返回row移除动画类型
    func deleteAnimation(forRows rows: [SWBaseRow]) -> UITableView.RowAnimation {
        guard let animationDelegate = animationDelegate, let rows = rows as? [SWTableRow] else {
            return .none
        }
        return animationDelegate.deleteAnimation(forRows: rows)
    }

    // 返回row替换动画类型
    func reloadAnimation(oldRows: [SWBaseRow], newRows: [SWBaseRow]) -> UITableView.RowAnimation {
        guard let animationDelegate = animationDelegate, let oldRows = oldRows as? [SWTableRow], let newRows = newRows as? [SWTableRow] else {
            return .none
        }
        return animationDelegate.reloadAnimation(oldRows: oldRows, newRows: newRows)
    }

    // 返回section插入动画类型
    func insertAnimation(forSections sections: [SWBaseSection]) -> UITableView.RowAnimation {
        guard let animationDelegate = animationDelegate, let sections = sections as? [SWTableSection] else {
            return .none
        }
        return animationDelegate.insertAnimation(forSections: sections)
    }

    // 返回section移除动画类型
    func deleteAnimation(forSections sections: [SWBaseSection]) -> UITableView.RowAnimation {
        guard let animationDelegate = animationDelegate, let sections = sections as? [SWTableSection] else {
            return .none
        }
        return animationDelegate.deleteAnimation(forSections: sections)
    }

    // 返回section替换动画类型
    func reloadAnimation(oldSections: [SWBaseSection], newSections: [SWBaseSection]) -> UITableView.RowAnimation {
        guard let animationDelegate = animationDelegate, let oldSections = oldSections as? [SWTableSection], let newSections = newSections as? [SWTableSection] else {
            return .none
        }
        return animationDelegate.reloadAnimation(oldSections: oldSections, newSections: newSections)
    }
}

// MARK: UITableViewDataSource
extension SWTableViewHandler : UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return form.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form[section].count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = form[indexPath] as? SWTableRow else {
            return UITableViewCell()
        }
        // 未注册先注册
        if let identifier = row.identifier {
            if !registedCellIdentifier.contains(identifier) {
                row.regist(to: tableView)
                registedCellIdentifier.append(identifier)
            }
        }
        guard let cell = row.dequeueReusableCell(tableView: tableView, indexPath: indexPath) else {
            return UITableViewCell()
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection index: Int) -> String? {
        guard let section = form[index] as? SWTableSection else {
            return nil
        }
        return section.header?.title
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection index: Int) -> String? {
        guard let section = form[index] as? SWTableSection else {
            return nil
        }
        return section.footer?.title
    }

    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }

    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return 0
    }
}

// MARK: UITableViewDelegate(含 UIScrollViewDelegate)
extension SWTableViewHandler : UITableViewDelegate {
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let row = form[indexPath] as? SWTableRow else {
            return
        }
        row.willDisplay()
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let row = form[indexPath] as? SWTableRow else {
            return
        }
        row.didEndDisplay()
    }

    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            tableView == self.tableView,
            let row = form[indexPath] as? SWTableRow,
            let cell = row._cell
        else {
            return
        }
        if !cell.cellCanBecomeFirstResponder() || !cell.cellBecomeFirstResponder() {
            tableView.endEditing(true)
        }
        row.didSelect()
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            tableView == self.tableView,
            let row = form[indexPath] as? SWTableRow
        else {
            return tableView.rowHeight
        }
        return row.cellHeight ?? row._cell?.cellHeight?() ?? tableView.rowHeight
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            tableView == self.tableView,
            let row = form[indexPath] as? SWTableRow
        else {
            return tableView.rowHeight
        }
        return row.cellHeight ?? row._cell?.cellHeight?() ?? tableView.rowHeight
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = form[section] as? SWTableSection else {
            return nil
        }
        return section.header?.viewForSection(section, type: .header)
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let section = form[section] as? SWTableSection else {
            return nil
        }
        return section.footer?.viewForSection(section, type:.footer)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection index: Int) -> CGFloat {
        guard let section = form[index] as? SWTableSection else {
            return 0
        }
        return height(specifiedHeight: section.header?.height,
                      sectionView: self.tableView(tableView, viewForHeaderInSection: index),
                      sectionTitle: self.tableView(tableView, titleForHeaderInSection: index))
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection index: Int) -> CGFloat {
        guard let section = form[index] as? SWTableSection else {
            return 0
        }
        return height(specifiedHeight: section.footer?.height,
                      sectionView: self.tableView(tableView, viewForFooterInSection: index),
                      sectionTitle: self.tableView(tableView, titleForFooterInSection: index))
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let row = form[indexPath] as? SWTableRow else {
            return
        }
        row.customHighlightCell()
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let row = form[indexPath] as? SWTableRow else {
            return
        }
        row.customUnHighlightCell()
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let row = form[indexPath] as? SWTableRow else {
            return false
        }
        guard !row.isDisabled else { return false }
        if row.trailingSwipe.actions.count > 0 { return true }
        if #available(iOS 11,*), row.leadingSwipe.actions.count > 0 { return true }
        guard let section = form[indexPath.section] as? TableMultivalusedSection else { return false }
        guard !(indexPath.row == section.count - 1 && section.multivaluedOptions.contains(.Insert) && section.showInsertIconInAddButton) else {
            return true
        }
        if
            indexPath.row > 0,
            section[indexPath.row - 1] is  SWBaseInlineRowType,
            let lastRow = section[indexPath.row - 1] as? SWTableRow,
            lastRow._inlineRow != nil
        {
            return false
        }
        return true
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let row = form[indexPath] as? SWTableRow else {
            return
        }
        if editingStyle == .delete {
            let section = row.section!
            if let _ = row._cell?.findFirstResponder() {
                tableView.endEditing(true)
            }
            section.remove(at: indexPath.row)
            rowsHaveBeenRemoved([row], at: [indexPath])
        } else if editingStyle == .insert {
            guard let section = form[indexPath.section] as? TableMultivalusedSection else { return }
            guard let multivaluedRowToInsertAt = section.multivaluedRowToInsertAt else {
                fatalError("Multivalued section multivaluedRowToInsertAt property must be set up")
            }
            let newRow = multivaluedRowToInsertAt(max(0, section.count - 1))
            let index = max(0, section.count - 1)
            section.insert(newRow, at: index)
            rowsHaveBeenAdded([newRow], at: [IndexPath(row: index, section: section.index ?? 0)])
            DispatchQueue.main.async {
                tableView.isEditing = !tableView.isEditing
                tableView.isEditing = !tableView.isEditing
            }
            tableView.scrollToRow(at: IndexPath(row: section.count - 1, section: indexPath.section), at: .none, animated: true)
            if newRow._cell?.cellCanBecomeFirstResponder() ?? false {
                newRow._cell?.cellBecomeFirstResponder()
            } else if let inlineRow = newRow as?  SWBaseInlineRowType {
                inlineRow.expandInlineRow()
            }
        }
    }

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard
            let row = form[indexPath] as? SWTableRow,
            row.canMoveRow
        else {
            return false
        }
        guard
            let section = form[indexPath.section] as? TableMultivalusedSection,
            section.multivaluedOptions.contains(.Reorder) && section.count > 1
        else {
            return row.canMoveRow
        }
        return true
    }

    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard let section = form[sourceIndexPath.section] as? TableMultivalusedSection else { return sourceIndexPath }
        guard sourceIndexPath.section == proposedDestinationIndexPath.section else { return sourceIndexPath }

        let destRow = form[proposedDestinationIndexPath] as! SWTableRow
        if destRow is  SWBaseInlineRowType && destRow._inlineRow != nil {
            return IndexPath(row: proposedDestinationIndexPath.row + (sourceIndexPath.row < proposedDestinationIndexPath.row ? 1 : -1), section:sourceIndexPath.section)
        }

        if proposedDestinationIndexPath.row > 0 {
            let previousRow = form[IndexPath(row: proposedDestinationIndexPath.row - 1, section: proposedDestinationIndexPath.section)] as! SWTableRow
            if previousRow is  SWBaseInlineRowType && previousRow._inlineRow != nil {
                return IndexPath(row: proposedDestinationIndexPath.row + (sourceIndexPath.row < proposedDestinationIndexPath.row ? 1 : -1), section:sourceIndexPath.section)
            }
        }
        if section.multivaluedOptions.contains(.Insert) && proposedDestinationIndexPath.row == section.count - 1 {
            return IndexPath(row: section.count - 2, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }

    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let section = form[sourceIndexPath.section] as? TableMultivalusedSection else { return }
        guard let targetSection = form[destinationIndexPath.section] as? TableMultivalusedSection else { return }
        if sourceIndexPath.row < section.count && destinationIndexPath.row < section.count && sourceIndexPath.row != destinationIndexPath.row {
            let sourceRow = form[sourceIndexPath] as! SWTableRow
            section.remove(at: sourceIndexPath.row, updateUI: false)
            targetSection.insert(sourceRow, at: destinationIndexPath.row)
            section.moveFinishClosure?(sourceRow, sourceIndexPath, destinationIndexPath)
        }
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard let row = form[indexPath] as? SWTableRow else { return .none }
        guard let section = form[indexPath.section] as? TableMultivalusedSection else { return row.editingStyle }
        if section.multivaluedOptions.contains(.Insert),
           section.addButtonProvider != nil,
           section.multivaluedRowToInsertAt != nil,
           indexPath.row == section.count - 1 {
            return section.showInsertIconInAddButton ? .insert : .none
        }
        if section.multivaluedOptions.contains(.Delete),
           row.editingStyle == .delete,
           row.trailingSwipe.actions.count > 0 {
            return .delete
        }
        if section.multivaluedOptions.contains(.Insert),
           row.editingStyle == .insert,
           section.multivaluedRowToInsertAt != nil {
            return .insert
        }
        return .none
    }

    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return self.tableView(tableView, editingStyleForRowAt: indexPath) != .none
    }

    @available(iOS 11,*)
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard
            let row = form[indexPath] as? SWTableRow,
            !row.leadingSwipe.actions.isEmpty
        else {
            return nil
        }
        return row.leadingSwipe.contextualConfiguration
    }

    @available(iOS 11,*)
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard
            let row = form[indexPath] as? SWTableRow,
            !row.trailingSwipe.actions.isEmpty
        else {
            return nil
        }
        return row.trailingSwipe.contextualConfiguration
    }

    @available(iOS, deprecated: 13, message: "UITableViewRowAction is deprecated, use leading/trailingSwipe actions instead")
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        guard
            let row = form[indexPath] as? SWTableRow,
            let actions = row.trailingSwipe.contextualActions as? [UITableViewRowAction],
            !actions.isEmpty
        else {
            return nil
        }
        return actions
    }

    // MARK:- UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        notifyBeginScroll()
        delegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidZoom?(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging?(scrollView)
        notifyBeginScroll()
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            notifyEndScroll()
        }
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyEndScroll()
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        notifyEndScroll()
        delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return delegate?.viewForZooming?(in: scrollView)
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        notifyBeginScroll()
        delegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        notifyEndScroll()
        delegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return delegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScrollToTop?(scrollView)
    }

    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
    
    /// 通知滚动开始
    func notifyBeginScroll() {
        if !isScrolling {
            isScrolling = true
            for cell in tableView?.visibleCells ?? [] {
                if let observerCell = cell as? SWScrollObserverCellType {
                    observerCell.willBeginScrolling()
                }
            }
        }
    }
    
    /// 通知滚动结束
    func notifyEndScroll() {
        if isScrolling {
            isScrolling = false
            for cell in tableView?.visibleCells ?? [] {
                if let observerCell = cell as? SWScrollObserverCellType {
                    observerCell.didEndScrolling()
                }
            }
        }
    }
}
