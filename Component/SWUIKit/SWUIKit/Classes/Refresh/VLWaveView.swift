//
//
//  Created by jack.
//  Copyright (c) vvlife. All rights reserved.
//

import UIKit

public class SWWaveView: UIView, UIGestureRecognizerDelegate, CAAnimationDelegate {

    var didEndPull: (() -> Void)?
    var bounceDuration: CFTimeInterval!
    var waveLayer: CAShapeLayer!
    private var space: CGFloat {
        return (self.width - animationWidth) / 2.0
    }
    var animationWidth: CGFloat = 200
    var layerColor: UIColor = .white {
        didSet {
            waveLayer.fillColor = self.layerColor.cgColor
            waveLayer.strokeColor = self.layerColor.cgColor
        }
    }

    init(frame: CGRect, bounceDuration: CFTimeInterval = 0.4, color: UIColor = UIColor.white) {
        self.bounceDuration = bounceDuration
        super.init(frame: frame)

        waveLayer = CAShapeLayer(layer: self.layer)
        waveLayer.lineWidth = 0
        waveLayer.path = wavePath(amountX: 0.0, amountY: 0.0)
        waveLayer.fillColor = self.layerColor.cgColor
        waveLayer.strokeColor = self.layerColor.cgColor
        self.layer.addSublayer(waveLayer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func wave(_ y: CGFloat) {
        self.waveLayer.path = self.wavePath(amountX: 0, amountY: y)
    }
    
    func didRelease(amountX: CGFloat, amountY: CGFloat) {
        self.boundAnimation(positionX: amountX, positionY: amountY)
    }
    
    func boundAnimation(positionX: CGFloat, positionY: CGFloat) {
        let bounce = CAKeyframeAnimation(keyPath: "path")
        let values = [
            self.wavePath(amountX: positionX, amountY: positionY),
            self.wavePath(amountX: -(positionX * 0.7), amountY: -(positionY * 1)),
            self.wavePath(amountX: positionX * 0.4, amountY: 0),
            self.wavePath(amountX: -(positionX * 0.3), amountY: -positionY * 0.1),
            self.wavePath(amountX: 0.0, amountY: 0.0)
        ]
        bounce.values = values
        bounce.duration = bounceDuration
        bounce.isRemovedOnCompletion = true
        bounce.fillMode = .forwards
        bounce.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        bounce.delegate = self
        self.waveLayer.add(bounce, forKey: "return")
    }
    
    func wavePath(amountX: CGFloat, amountY: CGFloat) -> CGPath {
        let w = self.frame.width
        let h = self.frame.height
        let centerY: CGFloat = 0
        let bottomY = h
        let topLeftPoint = CGPoint(x: space, y: centerY)
        let leftPoint = CGPoint(x: 0, y: centerY)
        let topMidPoint = CGPoint(x: w / 2 + amountX, y: centerY + amountY)
        let topRightPoint = CGPoint(x: w - space, y: centerY)
        let rightPoint = CGPoint(x: width, y: centerY)
        let bottomLeftPoint = CGPoint(x: 0, y: bottomY)
        let bottomRightPoint = CGPoint(x: w, y: bottomY)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: bottomLeftPoint)
        bezierPath.addLine(to: leftPoint)
        bezierPath.addLine(to: topLeftPoint)
        bezierPath.addCurve(to: topMidPoint, controlPoint1: CGPoint(x: (topLeftPoint.x + topMidPoint.x) / 2.0, y: topLeftPoint.y), controlPoint2: CGPoint(x: (topLeftPoint.x + topMidPoint.x) / 2.0, y: topMidPoint.y))
        bezierPath.addCurve(to: topRightPoint, controlPoint1: CGPoint(x: (topRightPoint.x + topMidPoint.x) / 2.0, y: topMidPoint.y), controlPoint2: CGPoint(x: (topRightPoint.x + topMidPoint.x) / 2.0, y: topRightPoint.y))
        bezierPath.addLine(to: rightPoint)
        bezierPath.addLine(to: bottomRightPoint)
        
        return bezierPath.cgPath
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        waveLayer.path = wavePath(amountX: 0.0, amountY: 0.0)
    }
}
