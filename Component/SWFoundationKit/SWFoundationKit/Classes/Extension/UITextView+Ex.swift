//
//  UITextView+Ex.swift
//  SWFoundationKit
//
//  Created by ice on 2021/10/17.
//

import Foundation
public class PlaceTextView: UITextView {
    public var placeHolderLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.text = "请输入内容~"
        $0.textColor = UIColor.lightGray
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    public var point: CGPoint = {
        let po = CGPoint(x: 5, y: 7)
        return po
    }()
    
    public override var font: UIFont? {
        didSet {
            if font != nil {
                // 让在属性哪里修改的字体,赋给给我们占位label
                placeHolderLabel.font = font
            }
        }
    }
    
    // 重写text
    public override var text: String? {
        didSet {
            // 根据文本是否有内容而显示占位label
            placeHolderLabel.isHidden = hasText
        }
    }
    
    // frame
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupUI()
    }
    // xib
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    // 添加控件,设置约束
    fileprivate func setupUI() {
        // 监听内容的通知
        NotificationCenter.default.addObserver(self, selector: #selector(PlaceTextView.valueChange), name:  UITextView.textDidChangeNotification, object: nil)
        
        // 添加控件
        addSubview(placeHolderLabel)
        
        // 设置约束,使用系统的约束
        placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: placeHolderLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: -20))
    }
    
    // 内容改变的通知方法
    @objc fileprivate func valueChange() {
        //占位文字的显示与隐藏
        placeHolderLabel.isHidden = hasText
    }
    // 移除通知
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 子控件布局
    public override func layoutSubviews() {
        super.layoutSubviews()
        // 设置占位文字的坐标
        placeHolderLabel.frame.origin.x = self.point.x
        placeHolderLabel.frame.origin.y = self.point.y
    }
}
