//
//  FoldRow.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/10/12.
//

import UIKit
import SnapKit

// MARK:- FoldCell
/// 可折叠的cell, value表示是否已打开
open class FoldCell: SWTableCellOf<Bool> {
    
    // MARK:- 可重写内容
    /// 左侧视图，子类可重写此属性来返回自定义的左侧视图，以达到减少复用时addview和removeSubView的效果
    open var leftView: UIView {
        return _defaultLeftView
    }
    /// 返回内容控件View的方法，子类可重写此属性来返回折叠的View，以达到复用时减少addview和removeSubView的效果，可参考FoldTextRow
    open var foldContentView: SWFoldContentView {
        return _defaultFoldContentView
    }
    /// 展开/收起 控件
    open var foldOpenView: SWBaseFoldOpenView {
        return _defaultFoldButton
    }
    
    // MARK:- 内容容器
    /// 左侧view
    open var leftViewBox: UIView = UIView()
    /// 内容容器
    open var foldContentBox: UIView = UIView()
    /// 展开/收起 按钮容器
    lazy var foldButtonBox: UIControl = UIControl()
    
    // MARK:- 默认内容
    /// 默认的左侧视图
    lazy var _defaultLeftView = UIView()
    /// 默认的折叠内容
    lazy var _defaultFoldContentView: SWFoldContentView = SWFoldContentView()
    /// 默认的展开/收起按钮样式
    public lazy var _defaultFoldButton: FoldDefaultOpenButton = FoldDefaultOpenButton()

    open override func setup() {
        super.setup()
        selectionStyle = .none
        contentView.addSubview(leftViewBox)
        contentView.addSubview(foldContentBox)
        contentView.addSubview(foldButtonBox)
        foldContentBox.addSubview(foldContentView)
        foldButtonBox.addSubview(foldOpenView)
        leftViewBox.addSubview(leftView)
        
        foldButtonBox.addTarget(self, action: #selector(onTapOpen), for: .touchUpInside)
        foldButtonBox.clipsToBounds = true
        foldContentBox.clipsToBounds = true
        leftViewBox.clipsToBounds = true
        
        leftViewBox.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(10)
            make.size.equalTo(CGSize.zero)
        }
        foldContentBox.snp.makeConstraints({ (make) in
            make.left.equalTo(leftViewBox.snp.right)
            make.right.equalTo(-15)
            make.top.equalTo(10)
            make.height.equalTo(20)
        })
        foldButtonBox.snp.makeConstraints { (make) in
            make.left.equalTo(foldContentBox.snp.left)
            make.right.equalTo(foldContentBox.snp.right)
            make.height.equalTo(foldOpenView.height())
            make.bottom.equalTo(-10)
        }
        
        
        leftView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        foldContentView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0)
        }
        
        foldOpenView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func onTapOpen() {
        guard let r = row as? SWFoldRowType else {
            return
        }
        r.isOpen = !r.isOpen
        r.customUpdateCell()
        updateHeight(row!.cellHeight!)
    }
}

// MARK: FoldRow
open class _FoldRowOf<C: FoldCell>: SWTableRowOf<C>, SWFoldRowType {
    /// 是否已经展开
    public var isOpen: Bool = false
    
    /// 折叠高度（超过这个高度会折叠并展示打开按钮, 默认为100）
    open var foldHeight: CGFloat = 100
    
    /// 设置左侧自定义View
    public var leftView: UIView?
    open var leftViewSize: CGSize = .zero
    open var spaceBetweenLeftAndContent : CGFloat = 5
    
    /// 设置可折叠区域内容控件 (如果对应的Cell中已经重写了foldContentView属性并返回值非nil, 则此属性将会失效)
    public var foldContentView: SWFoldContentView?
    
    /// 展开按钮样式
    public var foldOpenView: SWBaseFoldOpenView?
    /// 默认的展开按钮相关样式属性
    public var defaultFoldButtonSetting: SWFoldDefaultOpenButtonSetting?
    /// 展开按钮位置
    open var openViewPosition: SWFoldOpenPosition = .bottom
    
    
    // 更新cell的布局
    open override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell else {
            return
        }
        
