//
//  DemoFoldView.swift
//  GZCList_Example
//
//  Created by Guo ZhongCheng on 2020/10/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SWUIKit

// MARK:- DemoFoldTableCell
class DemoFoldTableCell: FoldCell {
    /// 左侧头像
    let _userImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    override var leftView: UIView {
        return _userImageView
    }
    
    /// 折叠内容
    let _foldDemoView: DemoFoldView = DemoFoldView()
    override var foldContentView: SWFoldContentView {
        return _foldDemoView
    }
    
    /// 展开/收起 按钮
    let _foldButton: DemoFoldButton = DemoFoldButton()
    override var foldOpenView: SWBaseFoldOpenView {
        return _foldButton
    }
}

// MARK:- DemoFoldRow
final class DemoFoldRow: _FoldRowOf<DemoFoldTableCell>, SWRowType {
    /// 文字
    var text: String = ""
    /// 图片 (建议1-9张)
    var images: [String] = []
    /// 头像地址
    var userImageUrl: String?
    
    override var openViewPosition: SWFoldOpenPosition {
        set {
        }
        get {
            return .cover
        }
    }
    
    override func customUpdateCell() {
        guard let cell = cell else {
            super.customUpdateCell()
            return
        }
        
        cell._foldDemoView.text = text
        cell._foldDemoView.images = images
        if let url = userImageUrl {
            /// 使用此方法，避免头像图片太大导致卡顿
            cell._userImageView.loadWebImage(url, maxWidth: 30)
            leftViewSize = CGSize(width: 30, height: 30)
        } else {
            leftViewSize = CGSize.zero
        }
        
        super.customUpdateCell()
    }
    
    override var identifier: String {
        if userImageUrl == nil {
            return "DemoFoldRowWithLeft"
        }
        return "DemoFoldRowRow"
    }
}

// MARK:- DemoFoldView
class DemoFoldView: SWFoldContentView {
    /// 头像地址
    var photoImageUrl: String?
    /// 文字
    var text: String = "" {
        didSet {
            textLabel.text = text
        }
    }
    /// 图片 (建议1-9张)
    var images: [String] = [] {
        didSet {
            imageItems.removeAll()
            if images.count <= 0 {
                imagesCollectionSize = CGSize.zero
            } else
            if images.count == 1 {
                imagesSection.column = 1
                imageItems += imageItem(images.first)
                imagesCollectionSize = CGSize(width: 100, height: 100)
            } else
            if images.count <= 3 {
                imagesSection.column = images.count
                for image in images {
                    imageItems += imageItem(image)
                }
                imagesCollectionSize = CGSize(width: (80 + imagesSection.itemSpace!) * CGFloat(images.count) - imagesSection.itemSpace!, height: 80)
            } else
            if images.count == 4 {
                imagesSection.column = 2
                for image in images {
                    imageItems += imageItem(image)
                }
                imagesCollectionSize = CGSize(width: 168, height: 168)
            } else {
                imagesSection.column = 3
                for image in images {
                    imageItems += imageItem(image)
                }
                imagesCollectionSize = CGSize(width: (60 + imagesSection.itemSpace!) * 3 - imagesSection.itemSpace!, height: (60 + imagesSection.lineSpace!) * ceil(CGFloat(images.count) / 3.0) - imagesSection.lineSpace!)
            }
            imagesSection >>> imageItems
        }
    }
    
    func imageItem(_ url: String?) -> ImageItem {
        return ImageItem() { row in
            row.imageUrl = url
            row.corners = CornerType.all(5)
            row.autoSize = false
            row.aspectRatio = CGSize(width: 1, height: 1)
            row.loadFaildImage = UIImage(named: "load_faild")
            row.contentMode = .scaleAspectFit
            row.backgroundColor = .white
        }
    }
     
    var imageItems = [ImageItem]()
    
    /// 文本内容
    let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    /// 图片内容
    let imagesCollection = SWFormCollectionView(frame: .zero, arrangement: .flow)
    /// 图片section
    var imagesSection = SWCollectionSection() { section in
        section.lineSpace = 8
        section.itemSpace = 8
    }
    /// 图片容器大小
    var imagesCollectionSize = CGSize.zero {
        didSet {
            imagesCollection.frame = CGRect(x: imagesCollection.frame.minX, y: imagesCollection.frame.minY, width: imagesCollectionSize.width, height: imagesCollectionSize.height)
            imagesCollection.snp.updateConstraints { (make) in
                make.top.equalTo(textLabel.snp.bottom).offset(spaceBetweenImageAndText())
                make.size.equalTo(imagesCollectionSize)
            }
            self.layoutIfNeeded()
        }
    }
    func spaceBetweenImageAndText() -> CGFloat {
        return imagesCollectionSize.height > 0 ? 10 : 0
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        clipsToBounds = true
        
        imagesCollection.backgroundColor = .clear
        imagesCollection.isScrollEnabled = false
        imagesCollection.form +++ imagesSection
        
        addSubview(textLabel)
        addSubview(imagesCollection)
        
        textLabel.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
        }
        
        imagesCollection.snp.makeConstraints { (make) in
            make.top.equalTo(textLabel.snp.bottom)
            make.left.equalToSuperview()
            make.size.equalTo(imagesCollectionSize)
        }
    }
    
    override func height(with width: CGFloat) -> CGFloat {
        let textHeight = textLabel.sizeThatFits(CGSize(width: width, height: CGFloat(MAXFLOAT))).height
        return textHeight + imagesCollectionSize.height + spaceBetweenImageAndText()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        imagesCollection.form >>> [imagesSection]
    }
}
