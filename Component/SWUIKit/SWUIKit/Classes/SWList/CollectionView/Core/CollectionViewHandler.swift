//
//  SWCollectionViewHandler.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/15.
//

import UIKit

// MARK:- 排列方式
/// 排列方式
/// - system: 系统自带的layout样式
/// - flow: 瀑布流样式
/// - aline: 自动换行布局
///     - aligment: 与滚动方向垂直的轴的元素布局方式，默认为排列在开始位置
///     - direction: 元素顺序，默认为从开始到结束排序
/// - blend: 混合模式（目前支持瀑布流与自动换行布局混合）
/// - custom: 自定义layout，需为UICollectionViewFlowLayout及其子类
public enum SWCollectionArrangement: Equatable {
    case system
    case flow
    case aline(aligment: SWCollectionCrossAxisAligment, direction: SWCollectionCrossAxisDirection)
    case blend
    case custom(_ layout: UICollectionViewFlowLayout)
}

// MARK:- SWCollectionViewHandlerDelegate
@objc public protocol SWCollectionViewHandlerDelegate: UIScrollViewDelegate {
    // row的value改变
    @objc optional func valueHasBeenChanged(for row: SWCollectionItem, oldValue: Any?, newValue: Any?)
}

// MARK:- SWCollectionViewHandler - Class
public class SWCollectionViewHandler: NSObject {
    deinit {
        #if DEBUG
        print("—————— 验证是否正确释放，如果返回时有输出这行，表示已经正确释放，没有循环引用 ——————")
        #endif
    }
    
    lazy var form: SWCollectionForm = {
        let f = SWCollectionForm()
        f.delegate = self
        return f
    }()
    
    public weak var collectionView: UICollectionView? {
        didSet {
            collectionView?.delegate = self
            collectionView?.dataSource = self
            collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        }
    }
    public var layout: UICollectionViewLayout? {
        didSet {
            if let flowLayout = layout as? SWCollectionFlowLayout {
                flowLayout.delegate = self
                flowLayout.baseDelegate = self
            } else if let alignLayout = layout as? SWCollectionAlineLayout {
                alignLayout.delegate = self
                alignLayout.baseDelegate = self
            } else if let blendLayout = layout as? SWCollectionBlendLayout {
                blendLayout.delegate = self
                blendLayout.baseDelegate = self
                blendLayout.alignDelegate = self
                blendLayout.flowDelegate = self
            }
        }
    }
    public weak var delegate: SWCollectionViewHandlerDelegate?
    
    // 用于存储已注册的header对应的identifier
    var registedHeaderIdentifier = [String]()
    // 用于存储已注册的footer对应的identifier
    var registedFooterIdentifier = [String]()
    // 用于存储已注册的Cell对应的identifier
    var registedCellIdentifier = [String]()
    
    /// 与滚动方向垂直轴方向的排列方式
    var crossAxisAligment: SWCollectionCrossAxisAligment = .start
    var crossAxisDirection: SWCollectionCrossAxisDirection = .startToEnd
    
