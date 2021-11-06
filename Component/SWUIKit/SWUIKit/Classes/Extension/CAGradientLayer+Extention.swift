//
//  CAGradientLayer+Extention.swift
//  VVRider
//
//  Created by julian on 2020/2/6.
//  Copyright © 2020 peter. All rights reserved.
//

import Foundation

public extension CAGradientLayer {
    convenience init(frame: CGRect,
                     colors: [UIColor],
                     _ locations: [NSNumber] = [0, 1],
                     _ startPoint: CGPoint = CGPoint(x: 0, y: 1),
                     _ endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
        self.init()
        self.frame = frame
        self.colors = []
        for color in colors {
            self.colors?.append(color.cgColor)
        }
        self.locations = locations
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    func createGradientImage() -> UIImage? {
        var image: UIImage?
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
}
