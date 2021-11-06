//
//  DemoStoryboardItem.swift
//  SWUIKit_Example
//
//  Created by Guo ZhongCheng on 2021/4/12.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SWUIKit

class DemoStoryboardItemCell: SWCollectionCellOf<Int> {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func update() {
        imageView.loadWebImage(row?.title)
        valueLabel.text = "\(row?.value ?? 0)"
    }
}

final class DemoStoryboardItem: SWCollectionItemOf<DemoStoryboardItemCell>, SWRowType {
    override var identifier: String {
        return "DemoStoryboardItem"
    }
    
    override var isStoryBoard: Bool {
        return true
    }
    
    override func cellWidth(for height: CGFloat) -> CGFloat {
        return height
    }
    
    override func cellHeight(for width: CGFloat) -> CGFloat {
        return width
    }
}
