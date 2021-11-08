//
//  ButtonItem.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/23.
//

import UIKit
import SnapKit

// MARK: ButtonCell
open class CollectionButtonCellOf<T: Equatable>: SWCollectionCellOf<T> {
    
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let rightView = UIView()
    let arrowImageView = UIImageView()
    
    open override func setup() {
        super.setup()
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(rightView)
        contentView.addSubview(arrowImageView)
        
        titleLabel.numberOfLines = 0
        /// 抗压缩
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        rightView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        arrowImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        /// 抗拉伸
        rightView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        iconImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        arrowImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.zero)
        }
        
        titleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(iconImageView.snp.right)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualTo(10).priority(.low)
            make.bottom.lessThanOrEqualTo(-10).priority(.low)
        })
        
        rightView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.zero)
            make.left.equalTo(titleLabel.snp.right)
            make.right.equalTo(arrowImageView.snp.left)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.zero)
        }
    }
    

    open override func didSelect() {
        super.didSelect()
        row?.deselect()
    }
    
}

// MARK: ButtonRow
/// 按钮Item（整个Item为一个按钮），点击可以任意操作（如点击跳转到新的界面）
/// 支持自定义标题样式、右侧箭头样式，同时可添加左侧图标，以及右侧箭头前的自定义View
/// 文字内容展示为row.title，如需更改可以继承这个类并在super.customUpdateCell()之后设置cell.titleLabel.text为想要的值
open class _ButtonItemOf<T: Equatable> : SWCollectionItemOf<CollectionButtonCellOf<T>> {
    open var presentationMode: SWPresentationMode<UIViewController>?
    
    /// 箭头样式
    public enum ArrowType: Equatable {
        /// 不带箭头
        case none
        /// 自定义
        case custom(_ image: UIImage, size: CGSize)
    }
    public var arrowType: ArrowType = .none
    
    /// 左侧图标
    public var iconImage: UIImage?
    public var iconSize: CGSize = .zero
    
    /// 标题样式
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    public var titleColor: UIColor = UIColor.black
    public var titleHighlightColor: UIColor?
    public var titleAlignment: NSTextAlignment = .left
    
    /// 右侧视图
    public var rightView: UIView?
    public var rightViewSize: CGSize = .zero
    
    /// 间距设置
    public var spaceBetweenIconAndTitle: CGFloat = 0
    public var spaceBetweenTitleAndRightView: CGFloat = 0
    public var spaceBetweenRightViewAndArrow: CGFloat = 0
    
    open override var identifier: String {
        return "ButtonItemOf\(T.self)"
    }
    
