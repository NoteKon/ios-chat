//
//  LabelItem.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/23.
//

import UIKit
import SnapKit

// MARK:- LabelCell
open class CollectionLabelCellOf<T: Equatable>: SWCollectionCellOf<T> {
    
    let titleLabel: UILabel = UILabel()
    let valueLabel: UILabel = UILabel()

    open override func setup() {
        super.setup()
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.textColor = .gray
        
        titleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(15).priority(.high)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualTo(10).priority(.low)
            make.bottom.lessThanOrEqualTo(-10).priority(.low)
        })
        
        valueLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-15).priority(.high)
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
        valueLabel.text = displayValueFor?(v) ?? (row as? NoValueDisplayTextConformance)?.noValueDisplayText
    }
}

// MARK:- LabelItem
open class _LabelItem: SWCollectionItemOf<CollectionLabelCellOf<String>> {
    
    // 样式设置
    /// 竖直方向排列方式
    public enum VerticalAlignment {
        case top
        case center
        case bottom
    }
    
    public var verticalAlignment: VerticalAlignment = .center
    
    /// title
    public var titlePosition: TitlePosition = .left
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    public var titleColor: UIColor = UIColor.black
    public var titleHighlightColor: UIColor?
    public var titleLines: Int = 0
    public var titleAlignment: NSTextAlignment = .left
    /// 富文本标题，如果设置了，则会替换掉title显示这个
    public var attributeTitle: NSAttributedString?
    
    /// value
    public enum ValuePosition {
        case left(_ spaceToTitle: CGFloat)
        case center
        case right
    }
    /// Value和Title的间距
    public var spaceBetweenTitleAndValue: CGFloat = 0
    public var valueFont: UIFont = UIFont.systemFont(ofSize: 14)
    public var valueColor: UIColor = UIColor.gray
    public var valueHighlightColor: UIColor?
    public var valueLines: Int = 0
    public var valueAlignment: NSTextAlignment = .right
    /// 富文本value，如果设置了，则会替换掉value显示这个
    public var attributeValue: NSAttributedString?
    
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
        if attributeValue != nil {
            cell.valueLabel.attributedText = attributeValue
        } else {
            cell.valueLabel.attributedText = nil
            cell.valueLabel.text = value
        }
        
        cell.titleLabel.numberOfLines = titleLines
        cell.titleLabel.font = titleFont
        cell.titleLabel.textColor = titleColor
        cell.titleLabel.textAlignment = titleAlignment
        
        cell.valueLabel.numberOfLines = valueLines
        cell.valueLabel.font = valueFont
        cell.valueLabel.textColor = valueColor
        cell.valueLabel.textAlignment = valueAlignment
        
