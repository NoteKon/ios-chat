//
//  ImageRow.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/22.
//

import UIKit
import SnapKit
import Kingfisher

// MARK:- ImageCell
open class ImageCellOf<T: Equatable>: SWTableCellOf<T>, SWScrollObserverCellType {
    
    public let imageBoxView: AnimatedImageView = AnimatedImageView()
    
    /// 圆角
    public var corners: [CornerType] = []
    
    func setImage(_ image: UIImage?, showSize: CGSize? = nil) {
        imageBoxView.image = image
        if let showSize = showSize {
            imageBoxView.setCorners(corners, rect: CGRect(x: 0, y: 0, width: showSize.width, height: showSize.height))
        }
        if isScrolling() {
            // 如果正在滚动，就不播放gif
            imageBoxView.stopAnimating()
        }
    }

    open override func setup() {
        super.setup()
        selectionStyle = .none
        imageBoxView.clipsToBounds = true
        contentView.addSubview(imageBoxView)
        
        imageBoxView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    /// 滚动时停止播放gif
    public func willBeginScrolling() {
        imageBoxView.stopAnimating()
    }
    
    public func didEndScrolling() {
        imageBoxView.startAnimating()
    }
}

// MARK:- ImageRow
open class ImageRowOf<T: Equatable>: SWTableRowOf<ImageCellOf<T>> {
    
    /// 是否自动调整高度
    public var autoHeight: Bool = true
    /// 图片预估比例
    public var estimatedSize: CGSize?
    /// 根据预估比例返回首次的高度
    var _cellHeight: CGFloat?
    public override var cellHeight: CGFloat? {
        set {
            _cellHeight = newValue
        }
        get {
            if _cellHeight == nil {
                let tbv = (section?.form?.delegate as? SWTableViewHandler)?.tableView
                guard
                    let size = estimatedSize,
                    let tableView = tbv else {
                    return _cellHeight
                }
                let height: CGFloat = (tableView.frame.width - contentInsets.left - contentInsets.right) * size.height / size.width
                let space: CGFloat = contentInsets.top + contentInsets.bottom
                let total: CGFloat = height + space
                _cellHeight = max(0, round(total))
            }
            return _cellHeight
        }
    }
    
    /// 图片url字符串
    public var imageUrl: String?
    
    /// uiimage对象
    public var image: UIImage?
    
    /** 加载中的样式
     *  .none 默认没有菊花
     *  .activity 使用系统菊花
     *  .image(imageData: Data) 使用一张图片作为菊花，支持gif图
     *  .custom(indicator: Indicator) 使用自定义菊花，要遵循Indicator协议
     */
    public var loadingIndicatorType: IndicatorType = .activity
    
    /// 加载中占位图片
    public var placeholderImage: UIImage?
    
    /// 加载失败图片
    public var loadFaildImage: UIImage?
    
    /// 图片填充模式
    public var contentMode: UIView.ContentMode = .scaleAspectFill
    
    /// 圆角
    public var corners: [CornerType] = []
 
    // 更新cell的布局
    open override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = _cell as? ImageCellOf<T> else {
            return
        }
        
        cell.imageBoxView.contentMode = contentMode
        cell.imageBoxView.snp.updateConstraints { (make) in
            make.edges.equalTo(contentInsets)
        }
    }
    
    open override var identifier: String {
        return "ImageRowOf\(T.self)"
    }
    
    open override func willDisplay() {
        super.willDisplay()
        loadImage()
    }
    
    open override func didEndDisplay() {
        super.didEndDisplay()
        cell?.imageBoxView.stopAnimating()
    }
    
    /// 加载图片
    func loadImage() {
        guard let cell = cell else {
            return
        }
        if let url = imageUrl {
            cell.imageBoxView.kf.indicatorType = self.loadingIndicatorType
            cell.imageBoxView.image = nil
            let imageWidth: CGFloat = cell.bounds.width - contentInsets.left - contentInsets.right
            if let placeholder = placeholderImage {
                setImage(placeholder)
            }
            cell.imageBoxView.loadWebImage(url, maxWidth: imageWidth, completionHandler:  { [weak self] (result) in
                switch result {
                    case .success(let imageOption):
                        guard let image = imageOption,
                              let strongSelf = self
                        else {
                            guard let errorImage = self?.loadFaildImage else {
                                return
                            }
                            DispatchQueue.main.async {
                                self?.setImage(errorImage)
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            strongSelf.setImage(image)
                        }
                    case .failure(_):
                        return
                }
            })
        } else if let image = image {
            setImage(image)
        }
    }
    
    func setImage(_ image: UIImage) {
        guard isShow else {
            return
        }
        guard let cell = cell else {
            return
        }
        var showImageSize = CGSize(width: cell.bounds.width - contentInsets.left - contentInsets.right, height: cell.bounds.height - contentInsets.top - contentInsets.bottom)
        if autoHeight {
            let imageWidth: CGFloat = showImageSize.width
            let imageHeight = imageWidth * image.size.height / image.size.width
            showImageSize.height = imageHeight
            let height: CGFloat = imageHeight + contentInsets.top + contentInsets.bottom
            // 由于计算误差的存在，相差2以上才更新高度
            if abs(height - (cellHeight ?? 0)) > 2 {
                cell.updateHeight(height, animation: false)
            }
        }
        cell.corners = corners
        // 如果已经不在展示就不设置图片
        guard isShow else {
            return
        }
        cell.setImage(image, showSize: showImageSize)
    }
}

///  图片展示Row，可设置图片预估比例、内容边距、圆角等，支持网络图片加载
public final class ImageRow: ImageRowOf<String>, SWRowType {
    
    public convenience init(url: String, _ initializer: (ImageRow) -> Void = { _ in }) {
        self.init(nil, tag: nil)
        imageUrl = url
        initializer(self)
    }
}
