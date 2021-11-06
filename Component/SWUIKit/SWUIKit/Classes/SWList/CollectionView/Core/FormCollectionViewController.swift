//
//  SWFormCollectionViewController.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/6/2.
//

import UIKit

open class SWFormCollectionViewController: UIViewController {
    
    // handler代理, 包括cell的value改变回调以及scrollviewDelegate相关方法
    public weak var handerDelegate: SWCollectionViewHandlerDelegate? {
        didSet {
            handler.delegate = handerDelegate
        }
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
    open var contentInset: UIEdgeInsets = .zero {
        didSet {
            handler.contentInset = contentInset
        }
    }
    /// 列数（默认为2），仅在arrangement为.system和.flow时生效，如果section中也包含了此属性，section的属性优先级更高
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
    
    // collectionView
    @IBOutlet public var collectionView: UICollectionView!
    // collectionView代理处理类
    public var handler: SWCollectionViewHandler = SWCollectionViewHandler()
    public var form: SWCollectionForm {
        return handler.form
    }
    
    /// 去除顶部留白
    public func cancelAdjustsScrollView() {
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if collectionView == nil {
            collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: handler.layout ?? handler.collectionLayout(for: arrangement))
            collectionView.backgroundColor = .white
            collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        if collectionView.superview == nil {
            view.addSubview(collectionView)
        }
        handler.collectionView = collectionView
        
        cancelAdjustsScrollView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handler.addLongTapIfNeeded()
    }
}
