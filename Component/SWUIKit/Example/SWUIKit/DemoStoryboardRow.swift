//
//  DemoStoryboardRow.swift
//  SWUIKit_Example
//
//  Created by Guo ZhongCheng on 2021/4/12.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SWUIKit

class DemoStoryboardCell: SWTableCellOf<String> {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func update() {
        titleLabel.text = row?.title
    }
}

final class DemoStoryboardRow: SWTableRowOf<DemoStoryboardCell>, SWRowType {
    override var identifier: String? {
        return "DemoStoryboardRow"
    }
    
    override var isStoryBoard: Bool {
        return true
    }
}
