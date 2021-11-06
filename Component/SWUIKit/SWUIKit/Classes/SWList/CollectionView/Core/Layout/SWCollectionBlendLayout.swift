//
//  SWCollectionBlendLayout.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/23.
//

import UIKit

/// 排列方式
/// - flow: 瀑布流样式
/// - aline: 自动换行布局
public enum SWBlendLayoutArrangement: Equatable {
    case flow
    case aline
}

/// 混排layout的代理
public protocol SWCollectionBlendLayoutDelegate: NSObject {
    /// 获取排列方式
    func collectionView(_: UICollectionView, layout: SWCollectionBaseLayout, arrangement inSection: Int) -> SWBlendLayoutArrangement
}

open class SWCollectionBlendLayout: SWCollectionBaseLayout {
    /// 定义默认排列方式
    var itemsAlignment: SWCollectionCrossAxisAligment = .start
    var itemsDirection: SWCollectionCrossAxisDirection = .startToEnd
    var defaultLineHeight: CGFloat = 40
    var defaultArrangement: SWBlendLayoutArrangement = .flow
    // 定位
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    
    // 暂存当前行的item
    var currentLineItemAttributes = [UICollectionViewLayoutAttributes]()
    // 代理
    public weak var delegate: SWCollectionBlendLayoutDelegate!
    // align代理
    public weak var alignDelegate: SWCollectionAlineLayoutDelegate!
    // flow代理
    public weak var flowDelegate: SWCollectionFlowLayoutDelegate!
    
    // 计算section中的所有item位置并添加到对应的数据对象中, 并返回section的item总高度
    open override func caculateItemAttributes(to sectionAttribute: SWFlowSectionAttribute, at indexPath: IndexPath) -> CGFloat {
        let style = arrangement(section: indexPath.section)
        switch style {
            case .flow:
                return caculateFlowItemAttributes(to: sectionAttribute, at: indexPath)
            case .aline:
                return caculateAlineItemAttributes(to: sectionAttribute, at: indexPath)
        }
    }
}

