//
//  SWPlaceholderTextView.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/14.
//

import UIKit
import SnapKit

public class SWPlaceholderTextView: UIView {

    //MARK: - 懒加载属性
    lazy public var plaleLabel = UILabel()
    lazy var countLabel = UILabel()
    lazy public var inputTextView = UITextView()
    
    public var text: String {
        get {
            return inputTextView.text
        }
    }
    
    public var beginEditingBlock: (() -> Void)?
    public var endEditingBlock: ((_ newHeight: CGFloat) -> Void)?
    public var textDidChangeBlock: ((_ text: String, _ newHeight: CGFloat) -> Void)?
    
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            inputTextView.snp.remakeConstraints { (make) in
                make.edges.equalTo(contentInset)
            }
            updatePlaceholderLayout()
        }
    }
    
    public var placeholderInset: UIEdgeInsets = .zero {
        didSet {
            guard plaleLabel.superview != nil else{
                return
            }
            inputTextView.textContainerInset = placeholderInset
            updatePlaceholderLayout()
        }
    }
    
    func updatePlaceholderLayout() {
        plaleLabel.snp.remakeConstraints { (make) in
            make.left.equalTo(placeholderInset.left + contentInset.left)
            make.top.equalTo(placeholderInset.top + contentInset.top)
            make.right.equalTo(-placeholderInset.right - contentInset.right)
            make.bottom.lessThanOrEqualTo(-placeholderInset.bottom - contentInset.bottom)
        }
    }

    //储存属性
    @objc public var placeholderGlobal: String? {     //提示文字
        didSet{
            plaleLabel.text = placeholderGlobal
        }
    }
    @objc public var placeholderColorGlobal: UIColor? {
        didSet{
            plaleLabel.textColor = placeholderColorGlobal
        }
    }
    @objc var isReturnHidden:Bool = false     //是否点击返回失去响应
    @objc public var isShowCountLabel:Bool = false { //是否显示计算个数的Label
        didSet{
            countLabel.isHidden = !isShowCountLabel
        }
    }
    @objc public var limitWords: UInt = 999999             //限制输入个数   默认为999999，不限制输入
    
    //MARK: - 系统方法
    /// PlaceholerTextView 唯一初始化方法
    public convenience init(placeholder:String?,placeholderColor:UIColor?) {
        self.init(frame: .zero)
        setup(placeholder: placeholder, placeholderColor: placeholderColor)
        placeholderGlobal = placeholder
        placeholderColorGlobal = placeholderColor
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //XIB 调用
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(placeholder: nil, placeholderColor: nil)
    }
    
    /// 设置光标颜色
    public override var tintColor: UIColor! {
        didSet {
            inputTextView.tintColor = tintColor
        }
    }
}

//MARK: - 自定义UI
extension SWPlaceholderTextView{
    
    /// placeholder Label Setup
    private func setup(placeholder:String?,placeholderColor:UIColor?){
        inputTextView.delegate = self
        inputTextView.textContainer.lineFragmentPadding = 0
        inputTextView.layoutManager.allowsNonContiguousLayout = false
        
        plaleLabel.backgroundColor = .clear
        countLabel.backgroundColor = .clear
        inputTextView.backgroundColor = .clear
        
        addSubview(inputTextView)
        if inputTextView.font==nil {
            inputTextView.font = UIFont.systemFont(ofSize: 14)
        }
        
        plaleLabel.textColor = placeholderColor
        plaleLabel.textAlignment = .left
        plaleLabel.font = inputTextView.font
        plaleLabel.text = placeholder
        plaleLabel.numberOfLines = 0
        plaleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        plaleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(plaleLabel)
        countLabel.font = inputTextView.font
        countLabel.isHidden = true
        countLabel.textColor = .lightGray
        addSubview(countLabel)
        
        plaleLabel.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        inputTextView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        countLabel.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(-5)
        }
    }
    
}

//MARK: - UITextViewDelegate代理方法
extension SWPlaceholderTextView : UITextViewDelegate{
    
    public func textViewDidChange(_ textView: UITextView) {
        checkShowHiddenPlaceholder()
        checkTextViewLengthAndModify(textView)
        countLabel.text = "\(textView.text.count)/\(limitWords)"
        if textDidChangeBlock != nil {
            textDidChangeBlock!(textView.text, textView.layoutManager.usedRect(for: textView.textContainer).height)
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        guard beginEditingBlock != nil else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.beginEditingBlock?()
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if endEditingBlock != nil {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.endEditingBlock?(strongSelf.inputTextView.layoutManager.usedRect(for: strongSelf.inputTextView.textContainer).height)
            }
        }
        inputTextView.scrollToTop()
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text=="\n"&&isReturnHidden==true {
            textView.resignFirstResponder()
        }
        
        if let positionRange = textView.markedTextRange {
            if let _ = textView.position(from: positionRange.start, offset: 0) {
                //正在使用拼音，不进行校验
            } else {
                //不在使用拼音，进行校验
                return checkTextViewLength(textView, range, text)
            }
        } else {
            //不在使用拼音，进行校验
            return checkTextViewLength(textView, range, text)
        }
        return true
    }
    
    //检查输入框的文字是否超长，如果超出长度则做截短
    func checkTextViewLengthAndModify(_ textView: UITextView) {
        if let positionRange = textView.markedTextRange {
            if let _ = textView.position(from: positionRange.start, offset: 0) {
                //正在使用拼音，不进行校验
                return
            }
        }
        if let text = textView.text {
            if text.count <= limitWords {
                //长度正常，不处理
            } else {
                //超出长度，开始处理
                let len: Int = Int(limitWords)
                let subText = String(text[text.startIndex ..< text.index(text.startIndex,offsetBy: len)])
                textView.text = subText
            }
        }
    }
    
    //检查输入框的文字是否超长
    func checkTextViewLength(_ textView: UITextView,_ range: NSRange,_ text: String) -> Bool {
        // 大于等于限制字数，而且不是删除键的时候不可以输入。
        // 考虑复制粘贴和光标不在最后得情况
        let resultCount: Int = textView.text.count + range.length + text.count
        let textString: NSString = text as NSString
        if resultCount > limitWords && !textString.isEqual(to: ""){
            return false
        }
        return true
    }
}

//MARK : - 工具方法

extension SWPlaceholderTextView {
    
    ///根据textView是否有内容显示placeholder
    public func checkShowHiddenPlaceholder(){
        if self.inputTextView.hasText {
            DispatchQueue.main.async {
                self.plaleLabel.text = nil
                self.countLabel.isHidden = !self.isShowCountLabel
            }
        }else{
            DispatchQueue.main.async {
                self.plaleLabel.text = self.placeholderGlobal
                self.countLabel.isHidden = true
            }
        }
    }
    
}

// MARK: - UITextViewExtension
extension UITextView {

    /// 滚动到顶部
    func scrollToTop() {
        // swiftlint:disable:next legacy_constructor
        let range = NSMakeRange(0, 1)
        scrollRangeToVisible(range)
    }

}
