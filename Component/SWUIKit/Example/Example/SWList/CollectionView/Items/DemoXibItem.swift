//
//  DemoXibItem.swift
//  SWUIKit_Example
//
//  Created by Guo ZhongCheng on 2021/4/12.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SWUIKit

class DemoXibItem: SWCollectionCellOf<String> {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func update() {
        titleLabel.text = row?.title
    }
}

final class DemoXibItemRow: SWCollectionItemOf<DemoXibItem>, SWRowType {
    override var xibName: String? {
        return "DemoXibItem"
    }
    
    override var bundle: Bundle? {
        return Bundle.main
    }
    
    override var identifier: String {
        return "DemoXibItemRow"
    }
    
    override func cellWidth(for height: CGFloat) -> CGFloat {
        return 100
    }
    
    override func cellHeight(for width: CGFloat) -> CGFloat {
        return 150
    }
}
