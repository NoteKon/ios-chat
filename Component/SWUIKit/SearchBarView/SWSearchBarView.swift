//
//  SWSearchBarView.swift
//  VVLife
//
//  Created by Bingle on 2020/1/9.
//  Copyright © 2020 vv. All rights reserved.
//

import UIKit

@objc protocol SWSearchBarViewDelegate: AnyObject {
    @objc optional func searchBarTextFieldDidChanged(searchBar: SWSearchBarView, text: String)
    @objc optional func searchBarTextFieldDidBeginEditing(searchBar: SWSearchBarView)
    @objc optional func searchBarTextFieldDidEndEditing(searchBar: SWSearchBarView)
    @objc optional func searchBarTextFieldShouldReturn(searchBar: SWSearchBarView) -> (Bool)
}

/// 搜索栏
@IBDesignable
class SWSearchBarView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchIconImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var clearButtonWidthConstaint: NSLayoutConstraint!
    @IBOutlet weak var textfieldTailConstraint: NSLayoutConstraint!
    @IBOutlet weak var delegate: SWSearchBarViewDelegate?
    @IBOutlet weak var textfieldRightConstraint: NSLayoutConstraint!
    
    /// placeholder
    @IBInspectable var placeholder: String = "" {
        didSet {
            searchTextField.placeholder = placeholder
        }
    }
    
    /// 文本颜色
    @IBInspectable var textColor: UIColor = .black {
        didSet {
            searchTextField.textColor = textColor
            searchTextField.tintColor = textColor
        }
    }
    
    /// placeholder 颜色
    @IBInspectable var placeholderColor: UIColor = UIColor(rgb: 0x999999) {
        didSet {
            searchTextField.attributedPlaceholder = NSAttributedString.init(string: searchTextField.placeholder ?? "",
                                                                            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor,
                                                                                         NSAttributedString.Key.font: searchTextField.font!])
        }
    }
    
    /// 搜索图标
    @IBInspectable var searchIconImage: UIImage? {
        didSet {
            searchIconImageView.image = searchIconImage
        }
    }
    
    /// 清空按钮图标
    @IBInspectable var clearIconImage: UIImage? {
        didSet {
            clearButton.setImage(clearIconImage, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initFromXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initFromXib()
    }
    
    func initFromXib() {
        let bundle = Bundle.init(for: SWSearchBarView.self)
        let nib = UINib(nibName: "SWSearchBarView", bundle: bundle)
        contentView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        self.addSubview(contentView)
        showClearButton(show: false)
    }
    
    /// 更新视图布局
    override func layoutSubviews() {
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
        textfieldRightConstraint.constant = show ? 0.0 : 46.0
    }
    
    func showActionView(actionViewWidth: CGFloat) {
        textfieldTailConstraint.constant = actionViewWidth
    }
    
}

extension SWSearchBarView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return delegate?.searchBarTextFieldShouldReturn?(searchBar: self) ?? true
    }
}
