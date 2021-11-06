//
//  SWPopMenuCell.swift
//  VVPartner
//
//  Created by julian on 2019/11/26.
//  Copyright © 2019 vv. All rights reserved.
//

import UIKit

public class SWPopMenuCell: UITableViewCell {
    
    static let kReuseIdentifier = "SWPopMenuCell"
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var seprateLine: UIView!
    @IBOutlet weak var leadingIconImageViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageViewHeightConstraint: NSLayoutConstraint!
    
    public var model: SWPopupMenuModel? {
        didSet {
            titleLabel.text = model?.text
            
            if let image = loadImageNamed(model?.icon ?? "",
                                          model?.bundleName ?? "SWUIKit",
                                          model?.targetClass ?? SWUIKitModule.self) {
                iconImageView.image = image
                leadingIconImageViewConstraint.constant = 12
            } else {
                leadingIconImageViewConstraint.constant = -iconImageViewWidthConstraint.constant
            }
        }
    }
    
    func loadImageNamed(_ name: String,
                        _ bundleName: String,
                        _ targetClass: AnyClass) -> UIImage? {
        return Bundle.loadImage(name: name, bundleName: bundleName, targetClass: targetClass)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