// MARK:- Aline排列
extension SWCollectionBlendLayout {
    // 计算section中的所有item位置并添加到对应的数据对象中, 并返回section的item总高度
    public func caculateAlineItemAttributes(to sectionAttribute: SWFlowSectionAttribute, at indexPath: IndexPath) -> CGFloat {
        let itemCount = self.collectionView!.numberOfItems(inSection: indexPath.section)
        
        /// 间距
        let contentEdges = contentInsets()
        let sectionEdges = sectionInsets(indexPath)
        let columnSpace = columnMargin(indexPath)
        let lineSpace = rowMargin(indexPath)
        /// 行高
        let lineHeight = sectionLineHeight(section: indexPath.section)
        /// 排列方式
        let alignment = itemsHorizontalAlignment(section: indexPath.section)
        let direction = itemsDirection(section: indexPath.section)
        
        // 获取CollectionView宽高
        let collectionViewW = collectionView!.frame.width
        let collectionViewH = collectionView!.frame.height
        
        // 滚动方向
        let isVertical:Bool = scrollDirection == .vertical
        
        
        if isVertical {
            // 最大宽度
            let maxW = collectionViewW - contentEdges.left - contentEdges.right - sectionEdges.left - sectionEdges.right
            switch direction {
                case .startToEnd:
                    offsetX = contentEdges.left + sectionEdges.left
                    offsetY = currentOffset + sectionEdges.top
                case .endToStart:
                    offsetX = contentEdges.left + sectionEdges.left + maxW
                    offsetY = currentOffset + sectionEdges.top
            }
            for i in 0 ..< itemCount {
                let itemIndexPath = IndexPath(item: i, section: indexPath.section)
                // 获取宽度
                let itemWidth = baseDelegate.collectionViewLayout(self, widthForItemAt: itemIndexPath, itemHeight: lineHeight)
                sectionAttribute.itemAttributes.append(
                    layoutAttributesForVerticalItem(
                        at: itemIndexPath,
                        itemWidth: itemWidth,
                        lineHeight: lineHeight,
                        maxWidth: maxW,
                        alignment: alignment,
                        direction: direction,
                        columnSpace: columnSpace,
                        lineSpace: lineSpace,
                        contentEdges: contentEdges,
                        sectionEdges: sectionEdges
                    )
                )
            }
            if currentLineItemAttributes.count > 0 {
                /// 将当前行重新排序
                updateVerticalCurrentLineAttributes(maxWidth: maxW, alignment: alignment, direction: direction, columnSpace: columnSpace, lineSpace: lineSpace, contentEdges: contentEdges, sectionEdges: sectionEdges)
                /// 清空暂存数据
                currentLineItemAttributes.removeAll()
            }
            /// 返回section最终高度
            return offsetY + lineHeight + sectionEdges.bottom - sectionAttribute.headerEndPoint
        } else {
            // 最大高度
            let maxH = collectionViewH - contentEdges.top - contentEdges.bottom - sectionEdges.top - sectionEdges.bottom
            switch direction {
                case .startToEnd:
                    offsetY = contentEdges.top + sectionEdges.top
                    offsetX = currentOffset + sectionEdges.left
                case .endToStart:
                    offsetY = contentEdges.top + sectionEdges.top + maxH
                    offsetX = currentOffset + sectionEdges.left
            }
            for i in 0 ..< itemCount {
                let itemIndexPath = IndexPath(item: i, section: indexPath.section)
                // 获取高度
                let itemHeight = baseDelegate.collectionViewLayout(self, heightForItemAt: itemIndexPath, itemWidth: lineHeight)
                let indexPath = IndexPath(item: i, section: indexPath.section)
                sectionAttribute.itemAttributes.append(
                    layoutAttributesForHorizontalItem(
                        at: indexPath,
                        itemHeight: itemHeight,
                        lineHeight: lineHeight,
                        maxHeight: maxH,
                        alignment: alignment,
                        direction: direction,
                        columnSpace: columnSpace,
                        lineSpace: lineSpace,
                        contentEdges: contentEdges,
                        sectionEdges: sectionEdges
                    )
                )
            }
            if currentLineItemAttributes.count > 0 {
                /// 将当前行重新排序
                updateHorizontalCurrentLineAttributes(maxHeight: maxH, alignment: alignment, direction: direction, columnSpace: columnSpace, lineSpace: lineSpace, contentEdges: contentEdges, sectionEdges: sectionEdges)
                /// 清空暂存数据
                currentLineItemAttributes.removeAll()
            }
            /// 返回section最终宽度
            return offsetX + lineHeight + sectionEdges.right - sectionAttribute.headerEndPoint
        }
    }
}

// MARK:- 计算每个item位置(竖直滚动)
extension SWCollectionBlendLayout {
    // 计算每个item位置(竖直滚动)
    func layoutAttributesForVerticalItem(
        at indexPath: IndexPath,
        itemWidth: CGFloat,
        lineHeight: CGFloat,
        maxWidth: CGFloat,
        alignment: SWCollectionCrossAxisAligment,
        direction: SWCollectionCrossAxisDirection ,
        columnSpace: CGFloat, lineSpace: CGFloat,
        contentEdges: UIEdgeInsets,
        sectionEdges: UIEdgeInsets
    ) -> UICollectionViewLayoutAttributes {
        // 获取attributes
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        var frame = attr.frame
        /// 调整item的宽高到最大宽高
        if itemWidth > maxWidth {
            frame.size.width = maxWidth
        } else {
            frame.size.width = itemWidth
        }
        frame.size.height = lineHeight
        switch direction {
            case .startToEnd:
                // 定位x
                if offsetX + frame.width > maxWidth + contentEdges.left + sectionEdges.left {
                    /// 将当前行重新排序
                    updateVerticalCurrentLineAttributes(maxWidth: maxWidth, alignment: alignment, direction: direction, columnSpace: columnSpace, lineSpace: lineSpace, contentEdges: contentEdges, sectionEdges: sectionEdges)
                    /// 清空暂存数据
                    currentLineItemAttributes.removeAll()
                    /// 换行
                    offsetX = contentEdges.left + sectionEdges.left
                    offsetY += lineHeight + lineSpace
                }
                frame.origin.x = offsetX
                offsetX += frame.width + columnSpace
                /// 暂存
                currentLineItemAttributes.append(attr)
            case .endToStart:
                // 定位x
                if offsetX - frame.width < contentEdges.left + sectionEdges.left {
                    /// 将当前行重新排序
                    updateVerticalCurrentLineAttributes(maxWidth: maxWidth, alignment: alignment, direction: direction, columnSpace: columnSpace, lineSpace: lineSpace, contentEdges: contentEdges, sectionEdges: sectionEdges)
                    /// 清空暂存数据
                    currentLineItemAttributes.removeAll()
                    /// 换行
                    offsetX = contentEdges.left + sectionEdges.left + maxWidth
                    offsetY += lineHeight + lineSpace
                }
                frame.origin.x = offsetX - frame.width
                offsetX -= frame.width + columnSpace
                /// 暂存
                currentLineItemAttributes.append(attr)
        }
        frame.origin.y = offsetY
        attr.frame = frame
        return attr
    }
    
