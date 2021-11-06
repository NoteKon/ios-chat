//
//  SWCollectionHeaderFooterView.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/15.
//

import Foundation
import UIKit

/**
 *  collectionView的header和footer需要实现的协议
 *  header和footer可以设置为String或View
 */
public protocol SWCollectionHeaderFooterViewRepresentable {
    
    /// 调用此方法来注册
    func register(to collectionView: UICollectionView, for kind: String)

    /**
     调用此方法来获取指定section的header或footer相对应的view
     
     - parameter section:    要获取view的section
     - parameter collectionView: 所在的collectionView
     - parameter type:       类型（header或footer）
     
     - returns: 对应的view
     */
    func viewForSection(_ section: SWCollectionSection,in collectionView: UICollectionView, type: HeaderFooterType, for indexPath: IndexPath) -> UICollectionReusableView?

    /// 如果Section的Header或Footer是用字符串创建的，则它将存储在title中，需要在viewForSection中实现具体展示
    var title: String? { get set }

    /// 高度
    var height: (() -> CGFloat)? { get set }
    
    /// 复用的identifier
    var identifier: String? { get set }
    
    /// 是否需要悬浮
    var shouldSuspension: Bool { get set }
}

/**
 *  用于生成header或footer
 */
public struct  SWCollectionHeaderFooterView<ViewType: UICollectionReusableView> : SWCollectionHeaderFooterViewRepresentable {
    
    public typealias ViewCreatedBlock = ((_ view: ViewType) -> Void)
    
    /// 复用的ID
    public var identifier: String? = "CollectionHeaderFooterView\(ViewType.self)"
    /// 标题
    public var title: String?
    /// view获取到之后会走的回调
    public var onCreated: ViewCreatedBlock?
    /// view创建完成的回调
    public var onSetupView: ((_ view: ViewType, _ section: SWCollectionSection) -> Void)?
    /// view的高度
    public var height: (() -> CGFloat)?
    
    /// 是否需要悬浮
    public var shouldSuspension: Bool = false

    /**
     调用此方法来获取section中的headerView或footerView
     
     - parameter section:    目标section
     - parameter type:       header 或 footer.
     
     - returns: view
     */
    public func viewForSection(_ section: SWCollectionSection,in collectionView: UICollectionView, type: HeaderFooterType, for indexPath: IndexPath) -> UICollectionReusableView? {
        var view: ViewType?
        if type == .header {
            view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier!, for: indexPath) as? ViewType
        } else {
            view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier!, for: indexPath) as? ViewType
        }
        guard let v = view else { return nil }
        onCreated?(v)
        onSetupView?(v, section)
        return v
    }
    
    /// 注册Header/Footer
    public func register(to collectionView: UICollectionView, for kind: String) {
        collectionView.register(ViewType.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier!)
    }

    /**
     使用枚举类型初始化，适用于自定义的header/footer
     */
    public init(_ block: @escaping ViewCreatedBlock) {
        onCreated = block
    }
}

class CollectionStringHeaderFooterView: UICollectionReusableView {
    /// 展示的标题内容
    var title: String? {
        didSet {
            updateText()
        }
    }
    
    /// 滚动方向,默认为竖直方向滚动
    var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            updateText()
            if scrollDirection == .vertical {
                titleLabel.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(16)
                    make.right.lessThanOrEqualTo(-16)
                }
            } else {
                titleLabel.snp.remakeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(16)
                    make.bottom.lessThanOrEqualTo(-16)
                    make.width.equalTo(17)
                }
            }
        }
    }
    
    func updateText() {
        if scrollDirection == .vertical {
            titleLabel.text = title
        } else {
            if let title = title {
                var changeTitle: String = ""
                for index in title.indices {
                    changeTitle += "\(title[index])\n"
                }
                titleLabel.text = changeTitle
            } else {
                titleLabel.text = title
            }
        }
    }
    
    let titleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.init(white: 0.88, alpha: 1.0)
        
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 16.7, weight: .medium)
        titleLabel.textColor = UIColor.init(white: 0.1, alpha: 1.0)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
            make.right.lessThanOrEqualTo(-16)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
