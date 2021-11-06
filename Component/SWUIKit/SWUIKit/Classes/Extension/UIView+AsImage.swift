//
//  UIView+AsImage.swift
//  VVLife
//
//  Created by 吴迪玮 on 2020/3/27.
//  Copyright © 2020 vv. All rights reserved.
//

import Foundation

public extension UIView {
    
    // 截图，UIView转成Image
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