        /// 复用, 隐藏多余的view
        for view in cell.leftViewBox.subviews {
            view.isHidden = true
        }
        if let left = leftView {
            left.isHidden = false
            if left.superview != cell.leftViewBox {
                cell.leftViewBox.addSubview(left)
                left.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
        } else {
            cell.leftView.isHidden = false
        }
        cell.leftViewBox.snp.updateConstraints { (make) in
            make.left.equalTo(contentInsets.left)
            make.top.equalTo(contentInsets.top)
            make.size.equalTo(leftViewSize)
        }
        
        var foldButton: SWBaseFoldOpenView = cell.foldOpenView
        /// 复用, 隐藏多余的view
        for view in cell.foldButtonBox.subviews {
            view.isHidden = true
        }
        if let openView = foldOpenView {
            if openView != cell.foldButtonBox {
                cell.foldButtonBox.addSubview(openView)
                openView.snp.remakeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
            foldButton = openView
        } else {
            if let setting = defaultFoldButtonSetting {
                cell._defaultFoldButton.text = setting.text
                cell._defaultFoldButton.textForOpened = setting.openedText
                cell._defaultFoldButton.textColor = setting.color
                cell._defaultFoldButton.textLabel.textAlignment = setting.textAlignment
            }
        }
        foldButton.isHidden = false
        foldButton.isOpen = isOpen
        cell.foldButtonBox.snp.updateConstraints { (make) in
            make.height.equalTo(foldButton.height())
            make.bottom.equalTo(-contentInsets.bottom)
        }
        cell.foldContentBox.snp.updateConstraints { (make) in
            make.left.equalTo(cell.leftViewBox.snp.right).offset(spaceBetweenLeftAndContent)
            make.right.equalTo(-contentInsets.right)
            make.top.equalTo(contentInsets.top)
        }
        
        /// 计算折叠内容尺寸
        var contentWidth: CGFloat = 0
        var contentHeight: CGFloat = 0
        if let tableView = cell.tableHandler()?.tableView {
            contentWidth = tableView.frame.width - contentInsets.left - contentInsets.right - leftViewSize.width - spaceBetweenLeftAndContent
        } else {
            contentWidth = cell.frame.width - contentInsets.left - contentInsets.right - leftViewSize.width - spaceBetweenLeftAndContent
        }
        
        var cellContentView = cell.foldContentView
        /// 复用隐藏多余view
        for view in cell.foldContentBox.subviews {
            view.isHidden = true
        }
        if let contentView = foldContentView {
            /// 添加可折叠内容view
            if contentView.superview != cell.foldContentBox {
                cell.foldContentBox.addSubview(contentView)
                contentView.snp.remakeConstraints { (make) in
                    make.left.top.right.equalToSuperview()
                    make.height.equalTo(0)
                }
            }
            cellContentView = contentView
        }
        contentHeight = cellContentView.height(with: contentWidth)
        cellContentView.isHidden = false
        
        // 高度判断是否需要折叠控制显示展开按钮
        var cHeight: CGFloat = 0
        var showContentHeight: CGFloat = contentHeight
        if contentHeight > foldHeight {
            foldButton.isHidden = false
            cHeight = (foldButton.isOpen ? contentHeight : foldHeight) + foldButton.height() + contentInsets.top + contentInsets.bottom
            if self.openViewPosition == .bottom {
                showContentHeight = foldButton.isOpen ? contentHeight : self.foldHeight
            } else {
                showContentHeight = contentHeight
            }
        } else {
            foldButton.isHidden = true
            cHeight = contentHeight + contentInsets.top + contentInsets.bottom
        }
        cellHeight = cHeight
        
        /// 展开/折叠 动画
        cell.foldContentBox.snp.updateConstraints { (make) in
            make.height.equalTo(min(showContentHeight, cHeight - contentInsets.top - contentInsets.bottom))
        }
        if isShow {
            UIView.animate(withDuration: 0.25, animations: {
                cell.contentView.layoutIfNeeded()
            }) { (finished) in
                cellContentView.updateHeight(showContentHeight)
            }
        } else {
            cell.contentView.layoutIfNeeded()
            cellContentView.updateHeight(showContentHeight)
        }
    }
    
    open override var identifier: String {
        return "_FoldRow"
    }
    
}

///  可折叠的Row，支持自定义折叠内容控件、左侧view以及折叠按钮样式
public final class FoldRow: _FoldRowOf<FoldCell>, SWRowType {
}