    /// 重新排列一行的位置(collectionView的滚动方向为垂直)
    func updateVerticalCurrentLineAttributes(
        maxWidth: CGFloat,
        alignment: SWCollectionCrossAxisAligment,
        direction: SWCollectionCrossAxisDirection,
        columnSpace: CGFloat, lineSpace: CGFloat,
        contentEdges: UIEdgeInsets,
        sectionEdges: UIEdgeInsets
    ) {
        // 将数组按坐标左到右排序
        currentLineItemAttributes.sort { (a, b) -> Bool in
            return a.frame.minX < b.frame.minX
        }
        if currentLineItemAttributes.count < 1 {
            return
        }
        switch alignment {
            case .fill:
                if direction == .startToEnd {
                    var addSpace: CGFloat = 0
                    var eachAdd: CGFloat = 0
                    if currentLineItemAttributes.count == 1 {
                        addSpace = (maxWidth - currentLineItemAttributes.last!.frame.maxX) * 0.5
                    } else {
                        eachAdd = (maxWidth - currentLineItemAttributes.last!.frame.maxX) / CGFloat(currentLineItemAttributes.count - 1)
                    }
                    for i in 0 ..< currentLineItemAttributes.count {
                        var frame = currentLineItemAttributes[i].frame
                        frame.origin.x += addSpace
                        addSpace += eachAdd
                        currentLineItemAttributes[i].frame = frame
                    }
                } else {
                    var cutSpace = currentLineItemAttributes.first!.frame.minX - contentEdges.left - sectionEdges.left
                    var eachCut: CGFloat = 0
                    if currentLineItemAttributes.count == 1 {
                        cutSpace *= 0.5
                    } else {
                        eachCut = cutSpace / CGFloat(currentLineItemAttributes.count - 1)
                    }
                    for i in 0 ..< currentLineItemAttributes.count {
                        var frame = currentLineItemAttributes[i].frame
                        frame.origin.x -= cutSpace
                        cutSpace -= eachCut
                        currentLineItemAttributes[i].frame = frame
                    }
                }
            case .start:
                if direction == .startToEnd {
                    return
                } else {
                    let cutSpace = currentLineItemAttributes.first!.frame.minX - contentEdges.left - sectionEdges.left
                    for i in 0 ..< currentLineItemAttributes.count {
                        var frame = currentLineItemAttributes[i].frame
                        frame.origin.x -= cutSpace
                        currentLineItemAttributes[i].frame = frame
                    }
                }
            case .center:
                if direction == .startToEnd {
                    let addSpace = (maxWidth + contentEdges.left + sectionEdges.left - currentLineItemAttributes.last!.frame.maxX) * 0.5
                    for i in 0 ..< currentLineItemAttributes.count {
                        var frame = currentLineItemAttributes[i].frame
                        frame.origin.x += addSpace
                        currentLineItemAttributes[i].frame = frame
                    }
                } else {
                    let cutSpace = (currentLineItemAttributes.first!.frame.minX - contentEdges.left - sectionEdges.left) * 0.5
                    for i in 0 ..< currentLineItemAttributes.count {
                        var frame = currentLineItemAttributes[i].frame
                        frame.origin.x -= cutSpace
                        currentLineItemAttributes[i].frame = frame
                    }
                }
            case .end:
                if direction == .startToEnd {
                    let addSpace = maxWidth + contentEdges.left + sectionEdges.left - currentLineItemAttributes.last!.frame.maxX
                    for i in 0 ..< currentLineItemAttributes.count {
                        var frame = currentLineItemAttributes[i].frame
                        frame.origin.x += addSpace
                        currentLineItemAttributes[i].frame = frame
                    }
                } else {
                    return
                }
        }
    }
}
// MARK:- 计算每个item位置(水平滚动)
extension SWCollectionBlendLayout {
    // 计算每个item位置(水平滚动)
    func layoutAttributesForHorizontalItem(
        at indexPath: IndexPath,
        itemHeight: CGFloat,
        lineHeight: CGFloat,
        maxHeight: CGFloat,
        alignment: SWCollectionCrossAxisAligment,
        direction: SWCollectionCrossAxisDirection ,
        columnSpace: CGFloat, lineSpace: CGFloat,
        contentEdges: UIEdgeInsets,
        sectionEdges: UIEdgeInsets
    ) -> UICollectionViewLayoutAttributes {
        // 获取attributes
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        var frame = attr.frame
        /// 调整item的宽高到最大宽高
        if itemHeight > maxHeight {
            frame.size.height = maxHeight
        } else {
            frame.size.height = itemHeight
        }
        frame.size.width = lineHeight
        switch direction {
            case .startToEnd:
                // 定位y
                if offsetY + frame.height > maxHeight + contentEdges.top + sectionEdges.top {
                    /// 将当前行重新排序
                    updateHorizontalCurrentLineAttributes(maxHeight: maxHeight, alignment: alignment, direction: direction, columnSpace: columnSpace, lineSpace: lineSpace, contentEdges: contentEdges, sectionEdges: sectionEdges)
                    /// 清空暂存数据
                    currentLineItemAttributes.removeAll()
                    /// 换行
                    offsetY = contentEdges.top + sectionEdges.top
                    offsetX += lineHeight + lineSpace
                }
                frame.origin.y = offsetY
                offsetY += frame.height + columnSpace
                /// 暂存
                currentLineItemAttributes.append(attr)
            case .endToStart:
                // 定位x
                if offsetY - frame.height < contentEdges.top + sectionEdges.top {
                    /// 将当前行重新排序
                    updateHorizontalCurrentLineAttributes(maxHeight: maxHeight, alignment: alignment, direction: direction, columnSpace: columnSpace, lineSpace: lineSpace, contentEdges: contentEdges, sectionEdges: sectionEdges)
                    /// 清空暂存数据
                    currentLineItemAttributes.removeAll()
                    /// 换行
                    offsetY = contentEdges.top + sectionEdges.top + maxHeight
                    offsetX += lineHeight + lineSpace
                }
                frame.origin.y = offsetY - frame.height
                offsetY -= frame.height + columnSpace
                /// 暂存
                currentLineItemAttributes.append(attr)
        }
        frame.origin.x = offsetX
        attr.frame = frame
        return attr
    }
    
