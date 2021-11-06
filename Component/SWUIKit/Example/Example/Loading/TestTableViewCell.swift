//
//  TestTableViewCell.swift
//  SWUIKit_Example
//
//  Created by ice on 2019/11/4.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class TestTableViewCell: UITableViewCell {
    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var iconImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func upLoadCell(text: String) {
       // self.label1.text = text
        //self.label1.backgroundColor = UIColor.red
    }
}
