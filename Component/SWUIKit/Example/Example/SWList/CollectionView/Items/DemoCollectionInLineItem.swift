//
//  DemoCollectionInLineItem.swift
//  GZCList_Example
//
//  Created by Guo ZhongCheng on 2020/9/21.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SWUIKit
import Kingfisher

class DemoCollectionInlineCell: SWCollectionCellOf<DemoItem> {
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    
    override func setup() {
        super.setup()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(30)
            make.top.equalTo(imageView.snp.bottom)
        }
    }
    
    override func update() {
        guard let value = row?.value else {
            return
        }
        imageView.loadWebImage(value.imageUrl)
        titleLabel.text = value.title
    }
}

final class CollectionInlineRootItem: SWCollectionItemOf<DemoCollectionInlineCell>, InlineCollectionItemType, SWRowType {
    typealias InlineRow = CollectionInlineOpenItem
    
    override var identifier: String {
        return "CollectionInlineRootItem"
    }
    
    var inlineRowOpenBlock: ((_ row: CollectionInlineOpenItem) -> Void)?
    
    func setupInlineRow(_ inlineRow: CollectionInlineOpenItem) {
        inlineRowOpenBlock?(inlineRow)
    }
    
    override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
    
    override func cellHeight(for width: CGFloat) -> CGFloat {
        return width + 30
    }
}

final class CollectionInlineOpenItem: SWCollectionItemOf<DemoCollectionInlineCell>, SWRowType {
    override var identifier: String {
        return "CollectionInlineOpenItem"
    }
}