    /// 排列方式，默认为系统样式
    public var arrangement: SWCollectionArrangement = .system {
        didSet {
            if collectionView != nil {
                collectionView?.collectionViewLayout = collectionLayout(for: arrangement)
            } else {
                collectionLayout(for: arrangement)
            }
            reloadCollection()
        }
    }
    /// 滚动方向,默认为竖直方向滚动
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            reloadCollection()
        }
    }
    
    /// 列数（默认为2），仅在arrangement为.system和.flow时生效
    public var column: Int = 2 {
        didSet {
            reloadCollection()
        }
    }
    /// 行高（默认为40），仅在arrangement为.align时生效
    public var lineHeight: CGFloat = 40 {
        didSet {
            reloadCollection()
        }
    }
    /// 行间距（默认为10）
    public var lineSpace: CGFloat = 10 {
        didSet {
            reloadCollection()
        }
    }
    /// 列间距（默认为10）
    public var itemSpace: CGFloat = 10 {
        didSet {
            reloadCollection()
        }
    }
    
    /// 内容边距
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            if !(layout is SWCollectionBaseLayout) {
                collectionView?.contentInset = contentInset
            }
            reloadCollection()
        }
    }
    
    /// 是否正在滚动
    public var isScrolling: Bool = false
    
    public override init() {
        super.init()
    }
    
    public init(_ collectionView: UICollectionView? = nil, _ delegate: SWCollectionViewHandlerDelegate? = nil) {
        super.init()
        self.collectionView = collectionView
        self.delegate = delegate
    }
    
    /// 根据排列方式获取layout的方法
    @discardableResult
    func collectionLayout(for arrangement: SWCollectionArrangement) -> UICollectionViewLayout {
        switch arrangement {
            case .flow:
                let flowLayout = SWCollectionFlowLayout()
                flowLayout.scrollDirection = scrollDirection
                layout = flowLayout
            case .system:
                let systemLayout = UICollectionViewFlowLayout()
                systemLayout.scrollDirection = scrollDirection
                layout = systemLayout
            case .aline(let a, let d):
                let alineLayout = SWCollectionAlineLayout()
                alineLayout.scrollDirection = scrollDirection
                alineLayout.itemsAlignment = a
                alineLayout.itemsDirection = d
                crossAxisAligment = a
                crossAxisDirection = d
                layout = alineLayout
            case .blend:
                let blendLayout = SWCollectionBlendLayout()
                blendLayout.scrollDirection = scrollDirection
                layout = blendLayout
            case .custom(let l):
                l.scrollDirection = scrollDirection
                layout = l
        }
        return layout!
    }
    
    // 刷新数据
    public func reloadCollection() {
        UIView.performWithoutAnimation {
            collectionView?.reloadData()
        }
        if let layout = collectionView?.collectionViewLayout as? SWCollectionBaseLayout {
            layout.updateLayout()
        } else {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
        addLongTapIfNeeded()
    }
    /// 仅刷新Layout
    public func updateLayout() {
        if let layout = collectionView?.collectionViewLayout as? SWCollectionBaseLayout {
            layout.updateLayout()
        } else {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    
    // 添加长按事件
    func addLongTapIfNeeded() {
        addedLongTap = false
        for section in form.allSections {
            if section is SWCollectionMultivalusedSection {
                addLongTapGesture()
                return
            }
        }
        if !addedLongTap {
            removeLongTap()
        }
    }
    /// 是否已添加
    var addedLongTap = false
    /// 添加长按事件
    func addLongTapGesture() {
        removeLongTap()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(_:)))
        collectionView?.addGestureRecognizer(longPress)
        addedLongTap = true
    }
    /// 移除原有长按事件
    func removeLongTap() {
        if let gestures = collectionView?.gestureRecognizers {
            for gesture in gestures {
                if gesture is UILongPressGestureRecognizer {
                    collectionView?.removeGestureRecognizer(gesture)
                }
            }
        }
    }
    
    // 滚动显示Row
    func makeRowVisible(_ row: SWCollectionItem, animation: Bool = true) {
        guard
            let indexPath = row.indexPath,
            let collectionView = collectionView
        else { return }
        collectionView.scrollToItem(at: indexPath, at: scrollDirection == .vertical ? .centeredVertically : .centeredHorizontally, animated: animation)
    }
    
    // 长按响应方法(仅在SWCollectionMultivalusedSection中才支持)
    @objc func handleLongGesture(_ longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
            case .began:
                /// 开始长按手势，判断section是否支持移动
                guard
                    let indexPath = collectionView?.indexPathForItem(at: longPress.location(in: collectionView)),
                    let section = form[indexPath.section] as? SWCollectionMultivalusedSection,
                    section.multivaluedOptions.contains(.Reorder),
                    section.allRows.count > 1
                else {
                    return
                }
                collectionView?.beginInteractiveMovementForItem(at: indexPath)
            case .changed:
                collectionView?.updateInteractiveMovementTargetPosition(longPress.location(in: collectionView))
                /// 判断是否在可移动的section内部
                guard
                    let indexPath = collectionView?.indexPathForItem(at: longPress.location(in: collectionView))
                else {
                    return
                }
                guard form[indexPath.section] is SWCollectionMultivalusedSection else {
                    collectionView?.cancelInteractiveMovement()
                    return
                }
            case .ended:
                collectionView?.endInteractiveMovement()
            case .possible:
                collectionView?.cancelInteractiveMovement()
            case .cancelled:
                collectionView?.cancelInteractiveMovement()
            case .failed:
                collectionView?.cancelInteractiveMovement()
            @unknown default:
                collectionView?.cancelInteractiveMovement()
        }
    }
    
    /// cell成为第一响应者
    public final func beginEditing<T>(of cell: SWCollectionCellOf<T>) {
        cell.row?.isHighlighted = true
        cell.row?.updateCell()
        cell.row?.callbackOnCellHighlightChanged?()
        guard (form.inlineRowHideOptions ?? SWCollectionForm.defaultInlineRowHideOptions).contains(.FirstResponderChanges) else { return }
        let row = cell.row
        let inlineItem = row?._inlineItem
        for r in (form.allRows as! [SWCollectionItem]).filter({ $0 !== row && $0 !== inlineItem && $0._inlineItem != nil }) {
            if let inline = r as?  SWBaseInlineRowType {
                inline.collapseInlineRow()
            }
        }
    }
    
    /// cell失去第一响应者
    public final func endEditing<T>(of cell: SWCollectionCellOf<T>) {
        cell.row?.isHighlighted = false
        cell.row?.callbackOnCellHighlightChanged?()
        cell.row?.callbackOnCellEndEditing?()
        cell.row?.updateCell()
    }
}

