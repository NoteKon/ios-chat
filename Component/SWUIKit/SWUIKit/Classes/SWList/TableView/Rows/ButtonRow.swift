//
//  ButtonRow.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/10.
//

import UIKit
import SnapKit

// MARK: ButtonCell
open class ButtonCellOf<T: Equatable>: SWTableCellOf<T> {
    
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
            make.left.equalTo(15)
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
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.zero)
        }
    }

    open override func update() {
        super.update()
        selectionStyle = row?.isDisabled ?? true ? .none : .default
    }

    open override func didSelect() {
        super.didSelect()
        row?.deselect()
    }
}

public typealias ButtonCell = ButtonCellOf<String>

// MARK: ButtonRow
open class _ButtonRowOf<T: Equatable> : SWTableRowOf<ButtonCellOf<T>> {
    open var presentationMode: SWPresentationMode<UIViewController>?
    
    /// 箭头样式
    public enum ArrowType: Equatable {
        /// 不带箭头
        case none
        /// 系统自带
        case system
        /// 自定义
        case custom(_ image: UIImage, size: CGSize)
    }
    public var arrowType: ArrowType = .system
    
    /// 左侧图标
    public var iconImage: UIImage?
    public var iconSize: CGSize = .zero
    
    /// 标题样式
    public var fontOfTitle: UIFont = UIFont.systemFont(ofSize: 15)
    public var colorOfTitle: UIColor = UIColor.black
    public var alignmentOfTitle: NSTextAlignment = .left
    
    /// 右侧视图
    public var rightView: UIView?
    public var rightViewSize: CGSize = .zero
    
    /// 间距设置
    public var spaceBetweenIconAndTitle: CGFloat = 8
    public var spaceBetweenTitleAndRightView: CGFloat = 0
    public var spaceBetweenRightViewAndArrow: CGFloat = 0
    
    open override var identifier: String {
        return "ButtonRowOf\(T.self)"
    }
    
    required public init(title: String?, tag: String?) {
        super.init(title: title, tag: tag)
        cellStyle = .default
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
        cell.titleLabel.textAlignment = alignmentOfTitle
        switch arrowType {
            case .none:
                cell.accessoryType = .none
                cell.arrowImageView.image = nil
                cell.arrowImageView.snp.updateConstraints { (make) in
                    make.right.equalTo(-contentInsets.right)
                    make.size.equalTo(CGSize.zero)
                }
            case .system:
                cell.accessoryType = isDisabled ? .none : .disclosureIndicator
                cell.arrowImageView.image = nil
                cell.arrowImageView.snp.updateConstraints { (make) in
                    make.right.equalTo(0)
                    make.size.equalTo(CGSize.zero)
                }
            case .custom(let image, let size):
                cell.accessoryType = .none
                cell.arrowImageView.image = image
                cell.arrowImageView.snp.updateConstraints { (make) in
                    make.right.equalTo(-contentInsets.right)
                    make.size.equalTo(size)
                }
        }
        cell.editingAccessoryType = cell.accessoryType
        cell.titleLabel.textColor = colorOfTitle
        cell.titleLabel.font = fontOfTitle
        cell.titleLabel.text = title
        if iconImage != nil {
            cell.iconImageView.image = iconImage
            cell.iconImageView.snp.updateConstraints { (make) in
                make.left.equalTo(contentInsets.left)
                make.size.equalTo(iconSize)
            }
            cell.titleLabel.snp.updateConstraints { (make) in
                make.left.equalTo(cell.iconImageView.snp.right).offset(spaceBetweenIconAndTitle)
            }
        } else {
            cell.iconImageView.image = nil
            cell.iconImageView.snp.updateConstraints { (make) in
                make.left.equalTo(contentInsets.left)
                make.size.equalTo(CGSize.zero)
            }
            cell.titleLabel.snp.updateConstraints { (make) in
                make.left.equalTo(cell.iconImageView.snp.right)
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

    open func prepare(for segue: UIStoryboardSegue) {
        (segue.destination as? SWRowControllerType)?.onDismissCallback = presentationMode?.onDismissCallback
    }
}

/// 按钮行（整个行为一个按钮），点击可以任意操作（如点击跳转到新的界面）
/// 支持自定义标题样式、右侧箭头样式，同时可添加左侧图标，以及右侧箭头前的自定义View
/// 文字内容展示为row.title，如需更改可以继承这个类并在super.customUpdateCell()之后设置cell.titleLabel.text为想要的值
public final class ButtonRowOf<T: Equatable> : _ButtonRowOf<T>, SWRowType {
}

/// 定义好的字符串类型value的按钮行
public typealias ButtonRow = ButtonRowOf<String>
