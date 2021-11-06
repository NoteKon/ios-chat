//
//  FoldTextRow.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/11.
//

// MARK:- FoldTextCell
open class FoldTextCell: FoldCell {
    /// 折叠内容
    let _foldTextView: SWFoldTextView = SWFoldTextView()
    open override var foldContentView: SWFoldContentView {
        return _foldTextView
    }
}

// MARK:- FoldTextRow
open class _FoldTextRow: _FoldRowOf<FoldTextCell> {
    
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

///  可折叠的文字展示Row，可自定义左侧视图、折叠按钮样式
public final class FoldTextRow: _FoldTextRow, SWRowType {
}