// MARK:- SWFormDelegate
extension SWCollectionViewHandler: SWFormDelegate {
    public func sectionsHaveBeenAdded(_ sections: [SWBaseSection], at: IndexSet) {
        noticeBeginItemAnimation()
        collectionView?.insertSections(at)
        noticeEndItemAnimation()
        for section in sections {
            if section is SWCollectionMultivalusedSection {
                addLongTapGesture()
                return
            }
        }
    }
    
    public func sectionsHaveBeenRemoved(_ sections: [SWBaseSection], at: IndexSet) {
        noticeBeginItemAnimation()
        collectionView?.deleteSections(at)
        noticeEndItemAnimation()
    }
    
    public func sectionsHaveBeenReplaced(oldSections: [SWBaseSection], newSections: [SWBaseSection], at indexes: IndexSet) {
        if oldSections.count == indexes.count, newSections.count == indexes.count {
            for i in 0 ..< oldSections.count {
                let oldSection = oldSections[i]
                let newSection = newSections[i]
                if oldSection.count != newSection.count {
                    collectionView?.reloadData()
                    return
                }
            }
            collectionView?.reloadSections(indexes)
        } else {
            collectionView?.reloadData()
        }
    }
    
    public func rowsHaveBeenAdded(_ rows: [SWBaseRow], at: [IndexPath]) {
        noticeBeginItemAnimation()
        collectionView?.insertItems(at: at)
        noticeEndItemAnimation()
    }
    
    public func rowsHaveBeenRemoved(_ rows: [SWBaseRow], at: [IndexPath]) {
        noticeBeginItemAnimation()
        collectionView?.deleteItems(at: at)
        noticeEndItemAnimation()
    }
    
    public func rowsHaveBeenReplaced(oldRows: [SWBaseRow], newRows: [SWBaseRow], at indexes: [IndexPath]) {
        if oldRows.count == indexes.count, newRows.count == indexes.count {
            collectionView?.reloadItems(at: indexes)
        } else {
            collectionView?.reloadData()
        }
        updateLayout()
    }
    
    public func valueHasBeenChanged(for row: SWBaseRow, oldValue: Any?, newValue: Any?) {
        if let t = row.tag {
            form.tagToValues[t] = newValue ?? NSNull()
        }
        guard let delegate = delegate, let row = row as? SWCollectionItem else {
            return
        }
        delegate.valueHasBeenChanged?(for: row, oldValue: oldValue, newValue: newValue)
    }
    
    public func noticeBeginItemAnimation() {
        if let layout = self.collectionView?.collectionViewLayout as? SWCollectionBaseLayout {
            layout.isInAnimation = true
        }
    }
    
    public func noticeEndItemAnimation() {
        let deadline = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            if let layout = self.collectionView?.collectionViewLayout as? SWCollectionBaseLayout {
                layout.isInAnimation = false
            }
        }
    }
}

