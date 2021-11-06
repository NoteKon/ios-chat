//
//  DemoXibCell.swift
//  SWUIKit_Example
//
//  Created by Guo ZhongCheng on 2021/4/12.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SWUIKit

class DemoXibCell: SWTableCellOf<String> {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func update() {
        titleLabel.text = row?.title
    }
}

final class DemoXibRow: SWTableRowOf<DemoXibCell>, SWRowType {
    override var xibName: String? {
        return "DemoXibCell"
    }
    
    override var bundle: Bundle? {
        return Bundle.main
    }
    
    override var identifier: String? {
        return "DemoXibRow"
    }
}
