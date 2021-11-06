//
//  SWCollectionBaseLayout.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/21.
//

import UIKit

public class SWFlowSectionAttribute: NSObject {
    public var indexPath: IndexPath!
    
    /// header位置
    public var headerAttributes: UICollectionViewLayoutAttributes?
    /// footer位置
    public var footerAttributes: UICollectionViewLayoutAttributes?
    /// 存放item位置的数组
    public var itemAttributes: [UICollectionViewLayoutAttributes] = []
    
    /// 存放每一列的高度（宽度）数组
    public var itemHeights = [Int]()
    /// 记录每一列的item总个数
    public var itemCounts =  [Int]()
    
    public var headerStartPoint: CGFloat = 0
    public var headerEndPoint: CGFloat = 0
    public var footerStarPoint: CGFloat = 0
    public var footerEndPoint: CGFloat = 0
}

public protocol SWCollectionBaseLayoutDelegate: NSObject {
    /// 获取头部的高度（垂直滚动）或宽度（水平滚动）
    func collectionViewLayout(_ collectionViewLayout: SWCollectionBaseLayout, heightOrWidthForHeaderAt indexPath: IndexPath) -> CGFloat
    
    /// 获取尾部的高度（垂直滚动）或宽度（水平滚动）
    func collectionViewLayout(_ collectionViewLayout: SWCollectionBaseLayout, heightOrWidthForFooterAt indexPath: IndexPath) -> CGFloat
    
    /// 头部的视图是否需要悬浮
    func collectionViewLayout(_ collectionViewLayout: SWCollectionBaseLayout, headerShouldSuspensionAt indexPath: IndexPath) -> Bool
    
    /// 尾部的视图是否需要悬浮
    func collectionViewLayout(_ collectionViewLayout: SWCollectionBaseLayout, footerShouldSuspensionAt indexPath: IndexPath) -> Bool
    
    /// section内元素的上左下右间距
    func sectionInsetsInLayout(_ collectionViewLayout: SWCollectionBaseLayout, at indexPath: IndexPath) -> UIEdgeInsets
    
    /// collectionView的上左下右间距
    func contentInsetsInLayout(_ collectionViewLayout: SWCollectionBaseLayout) -> UIEdgeInsets
    
    /// 列间距
    func columnMarginInLayout(_ collectionViewLayout: SWCollectionBaseLayout, at indexPath: IndexPath) -> CGFloat
    /// 行间距
    func rowMarginInLayout(_ collectionViewLayout: SWCollectionBaseLayout, at indexPath: IndexPath) -> CGFloat
    
    /// 根据宽度，获取对应的比例的高度 用于垂直滚动
    func collectionViewLayout(_ collectionViewLayout: SWCollectionBaseLayout, heightForItemAt indexPath: IndexPath, itemWidth width:CGFloat) -> CGFloat
    
    /// 根据高度，获取对应的比例的宽度 用于水平滚动
    func collectionViewLayout(_ collectionViewLayout: SWCollectionBaseLayout, widthForItemAt indexPath: IndexPath, itemHeight height:CGFloat) -> CGFloat
}

open class SWCollectionBaseLayout: UICollectionViewFlowLayout {
    /// 存放各section位置等数据的数组
    public var sectionAttributes: [SWFlowSectionAttribute] = []
    /// 计算中的中间量，用于定位各个section的header、footer、items的开始位置
    public var currentOffset: CGFloat = 0
    /// 存储整个view的高度（宽度）
    public var maxH:Int = 0
    
    /// 是否需要重新布局
    private var shouldRecalculation: Bool = true
    /// 是否在插入/移除动画过程中
    public var isInAnimation: Bool = false
    
    // 代理
    public weak var baseDelegate: SWCollectionBaseLayoutDelegate!
    
    /// 刷新布局
    public func updateLayout() {
        shouldRecalculation = true
        invalidateLayout()
    }
    