// MARK:- UICollectionViewDataSource
extension SWCollectionViewHandler: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return form.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return form[section].count
    }
    
    func emptyCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !registedCellIdentifier.contains("UICollectionViewCell") {
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let row = form[indexPath] as? SWCollectionItem else {
            return emptyCell(collectionView, cellForItemAt: indexPath)
        }
        // 未注册先注册
        if !registedCellIdentifier.contains(row.identifier) {
            row.regist(to: collectionView)
            registedCellIdentifier.append(row.identifier)
        }
        guard let cell = row.dequeueReusableCell(collectionView: collectionView, indexPath: indexPath) else {
            return emptyCell(collectionView, cellForItemAt: indexPath)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard collectionView == self.collectionView else { return UICollectionReusableView() }
        if kind == UICollectionView.elementKindSectionHeader {
            guard
                let section = form[indexPath.section] as? SWCollectionSection,
                let header = section.header,
                let identifier = header.identifier
            else {
                return UICollectionReusableView()
            }
            // 未注册先注册
            if !registedHeaderIdentifier.contains(identifier) {
                header.register(to: collectionView, for: UICollectionView.elementKindSectionHeader)
                registedHeaderIdentifier.append(identifier)
            }
            guard let headerView = header.viewForSection(section, in: collectionView, type: .header, for: indexPath) else { return UICollectionReusableView() }
            return headerView
        }
        if kind == UICollectionView.elementKindSectionFooter {
            guard
                let section = form[indexPath.section] as? SWCollectionSection,
                let footer = section.footer,
                let identifier = footer.identifier
            else {
                return UICollectionReusableView()
            }
            // 未注册先注册
            if !registedFooterIdentifier.contains(identifier) {
                footer.register(to: collectionView, for: UICollectionView.elementKindSectionFooter)
                registedFooterIdentifier.append(identifier)
            }
            guard let footerView = footer.viewForSection(section, in: collectionView, type: .footer, for: indexPath) else { return UICollectionReusableView() }
            return footerView
        }
        return UICollectionReusableView()
    }
    
    // 设置是否可以移动
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard
            let row = form[indexPath] as? SWCollectionItem,
            row.canMoveRow
        else {
            return false
        }
        guard
            let section = form[indexPath.section] as? SWCollectionMultivalusedSection,
            section.multivaluedOptions.contains(.Reorder) && section.count > 1
        else {
            return row.canMoveRow
        }
        return true
    }
    
    // 移动后交换数据
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard
            let fromSection = form[sourceIndexPath.section] as? SWCollectionMultivalusedSection,
            let toSection = form[destinationIndexPath.section] as? SWCollectionMultivalusedSection,
            let fromRow = fromSection[sourceIndexPath.row] as? SWCollectionItem
        else {
            return
        }
        if sourceIndexPath != destinationIndexPath {
            fromSection.remove(at: sourceIndexPath.row, updateUI: false)
            toSection.insert(fromRow, at: destinationIndexPath.row)
            
            collectionView.reloadSections(IndexSet(integersIn: min(sourceIndexPath.section, destinationIndexPath.section) ... max(sourceIndexPath.section, destinationIndexPath.section)))
            // 动画结束后刷新布局（避免使用瀑布流时发生布局错乱）
            let deadline = DispatchTime.now() + 0.25
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                if let layout = collectionView.collectionViewLayout as? SWCollectionBaseLayout {
                    layout.updateLayout()
                } else {
                    collectionView.collectionViewLayout.invalidateLayout()
                }
            }
            
            fromSection.moveFinishClosure?(fromRow, sourceIndexPath, destinationIndexPath)
        }
    }
}

// MARK:- UICollectionViewDelegateFlowLayout
extension SWCollectionViewHandler: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard
            collectionView == self.collectionView,
            let section = form[indexPath.section] as? SWCollectionSection,
            let row = form[indexPath] as? SWCollectionItem
        else { return .zero }
        let sectionInset: UIEdgeInsets = section.contentInset
        // 计算Size
        if scrollDirection == .vertical {
            let width: CGFloat = floor((collectionView.frame.width - itemSpace * CGFloat(column - 1) - contentInset.left - contentInset.right - sectionInset.left - sectionInset.right) / CGFloat(column))
            let height = row.cellHeight(for: width)
            return CGSize(width: width, height: height)
        }
        let height: CGFloat = (collectionView.frame.height - lineSpace * CGFloat(column - 1) - contentInset.top - contentInset.bottom - sectionInset.top - sectionInset.bottom) / CGFloat(column)
        let width = row.cellWidth(for: height)
        return CGSize(width: width, height: height)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard
            let section = form[section] as? SWCollectionSection
        else {
            return .zero
        }
        return section.contentInset
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard
            let section = form[section] as? SWCollectionSection,
            let sectionLineSpace = section.lineSpace
        else {
            return lineSpace
        }
        return sectionLineSpace
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard
            let section = form[section] as? SWCollectionSection,
            let sectionItemSpace = section.itemSpace
        else {
            return itemSpace
        }
        return sectionItemSpace
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size = headerFooterSize(specifiedHeight: (form[section] as! SWCollectionSection).header?.height)
        return size
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let size = headerFooterSize(specifiedHeight: (form[section] as! SWCollectionSection).footer?.height)
        return size
    }
    
    /** 计算header和footer的size. */
    fileprivate func headerFooterSize(specifiedHeight: (() -> CGFloat)?) -> CGSize {
        if let height = specifiedHeight {
            return scrollDirection == .vertical ? CGSize(width: collectionView?.frame.width ?? 0,height: height()) : CGSize(width: height(),height: collectionView?.frame.height ?? 0)
        }
        return .zero
    }
}

