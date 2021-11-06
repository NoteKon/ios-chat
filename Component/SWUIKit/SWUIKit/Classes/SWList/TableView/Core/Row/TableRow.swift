//
//  SWTableRow.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/3.
//

import Foundation

public protocol SWTypedTableRowType: AnyObject {
    associatedtype Cell: SWTableCell, SWTypedTableCellType
    
    /// Cell
    var cell: Cell? { get }

    /// Value
    var value: Cell.Value? { get set }
}

// MARK:- 关联了CellType和Value的row
open class SWTableRowOf<Cell: SWTypedTableCellType>: SWTableBaseRowOf<Cell.Value>, SWTypedTableRowType where Cell: SWTableCell {
    public var cell: Cell? {
        return _cell as? Cell
    }
    
    // 注册Cell的方法
    override func regist(to tableView: UITableView) {
        guard let identifier = identifier else {
            return
        }
        if isStoryBoard {
        } else
        if xibName != nil, bundle != nil {
            tableView.register(UINib(nibName: xibName!, bundle: bundle), forCellReuseIdentifier: identifier)
        } else {
            tableView.register(Cell.self, forCellReuseIdentifier: identifier)
        }
    }
    
    // 获取cell的方法
    override func dequeueReusableCell(tableView: UITableView, indexPath: IndexPath) -> SWTableCell? {
        var cell: Cell?
        if let identifier = identifier {
            cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell
        } else {
            cell = self.cell
        }
        if cell == nil {
            if xibName != nil, bundle != nil {
                cell = bundle!.loadNibNamed(xibName!, owner: nil, options: nil)?.last as? Cell
            } else {
                cell = Cell.init(style: cellStyle, reuseIdentifier: nil)
            }
        }
        self._cell = cell
        self.cell?.row = self
        // setup
        if !(cell?.isSetup ?? false) {
            cell?.setup()
        }
        updateCell()
        return cell
    }
    
    open override func customHighlightCell() {
        isHighlighted = true
        super.customHighlightCell()
    }
    
    open override func customUnHighlightCell() {
        isHighlighted = false
        super.customUnHighlightCell()
    }
    
    // 带value的初始化方法
    public init(title: String? = nil, tag: String? = nil, value: Cell.Value) {
        super.init(title: title, tag: tag)
        self.value = value
    }
    
    public required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
    }
}

// MARK:- 关联了Value的row
open class SWTableBaseRowOf<T>: SWTableRow where T: Equatable {
    /// SWRow对应的Value
    private var _value: T? {
        didSet {
            guard _value != oldValue else { return }
            _baseValue = _value
            guard let form = section?.form else { return }
            if let delegate = form.delegate {
                delegate.valueHasBeenChanged(for: self, oldValue: oldValue, newValue: _value)
                callbackOnChange?()
            }
            guard let t = tag else { return }
            form.tagToValues[t] = (value != nil ? value! : NSNull())
        }
    }
    open var value: T? {
        set (newValue) {
            _value = newValue
            guard let _ = section?.form else { return }
        }
        get {
            return _value
        }
    }
    
    
    /// 用于获取此行value显示的字符串的 Block
    public var displayValueFor: ((T?) -> String?)? = {
        return $0.map { String(describing: $0) }
    }
}

// MARK:- SWRow的基类
open class SWTableRow: SWBaseRow {
    /// 获取form
    public var form: SWTableForm? {
        return section?.form as? SWTableForm
    }
    /// 获取tableview
    public var tableView: UITableView? {
        return (section?.form?.delegate as? SWTableViewHandler)?.tableView
    }
    
    // row的默认预估高度
    public static var estimatedRowHeight: CGFloat = 44.0
    /// 短边长度
    public var shortSideLength: CGFloat {
        guard let cell = _cell else {
            return 0
        }
        return min(cell.contentView.frame.height, cell.contentView.frame.width)
    }
    // 未复用初始化时用的cellStyle
    open var cellStyle = UITableViewCell.CellStyle.value1
    
    /// cell背景色
    public var backgroundColor: UIColor?
    /// 内容背景色
    public var contentBgColor: UIColor = .clear
    public var highlightContentBgColor: UIColor?
    /// 圆角
    public var cornerRadius: CGFloat?   /// 按指定值设置圆角
    public var cornerScale: CGFloat?    /// 按 短边长度 * cornerScale 的值设置圆角，设置后cornerRadius失效，取值范围为 0 ~ 0.5
    /// 边框
    public var borderWidth: CGFloat?
    public var borderColor: UIColor = .clear
    public var highlightBorderColor: UIColor?
    
    /// 内容边距
    open var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    
    // 内联的Row
    var _inlineRow: SWTableRow?
    // tableView滚动定位参数
    open var destinationScrollPosition: UITableView.ScrollPosition = UITableView.ScrollPosition.none
    
    // 设置Row的显示与隐藏
    public override var isHidden: Bool {
        didSet {
            guard let s = section as? SWTableSection else {
                return
            }
            if isHidden {
                s.hide(row: self)
            } else {
                s.show(row: self)
            }
        }
    }
    
    // MARK:- 编辑相关
    /// 编辑模式
    open var editingStyle: UITableViewCell.EditingStyle = .none
    
    // MARK:- 复用相关
    /// 复用的identity，如果没设置 则不复用
    open var identifier: String? {
        return nil
    }
    
    // - xib创建
    /// 当xibName、bundle都不为nil时才会采用xib创建
    open var xibName: String? {
        return nil
    }
    open var bundle: Bundle? {
        return nil
    }
    
    // - storyboard创建
    /// 返回true时表示是在storyboard中创建的cell，不需要注册
    open var isStoryBoard: Bool {
        return false
    }
    
