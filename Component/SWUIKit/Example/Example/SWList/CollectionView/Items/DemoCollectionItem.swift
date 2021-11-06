//
//  DemoCollectionItem.swift
//  GZCList_Example
//
//  Created by Guo ZhongCheng on 2020/9/16.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SWUIKit
import Kingfisher

struct DemoItem: Equatable {
    var imageUrl: String
    var title: String
}

class DemoCollectionCell: SWCollectionCellOf<DemoItem> {
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    
    override func setup() {
        super.setup()
        
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

final class DemoCollectionItem: SWCollectionItemOf<DemoCollectionCell>, SWRowType {
    
    override var identifier: String {
        return "DemoCollectionItem"
    }
    
    var _height: CGFloat?
    
    override func cellHeight(for width: CGFloat) -> CGFloat {
        if _height == nil {
           _height = width + 40 + CGFloat(arc4random() % 100)
        }
        return _height!
    }
    
    override func cellWidth(for height: CGFloat) -> CGFloat {
        if _height == nil {
           _height = height + 40 + CGFloat(arc4random() % 100)
        }
        return _height!
    }
}