    /**
    *  collectionView初次显示或者调用invalidateLayout方法后会调用此方法
    *  触发此方法会重新计算布局，每次布局也是从此方法开始
    *  在此方法中需要做的事情是准备后续计算所需的东西，以得出后面的ContentSize和每个item的layoutAttributes
    */
    override open func prepare() {
        if !isInAnimation {
            if !shouldRecalculation {
                return
            }
            shouldRecalculation = false
        }
        // 每次都清空所有位置
        sectionAttributes.removeAll()
        let sectionCount = self.collectionView!.numberOfSections
        let contentEdge = contentInsets()
        currentOffset = scrollDirection == .vertical ? contentEdge.top : contentEdge.left
        for i in 0 ..< sectionCount {
            /** 添加头部 */
            let indexPath = IndexPath(item: 0, section: i)
            let header = baseDelegate.collectionViewLayout(self, heightOrWidthForHeaderAt: indexPath)
            let sectionAttr = SWFlowSectionAttribute()
            sectionAttr.indexPath = indexPath
            sectionAttr.headerStartPoint = currentOffset
            if header > 0 {
                let (value, attr) = self.layoutAttributesForHeaderFooterView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath, contentInsets: contentEdge)
                sectionAttr.headerAttributes = attr
                currentOffset += value
            }
            sectionAttr.headerEndPoint = currentOffset
            
            /** 添加items */
            currentOffset += caculateItemAttributes(to: sectionAttr, at: indexPath)
            /** 添加尾部 */
            let footer = baseDelegate.collectionViewLayout(self, heightOrWidthForFooterAt: indexPath)
            sectionAttr.footerStarPoint = currentOffset
            if footer > 0 {
                let (value, attr) = self.layoutAttributesForHeaderFooterView(ofKind: UICollectionView.elementKindSectionFooter, at: indexPath, contentInsets: contentEdge)
                sectionAttr.footerAttributes = attr
                sectionAttr.footerStarPoint = currentOffset
                currentOffset += value
            }
            sectionAttr.footerEndPoint = currentOffset
            sectionAttributes.append(sectionAttr)
        }
        maxH = Int(currentOffset + contentEdge.bottom)
    }
    
    open func caculateItemAttributes(to sectionAttribute: SWFlowSectionAttribute, at indexPath: IndexPath) -> CGFloat {
        fatalError("必须重写,在此方法中计算section各元素位置，添加更新到sectionAttribute中，并返回此section的最终高度")
    }
    
    /**
    *  当CollectionView开始刷新后，会调用此方法并传递rect参数（即当前可视区域）
    *  我们需要利用rect参数判断出在当前可视区域中有哪几个indexPath会被显示（无视rect而全部计算将会带来不好的性能）
    *  最后计算相关indexPath的layoutAttributes，加入数组中并返回
    */
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attrs = [UICollectionViewLayoutAttributes]()
        for i in 0 ..< sectionAttributes.count {
            let attr = sectionAttributes[i]
            /// 后面的还没有进入展示的范围，直接返回
            if scrollDirection == .vertical,attr.headerStartPoint > rect.maxY {
                break
            }
            if scrollDirection == .horizontal,attr.headerStartPoint > rect.maxX {
                break
            }
            if let items = attributesForItemsInRect(rect, at: attr) {
                attrs.append(contentsOf: items)
            }
            if let header = attributesForHeaderInRect(rect, at: attr) {
                attrs.append(header)
            }
            if let footer = attributesForFooterInRect(rect, at: attr) {
                attrs.append(footer)
            }
        }
        return attrs
    }
    
    // 内容总高度、宽度
    override open var collectionViewContentSize: CGSize {
        if scrollDirection == .horizontal {
            return CGSize(width: CGFloat(maxH), height: (collectionView!.bounds.height))
        }
        return CGSize(width: (collectionView!.bounds.width), height: CGFloat(maxH))
    }
    
    // 返回指定位置的item的位置
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.section < sectionAttributes.count else {
            return nil
        }
        let sectionAttribute = sectionAttributes[indexPath.section]
        guard indexPath.row < sectionAttribute.itemAttributes.count else {
            return nil
        }
        return sectionAttribute.itemAttributes[indexPath.row]
    }
    
    /// 代理获取section的上下左右间距
    public func sectionInsets(_ indexPath: IndexPath) -> UIEdgeInsets {
        return baseDelegate.sectionInsetsInLayout(self, at: indexPath)
    }
    
    /// 代理获取collectionView的上左下右间距
    public func contentInsets() -> UIEdgeInsets {
        return baseDelegate.contentInsetsInLayout(self)
    }
    
    /// 代理获取列间距
    public func columnMargin(_ indexPath: IndexPath) -> CGFloat {
        return baseDelegate.columnMarginInLayout(self, at: indexPath)
    }
    
    /// 代理获取行间距
    public func rowMargin(_ indexPath: IndexPath) -> CGFloat {
        return baseDelegate.rowMarginInLayout(self, at: indexPath)
    }
    
    /// 显示范围改变时是否需要重新布局
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // 计算header/footer的位置，返回值为（增加的高度/宽度，位置信息）
    func layoutAttributesForHeaderFooterView(ofKind elementKind: String, at indexPath: IndexPath, contentInsets: UIEdgeInsets) -> (CGFloat, UICollectionViewLayoutAttributes) {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)

        let maxWidth = collectionView!.bounds.width - contentInsets.left - contentInsets.right
        let maxHeight = collectionView!.bounds.height - contentInsets.top - contentInsets.bottom
        
        var value: CGFloat = 0
        if elementKind == UICollectionView.elementKindSectionHeader {
            value = baseDelegate.collectionViewLayout(self, heightOrWidthForHeaderAt: indexPath)
            if scrollDirection == .vertical {
                attributes.frame = CGRect(x: contentInsets.left, y: currentOffset, width: maxWidth, height: value)
            } else {
                attributes.frame = CGRect(x: currentOffset, y: contentInsets.top, width: value, height: maxHeight)
            }
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            value = baseDelegate.collectionViewLayout(self, heightOrWidthForFooterAt: indexPath)
            if scrollDirection == .vertical {
                attributes.frame = CGRect(x: contentInsets.left, y: currentOffset, width: maxWidth, height: value)
            } else {
                attributes.frame = CGRect(x: currentOffset, y: contentInsets.top, width: value, height: maxHeight)
            }
        }
        return (value,attributes)
    }
    
    /// 找到要展示的item的位置
    public func attributesForItemsInRect(_ rect: CGRect, at section: SWFlowSectionAttribute) -> [UICollectionViewLayoutAttributes]? {
        var attrs = [UICollectionViewLayoutAttributes]()
        for attr in section.itemAttributes {
            if rect.intersects(attr.frame) {
                attrs.append(attr)
            }
        }
        return attrs
    }
    
    /// 找到要展示的header/footer的位置
    public func attributesForHeaderInRect(_ rect: CGRect, at section: SWFlowSectionAttribute) -> UICollectionViewLayoutAttributes? {
        let attr = section
        if attr.headerAttributes == nil {
            return nil
        }
        /// 是否需要悬浮
        let shouldSuspension = baseDelegate.collectionViewLayout(self, headerShouldSuspensionAt: attr.indexPath)
        if shouldSuspension {
            let headerSize = baseDelegate.collectionViewLayout(self, heightOrWidthForHeaderAt: attr.indexPath)
            if scrollDirection == .vertical, attr.headerStartPoint >= collectionView!.contentOffset.y  {
                var frame = attr.headerAttributes!.frame
                frame.origin.y = attr.headerStartPoint
                attr.headerAttributes?.frame = frame
                return attr.headerAttributes
            }
            if scrollDirection == .horizontal, attr.headerStartPoint >= collectionView!.contentOffset.x  {
                var frame = attr.headerAttributes!.frame
                frame.origin.x = attr.headerStartPoint
                attr.headerAttributes?.frame = frame
                return attr.headerAttributes
            }
            var nextAttrPosition: CGFloat?
            if attr.footerAttributes != nil {
                nextAttrPosition = attr.footerStarPoint
            } else
            if let nextAttr = nextSectionAttr(attr) {
                /// 已经滚动到下一个，直接跳过
                if scrollDirection == .vertical, collectionView!.contentOffset.y > nextAttr.headerStartPoint {
                    return nil
                }
                if scrollDirection == .horizontal, collectionView!.contentOffset.x > nextAttr.headerStartPoint {
                    return nil
                }
                nextAttrPosition = nextAttr.headerStartPoint
            }
            if scrollDirection == .vertical {
                let width = attr.headerAttributes?.frame.width ?? collectionViewContentSize.width
                let x: CGFloat = attr.headerAttributes?.frame.minX ?? 0
                let offsetY = collectionView!.contentOffset.y
                var y = offsetY
                if
                    let next = nextAttrPosition,
                    next - offsetY < headerSize
                {
                    y = next - headerSize
                }
                attr.headerAttributes?.frame = CGRect(x: x, y: y, width: width, height: headerSize)
                attr.headerAttributes?.zIndex = 1024
            } else {
                let height = attr.headerAttributes?.frame.height ?? collectionViewContentSize.height
                let y: CGFloat = attr.headerAttributes?.frame.minY ?? 0
                let offsetX = collectionView!.contentOffset.x
                var x = offsetX
                if
                    let next = nextAttrPosition,
                    next - offsetX < headerSize
                {
                    x = next - headerSize
                }
                attr.headerAttributes?.frame = CGRect(x: x, y: y, width: headerSize, height: height)
                attr.headerAttributes?.zIndex = 1024
            }
            return attr.headerAttributes
        } else {
            return attr.headerAttributes
        }
    }
    public func attributesForFooterInRect(_ rect: CGRect, at section: SWFlowSectionAttribute) -> UICollectionViewLayoutAttributes? {
        let attr = section
        if attr.footerAttributes == nil {
            return nil
        }
        /// 是否需要悬浮
        let shouldSuspension = baseDelegate.collectionViewLayout(self, footerShouldSuspensionAt: attr.indexPath)
        if shouldSuspension {
            if scrollDirection == .vertical, attr.footerEndPoint < collectionView!.contentOffset.y + collectionView!.bounds.height  {
                var frame = attr.footerAttributes!.frame
                frame.origin.y = attr.footerStarPoint
                attr.footerAttributes?.frame = frame
                return attr.footerAttributes
            }
            if scrollDirection == .horizontal, attr.footerEndPoint < collectionView!.contentOffset.x + collectionView!.bounds.width  {
                var frame = attr.footerAttributes!.frame
                frame.origin.x = attr.footerStarPoint
                attr.footerAttributes?.frame = frame
                return attr.footerAttributes
            }
            var lastAttrPosition: CGFloat?
            if attr.headerAttributes != nil {
                lastAttrPosition = attr.headerEndPoint
            } else
            if let lastAttr = lastSectionAttr(attr) {
                /// 已经滚动到上一个section，跳过
                if scrollDirection == .vertical, lastAttr.footerEndPoint > collectionView!.contentOffset.y + collectionView!.bounds.height {
                    return nil
                }
                if scrollDirection == .horizontal, lastAttr.footerEndPoint > collectionView!.contentOffset.x + collectionView!.bounds.width {
                    return nil
                }
                lastAttrPosition = lastAttr.footerEndPoint
            }
            
            let footerSize = baseDelegate.collectionViewLayout(self, heightOrWidthForFooterAt: attr.indexPath)
            if scrollDirection == .vertical {
                let width = attr.footerAttributes?.frame.width ?? collectionViewContentSize.width
                let x: CGFloat = attr.footerAttributes?.frame.minX ?? 0
                let offsetY = collectionView!.contentOffset.y + collectionView!.bounds.height
                var y = offsetY - footerSize
                if
                    let last = lastAttrPosition,
                    offsetY - last < footerSize
                {
                    y = attr.headerEndPoint
                }
                attr.footerAttributes?.frame = CGRect(x: x, y: y, width: width, height: footerSize)
                attr.footerAttributes?.zIndex = 1024
            } else {
                let height = attr.footerAttributes?.frame.height ?? collectionViewContentSize.height
                let y: CGFloat = attr.footerAttributes?.frame.minY ?? 0
                let offsetX = collectionView!.contentOffset.x + collectionView!.bounds.width
                var x = offsetX - footerSize
                if
                    let last = lastAttrPosition,
                    offsetX - last < footerSize
                {
                    x = attr.headerEndPoint
                }
                attr.footerAttributes?.frame = CGRect(x: x, y: y, width: footerSize, height: height)
                attr.footerAttributes?.zIndex = 1024
            }
            return attr.footerAttributes
        } else {
            return attr.footerAttributes
        }
    }
    
    /// 下一个section
    func nextSectionAttr(_ attribute: SWFlowSectionAttribute?) -> SWFlowSectionAttribute? {
        guard let attr = attribute else {
            return nil
        }
        var index: Int = sectionAttributes.firstIndex(of: attr)!
        if index == sectionAttributes.count - 1 {
            return nil
        }
        index += 1
        return sectionAttributes[index]
    }
    
    /// 上一个section
    func lastSectionAttr(_ attribute: SWFlowSectionAttribute?) -> SWFlowSectionAttribute? {
        guard let attr = attribute else {
            return nil
        }
        var index: Int = sectionAttributes.firstIndex(of: attr)!
        if index == 0 {
            return nil
        }
        index -= 1
        return sectionAttributes[index]
    }
}

