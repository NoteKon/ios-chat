//
//  ImageItem.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/23.
//

import UIKit
import SnapKit
import Kingfisher

// MARK:- ImageCell
open class CollectionImageCellOf<T: Equatable>: SWCollectionCellOf<T>, SWScrollObserverCellType {
    
    public let imageBoxView: AnimatedImageView = AnimatedImageView()
    
    /// 圆角
    public var corners: [CornerType] = []
    
    public func setImage(_ image: UIImage?, showSize: CGSize? = nil) {
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
        
        imageBoxView.clipsToBounds = true
        contentView.addSubview(imageBoxView)
        
        imageBoxView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview().priority(.high)
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
open class ImageItemOf<T: Equatable>: SWCollectionItemOf<CollectionImageCellOf<T>> {
    
    /// 是否自动调整宽度/高度
    public var autoSize: Bool = true
    
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
        guard let cell = _cell as? CollectionImageCellOf<T> else {
            return
        }
        
        cell.imageBoxView.contentMode = contentMode
        cell.imageBoxView.snp.updateConstraints { (make) in
            make.edges.equalTo(contentInsets).priority(.high)
        }
    }
    
    open override func willDisplay() {
        super.willDisplay()
        loadImage()
    }
    
    open override func didEndDisplay() {
        super.didEndDisplay()
        cell?.imageBoxView.stopAnimating()
    }
    
    open override var identifier: String {
        return "ImageItemOf\(T.self)"
    }
    
    open override func cellHeight(for width: CGFloat) -> CGFloat {
        if let aspectHeight = aspectHeight(width) {
            return aspectHeight
        }
        // 默认为1:1
        return width
    }
    
    open override func cellWidth(for height: CGFloat) -> CGFloat {
        if let aspectWidth = aspectWidth(height) {
            return aspectWidth
        }
        // 默认为1:1
        return height
    }
    
    /// 设置内容边距默认为0
    public required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
        contentInsets = .zero
    }
    
    /// 加载图片
    func loadImage() {
        guard let cell = cell else {
            return
        }
        if let url = imageUrl {
            cell.imageBoxView.kf.indicatorType = self.loadingIndicatorType
            var maxWidth: CGFloat?
            var maxHeigh: CGFloat?
            if contentMode == .scaleAspectFit {
                if scrollDirection == .vertical {
                    maxWidth = cell.bounds.width - contentInsets.left - contentInsets.right
                } else {
                    maxHeigh = cell.bounds.height - contentInsets.top - contentInsets.bottom
                }
            } else {
                maxWidth = cell.bounds.width - contentInsets.left - contentInsets.right
                maxHeigh = cell.bounds.height - contentInsets.top - contentInsets.bottom
                let maxValue: CGFloat = max(maxWidth!, maxHeigh!)
                maxWidth = maxValue
                maxHeigh = maxValue
            }
            if let placeholder = placeholderImage {
                setImage(placeholder)
            }
            cell.imageBoxView.loadWebImage(url, maxWidth: maxWidth, maxHeight: maxHeigh, completionHandler:  { [weak self] (result) in
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
        guard let cell = _cell as? CollectionImageCellOf<T> else {
            return
        }
        var showImageSize = CGSize(width: cell.bounds.width - contentInsets.left - contentInsets.right, height: cell.bounds.height - contentInsets.top - contentInsets.bottom)
        if autoSize {
            if self.scrollDirection == .vertical {
                let imageWidth: CGFloat = cell.bounds.width - contentInsets.left - contentInsets.right
                let imageHeight = imageWidth * image.size.height / image.size.width
                let cellHeight: Int = Int(imageHeight + contentInsets.top + contentInsets.bottom)
                // 相差2以上才更新尺寸
                if let ratio = aspectRatio, abs(cellHeight - Int(ratio.height)) > 2 || abs(Int(cell.bounds.width) - Int(ratio.width)) > 2 {
                    aspectRatio = CGSize(width: Int(cell.bounds.width), height: cellHeight)
                    updateLayout()
                } else if aspectRatio == nil {
                    aspectRatio = CGSize(width: Int(cell.bounds.width), height: cellHeight)
                    updateLayout()
                }
                showImageSize  = CGSize(width: imageWidth, height: imageHeight)
            } else {
                let imageHeight: CGFloat = cell.bounds.height - contentInsets.top - contentInsets.bottom
                let imageWidth = imageHeight * image.size.width / image.size.height
                let cellWidth: Int = Int(imageWidth + contentInsets.left + contentInsets.right)
                // 相差2以上才更新尺寸
                if let ratio = aspectRatio, abs(Int(cell.bounds.height) - Int(ratio.height)) > 2 || abs(cellWidth - Int(ratio.width)) > 2 {
                    aspectRatio = CGSize(width: cellWidth, height: Int(cell.bounds.height))
                    updateLayout()
                } else if aspectRatio == nil {
                    aspectRatio = CGSize(width: cellWidth, height: Int(cell.bounds.height))
                    updateLayout()
                }
                showImageSize  = CGSize(width: imageWidth, height: imageHeight)
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

///  图片展示Item，可设置图片预估比例、内容边距、圆角等，支持网络图片加载
public final class ImageItem: ImageItemOf<String>, SWRowType {
    
    public convenience init(url: String, _ initializer: (ImageItem) -> Void = { _ in }) {
        self.init(nil, tag: nil)
        imageUrl = url
        initializer(self)
    }
    
}
