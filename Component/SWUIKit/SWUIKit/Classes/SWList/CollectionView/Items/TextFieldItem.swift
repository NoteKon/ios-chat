//
//  TextFieldItem.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/23.
//

import Foundation
import UIKit
import SnapKit

// MARK:- TextFieldCell
open class CollectionTextFieldCell: SWCollectionCellOf<String> {
    
    let boxView: UIView = UIView()
    let titleLabel: UILabel = UILabel()
    let textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .none
        return field
    }()
    
    /// 文字改变回调
    var onTextDidChangeBlock: ((_ textField: UITextField) -> Void)?

    open override func setup() {
        super.setup()
        boxView.clipsToBounds = true
        
        contentView.addSubview(boxView)
        boxView.addSubview(titleLabel)
        boxView.addSubview(textField)
        
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        textField.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        textField.addTarget(self, action: #selector(textDidChanged(_:)), for: .editingChanged)
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textColor = .black
        
        boxView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))
        }
        
        titleLabel.snp.makeConstraints({ (make) in
            make.centerY.left.equalToSuperview()
        })
        
        textField.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right)
        }
    }
    
    @objc func textDidChanged(_ textField: UITextField) {
        onTextDidChangeBlock?(textField)
    }
    
    open override var canBecomeFirstResponder: Bool {
        return !(row?.isDisabled ?? false)
    }
    
    open override func becomeFirstResponder() -> Bool {
        collectionHandler()?.beginEditing(of: self)
        return textField.becomeFirstResponder()
    }
    
    open override func resignFirstResponder() -> Bool {
        let result = textField.resignFirstResponder()
        if result {
            collectionHandler()?.endEditing(of: self)
        }
        return result
    }
}

// MARK:- TextFieldRow
open class _TextFieldItemOf<T: CollectionTextFieldCell>: SWCollectionItemOf<T>, UITextFieldDelegate {
    /// 固定高度
    public var aspectHeight: CGFloat = 44
    
    /// box到cell的边距
    public var boxInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    /// 内容到box的边距
    public var boxPadding: UIEdgeInsets = UIEdgeInsets.zero
    /// box的背景色
    public var boxBackgroundColor: UIColor = .clear
    // 边框
    public var boxBorderWidth: CGFloat = 0.0
    public var boxBorderColor: UIColor = .clear
    public var boxCornerRadius: CGFloat = 0.0
    /// 高亮
    public var boxHighlightBorderColor: UIColor?
    public var boxHighlightBorderWidth: CGFloat?
    
    // 样式设置
    /// title
    public var titlePosition: TitlePosition = .left
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    public var titleTextColor: UIColor = UIColor.black
    public var titleLines: Int = 0
    public var titleAlignment: NSTextAlignment = .left
    /// 富文本标题，如果设置了，则会替换掉title显示这个
    public var attributeTitle: NSAttributedString?
    
    /// 输入框
    /// 输入框和Title的间距
    public var inputSpaceToTitle: CGFloat = 5
    /// 输入框字体
    public var inputFont: UIFont = UIFont.systemFont(ofSize: 14)
    /// 光标颜色
    public var inputCursorColor: UIColor = UIColor.systemBlue
    /// 输入框字体颜色
    public var inputTextColor: UIColor = UIColor.black
    /// 输入框对齐方式
    public var inputAlignment: NSTextAlignment = .right
    /// 键盘样式
    public var keyboardType: UIKeyboardType = .default
    /// 回车键样式
    public var returnKeyType: UIReturnKeyType = .default
    /// 是否密码输入框
    public var isSecureTextEntry: Bool = false
    
    /// 输入框提示文字
    public var placeHolder: String?
    public var placeHolderColor: UIColor = UIColor.gray
    
    /// 输入框校验谓词
    public var inputPredicateFormat: String?
    /// 输入字符数量限制
    public var limitWords: Int?
    