        if title == nil, attributeTitle == nil {
            cell.titleLabel.snp.remakeConstraints({ (make) in
                make.left.equalTo(contentInsets.left - spaceBetweenTitleAndValue)
                make.top.equalTo(contentInsets.top)
                make.width.height.equalTo(0)
            })
        } else {
            switch titlePosition {
                case .left:
                    switch verticalAlignment {
                        case .top:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left)
                                make.top.equalTo(contentInsets.top)
                                make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                                make.right.lessThanOrEqualTo(-contentInsets.right)
                            })
                        case .center:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left)
                                make.top.greaterThanOrEqualTo(contentInsets.top)
                                make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                                make.centerY.equalToSuperview()
                                make.right.lessThanOrEqualTo(-contentInsets.right)
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
                                make.left.equalTo(contentInsets.left)
                                make.top.equalTo(contentInsets.top)
                                make.width.equalTo(width)
                                make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                            })
                        case .center:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left)
                                make.top.greaterThanOrEqualTo(contentInsets.top)
                                make.width.equalTo(width)
                                make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                                make.centerY.equalToSuperview()
                            })
                        case .bottom:
                            cell.titleLabel.snp.remakeConstraints({ (make) in
                                make.left.equalTo(contentInsets.left)
                                make.top.greaterThanOrEqualTo(contentInsets.top)
                                make.width.equalTo(width)
                                make.bottom.equalTo(-contentInsets.bottom)
                            })
                    }
            }
        }
        
        if value == nil, attributeValue == nil {
            cell.valueLabel.snp.remakeConstraints({ (make) in
                make.left.equalTo(cell.titleLabel.snp.right)
                make.top.equalTo(contentInsets.top)
                make.right.equalTo(-contentInsets.right)
            })
        } else {
            switch verticalAlignment {
                case .top:
                    cell.valueLabel.snp.remakeConstraints({ (make) in
                        make.left.equalTo(cell.titleLabel.snp.right).offset(spaceBetweenTitleAndValue)
                        make.top.equalTo(contentInsets.top)
                        make.right.equalTo(-contentInsets.right)
                        make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                    })
                case .center:
                    cell.valueLabel.snp.remakeConstraints({ (make) in
                        make.left.equalTo(cell.titleLabel.snp.right).offset(spaceBetweenTitleAndValue)
                        make.top.greaterThanOrEqualTo(contentInsets.top)
                        make.right.equalTo(-contentInsets.right)
                        make.bottom.lessThanOrEqualTo(-contentInsets.bottom)
                        make.centerY.equalToSuperview()
                    })
                case .bottom:
                    cell.valueLabel.snp.remakeConstraints({ (make) in
                        make.left.equalTo(cell.titleLabel.snp.right).offset(spaceBetweenTitleAndValue)
                        make.top.greaterThanOrEqualTo(contentInsets.top)
                        make.right.equalTo(-contentInsets.right)
                        make.bottom.equalTo(-contentInsets.bottom)
                    })
            }
        }
        if isShow {
            updateLayout()
        }
    }
    
    open override func customHighlightCell() {
        super.customHighlightCell()
        guard let cell = _cell as? CollectionLabelCellOf<String> else {
            return
        }
        cell.titleLabel.textColor = titleHighlightColor ?? titleColor
        cell.valueLabel.textColor = valueHighlightColor ?? valueColor
    }
    
    open override func customUnHighlightCell() {
        super.customUnHighlightCell()
        guard let cell = _cell as? CollectionLabelCellOf<String> else {
            return
        }
        cell.titleLabel.textColor = titleColor
        cell.valueLabel.textColor = valueColor
    }
    
    open override var identifier: String {
        return "LabelItem"
    }
    
    open override func cellHeight(for width: CGFloat) -> CGFloat {
        if let aspectHeight = aspectHeight(width) {
            return aspectHeight
        }
        var titleMaxWidth = floor(width - contentInsets.left - contentInsets.right)
        switch titlePosition {
            case .width(let w):
                titleMaxWidth = w
            default:
                break
        }
        let titleSize =
            title?.boundingRect(with: CGSize(width: titleMaxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: titleFont], context: nil).size ??
            attributeTitle?.boundingRect(with: CGSize(width: titleMaxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, context: nil).size ??
            .zero
        let valueMaxWidth = floor(width - titleSize.width - contentInsets.left - contentInsets.right - spaceBetweenTitleAndValue)
        let valueSize =
            value?.boundingRect(with: CGSize(width: valueMaxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: valueFont], context: nil).size ??
            attributeValue?.boundingRect(with: CGSize(width: valueMaxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, context: nil).size ??
            .zero
        let height = ceil(max(titleSize.height, valueSize.height)) + contentInsets.top + contentInsets.bottom
        shortSideLength = min(width, height)
        return height
    }
    
    open override func cellWidth(for height: CGFloat) -> CGFloat {
        if let aspectWidth = aspectWidth(height) {
            return aspectWidth
        }
        let textMaxHeight = height
        let titleSize = title?.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: textMaxHeight), options: .usesLineFragmentOrigin, attributes: [.font: titleFont], context: nil).size ??
            attributeTitle?.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: textMaxHeight), options: .usesLineFragmentOrigin, context: nil).size ??
            .zero
        let valueSize =
            value?.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: textMaxHeight), options: .usesLineFragmentOrigin, attributes: [.font: valueFont], context: nil).size ??
            attributeValue?.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: textMaxHeight), options: .usesLineFragmentOrigin, context: nil).size ??
            .zero
        let width = ceil(contentInsets.left + titleSize.width + valueSize.width + contentInsets.right + spaceBetweenTitleAndValue)
        shortSideLength = min(width, height)
        return width
    }
}

///  文字展示Row，可展示标题和value，同时提供自定义标题、value样式和位置的属性
public final class LabelItem: _LabelItem, SWRowType {
}