// MARK:- CollectionBaseFlowLayoutDelegate
extension SWCollectionViewHandler : SWCollectionBaseLayoutDelegate {
    public func collectionViewLayout(_ collectionViewLayout: SWCollectionBaseLayout, heightOrWidthForHeaderAt indexPath: IndexPath) -> CGFloat {
        guard
            let section = form[indexPath.section] as? SWCollectionSection,
            let header = section.header else {
            return 0
        }
        return header.height?() ?? 0
    }
    
    public func collectionViewLayout(_ collectionViewLayout: SWCollectionBaseLayout, heightOrWidthForFooterAt indexPath: IndexPath) -> CGFloat {
        guard
            let section = form[indexPath.section] as? SWCollectionSection,
            let footer = section.footer else {
            return 0
        }
        return footer.height?() ?? 0
    }
    
    /// 是否需要悬浮
    public func collectionViewLayout(_ collectionViewLayout: SWCollectionBaseLayout, headerShouldSuspensionAt indexPath: IndexPath) -> Bool {
        guard
            let section = form[indexPath.section] as? SWCollectionSection,
            let header = section.header
        else {
            return false
        }
        return header.shouldSuspension
    }
    public func collectionViewLayout(_ collectionViewLayout: SWCollectionBaseLayout, footerShouldSuspensionAt indexPath: IndexPath) -> Bool {
        guard
            let section = form[indexPath.section] as? SWCollectionSection,
            let footer = section.footer
        else {
            return false
        }
        return footer.shouldSuspension
    }
    
    public func sectionInsetsInLayout(_ collectionViewLayout: SWCollectionBaseLayout, at indexPath: IndexPath) -> UIEdgeInsets {
        guard
            let section = form[indexPath.section] as? SWCollectionSection
        else {
            return .zero
        }
        return section.contentInset
    }
    
    public func contentInsetsInLayout(_ collectionViewLayout: SWCollectionBaseLayout) -> UIEdgeInsets {
        return contentInset
    }
    
    public func rowMarginInLayout(_ collectionViewLayout: SWCollectionBaseLayout, at indexPath: IndexPath) -> CGFloat {
        guard
            let section = form[indexPath.section] as? SWCollectionSection,
            let sectionLineSpace = section.lineSpace
        else {
            return lineSpace
        }
        return sectionLineSpace
    }
    
    public func columnMarginInLayout(_ collectionViewLayout: SWCollectionBaseLayout, at indexPath: IndexPath) -> CGFloat {
        guard
            let section = form[indexPath.section] as? SWCollectionSection,
            let sectionItemSpace = section.itemSpace
        else {
            return itemSpace
        }
        return sectionItemSpace
    }
    
    /// 计算item的大小
    public func collectionViewLayout(_ collectionViewLayout: SWCollectionBaseLayout, heightForItemAt indexPath: IndexPath, itemWidth width: CGFloat) -> CGFloat {
        guard let row = form[indexPath] as? SWCollectionItem else {
            return 0
        }
        let height = row.cellHeight(for: width)
        return height
    }
    
    public func collectionViewLayout(_ collectionViewLayout: SWCollectionBaseLayout, widthForItemAt indexPath: IndexPath, itemHeight height: CGFloat) -> CGFloat {
        guard let row = form[indexPath] as? SWCollectionItem else {
            return 0
        }
        let width = row.cellWidth(for: height)
        return width
    }
}

// MARK:- SWCollectionFlowLayoutDelegate
extension SWCollectionViewHandler : SWCollectionFlowLayoutDelegate {
    public func columnCountInLayout(_ collectionViewLayout: SWCollectionBaseLayout, at indexPath: IndexPath) -> NSInteger {
        guard
            let section = form[indexPath.section] as? SWCollectionSection,
            let sectionColum = section.column
        else {
            return column
        }
        return sectionColum
    }
}

