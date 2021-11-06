//
//  LineRow.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/11.
//

import Foundation
import UIKit
import SnapKit

// MARK:- LineCell
/// 分割线的cell，这里的value 没啥用
open class LineCell: SWTableCellOf<Bool> {
    
    let lineView: UIView = UIView()
    
    open override func setup() {
        super.setup()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero).priority(.low)
        }
    }
}

// MARK:- LineRow
/// 定义好的分割线Row，可自定义线的宽度、圆角、内容边距、线的颜色以及背景色
public final class LineRow: SWTableRowOf<LineCell>, SWRowType {
    
    /// 线的颜色
    public var lineColor: UIColor = .lightGray
    /// 线的圆角
    public var lineRadius: CGFloat = 0
    /// 线的宽度
    public var lineWidth: CGFloat = 0.5 {
        didSet {
            cellHeight = lineWidth + contentInsets.top + contentInsets.bottom
        }
    }
    
    // 更新cell的布局
    public override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell else {
            return
        }
        cell.lineView.backgroundColor = lineColor
        cell.lineView.layer.cornerRadius = min(lineRadius, lineWidth * 0.5)
        cell.lineView.snp.updateConstraints { (make) in
            make.edges.equalTo(contentInsets).priority(.low)
        }
        cell.layoutIfNeeded()
    }
    
    public override var identifier: String {
        return "LineRow"
    }
    
    public required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
        contentInsets = .zero
        cellHeight = 0.5
    }
}
