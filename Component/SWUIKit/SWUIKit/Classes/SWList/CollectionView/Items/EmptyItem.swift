//
//  EmptyItem.swift
//  SWUIKit
//
//  Created by Guo ZhongCheng on 2021/3/30.
//

import Foundation
// MARK:- EmptyCell
/// 分割线的cell，这里的value 没啥用
open class CollectionEmptyCell: SWCollectionCellOf<Bool> {
    
    open override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}

// MARK:- LineRow
/// 定义好的分割线Item，可自定义线的宽度、圆角、内容边距、线的颜色以及背景色
public final class EmptyItem: SWCollectionItemOf<CollectionEmptyCell> {
    
    public override var identifier: String {
        return "EmptyItem"
    }
    
    required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
    }
    
    // 优先级: 固定宽/高度 > 固定比例 > 0
    /// 固定高度
    var itemHeight: CGFloat?
    /// 固定宽度
    var itemWidth: CGFloat?
    /// 固定比例
    var itemRatio: CGSize?
    
    /// 固定高度创建
    /// - Parameter height: 高度
    public init(height: CGFloat) {
        super.init(title: nil, tag: nil)
        itemHeight = height
    }
    
    /// 固定宽度创建
    /// - Parameter width: 宽度
    public init(width: CGFloat) {
        super.init(title: nil, tag: nil)
        itemWidth = width
    }
    
    /// 固定比例创建
    /// - Parameter ratio: 比例
    public init(ratio: CGSize) {
        super.init(title: nil, tag: nil)
        itemRatio = ratio
    }
    
    public override func cellHeight(for width: CGFloat) -> CGFloat {
        if let heigh = itemHeight {
            return heigh
        }
        if let ratio = itemRatio {
            return width * ratio.height / ratio.width
        }
        return 0
    }
    
    public override func cellWidth(for height: CGFloat) -> CGFloat {
        if let width = itemWidth {
            return width
        }
        if let ratio = itemRatio {
            return height * ratio.width / ratio.height
        }
        return 0
    }
}
