//
//  DemoInlineRow.swift
//  GZCList_Example
//
//  Created by Guo ZhongCheng on 2020/9/8.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SWUIKit

struct InlineRowValue {
    var title: String
}

class InlineRootRow: SWTableRowOf<LabelCell>, SWInlineTableRowType {
    typealias InlineRow = InlineOpenRow
    
    func setupInlineRow(_ inlineRow: InlineOpenRow) {
        inlineRow.value = "打开了"
        inlineRow.cellHeight = UITableView.automaticDimension
    }
    
    override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
}

class InlineOpenRow: SWTableRowOf<LabelCell> {
    
}
