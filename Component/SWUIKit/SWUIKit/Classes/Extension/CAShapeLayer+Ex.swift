//
//  CAShapeLayer+Ex.swift
//  Pods-SWUIKit_Example
//
//  Created by ice on 2020/2/24.
//

import Foundation

extension CAShapeLayer {
    
    /// 画虚线
    /// - Parameters:
    ///   - rect: 画虚线的区域
    ///   - color: 虚线颜色
    static public func dottedLine(rect: CGRect, color: UIColor) -> CAShapeLayer {
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        shapeLayer.bounds = rect
        shapeLayer.position = CGPoint(x: rect.width / 2, y: rect.height / 2)
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPhase = 0
        shapeLayer.lineDashPattern = [NSNumber(value: 1.5), NSNumber(value: 1)]
        
        let path: CGMutablePath = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        shapeLayer.path = path
        
        return shapeLayer
    }
}
