//
//  UIView+Ex.swift
//  MorSunCare
//
//  Created by ice on 2021/9/5.
//

import UIKit
extension UIView {
    /// 设置阴影
    /// layer.shadowOffset = CGSize(width: 10, height: 10)
    /// width : 为正数时，向右偏移，为负数时，向左偏移
    /// height : 为正数时，向下偏移，为负数时，向上偏移
    /// - Parameters:
    ///   - color: 阴影颜色
    ///   - offset: 阴影偏移量
    ///   - opacity: 阴影透明度
    ///   - radius: 阴影半径
    /// 使用该方法，显示初始化frame，不能用自动布局约束，否则适配有问题
    func addShadow(color: UIColor, offset: CGSize, opacity: Float, radius: CGFloat) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
}

extension UIView {
    
    /// 渐变色
    /// - Parameters:
    ///   - startColor: 开始渐变的颜色
    ///   - middleColor: 中间渐变颜色
    ///   - endColor: 结束渐变颜色
    ///   - locations: 渲染位置 前半段比例，后半段比例，默认各50%
    ///   - isVertical: 水平或者垂直渐变, 默认垂直渐变，水平从左到右，垂直从上到下
    ///  eg: addGradientColor(startColor: UIColor.red, middleColor: UIColor.white, endColor: UIColor.white)
    /// 调用前必须设置好frame尺寸，自动布局会有适配问题
    func addGradientColor(startColor: UIColor,
                          middleColor: UIColor,
                          endColor: UIColor,
                          locations: [NSNumber] = [0.0, 0.5, 1.0],
                          isVertical: Bool = true) {
        let layer = CAGradientLayer()
        layer.bounds = self.bounds
        layer.borderWidth = 0
        layer.frame = self.bounds
        layer.cornerRadius = self.layer.cornerRadius
        layer.colors = [startColor.cgColor, middleColor.cgColor, endColor.cgColor]
        layer.locations = locations
        let startPoint = isVertical ? CGPoint(x: 0, y: 0) : CGPoint(x: 0, y: 0)
        let endPoint = isVertical ?  CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0)
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        self.layer.insertSublayer(layer, at: 0)
    }
}

//extension UIView {
//    func toImage() -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
//        let context = UIGraphicsGetCurrentContext()
//        self.layer.render(in: context!)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image!
//    }
//}