// MARK:- WLYSWCollectionAlineLayoutDelegate
extension SWCollectionViewHandler : SWCollectionAlineLayoutDelegate {
    public func collectionView(_: UICollectionView, layout: SWCollectionBaseLayout, crossAxisAlignment inSection: Int) -> SWCollectionCrossAxisAligment {
        guard
            let section = form[inSection] as? SWCollectionSection,
            let sectionAligment = section.crossAxisAligment
        else {
            return crossAxisAligment
        }
        return sectionAligment
    }
    
    public func collectionView(_: UICollectionView, layout: SWCollectionBaseLayout, crossAxisDirection inSection: Int) -> SWCollectionCrossAxisDirection {
        guard
            let section = form[inSection] as? SWCollectionSection,
            let sectionDirection = section.crossAxisDirection
        else {
            return crossAxisDirection
        }
        return sectionDirection
    }
    
    public  func collectionView(_: UICollectionView, layout: SWCollectionBaseLayout, lineHeight inSection: Int) -> CGFloat {
        guard
            let section = form[inSection] as? SWCollectionSection,
            let sectionLineHeight = section.lineHeight
        else {
            return lineHeight
        }
        return sectionLineHeight
    }
}

// MARK:- SWCollectionBlendLayoutDelegate
extension SWCollectionViewHandler: SWCollectionBlendLayoutDelegate {
    public func collectionView(_: UICollectionView, layout: SWCollectionBaseLayout, arrangement inSection: Int) -> SWBlendLayoutArrangement {
        guard let section = form[inSection] as? SWCollectionSection else {
            return .flow
        }
        return section.arrangement
    }
}

// MARK:- UICollectionViewDelegate（含 UIScrollViewDelegate）
extension SWCollectionViewHandler: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard
            collectionView == self.collectionView,
            let row = form[indexPath] as? SWCollectionItem,
            let cell = row._cell
        else { return }
        
        if !cell.cellCanBecomeFirstResponder() || !cell.cellBecomeFirstResponder() {
            self.collectionView?.endEditing(true)
        }
        row.customHighlightCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard
            collectionView == self.collectionView,
            let row = form[indexPath] as? SWCollectionItem,
            let cell = row._cell
        else { return }
        
        if !cell.cellCanBecomeFirstResponder() || !cell.cellBecomeFirstResponder() {
            self.collectionView?.endEditing(true)
        }
        row.customUnHighlightCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            collectionView == self.collectionView,
            let row = form[indexPath] as? SWCollectionItem,
            let cell = row._cell
        else { return }
        
        if !cell.cellCanBecomeFirstResponder() || !cell.cellBecomeFirstResponder() {
            self.collectionView?.endEditing(true)
        }
        row.didSelect()
        row.customUnHighlightCell()
    }
    
    // 可变Section添加row
    public func collectionView(_ collectionView: UICollectionView, addRowAt indexPath: IndexPath) {
        guard
            let section = form[indexPath.section] as? SWCollectionMultivalusedSection,
            section.multivaluedOptions.contains(.Insert)
        else { return }
        guard let multivaluedRowToInsertAt = section.multivaluedRowToInsertAt else {
            fatalError("Multivalued section multivaluedRowToInsertAt property must be set up")
        }
        let newRow = multivaluedRowToInsertAt(max(0, section.count - 1))
        let index = max(0, section.count - 1)
        section.insert(newRow, at: index)
        rowsHaveBeenAdded([newRow], at: [IndexPath(row: index, section: section.index ?? 0)])
        collectionView.scrollToItem(at: IndexPath(row: section.count - 1, section: indexPath.section), at: scrollDirection == .vertical ? .centeredVertically : .centeredHorizontally , animated: true)
        if newRow._cell?.cellCanBecomeFirstResponder() ?? false {
            newRow._cell?.cellBecomeFirstResponder()
        } else if let inlineRow = newRow as?  SWBaseInlineRowType {
            inlineRow.expandInlineRow()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let row = form[indexPath] as? SWCollectionItem else {
            return
        }
        row.willDisplay()
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let row = form[indexPath] as? SWCollectionItem else {
            return
        }
        row.didEndDisplay()
    }
    
    // MARK: UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        notifyBeginScroll()
        delegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidZoom?(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        notifyBeginScroll()
        delegate?.scrollViewWillBeginDragging?(scrollView)
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
        updateLayout()
        notifyEndScroll()
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateLayout()
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
        updateLayout()
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
            for cell in collectionView?.visibleCells ?? [] {
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
            for cell in collectionView?.visibleCells ?? [] {
                if let observerCell = cell as? SWScrollObserverCellType {
                    observerCell.didEndScrolling()
                }
            }
        }
    }
}