    /// 重新排列一行的位置(collectionView的滚动方向为水平)
    func updateHorizontalCurrentLineAttributes(
        maxHeight: CGFloat,
        alignment: SWCollectionCrossAxisAligment,
        direction: SWCollectionCrossAxisDirection,
        columnSpace: CGFloat, lineSpace: CGFloat,
        contentEdges: UIEdgeInsets,
        sectionEdges: UIEdgeInsets
    ) {
        // 将数组按坐标上到下排序
        currentLineItemAttributes.sort { (a, b) -> Bool in
            return a.frame.minY < b.frame.minY
        }
        switch alignment {
            case .fill:
                if currentLineItemAttributes.count < 1 {
                    return
                }
                if direction == .startToEnd {
                    var addSpace: CGFloat = 0
                    var eachAdd: CGFloat = 0
                    if currentLineItemAttributes.count == 1 {
                        addSpace = (maxHeight - currentLineItemAttributes.last!.frame.maxY) * 0.5
                    } else {
                        eachAdd = (maxHeight - currentLineItemAttributes.last!.frame.maxY) / CGFloat(currentLineItemAttributes.count - 1)
                    }
                    for i in 0 ..< currentLineItemAttributes.count {
                        var frame = currentLineItemAttributes[i].frame
                        frame.origin.y += addSpace
                        addSpace += eachAdd
                        currentLineItemAttributes[i].frame = frame
                    }
                } else {
                    var cutSpace = currentLineItemAttributes.first!.frame.minY - contentEdges.top - sectionEdges.top
                    var eachCut: CGFloat = 0
                    if currentLineItemAttributes.count == 1 {
                        cutSpace *= 0.5
                    } else {
                        eachCut = cutSpace / CGFloat(currentLineItemAttributes.count - 1)
                    }
                    for i in 0 ..< currentLineItemAttributes.count {
                        var frame = currentLineItemAttributes[i].frame
                        frame.origin.y -= cutSpace
                        cutSpace -= eachCut
                        currentLineItemAttributes[i].frame = frame
                    }
                }
            case .start:
                if direction == .startToEnd {
                    return
                } else {
                    let cutSpace = currentLineItemAttributes.first!.frame.minY - contentEdges.top - sectionEdges.top
                    for i in 0 ..< currentLineItemAttributes.count {
                        var frame = currentLineItemAttributes[i].frame
                        frame.origin.y -= cutSpace
                        currentLineItemAttributes[i].frame = frame
                    }
                }
            case .center:
                if direction == .startToEnd {
                    let addSpace = (maxHeight + contentEdges.top + sectionEdges.top - currentLineItemAttributes.last!.frame.maxY) * 0.5
                    for i in 0 ..< currentLineItemAttributes.count {
                        var frame = currentLineItemAttributes[i].frame
                        frame.origin.y += addSpace
                        currentLineItemAttributes[i].frame = frame
                    }
                } else {
                    let cutSpace = (currentLineItemAttributes.first!.frame.minY - contentEdges.top - sectionEdges.top) * 0.5
                    for i in 0 ..< currentLineItemAttributes.count {
                        var frame = currentLineItemAttributes[i].frame
                        frame.origin.y -= cutSpace
                        currentLineItemAttributes[i].frame = frame
                    }
                }
            case .end:
                if direction == .startToEnd {
                    let addSpace = maxHeight + contentEdges.top + sectionEdges.top - currentLineItemAttributes.last!.frame.maxY
                    for i in 0 ..< currentLineItemAttributes.count {
                        var frame = currentLineItemAttributes[i].frame
                        frame.origin.y += addSpace
                        currentLineItemAttributes[i].frame = frame
                    }
                } else {
                    return
                }
        }
    }
}