    /// 输入框事件
    var onTextShouldChangeBlock: ((_ textField: UITextField, _ range: NSRange, _ string: String) -> Bool)?
    var onTextDidChangeBlock: ((_ textField: UITextField) -> Void)?
    var onTextFieldDidBeginEditingBlock: ((_ textField: UITextField) -> Void)?
    var onTextFieldDidEndEditingBlock: ((_ textField: UITextField) -> Void)?
    var onTextFieldShouldReturnBlock: ((_ textField: UITextField) -> Bool)?
    var onTextFieldShouldClearBlock: ((_ textField: UITextField) -> Bool)?
    
    // 设置回调事件
    public func onTextShouldChange(_ callBack:@escaping ((_ row: _TextFieldItemOf<T>, _ textField: UITextField, _ range: NSRange, _ string: String) -> Bool)) {
        onTextShouldChangeBlock = { [weak self](textField, range, string) in
            return callBack(self!, textField, range, string)
        }
    }
    public func onTextDidChanged(_ callBack: @escaping ((_ row: _TextFieldItemOf<T>, _ textField: UITextField) -> Void)) {
        onTextDidChangeBlock = { [weak self] (textField) in
            callBack(self!, textField)
        }
    }
    public func onTextFieldDidBeginEditing(_ callBack: @escaping ((_ row: _TextFieldItemOf<T>, _ textField: UITextField) -> Void)) {
        onTextFieldDidBeginEditingBlock = { [weak self] (textField) in
            callBack(self!, textField)
        }
    }
    public func onTextFieldDidEndEditing(_ callBack: @escaping ((_ row: _TextFieldItemOf<T>, _ textField: UITextField) -> Void)) {
        onTextFieldDidEndEditingBlock = { [weak self] (textField) in
            callBack(self!, textField)
        }
    }
    public func onTextFieldShouldReturn(_ callBack: @escaping ((_ row: _TextFieldItemOf<T>, _ textField: UITextField) -> Bool)) {
        onTextFieldShouldReturnBlock = { [weak self] (textField) in
            return callBack(self!, textField)
        }
    }
    public func onTextFieldShouldClearBlock(_ callBack: @escaping ((_ row: _TextFieldItemOf<T>, _ textField: UITextField) -> Bool)) {
        onTextFieldShouldClearBlock = { [weak self] (textField) in
            return callBack(self!, textField)
        }
    }
    
    // 设置宽高
    open override func cellHeight(for width: CGFloat) -> CGFloat {
        if let height = aspectHeight(width) {
            return height
        }
        return aspectHeight
    }
    
    open override func cellWidth(for height: CGFloat) -> CGFloat {
        if let width = aspectWidth(height) {
            return width
        }
        return aspectHeight
    }
    
    // 更新cell的布局
    open override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell else {
            return
        }
        if attributeTitle != nil {
            cell.titleLabel.attributedText = attributeTitle
        } else {
            cell.titleLabel.attributedText = nil
            cell.titleLabel.text = title
        }
        
        cell.boxView.layer.cornerRadius = boxCornerRadius
        cell.boxView.layer.borderColor = isHighlighted ? (boxHighlightBorderColor ?? boxBorderColor).cgColor : boxBorderColor.cgColor
        cell.boxView.layer.borderWidth = isHighlighted ? (boxHighlightBorderWidth ?? boxBorderWidth) : boxBorderWidth
        cell.boxView.backgroundColor = boxBackgroundColor
        
        cell.titleLabel.numberOfLines = titleLines
        cell.titleLabel.font = titleFont
        cell.titleLabel.textColor = titleTextColor
        cell.titleLabel.textAlignment = titleAlignment
        
