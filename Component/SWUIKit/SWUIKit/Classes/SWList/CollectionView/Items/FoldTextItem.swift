//
//  FoldTextItem.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/23.
//

import UIKit
import SnapKit

// MARK:- CollectionFoldTextCell
/// 文字内容可折叠的cell, value表示是否已打开
open class FoldCollectionTextCell: FoldCollectionCell {
    /// 折叠内容
    let _foldTextView: SWFoldTextView = SWFoldTextView()
    open override var foldContentView: SWFoldContentView {
        return _foldTextView
    }
}

// MARK: FoldTextItem
open class _FoldTextItem: _FoldItemOf<FoldCollectionTextCell> {
    /// 内容样式
    public var fontOfText: UIFont = UIFont.systemFont(ofSize: 15)
    public var colorOfText: UIColor = UIColor.black
    public var alignmentOfText: NSTextAlignment = .left
    /// 富文本内容，该设置会替换title作为展示内容
    public var attributeText: NSAttributedString?
    
    // 更新cell的布局
    open override func customUpdateCell() {
        guard let cell = cell else {
            super.customUpdateCell()
            return
        }
        
        cell._foldTextView.titleLabel.font = fontOfText
        cell._foldTextView.titleLabel.textColor = colorOfText
        cell._foldTextView.titleLabel.textAlignment = alignmentOfText
        if attributeText != nil {
            cell._foldTextView.titleLabel.attributedText = attributeText
        } else {
            cell._foldTextView.titleLabel.attributedText = nil
            cell._foldTextView.titleLabel.text = title
        }
        super.customUpdateCell()
    }
    
    open override var identifier: String {
        if leftView == nil {
            return "_FoldTextRowWithLeft"
        }
        return "_FoldTextRow"
    }
}

///  可折叠的文字展示Item，可设置最大高度，文字样式等（*注意 使用水平布局时，不会折叠，会直接展示全部内容，如果有需要再修改*）
public final class FoldTextItem: _FoldTextItem, SWRowType {
}
