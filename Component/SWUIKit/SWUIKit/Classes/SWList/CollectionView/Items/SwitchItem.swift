//
//  SwitchItem.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/10/14.
//

import UIKit
import SnapKit

// MARK:- SwitchCell
open class CollectionSwitchCell: SWCollectionCellOf<Bool> {
    
    let titleLabel: UILabel = UILabel()
    let valueSwitch: UISwitch = UISwitch()
    
    /// 添加到滑块上的文字
    let valueTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    /// 滑块控件
    var switchSliderImageView: UIImageView?
    
    func findSilder(_ view: UIView) -> UIImageView? {
        if view is UIImageView, view.frame.width == 43, view.frame.width == 43 {
            return view as? UIImageView
        }
        if view.subviews.count > 0 {
            for v in view.subviews {
                if let imgV = findSilder(v) {
                    return imgV
                }
            }
        }
        return nil
    }

    open override func setup() {
        super.setup()
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueSwitch)
        
        /// 找到滑块
        switchSliderImageView = findSilder(valueSwitch)
        if let slider = switchSliderImageView {
            slider.addSubview(valueTextLabel)
            valueTextLabel.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-3)
            }
        }
        
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        valueSwitch.addTarget(self, action: #selector(switchDidChange), for: .touchUpInside)
        valueSwitch.layer.cornerRadius = valueSwitch.bounds.height * 0.5
        valueSwitch.clipsToBounds = true
        valueSwitch.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        valueSwitch.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        titleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualTo(10).priority(.low)
            make.bottom.lessThanOrEqualTo(-10).priority(.low)
        })
        
        valueSwitch.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualTo(10).priority(.low)
            make.bottom.lessThanOrEqualTo(-10).priority(.low)
        }
    }
    
    open override func update() {
        super.update()
        titleLabel.text = row?.title
        guard let v = value else {
            return
        }
        valueSwitch.isOn = v
    }
    
    @objc func switchDidChange(){
        row?.value = valueSwitch.isOn
    }
}

// MARK:- SwitchRow
open class _SwitchItem: SWCollectionItemOf<CollectionSwitchCell> {
    /// 固定高度
    public var aspectHeight: CGFloat = 44
    
    // 样式设置
    /// 竖直方向排列方式
    public enum VerticalAlignment {
        case top
        case center
        case bottom
    }
    
    public var verticalAlignment: VerticalAlignment = .center
    
    // title
    public var titlePosition: TitlePosition = .left
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    public var titleColor: UIColor = UIColor.black
    public var titleLines: Int = 0
    public var titleAlignment: NSTextAlignment = .left
    /// 富文本标题，如果设置了，则会替换掉title显示这个
    public var attributeTitle: NSAttributedString?
    
    // switch
    /// 未选中
    public var switchTintColor: UIColor = .lightGray
    /// 选中
    public var switchOnTintColor: UIColor = .systemBlue
    /// 滑块颜色
    public var switchSliderColor: UIColor = .white
    /// 默认滑块文字
    public var switchSliderText: String?
    /// 选中滑块文字
    public var switchOnSliderText: String?
    /// 滑块内文字颜色
    public var switchSliderTextColor: UIColor = .clear
    
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
        
        cell.titleLabel.numberOfLines = titleLines
        cell.titleLabel.font = titleFont
        cell.titleLabel.textColor = titleColor
        cell.titleLabel.textAlignment = titleAlignment
        
        cell.valueSwitch.thumbTintColor = switchSliderColor
        cell.valueSwitch.onTintColor = switchOnTintColor
        cell.valueSwitch.tintColor = switchTintColor
        cell.valueSwitch.backgroundColor = switchTintColor
        
        updateSliderText()
        cell.valueTextLabel.textColor = switchSliderTextColor
        
