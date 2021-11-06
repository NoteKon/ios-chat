//
//  DemoFoldButton.swift
//  GZCList_Example
//
//  Created by Guo ZhongCheng on 2020/9/11.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SWUIKit

class DemoFoldButton: SWBaseFoldOpenView {
    /// 是否显示收起
    var showCloseWhenOpend: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViews()
    }
    
    func setUpViews() {
        clipsToBounds = true
        backgroundColor = .clear
        layer.addSublayer(gradientLayer)
        addSubview(textLabel)
        addSubview(iconImageView)
        
        textLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(10)
            make.centerX.equalToSuperview().offset(-10)
        }
        
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(textLabel.snp.right)
            make.centerY.equalTo(textLabel)
            make.width.height.equalTo(20)
        }
    }
    
    var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.text = "展开全部内容"
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    // 渐变背景
    let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.white.withAlphaComponent(0.1).cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        gradient.locations = [0, 0.4, 1]
        return gradient
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = self.openIcon
        return imageView
    }()
    
    let openIcon = UIImage(named: "flod_open")
    let closeIcon = UIImage(named: "flod_close")
    
    override func height() -> CGFloat {
        if showCloseWhenOpend {
            return 50
        }
        return isOpen ? 0 : 50
    }
    
    override var isOpen: Bool {
        didSet {
            textLabel.text = isOpen ? "收起内容" : "展开全部内容"
            iconImageView.image = isOpen ? closeIcon : openIcon
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
}