    // 注册/获取Cell,子类中实现
    func regist(to tableView: UITableView) {}
    func dequeueReusableCell(tableView: UITableView, indexPath: IndexPath) -> SWTableCell? { return nil }
    
    
    // MARK:-
    // row对应cell的高度
    open var cellHeight: CGFloat?
    // row 对应的 Cell
    weak var _cell: SWTableCell?
    
    // MARK:- 事件
    /// 用于支持左滑事件
    public lazy var trailingSwipe = {[unowned self] in SWSwipeConfiguration(self)}()
    /// 用于支持右滑事件（iOS11以上才支持）
    private lazy var _leadingSwipe = {[unowned self] in SWSwipeConfiguration(self)}()
    @available(iOS 11,*)
    public var leadingSwipe: SWSwipeConfiguration{
        get { return self._leadingSwipe }
        set { self._leadingSwipe = newValue }
    }
    
    /// 选中
    open override func didSelect() {
        if !isDisabled {
            _cell?.didSelect()
            customDidSelect()
            callbackCellOnSelection?()
        }
    }
    
    /// 更新cell
    open override func updateCell() {
        _cell?.update()
        customUpdateCell()
        callbackCellUpdate?()
    }
    
    open override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = _cell else {
            return
        }
        cell.contentView.isUserInteractionEnabled = !isDisabled
        cell.backgroundColor = backgroundColor
        cell.contentView.backgroundColor = contentBgColor
        cell.contentView.clipsToBounds = cornerScale != nil || cornerRadius != nil
        if cornerScale != nil {
            let scale = max(0, min(0.5 , cornerScale!))
            cell.contentView.layer.cornerRadius = shortSideLength * scale
        } else
        if cornerRadius != nil {
            cell.contentView.layer.cornerRadius = cornerRadius!
        } else {
            cell.contentView.layer.cornerRadius = 0
        }
        if borderWidth != nil {
            cell.contentView.layer.borderWidth = borderWidth!
            cell.contentView.layer.borderColor = borderColor.cgColor
        } else {
            cell.contentView.layer.borderWidth = 0
        }
    }
    
    /// 动画调整cell高度，一般用于自动布局的Cell，固定高度的
    public func updateHeightIfNeeded() {
        if isShow {
            tableView?.beginUpdates()
            _cell?.layoutIfNeeded()
            tableView?.endUpdates()
        }
    }
    
    /// cell高亮时调用，子类中重写可联动其他事件
    open override func customHighlightCell() {
        guard let cell = _cell else {
            return
        }
        cell.contentView.backgroundColor = highlightContentBgColor ?? contentBgColor
        cell.contentView.layer.borderColor = (highlightBorderColor ?? borderColor).cgColor
        callbackOnCellHighlightChanged?()
    }
    /// cell结束高亮时调用，子类中重写可联动其他事件
    open override func customUnHighlightCell() {
        guard let cell = _cell else {
            return
        }
        cell.contentView.backgroundColor = contentBgColor
        cell.contentView.layer.borderColor = borderColor.cgColor
        callbackOnCellHighlightChanged?()
    }
    
    // MARK:- 初始化
    public required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
    }
}

extension SWTableRow {
    public func reload(with rowAnimation: UITableView.RowAnimation = .none) {
        guard
            let tableView = (section?.form?.delegate as? SWTableViewHandler)?.tableView,
            let indexPath = indexPath
        else { return }
        tableView.reloadRows(at: [indexPath], with: rowAnimation)
    }

    @objc public func deselect(animated: Bool = true) {
        guard
            let tableView = (section?.form?.delegate as? SWTableViewHandler)?.tableView,
            let indexPath = indexPath
        else { return }
        tableView.deselectRow(at: indexPath, animated: animated)
    }

    public func select(animated: Bool = false) {
        guard
            let tableView = (section?.form?.delegate as? SWTableViewHandler)?.tableView,
            let indexPath = indexPath
        else { return }
        tableView.selectRow(at: indexPath, animated: animated, scrollPosition: destinationScrollPosition)
    }
}

// MARK: - SWTableRow各种回调事件
extension SWRowType where Self: SWTableRow {
    // 设置选中回调
    @discardableResult
    public func onCellSelection(_ callback: @escaping ((_ cell: SWTableCell, _ row: Self) -> Void)) -> Self {
        callbackCellOnSelection = { [weak self] in
            guard
                let c = self?._cell,
                let r = self
            else {
                return
            }
            callback(c, r)
        }
        return self
    }
    
    // 设置value改变时的回调
    @discardableResult
    public func onChange(_ callback: @escaping (_ row: Self) -> Void) -> Self {
        callbackOnChange = { [weak self] in
            guard let r = self else {
                return
            }
            callback(r)
        }
        return self
    }
    
    // 设置高亮的回调
    @discardableResult
    public func onHighlightChanged(_ callback: @escaping (_ row: Self) -> Void) -> Self {
        callbackOnCellHighlightChanged = { [weak self] in
            guard let r = self else {
                return
            }
            callback(r)
        }
        return self
    }
    
    // 设置结束编辑的回调
    @discardableResult
    public func onEndEditing(_ callback: @escaping (_ row: Self) -> Void) -> Self {
        callbackOnCellEndEditing = { [weak self] in
            guard let r = self else {
                return
            }
            callback(r)
        }
        return self
    }
    
    // 设置update回调
    @discardableResult
    public func cellUpdate(_ callback: @escaping ((_ cell: SWTableCell,_ row: Self) -> Void)) -> Self {
        callbackCellUpdate = { [weak self] in
            guard let c = self?._cell,
                  let r = self else {
                return
            }
            callback(c, r)
        }
        return self
    }
}