        if title == nil, attributeTitle == nil {
            cell.titleLabel.snp.remakeConstraints({ (make) in
                make.left.equalTo(contentInsets.left).priority(.high)
                make.top.equalTo(contentInsets.top).priority(.high)
                make.right.lessThanOrEqualTo(-contentInsets.right).priority(.low)
                make.width.height.equalTo(0)
            })
        } else {
            switch titlePosition {
                case .left:
                    switch verticalAlignment {
                        case .top:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left).priority(.high)
                                make.top.equalTo(contentInsets.top).priority(.high)
                                make.bottom.lessThanOrEqualTo(-contentInsets.bottom).priority(.low)
                                make.right.lessThanOrEqualTo(-contentInsets.right).priority(.high)
                            })
                        case .center:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left).priority(.high)
                                make.top.greaterThanOrEqualTo(contentInsets.top).priority(.low)
                                make.bottom.lessThanOrEqualTo(-contentInsets.bottom).priority(.low)
                                make.centerY.equalToSuperview().priority(.high)
                                make.right.lessThanOrEqualTo(-contentInsets.right).priority(.high)
                            })
                        case .bottom:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left).priority(.high)
                                make.top.greaterThanOrEqualTo(contentInsets.top).priority(.low)
                                make.bottom.equalTo(-contentInsets.bottom).priority(.high)
                                make.right.lessThanOrEqualTo(-contentInsets.right).priority(.high)
                            })
                    }
                case .width(let width):
                    switch verticalAlignment {
                        case .top:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left).priority(.high)
                                make.top.equalTo(contentInsets.top).priority(.high)
                                make.width.equalTo(width).priority(.high)
                                make.bottom.lessThanOrEqualTo(-contentInsets.bottom).priority(.low)
                                make.right.lessThanOrEqualTo(-contentInsets.right).priority(.high)
                            })
                        case .center:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left).priority(.high)
                                make.top.greaterThanOrEqualTo(contentInsets.top).priority(.low)
                                make.width.equalTo(width).priority(.high)
                                make.bottom.lessThanOrEqualTo(-contentInsets.bottom).priority(.low)
                                make.centerY.equalToSuperview().priority(.high)
                                make.right.lessThanOrEqualTo(-contentInsets.right).priority(.high)
                            })
                        case .bottom:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left).priority(.high)
                                make.top.greaterThanOrEqualTo(contentInsets.top).priority(.low)
                                make.width.equalTo(width).priority(.high)
                                make.bottom.equalTo(-contentInsets.bottom).priority(.high)
                                make.right.lessThanOrEqualTo(-contentInsets.right).priority(.high)
                            })
                    }
            }
        }
        
        switch verticalAlignment {
            case .top:
                cell.valueSwitch.snp.remakeConstraints({ (make) in
                    make.top.equalTo(contentInsets.top).priority(.high)
                    make.right.equalTo(-contentInsets.right).priority(.high)
                    make.bottom.lessThanOrEqualTo(-contentInsets.bottom).priority(.low)
                })
            case .center:
                cell.valueSwitch.snp.remakeConstraints({ (make) in
                    make.top.greaterThanOrEqualTo(contentInsets.top).priority(.low)
                    make.right.equalTo(-contentInsets.right).priority(.high)
                    make.bottom.lessThanOrEqualTo(-contentInsets.bottom).priority(.low)
                    make.centerY.equalToSuperview().priority(.high)
                })
            case .bottom:
                cell.valueSwitch.snp.remakeConstraints({ (make) in
                    make.top.greaterThanOrEqualTo(contentInsets.top).priority(.low)
                    make.right.equalTo(-contentInsets.right).priority(.high)
                    make.bottom.equalTo(-contentInsets.bottom).priority(.high)
                })
        }
        cell.layoutIfNeeded()
    }
    
    open override var value: SWCollectionCellOf<Bool>.Value? {
        didSet {
            updateSliderText()
        }
    }
    
    func updateSliderText() {
        guard let cell = cell else {
            return
        }
        cell.valueTextLabel.text = (value ?? false) ? switchOnSliderText : switchSliderText
    }
    
    open override var identifier: String {
        return "_SwitchItem"
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
}

///  带switch控件的Item，可展示标题和switch，同时提供自定义标题、switch样式和位置等属性
public final class SwitchItem: _SwitchItem, SWRowType {
}
