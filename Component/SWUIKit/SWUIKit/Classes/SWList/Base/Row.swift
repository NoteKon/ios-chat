//
//  SWRow.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/6/2.
//

import Foundation

open class SWBaseRow: NSObject {
    
    /// SWRow的title(可用于展示)
    public var title: String?
    
    /// 标记Row的唯一标识，同一个SWForm中的row的tag一定不能相同
    public var tag: String?
    
    /// SWRow所在的Section
    public internal(set) weak var section: SWBaseSection?
    
    /// SWRow对应的Value
    var _baseValue: Any?
    
    /// value改变后的回调
    var callbackOnChange: (() -> Void)?
    /// cell更新后的回调
    var callbackCellUpdate: (() -> Void)?
    /// cell选中回调
    var callbackCellOnSelection: (() -> Void)?
    /// cell高亮（成为第一响应者）回调
    var callbackOnCellHighlightChanged: (() -> Void)?
    /// cell结束编辑的回调，可以在这里进行value验证等操作
    var callbackOnCellEndEditing: (() -> Void)?
    
    /// 内联Row展开回调
    var callbackOnExpandInlineRow: Any?
    /// 内联Row收起回调
    var callbackOnCollapseInlineRow: Any?
    
    /// 展示 / 结束展示
    var isShow: Bool = false
    open func willDisplay() {
        isShow = true
    }
    open func didEndDisplay() {
        isShow = false
    }
    
    /// 选中
    open func didSelect() {}
    
    /// cell选中时调用，子类中重写可以在选中时改变row的状态等
    open func customDidSelect() {}
    /// cell更新时调用，子类中重写可联动其他事件，**使用了复用cell的row建议在此方法中更新cell的界面展示**
    open func customUpdateCell() {}
    
    /// cell高亮时调用，子类中重写可修改样式
    open func customHighlightCell() {}
    /// cell结束高亮时调用，子类中重写可修改样式
    open func customUnHighlightCell() {}
    
    /// 获取IndexPath
    public final var indexPath: IndexPath? {
        guard let sectionIndex = section?.index, let rowIndex = section?.firstIndex(of: self) else { return nil }
        return IndexPath(row: rowIndex, section: sectionIndex)
    }
    
    /// 是否不可点击
    public var isDisabled: Bool = false
    /// 是否隐藏
    public var isHidden: Bool = false
    /// 高亮（可在update中根据高亮状态进行一些样式设置）
    public var isHighlighted: Bool = false
    /// 选中（可在update中根据选中状态进行一些样式设置）
    public var isSelected: Bool = false
    
    // MARK:- 编辑相关
    /// 是否可以移动
    open var canMoveRow: Bool = false
    
    /// 默认的value
    public var baseValue: Any? {
        set {}
        get { return nil }
    }
    
    /// 刷新cell的方法（子类中重写，通知cell进行更新）
    open func updateCell() {}
    
    /// 初始化
    public required init(title: String? = nil, tag: String? = nil) {
        self.tag = tag
        self.title = title
    }
}

// MARK:- 事件
extension SWBaseRow {
    // 添加 / 移除事件
    final func willBeRemovedFromForm() {
        if let t = tag {
            section?.form?.rowsByTag[t] = nil
            section?.form?.tagToValues[t] = nil
        }
    }
    final func willBeRemovedFromSection() {
        willBeRemovedFromForm()
        section = nil
    }
    final func wasAddedTo(section: SWBaseSection) {
        self.section = section
        if let t = tag {
            self.section?.form?.rowsByTag[t] = self
            self.section?.form?.tagToValues[t] = baseValue != nil ? baseValue! : NSNull()
        }
    }
}

// MARK:- SWRow的初始化协议
public protocol SWRowType: AnyObject {
    init(_ title: String?,tag: String?, _ initializer: (Self) -> Void)
}

extension SWRowType where Self: SWBaseRow {
    /**
     默认的初始化方法
     */
    public init(_ title: String? = nil, tag: String? = nil, _ initializer: (Self) -> Void = { _ in }) {
        self.init(title: title, tag: tag)
        initializer(self)
    }
}
