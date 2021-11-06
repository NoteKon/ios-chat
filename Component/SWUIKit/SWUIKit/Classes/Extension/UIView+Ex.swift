//
//  UIView+Ex.swift
//  VVLife
//
//  Created by 吴迪玮 on 2020/6/5.
//  Copyright © 2020 vv. All rights reserved.
//

import UIKit

private var roundRectLayerContext: UInt8 = 0

extension UIView {
    public func addCornerRadiusShadowPath(
        cornerRadius: CGFloat = 2.0,
        shadowOffsetWidth: Double = 0.0,
        shadowOffsetHeight: Double = 3.0,
        shadowColor: UIColor = .black,
        shadowOpacity: Float = 0.5,
        shadowRadius: CGFloat = 0.0
    ) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.shadowPath = shadowPath.cgPath
    }
    
    private var roundRectLayer: CAShapeLayer? {
        get {
            return synchronizedSelf {
                if let disposeObject = objc_getAssociatedObject(self, &roundRectLayerContext) as? CAShapeLayer {
                    return disposeObject
                }
                return nil
            }
        }
        
        set {
            synchronizedSelf {
                objc_setAssociatedObject(self, &roundRectLayerContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public func addRoundRectLayer() {
        if let existingLayer = roundRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: layer.cornerRadius).cgPath
        shapeLayer.fillColor = backgroundColor?.cgColor

        shapeLayer.strokeColor = UIColor(hex: 0xFAFAFA).cgColor
        
        self.layer.insertSublayer(shapeLayer, at: 0)
        self.roundRectLayer = shapeLayer
    }
    
    /// 创建基础Animation
    public func createAnimation (keyPath: String,
                          toValue: CGFloat,
                          duration: CFTimeInterval = 0.25,
                          repeatCount: Float = 1) -> CABasicAnimation {
        let scaleAni = CABasicAnimation()
        scaleAni.keyPath = keyPath
        /// 设置动画的起始位置。也就是动画从哪里到哪里。不指定起点，默认就从positoin开始
        scaleAni.toValue = toValue
        /// 动画持续时间
        scaleAni.duration = duration
        ///动画重复次数
//        scaleAni.repeatCount = repeatCount
        
        return scaleAni
    }
}

private var cornerImageLayerContext: UInt8 = 0

extension UIImageView {
    public func addCornerWithClip(radius: CGFloat, isOnlyTop: Bool = false) {
        var imageIsRounded = false
        self.synchronizedSelf {
            imageIsRounded = objc_getAssociatedObject(self.image!, &cornerImageLayerContext) != nil
        }
        guard !imageIsRounded else { return }
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 1.0)
        UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: isOnlyTop ? [.topLeft, .topRight] : .allCorners, cornerRadii: CGSize(width: radius, height: radius)).addClip()
        self.draw(self.bounds)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        if newImage != nil {
            self.synchronizedSelf {
                objc_setAssociatedObject(newImage!, &cornerImageLayerContext, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.image = newImage
            }
        }
        
        // 结束
        UIGraphicsEndImageContext()
    }
    
    public func addCornerWithClip(
        radius: CGFloat,
        borderWidth: CGFloat,
        backgroundColor: UIColor,
        borderColor: UIColor) {
        let image = drawRectWithRoundedCorner(radius: radius,
                                                borderWidth: borderWidth,
                                                backgroundColor: backgroundColor,
                                                borderColor: borderColor)
        self.image = image
    }
   
    private func drawRectWithRoundedCorner(
        radius: CGFloat,
        borderWidth: CGFloat,
        backgroundColor: UIColor,
        borderColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.setAlpha(1)
        context?.setFillColor(backgroundColor.cgColor)
        context?.fill(self.bounds)
        let maskPath = UIBezierPath.init(roundedRect: self.bounds.insetBy(dx: 1, dy: 1), cornerRadius: radius)
        context?.setStrokeColor(borderColor.cgColor)
        maskPath.stroke()
        maskPath.lineWidth = borderWidth
        context?.addPath(maskPath.cgPath)
        context?.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output!
   }
}

// MARK:- SWList
extension UIView {

    public func findFirstResponder() -> UIView? {
        if isFirstResponder { return self }
        for subView in subviews {
            if let firstResponder = subView.findFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }
    
    /// 未设置rect时，需要在设置完成frame后调用（自动布局建议在layoutsubviews方法中调用）
    public func setCorners(_ corners: [CornerType], rect: CGRect? = nil) {
        let maskPath = CornerType.cornersPath(corners, rect: rect ?? self.bounds)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath?.cgPath
        layer.mask = maskLayer
    }
    
    /// 获取所在的VC
    func getViewController() -> UIViewController? {
        for view in sequence(first: self.superview, next: {$0?.superview}){
            if let responder = view?.next{
                if responder.isKind(of: UIViewController.self){
                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
}
