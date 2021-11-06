//
//  SWFormCollectionView.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/16.
//

import UIKit

open class SWFormCollectionView: UICollectionView {
    
    // handler代理, 包括cell的value改变回调以及scrollviewDelegate相关方法
    public weak var handerDelegate: SWCollectionViewHandlerDelegate? {
        didSet {
            handler.delegate = handerDelegate
        }
    }
    
    // collectionView代理处理类
    public var handler = SWCollectionViewHandler()
    public var form: SWCollectionForm {
        return handler.form
    }
    
    /// 排列方式，默认为系统样式
    open var arrangement: SWCollectionArrangement = .system {
        didSet {
            handler.arrangement = arrangement
        }
    }
    /// 滚动方向,默认为竖直方向滚动
    open var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            handler.scrollDirection = scrollDirection
        }
    }
    /// 内容边距
    open var contentInsets: UIEdgeInsets = .zero {
        didSet {
            handler.contentInset = contentInsets
        }
    }
    
    /// 列数（默认为2），仅在arrangement为.system和.flow时生效，如果section中也包含了此属性，section的属性优先级更高
    /// 要修改的话可以重写`collecitonSetting`方法进行设置
    open var column: Int = 2 {
        didSet {
            handler.column = column
        }
    }
    /// 行高（默认为40），仅在arrangement为.align时生效，如果section中也包含了此属性，section的属性优先级更高
    open var lineHeight: CGFloat = 40 {
        didSet {
            handler.lineHeight = lineHeight
        }
    }
    /// 行间距（默认为10），如果section中也包含了此属性，section的属性优先级更高
    open var lineSpace: CGFloat = 10 {
        didSet {
            handler.lineSpace = lineSpace
        }
    }
    /// 列间距（默认为10），如果section中也包含了此属性，section的属性优先级更高
    open var itemSpace: CGFloat = 10 {
        didSet {
            handler.itemSpace = itemSpace
        }
    }
    
    // MARK:- 初始化方法
    public convenience init() {
        self.init(frame: .zero, arrangement: .system)
    }
    
    public required init(frame: CGRect, arrangement: SWCollectionArrangement) {
        super.init(frame: frame, collectionViewLayout: handler.collectionLayout(for: arrangement))
        handler.arrangement = arrangement
        defaultSettings()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        arrangement = .system
        defaultSettings()
    }
    
    func defaultSettings() {
        handler.collectionView = self
        cancelAdjustsScrollView()
    }
    
    /// 去除顶部留白
    public func cancelAdjustsScrollView() {
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if !handler.addedLongTap {
            handler.addLongTapIfNeeded()
        }
    }
}
