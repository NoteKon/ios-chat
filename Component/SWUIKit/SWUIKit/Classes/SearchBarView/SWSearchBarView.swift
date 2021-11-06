//
//  SWSearchBarView.swift
//
//  Created by Bingle on 2020/1/9.
//  Copyright © 2020 vv. All rights reserved.
//

import UIKit

@objc public protocol SWSearchBarViewDelegate: AnyObject {
    @objc optional func searchBarTextFieldDidChanged(searchBar: SWSearchBarView, text: String)
    @objc optional func searchBarTextFieldDidBeginEditing(searchBar: SWSearchBarView)
    @objc optional func searchBarTextFieldDidEndEditing(searchBar: SWSearchBarView)
    @objc optional func searchBarTextFieldShouldReturn(searchBar: SWSearchBarView) -> (Bool)
}

/// 搜索栏
@IBDesignable
open class SWSearchBarView: UIView {
    
    @IBOutlet public var contentView: UIView!
    @IBOutlet public weak var containerView: UIView!
    @IBOutlet public weak var searchIconImageView: UIImageView!
    @IBOutlet public weak var searchTextField: UITextField!
    @IBOutlet public weak var clearButton: UIButton!
    @IBOutlet public weak var clearButtonWidthConstaint: NSLayoutConstraint!
    @IBOutlet public weak var textfieldTailConstraint: NSLayoutConstraint!
    @IBOutlet public weak var delegate: SWSearchBarViewDelegate?
    @IBOutlet public weak var textfieldRightConstraint: NSLayoutConstraint!
    
    /// placeholder
    @IBInspectable public var placeholder: String = "" {
        didSet {
            searchTextField.placeholder = placeholder
        }
    }
    
    /// 文本颜色
    @IBInspectable public var textColor: UIColor = .black {
        didSet {
            searchTextField.textColor = textColor
            searchTextField.tintColor = textColor
        }
    }
    
    /// placeholder 颜色
    @IBInspectable public var placeholderColor: UIColor = UIColor(hex: 0x999999) {
        didSet {
            searchTextField.attributedPlaceholder = NSAttributedString.init(string: searchTextField.placeholder ?? "",
                                                                            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor,
                                                                                         NSAttributedString.Key.font: searchTextField.font!])
        }
    }
    
    /// 搜索图标
    @IBInspectable public var searchIconImage: UIImage? {
        didSet {
            searchIconImageView.image = searchIconImage
        }
    }
    
    /// 清空按钮图标
    @IBInspectable public var clearIconImage: UIImage? {
        didSet {
            clearButton.setImage(clearIconImage, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initFromXib()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initFromXib()
    }
    
    func initFromXib() {
        let nib = UINib(nibName: "SWSearchBarView", bundle: getCurrentBundle())
        contentView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        self.addSubview(contentView)
        searchIconImageView.image = loadImageNamed("sw_search_grey_icon")
        clearButton.setImage(loadImageNamed("sw_search_bar_clear_gray"), for: .normal)
        showClearButton(show: false)
    }
    
    /// 更新视图布局
    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
    
    // MARK: - Action Method
    
    @IBAction func clearAction(_ sender: UIButton) {
        searchTextField.text = ""
        showClearButton(show: false)
        delegate?.searchBarTextFieldDidChanged?(searchBar: self, text: "")
    }
    
    // MARK: - TextFiled Change
    
    @IBAction func textFieldEditingChangedAction(_ sender: UITextField) {
        let showClear = (sender.text?.count ?? 0) > 0
        let text = sender.text ?? ""
        showClearButton(show: showClear)
        delegate?.searchBarTextFieldDidChanged?(searchBar: self, text: text)
    }
    
    @IBAction func textFieldEditingBeginAction(_ sender: UITextField) {
        let showClear = (sender.text?.count ?? 0) > 0
        showClearButton(show: showClear)
        delegate?.searchBarTextFieldDidBeginEditing?(searchBar: self)
    }
    
    @IBAction func textFieldEditingDidEndAction(_ sender: UITextField) {
        showClearButton(show: false)
        delegate?.searchBarTextFieldDidEndEditing?(searchBar: self)
    }
    
    func showClearButton(show: Bool) {
        clearButtonWidthConstaint.constant = show ? 30.0 : 0.0
        textfieldRightConstraint.constant = show ? 0.0 : -30.0
    }
    
    func showActionView(actionViewWidth: CGFloat) {
        textfieldTailConstraint.constant = actionViewWidth
    }
    
}

extension SWSearchBarView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return delegate?.searchBarTextFieldShouldReturn?(searchBar: self) ?? true
    }
}