        cell.textField.font = inputFont
        cell.textField.textColor = inputTextColor
        cell.textField.tintColor = inputCursorColor
        cell.textField.textAlignment = inputAlignment
        cell.textField.placeholder = nil
        cell.textField.delegate = self
        cell.textField.keyboardType = keyboardType
        cell.textField.returnKeyType = returnKeyType
        cell.textField.isSecureTextEntry = isSecureTextEntry
        cell.onTextDidChangeBlock = { [weak self] (textField) in
            if let _ = textField.text, self?.limitWords != nil {
                if let positionRange = textField.markedTextRange {
                    if let _ = textField.position(from: positionRange.start, offset: 0) {
                        //正在使用拼音，不进行校验
                    } else {
                        //不在使用拼音，进行校验
                        self?.checkTextFieldLengthAndModify(textField)
                    }
                } else {
                    //不在使用拼音，进行校验
                    self?.checkTextFieldLengthAndModify(textField)
                }
            }
            self?.value = textField.text
            self?.onTextDidChangeBlock?(textField)
        }
        
        if placeHolder != nil {
            let placeholserAttributes = [NSAttributedString.Key.foregroundColor : placeHolderColor]
            cell.textField.attributedPlaceholder = NSAttributedString(string: placeHolder! ,attributes: placeholserAttributes)
        }
        
        cell.boxView.snp.updateConstraints { (make) in
            make.edges.equalTo(boxInsets)
        }
        
        switch titlePosition {
            case .left:
                cell.titleLabel.snp.remakeConstraints({ (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(boxPadding.left)
                })
            case .width(let width):
                cell.titleLabel.snp.remakeConstraints({ (make) in
                    make.left.equalTo(boxPadding.left)
                    make.centerY.equalToSuperview()
                    make.width.equalTo(width)
                })
        }
        
        cell.textField.snp.updateConstraints({ (make) in
            make.left.equalTo(cell.titleLabel.snp.right).offset(inputSpaceToTitle)
            make.top.equalTo(boxPadding.top)
            make.bottom.equalTo(-boxPadding.bottom)
            make.right.equalTo(-boxPadding.right)
        })
        
        cell.layoutIfNeeded()
    }
    
    open override var identifier: String {
        return "_TextFieldItemOf\(T.self)"
    }
    
    // MARK:- UITextFieldDelegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if inputPredicateFormat != nil {
            guard var changedString = textField.text else {
                return onTextShouldChangeBlock?(textField,range,string) ?? true
            }
            let startIndex = changedString.index(changedString.startIndex, offsetBy: range.location)
            let endIndex = changedString.index(startIndex, offsetBy: range.length)
            changedString.replaceSubrange(startIndex ..< endIndex, with: string)
            if changedString.lengthOfBytes(using: .utf8) == 0 {
                return onTextShouldChangeBlock?(textField,range,string) ?? true
            }
            let inputPredicate = NSPredicate(format: "SELF MATCHES %@", inputPredicateFormat!)
            return inputPredicate.evaluate(with: changedString)
        }
        return onTextShouldChangeBlock?(textField,range,string) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        onTextFieldDidBeginEditingBlock?(textField)
        _ = cell?.becomeFirstResponder()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        onTextFieldDidEndEditingBlock?(textField)
        _ = cell?.resignFirstResponder()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return onTextFieldShouldReturnBlock?(textField) ?? true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return onTextFieldShouldClearBlock?(textField) ?? true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return !isDisabled
    }
    
    //检查输入框的文字是否超长，如果超出长度则做截短
    func checkTextFieldLengthAndModify(_ textField: UITextField) {
        if let text = textField.text {
            if self.checkTextFielLength(textField) {
                //长度正常，不处理
            } else {
                //超出长度，开始处理
                let len = limitWords!
                let subText = String(text[text.startIndex ..< text.index(text.startIndex,offsetBy: len)])
                textField.text = subText
            }
        }
    }
    
    func checkTextFielLength(_ textField: UITextField) -> Bool {
        guard
            let max = limitWords,
            let str = textField.text
        else {
            return true
        }
        return str.count <= max
    }
}

///  带textfield的Item，可展示标题和输入框，同时提供自定义标题、输入框样式等属性, 不推荐在水平滚动的CollectionView中使用
public final class TextFieldItem: _TextFieldItemOf<CollectionTextFieldCell>, SWRowType {
}