// MARK:- Flow排列
extension SWCollectionBlendLayout {
    // 计算section中的所有item位置并添加到对应的数据对象中, 并返回section的item总高度
    public func caculateFlowItemAttributes(to sectionAttribute: SWFlowSectionAttribute, at indexPath: IndexPath) -> CGFloat {
        let itemCount = self.collectionView!.numberOfItems(inSection: indexPath.section)
        let contentEdges = contentInsets()
        let sectionEdges = sectionInsets(indexPath)
        let column = columnCount(indexPath)
        let columnSpace = columnMargin(indexPath)
        let lineSpace = rowMargin(indexPath)
        // 每次都清空计算的高度
        sectionAttribute.itemCounts = [Int](repeating: 0, count: column)
        sectionAttribute.itemHeights = [Int](repeating: Int(scrollDirection == .vertical ? sectionInsets(indexPath).top : sectionInsets(indexPath).left), count: column)
        for j in 0..<itemCount {
            let indexPath = IndexPath(item: j, section: indexPath.section)
            let attr = layoutAttributesForItem(at: indexPath, sectionAttr: sectionAttribute, column: column, columnSpace: columnSpace, lineSpace: lineSpace, contentEdges: contentEdges, sectionEdges: sectionEdges)
            sectionAttribute.itemAttributes.append(attr)
        }
        // 找出最高列列号
        let maxHeight:Int = sectionAttribute.itemHeights.sorted().last!
        return CGFloat(maxHeight)
    }
    