    open override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            if
                let presentationMode = presentationMode,
                let cell = _cell,
                let viewController = cell.getViewController()
            {
                if let controller = presentationMode.makeController() {
                    presentationMode.present(controller, row: self, presentingController: viewController)
                } else {
                    presentationMode.present(nil, row: self, presentingController: viewController)
                }
            }
        }
    }

    open override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell else {
            return
        }
        
        switch arrowType {
            case .none:
                cell.arrowImageView.image = nil
                cell.arrowImageView.snp.updateConstraints { (make) in
                    make.right.equalTo(-contentInsets.right)
                    make.size.equalTo(CGSize.zero)
                }
            case .custom(let image, let size):
                cell.arrowImageView.image = image
                cell.arrowImageView.snp.updateConstraints { (make) in make.right.equalTo(-contentInsets.right)
                    make.size.equalTo(size)
                }
        }
        
        cell.titleLabel.textAlignment = titleAlignment
        cell.titleLabel.textColor = titleColor
        cell.titleLabel.font = titleFont
        cell.titleLabel.text = title
        cell.titleLabel.snp.updateConstraints { (make) in
            make.left.equalTo(cell.iconImageView.snp.right).offset(spaceBetweenIconAndTitle)
        }
        
        if iconImage != nil {
            cell.iconImageView.image = iconImage
            cell.iconImageView.snp.updateConstraints { (make) in
                make.size.equalTo(iconSize)
                make.left.equalTo(contentInsets.left)
            }
        } else {
            cell.iconImageView.image = nil
            cell.iconImageView.snp.updateConstraints { (make) in
                make.size.equalTo(CGSize.zero)
                make.left.equalTo(contentInsets.left)
            }
        }
        
        cell.rightView.snp.updateConstraints { (make) in
            make.left.equalTo(cell.titleLabel.snp.right).offset(spaceBetweenTitleAndRightView)
            make.right.equalTo(cell.arrowImageView.snp.left).offset(-spaceBetweenRightViewAndArrow)
        }
        
        if rightView != nil {
            /// 复用，隐藏其他子view
            for v in cell.rightView.subviews {
                v.isHidden = v != rightView
            }
            if rightView?.superview != cell.rightView {
                rightView?.removeFromSuperview()
                cell.rightView.addSubview(rightView!)
                rightView?.snp.makeConstraints({ (make) in
                    make.edges.equalToSuperview()
                })
            }
            cell.rightView.snp.updateConstraints { (make) in
                make.size.equalTo(rightViewSize)
            }
        } else {
            rightView?.isHidden = true
            cell.rightView.snp.updateConstraints { (make) in
                make.size.equalTo(CGSize.zero)
            }
        }
        cell.layoutIfNeeded()
    }
    
    open override func customHighlightCell() {
        super.customHighlightCell()
        guard let cell = _cell as? CollectionButtonCellOf<T> else {
            return
        }
        cell.titleLabel.textColor = titleHighlightColor ?? titleColor
    }
    
    open override func customUnHighlightCell() {
        super.customUnHighlightCell()
        guard let cell = _cell as? CollectionButtonCellOf<T> else {
            return
        }
        cell.titleLabel.textColor = titleColor
    }

    open func prepare(for segue: UIStoryboardSegue) {
        (segue.destination as? SWRowControllerType)?.onDismissCallback = presentationMode?.onDismissCallback
    }
    
    /// 宽计算高
    open override func cellHeight(for width: CGFloat) -> CGFloat {
        if let aspectHeight = aspectHeight(width) {
            return aspectHeight
        }
        var arrowSize: CGSize = .zero
        switch arrowType {
            case .none:
                break
            case .custom(_ , let size):
                arrowSize = size
        }
        let titleMaxWidth = width - arrowSize.width - contentInsets.left - contentInsets.right - iconSize.width - rightViewSize.width - spaceBetweenRightViewAndArrow - spaceBetweenTitleAndRightView - spaceBetweenIconAndTitle
        let titleSize = title?.boundingRect(with: CGSize(width: titleMaxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: titleFont], context: nil).size ?? .zero
        let maxHeight = ceil(max(titleSize.height, iconSize.height, rightViewSize.height, arrowSize.height))
        let height = maxHeight + contentInsets.top + contentInsets.bottom
        shortSideLength = min(width, height)
        return height
    }
    
    /// 高计算宽
    open override func cellWidth(for height: CGFloat) -> CGFloat {
        if let aspectWidth = aspectWidth(height) {
            return aspectWidth
        }
        var arrowSize: CGSize = .zero
        switch arrowType {
            case .none:
                break
            case .custom(_ , let size):
                arrowSize = size
        }
        let titleMaxHeight = height
        let titleSize = title?.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: titleMaxHeight), options: .usesLineFragmentOrigin, attributes: [.font: titleFont], context: nil).size ?? .zero
        let width = contentInsets.left + iconSize.width + spaceBetweenIconAndTitle + ceil(titleSize.width) + spaceBetweenTitleAndRightView + rightViewSize.width + spaceBetweenRightViewAndArrow + arrowSize.width + contentInsets.right
        shortSideLength = min(width, height)
        return width
    }
}

public final class ButtonItemOf<T: Equatable> : _ButtonItemOf<T>, SWRowType {
}

/// 定义好的字符串类型value的按钮行
public typealias ButtonItem = ButtonItemOf<String>