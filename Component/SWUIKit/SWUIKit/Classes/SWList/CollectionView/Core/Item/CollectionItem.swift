//
//  SWCollectionItem.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/15.
//

import Foundation

public protocol  SWTypedCollectionItemType: AnyObject {
    associatedtype Cell: SWCollectionCell,  SWTypedCollectionCellType
    
    /// Cell
    var cell: Cell? { get }

    /// Value
    var value: Cell.Value? { get set }
}

// MARK:- 关联了CellType和Value的row
open class SWCollectionItemOf<Cell:  SWTypedCollectionCellType>:  SWCollectionBaseItemOf<Cell.Value>,  SWTypedCollectionItemType where Cell: SWCollectionCell {
    public var cell: Cell? {
        return _cell as? Cell
    }
    
    // 注册Cell的方法
    override func regist(to collectionView: UICollectionView) {
        if isStoryBoard {
        } else
        if xibName != nil, bundle != nil {
            collectionView.register(UINib(nibName: xibName!, bundle: bundle), forCellWithReuseIdentifier: identifier)
        } else {
            collectionView.register(Cell.self, forCellWithReuseIdentifier: identifier)
        }
    }
    
    // 获取cell的方法
    override func dequeueReusableCell(collectionView: UICollectionView, indexPath: IndexPath) -> SWCollectionCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! Cell
        self._cell = cell
        self.cell?.row = self
        if !(self.cell?.isSetup ?? false) {
            self.cell?.setup()
        }
        updateCell()
        return self.cell
    }
    
    open override func customHighlightCell() {
        if isDisabled {
            return
        }
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
open class  SWCollectionBaseItemOf<T>: SWCollectionItem where T: Equatable {
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
open class SWCollectionItem: SWBaseRow {
    /// 获取form
    public var form: SWCollectionForm? {
        return section?.form as? SWCollectionForm
    }
    /// 获取collectionView
    public var collectionView: UICollectionView? {
        return (section?.form?.delegate as? SWCollectionViewHandler)?.collectionView
    }
    
    /// 滚动方向
    public var scrollDirection: UICollectionView.ScrollDirection {
        guard let handler = section?.form?.delegate as? SWCollectionViewHandler else {
            return .vertical
        }
        return handler.scrollDirection
    }
    
    /// 固定宽高比(如果设置了固定宽高比，会根据宽高比计算宽高，不会根据内容自动计算宽高)
    public var aspectRatio: CGSize?
    /// 短边长度
    public var shortSideLength: CGFloat = 0
    
    /// cell背景色
    public var backgroundColor: UIColor = .clear
    /// 背景色
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
    
    
    // 内联的item
    var _inlineItem: SWCollectionItem?
    // CollectionView滚动定位参数
    open var destinationScrollPosition: UICollectionView.ScrollPosition = UICollectionView.ScrollPosition.centeredVertically
    
    // 设置item的显示与隐藏
    public override var isHidden: Bool {
        didSet {
            guard let s = section as? SWCollectionSection else {
                return
            }
            if isHidden {
                s.hide(row: self)
            } else {
                s.show(row: self)
            }
        }
    }
    
    // MARK:- 复用相关
    /// 复用的identity，如果没设置 则不复用
    open var identifier: String {
        fatalError("CollectionItem的identifier不能为nil")
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
    func regist(to collectionView: UICollectionView) {}
    func dequeueReusableCell(collectionView: UICollectionView, indexPath: IndexPath) -> SWCollectionCell? { return nil }
    
    
    // MARK:-
    // 计算item对应cell的高度或宽度, 默认为 1:1
    open func cellHeight(for width: CGFloat) -> CGFloat {
        if let aspectHeight = aspectHeight(width) {
            return aspectHeight
        }
        return width
    }
    open func cellWidth(for height: CGFloat) -> CGFloat {
        if let aspectWidth = aspectWidth(height) {
            return aspectWidth
        }
        return height
    }
    // row 对应的 Cell
    weak var _cell: SWCollectionCell?
    
    // MARK:- 事件
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
    
    /// 更新Cell时调用，子类中重写可以联动其他效果
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
    
    /// cell高亮时调用，子类中重写可联动其他事件
    open override func customHighlightCell() {
        guard let cell = _cell else {
            return
        }
        cell.contentView.backgroundColor = highlightContentBgColor ?? contentBgColor
        cell.contentView.layer.borderColor = (highlightBorderColor ?? borderColor).cgColor
    }
    /// cell结束高亮时调用，子类中重写可联动其他事件
    open override func customUnHighlightCell() {
        guard let cell = _cell else {
            return
        }
        cell.contentView.backgroundColor = contentBgColor
        cell.contentView.layer.borderColor = borderColor.cgColor
    }
    
    // MARK:- 初始化
    public required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
    }
}

extension SWCollectionItem {
    /// 根据设定好的宽高比计算宽/高值
    public func aspectWidth(_ height: CGFloat) -> CGFloat? {
        if aspectRatio != nil {
            let width = height * aspectRatio!.width / aspectRatio!.height
            shortSideLength = min(width, height)
            return width
        }
        return nil
    }
    public func aspectHeight(_ width: CGFloat) -> CGFloat? {
        if aspectRatio != nil {
            let height = width * aspectRatio!.height / aspectRatio!.width
            shortSideLength = min(width, height)
            return height
        }
        return nil
    }
    
    /// 刷新
    public func reload() {
        guard
            let handler = section?.form?.delegate as? SWCollectionViewHandler,
            let collectionView = handler.collectionView,
            let indexPath = indexPath
        else { return }
        handler.noticeBeginItemAnimation()
        collectionView.reloadItems(at: [indexPath])
        handler.noticeEndItemAnimation()
    }
    /// 刷新界面布局
    public func updateLayout(_ animationDuration: TimeInterval = 0) {
        guard
            let handler = section?.form?.delegate as? SWCollectionViewHandler
        else { return }
        if animationDuration > 0 {
            UIView.animate(withDuration: animationDuration) {
                handler.updateLayout()
            }
        } else {
            UIView.performWithoutAnimation {
                handler.updateLayout()
            }
        }
    }

    /// 取消选中
    @objc public func deselect(animated: Bool = true) {
        guard
            let collectionView = (section?.form?.delegate as? SWCollectionViewHandler)?.collectionView,
            let indexPath = indexPath
        else { return }
        collectionView.deselectItem(at: indexPath, animated: animated)
    }

    /// 选中
    public func select(animated: Bool = false) {
        guard
            let collectionView = (section?.form?.delegate as? SWCollectionViewHandler)?.collectionView,
            let indexPath = indexPath
        else { return }
        collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: destinationScrollPosition)
    }
}

// MARK: - SWCollectionItem各种回调事件
extension SWRowType where Self: SWCollectionItem {
    // 设置选中回调
    @discardableResult
    public func onCellSelection(_ callback: @escaping ((_ cell: SWCollectionCell, _ row: SWCollectionItem) -> Void)) -> Self {
        callbackCellOnSelection = { [weak self] in
            guard
                let r = self,
                let c = self?._cell
            else {
                return
            }
            callback(c, r)
        }
        return self
    }
    
    // 设置value改变时的回调
    @discardableResult
    public func onChange(_ callback: @escaping (Self) -> Void) -> Self {
        callbackOnChange = { [weak self] in callback(self!) }
        return self
    }
    
    // 设置update回调
    @discardableResult
    public func cellUpdate(_ callback: @escaping ((_ cell: SWCollectionCell,_ row: Self) -> Void)) -> Self {
        callbackCellUpdate = { [weak self] in  callback(self!._cell!, self!) }
        return self
    }
}