    // 计算每个item位置
    func layoutAttributesForItem(
        at indexPath: IndexPath,
        sectionAttr: SWFlowSectionAttribute,
        column: Int,
        columnSpace: CGFloat,
        lineSpace: CGFloat,
        contentEdges: UIEdgeInsets,
        sectionEdges: UIEdgeInsets
    ) -> UICollectionViewLayoutAttributes {
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        // 获取CollectionView宽高
        let collectionViewW = collectionView?.frame.width
        let collectionViewH = collectionView?.frame.height
        
        // 垂直滚动，宽度一样
        let defaultW = (collectionViewW! - contentEdges.left - contentEdges.right - sectionEdges.left - sectionEdges.right - CGFloat(column - 1) * columnSpace) / CGFloat(column)
        // 水平滚动，高度一样
        let defaultH = (collectionViewH! - contentEdges.top - contentEdges.bottom - sectionEdges.top - sectionEdges.bottom - CGFloat(column - 1) * lineSpace) / CGFloat(column)
        
        let isVertical:Bool = scrollDirection == .vertical
        let w = isVertical ? defaultW : baseDelegate.collectionViewLayout(self, widthForItemAt: indexPath, itemHeight: defaultH)
        let h = isVertical ? baseDelegate.collectionViewLayout(self, heightForItemAt: indexPath, itemWidth: defaultW) : defaultH
        
        // 获取最短的高度/宽度
        let minHeight:Int = sectionAttr.itemHeights.sorted().first!
        let columnIndex = sectionAttr.itemHeights.firstIndex(of: minHeight)
        // 数据追加在最短列
        sectionAttr.itemCounts[columnIndex!] += 1
        
        // 计算 x y 位置
        let x = isVertical ? (contentEdges.left + sectionEdges.left + CGFloat(columnIndex!) * (w + columnSpace)) : (CGFloat(minHeight) + currentOffset)
        let y = isVertical ? (CGFloat(minHeight) + currentOffset) : (contentEdges.top + sectionEdges.top + CGFloat(columnIndex!) * (h + columnSpace))
    
        // 设置位置
        attr.frame = CGRect(x: Double(x), y: Double(y), width: Double(w), height: Double(h))
        
        sectionAttr.itemHeights[columnIndex!] += Int(isVertical ? h : w) + Int(lineSpace)
        return attr
    }
}

// MARK:- 代理获取数据
extension SWCollectionBlendLayout {
    /// 代理获取排列方式
    private func arrangement(section atIndex: Int) -> SWBlendLayoutArrangement {
        guard let collection = self.collectionView else {
            return .flow
        }
        return delegate.collectionView(collection, layout: self, arrangement: atIndex)
    }
    
    /// 代理获取排列方式
    func itemsHorizontalAlignment(section atIndex: Int) -> SWCollectionCrossAxisAligment {
        guard let collection = self.collectionView else {
            return self.itemsAlignment
        }
        let result = self.alignDelegate.collectionView(collection, layout: self, crossAxisAlignment: atIndex)
        return result
    }
    
    func itemsDirection(section atIndex: Int) -> SWCollectionCrossAxisDirection {
        guard let collection = self.collectionView else {
            return self.itemsDirection
        }
        let result = self.alignDelegate.collectionView(collection, layout: self, crossAxisDirection: atIndex)
        return result
    }
    
    func sectionLineHeight(section atIndex: Int) -> CGFloat {
        guard let collection = self.collectionView else {
            return self.defaultLineHeight
        }
        let result = self.alignDelegate.collectionView(collection, layout: self, lineHeight: atIndex)
        return result
    }
    
    /// 代理获取列数
    private func columnCount(_ indexPath: IndexPath) -> NSInteger {
        return flowDelegate.columnCountInLayout(self, at: indexPath)
    }
}

