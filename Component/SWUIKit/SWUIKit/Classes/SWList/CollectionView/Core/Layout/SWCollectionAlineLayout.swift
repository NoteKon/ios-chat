//
//  SWCollectionAlineLayout.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/15.
//

/// 与滚动方向垂直的轴的元素布局方式
/// * 位置参考：
///     scrollDirection为vertical（竖直滚动）时，start表示左侧，end表示右侧
///     scrollDirection为horizontal（水平滚动）时，start表示上方，end表示下方
///
/// - fill: 充满(撑满，剩余空间平分)
/// - start: 集中于开始位置
/// - center: 集中于中间位置
/// - end: 集中于结束位置
public enum SWCollectionCrossAxisAligment {
    case fill
    case start
    case center
    case end
}

/// 与滚动方向垂直的轴的元素的排布方向
/// * 位置参考：
///     scrollDirection为vertical（竖直滚动）时，start表示左侧，end表示右侧
///     scrollDirection为horizontal（水平滚动）时，start表示上方，end表示下方
///
/// - startToEnd:  从开始位置到结束位置
/// - endToStart:  从结束位置到开始位置
public enum SWCollectionCrossAxisDirection {
    case startToEnd
    case endToStart
}

public protocol SWCollectionAlineLayoutDelegate: NSObject {
    /// 获取 section 的 items 排列方向的对齐方式
    func collectionView(_: UICollectionView, layout: SWCollectionBaseLayout, crossAxisAlignment inSection: Int) -> SWCollectionCrossAxisAligment
    
    /// 获取 section 的 items 的排布方向
    func collectionView(_: UICollectionView, layout: SWCollectionBaseLayout, crossAxisDirection inSection: Int) -> SWCollectionCrossAxisDirection
    
    /// 获取 section 的行高
    func collectionView(_: UICollectionView, layout: SWCollectionBaseLayout, lineHeight inSection: Int) -> CGFloat
}

/// 在 UICollectionViewFlowLayout 基础上，自定义 UICollectionView 对齐布局
///
/// 实现以下功能：
/// 1. 设置排列方向对齐方式：流式（默认）、居左、居中、居右、平铺；
/// 2. 设置显示条目排布方向：从左到右（默认）、从右到左。
open class SWCollectionAlineLayout: SWCollectionBaseLayout {
    /// 定义默认排列方式
    var itemsAlignment: SWCollectionCrossAxisAligment = .start
    var itemsDirection: SWCollectionCrossAxisDirection = .startToEnd
    var defaultLineHeight: CGFloat = 40

    // 定位
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    
    // 暂存当前行的item
    var currentLineItemAttributes = [UICollectionViewLayoutAttributes]()
    
    // 代理
    public weak var delegate: SWCollectionAlineLayoutDelegate!
    
    // 计算section中的所有item位置并添加到对应的数据对象中, 并返回section的item总高度
    open override func caculateItemAttributes(to sectionAttribute: SWFlowSectionAttribute, at indexPath: IndexPath) -> CGFloat {
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
extension SWCollectionAlineLayout {
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
extension SWCollectionAlineLayout {
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
    
// MARK:- 代理获取排列方式
extension SWCollectionAlineLayout {
    func itemsHorizontalAlignment(section atIndex: Int) -> SWCollectionCrossAxisAligment {
        guard let collection = self.collectionView else {
            return self.itemsAlignment
        }
        let result = self.delegate.collectionView(collection, layout: self, crossAxisAlignment: atIndex)
        return result
    }
    
    func itemsDirection(section atIndex: Int) -> SWCollectionCrossAxisDirection {
        guard let collection = self.collectionView else {
            return self.itemsDirection
        }
        let result = self.delegate.collectionView(collection, layout: self, crossAxisDirection: atIndex)
        return result
    }
    
    func sectionLineHeight(section atIndex: Int) -> CGFloat {
        guard let collection = self.collectionView else {
            return self.defaultLineHeight
        }
        let result = self.delegate.collectionView(collection, layout: self, lineHeight: atIndex)
        return result
    }
}
