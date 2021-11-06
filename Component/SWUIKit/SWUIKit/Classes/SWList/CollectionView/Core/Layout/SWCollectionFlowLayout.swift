//
//  SWCollectionFlowLayout.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/15.
//

import UIKit

public protocol SWCollectionFlowLayoutDelegate: NSObject {
    /// 获取列数
    func columnCountInLayout(_ collectionViewLayout: SWCollectionBaseLayout, at indexPath: IndexPath) -> NSInteger
}

open class SWCollectionFlowLayout: SWCollectionBaseLayout {
    // 代理
    public weak var delegate: SWCollectionFlowLayoutDelegate!
    
    // 计算section中的所有item位置并添加到对应的数据对象中, 并返回section的item总高度
    open override func caculateItemAttributes(to sectionAttribute: SWFlowSectionAttribute, at indexPath: IndexPath) -> CGFloat {
        let itemCount = self.collectionView!.numberOfItems(inSection: indexPath.section)
        let contentEdges = contentInsets()
        let sectionEdges = sectionInsets(indexPath)
        let column = columnCount(indexPath)
        let columnSpace = columnMargin(indexPath)
        let lineSpace = rowMargin(indexPath)
        // 每次都清空计算的高度
        sectionAttribute.itemCounts = [Int](repeating: 0, count: column)
        sectionAttribute.itemHeights = [Int](repeating: Int(scrollDirection == .vertical ? sectionInsets(indexPath).top : sectionInsets(indexPath).left), count: column)
        for j in 0 ..< itemCount {
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
    
    /// 代理获取列数
    private func columnCount(_ indexPath: IndexPath) -> NSInteger {
        return delegate.columnCountInLayout(self, at: indexPath)
    }
}
