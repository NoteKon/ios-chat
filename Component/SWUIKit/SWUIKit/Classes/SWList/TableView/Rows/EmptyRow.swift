//
//  EmptyRow.swift
//  SWUIKit
//
//  Created by Guo ZhongCheng on 2021/3/30.
//

import Foundation

// MARK:- EmptyCell
/// 分割线的cell，这里的value 没啥用
open class EmptyCell: SWTableCellOf<Bool> {
    
    open override func setup() {
        super.setup()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}

// MARK:- LineRow
/// 定义好的分割线Row，可自定义线的宽度、圆角、内容边距、线的颜色以及背景色
public final class EmptyRow: SWTableRowOf<EmptyCell> {
    
    public override var identifier: String {
        return "EmptyRow"
    }
    
    /// 固定高度创建
    /// - Parameter height: 高度
    public init(height: CGFloat) {
        super.init(title: nil, tag: nil)
        cellHeight = height
    }
    
    required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
    }
}
