//
//  DbgTableViewCell.swift
//  Alamofire
//
//  Created by dailiangjin on 2019/9/3.
//

import UIKit

class DbgTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var model: DbgLoader? {
        didSet {
            self.textLabel?.text = self.model?.debug_title()
            
            switch self.model {
            case let m as DbgSwitchLoader:
                let sw = UISwitch()
                sw.isOn = m.debug_enable()
                sw.addTarget(self, action: #selector(switchAction(_:)), for: .valueChanged)
                self.accessoryView = sw
                self.selectionStyle = .none
            case is DbgDetailLoader:
                self.accessoryView = nil
                self.accessoryType = .disclosureIndicator
            default:
                self.accessoryView = nil
                self.accessoryType = .none
            }
        }
    }
    
    @objc func switchAction(_ sender: UIControl) {
        self.model?.debug_action()
    }
}
