//
//  UIImage+Ex.swift
//  Pods
//
//  Created by huang on 2020/5/13.
//

import UIKit
import Kingfisher

extension UIImage {
    /// 由颜色创建图片
    /// - Parameter color: 颜色
    public static func from(color: UIColor,
                            rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    public func crop(rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContext(size)
        draw(in: rect)
        let cropImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return cropImage!
    }
    
    /// 根据尺寸重新生成图片
    ///
    /// - Parameter size: 设置的大小
    /// - Returns: 新图
    public func imageWithNewSize(size: CGSize) -> UIImage? {

        if self.size.height > size.height {

            let width = size.height / self.size.height * self.size.width

            let newImgSize = CGSize(width: width, height: size.height)

            UIGraphicsBeginImageContext(newImgSize)

            self.draw(in: CGRect(x: 0, y: 0, width: newImgSize.width, height: newImgSize.height))

            let theImage = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()

            guard let newImg = theImage else { return  nil}

            return newImg

        } else {

            let newImgSize = CGSize(width: size.width, height: size.height)

            UIGraphicsBeginImageContext(newImgSize)

            self.draw(in: CGRect(x: 0, y: 0, width: newImgSize.width, height: newImgSize.height))

            let theImage = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()

            guard let newImg = theImage else { return  nil}

            return newImg
        }

    }
    
    /**
     根据坐标获取图片中的像素颜色值
     */
    subscript (x: Int, y: Int) -> UIColor? {
         
        if x < 0 || x > Int(size.width) || y < 0 || y > Int(size.height) {
            return UIColor.clear
        }
        
        let provider = self.cgImage!.dataProvider
        let providerData = provider!.data
        let dataLength = Int(CFDataGetLength(providerData))
        let data = CFDataGetBytePtr(providerData)
         
        let numberOfComponents = 4
        let pointLength = Int(size.width * size.height) * numberOfComponents
        let scale = Float(dataLength) / Float(pointLength)
        let pixelData = Int(Float(((Int(size.width) * y) + x) * numberOfComponents) * scale)
         
        let r = CGFloat(data![pixelData]) / 255.0
        let g = CGFloat(data![pixelData + 1]) / 255.0
        let b = CGFloat(data![pixelData + 2]) / 255.0
        let a = CGFloat(data![pixelData + 3]) / 255.0
         
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /// 更改图片颜色
    public func imageWithTintColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        color.setFill()
        let bounds = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
    
    /// 图片设置圆角
    /// - Parameters:
    ///   - cornerRadius: 圆角半径
    /// - Returns: 图片
    public func image(cornerRadius: CGFloat) -> UIImage {
       let rect = CGRect(origin: CGPoint.zero, size: size)
        //1. 开启上下文
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        //3. 颜色填充
        UIRectFill(rect)
        //4. 图像绘制
        //切回角
        let path = UIBezierPath(ovalIn: rect)
        path.addClip()
        
        self.draw(in: rect)
        //5. 获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        //6 关闭上下文
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK:- 指定特定位置圆角
public extension UIImage {
    
    /// 添加圆角
    /// - Parameters:
    ///   - corners: 圆角配置数组
    ///   - imageScale: 圆角缩放倍数
    ///   - opaque: 是否包含透明通道，默认false
    /// - Returns: 添加了圆角的图片
    func corners(_ corners: [CornerType], imageScale: CGFloat = 1, toSize: CGSize? = nil, opaque: Bool = false) -> UIImage? {
        var targetSize: CGSize = size
        if toSize != nil {
            targetSize = toSize!
        }
        /// 开始画布
        UIGraphicsBeginImageContextWithOptions(targetSize, opaque, UIScreen.main.scale)
        /// 画圆角
        let rect = CGRect(origin: .zero, size: targetSize)
        CornerType.cornersPath(corners, rect: rect, scale: imageScale)?.addClip()
        draw(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 根据给定的比例缩放图片，支持gif
    ///
    /// - Parameter scale: 缩放倍数
    /// - Parameter originData: 图片的原始数据，用于判断是否gif, 以及对gif进行缩放，不传则默认为非静态图片
    /// - Returns: 新图对象
    func reSize(scale: CGFloat, originData: Data? = nil) -> UIImage? {
        return reSizeWithJudgment(scale: scale,originData: originData).0
    }
    
    /// 根据给定的比例缩放图片，支持gif，返回值带是否gif的判断值
    ///
    /// - Parameter scale: 缩放倍数
    /// - Parameter originData: 图片的原始数据，用于判断是否gif, 以及对gif进行缩放，不传则默认为非静态图片
    /// - Returns: 元组，(压缩后的UIImage对象, 是否gif图片)
    func reSizeWithJudgment(scale: CGFloat, originData: Data? = nil) -> (UIImage?, Bool) {
        /// 有原始数据则判断是否gif
        if let data = originData,
           data.kf.imageFormat == ImageFormat.GIF
        {
            /// 返回压缩后的图片
            return (KingfisherWrapper.animatedImage(data: data, options: .init(scale: 1/scale)), true)
        }
        let verificationScale = max(0, scale)
        /// 计算目标尺寸
        let targetSize: CGSize = CGSize(width: Int(self.size.width * verificationScale), height: Int(self.size.height * verificationScale))
        /// 重绘图片
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let newImg = theImage else { return  (nil, false)}
        return (newImg, false)
    }
}

/// 圆角枚举
public struct CornerType {
    
    // MARK:- 快速创建
    // 左上
    public static func leftTop(_ value: CGFloat) -> CornerType {
        return CornerType(position: .leftTop, value: value)
    }
    // 右上
    public static func rightTop(_ value: CGFloat) -> CornerType {
        return CornerType(position: .rightTop, value: value)
    }
    // 左下
    public static func leftBottom(_ value: CGFloat) -> CornerType {
        return CornerType(position: .leftBottom, value: value)
    }
    // 右下
    public static func rightBottom(_ value: CGFloat) -> CornerType {
        return CornerType(position: .rightBottom, value: value)
    }
    // 全部
    public static func all(_ value: CGFloat) -> [CornerType] {
        return [CornerType(position: .leftTop, value: value),
                CornerType(position: .rightTop, value: value),
                CornerType(position: .leftBottom, value: value),
                CornerType(position: .rightBottom, value: value)]
    }
    
    // MARK:- 获取路径
    /// 生成圆角裁剪的路径
    /// - Parameters:
    ///   - corners: 圆角设置数组
    ///   - size: 目标大小
    ///   - scale: 圆角缩放倍数（corners的value会乘上这个数）
    /// - Returns: 圆角路径
    public static func cornersPath(_ corners: [CornerType], rect: CGRect, scale: CGFloat = 1) -> UIBezierPath? {
        if corners.count == 0 {
            return UIBezierPath(rect: rect)
        } else {
            /// 默认值
            var leftTop: CGFloat = 0
            var rightTop: CGFloat = 0
            var leftBottom: CGFloat = 0
            var rightBottom: CGFloat = 0
            /// 遍历设置圆角值
            for corner in corners {
                switch corner.position {
                    case .leftTop:
                        leftTop = corner.value * scale
                    case .rightTop:
                        rightTop = corner.value * scale
                    case .leftBottom:
                        leftBottom = corner.value * scale
                    case .rightBottom:
                        rightBottom = corner.value * scale
                }
            }
            
            let path = UIBezierPath()
            let maxRadius = min(rect.width, rect.height)
            /// 画左上角圆弧
            var tempValue = min(maxRadius,abs(leftTop))
            if leftTop < 0 {
                path.addArc(
                    withCenter: CGPoint(x: rect.minX, y: rect.minY),
                    radius: tempValue,
                    startAngle: 0.5 * CGFloat.pi,
                    endAngle: 0,
                    clockwise: false)
            } else {
                path.addArc(
                    withCenter: CGPoint(x: rect.minX + tempValue, y: rect.minY + tempValue),
                    radius: tempValue,
                    startAngle: CGFloat.pi,
                    endAngle: 1.5 * CGFloat.pi,
                    clockwise: true)
            }
            /// 画右上角圆弧
            tempValue = min(maxRadius,abs(rightTop))
            if rightTop < 0 {
                path.addArc(
                    withCenter: CGPoint(x: rect.maxX, y: rect.minY),
                    radius: tempValue,
                    startAngle: CGFloat.pi,
                    endAngle: 0.5 * CGFloat.pi,
                    clockwise: false)
            } else {
                path.addArc(
                    withCenter: CGPoint(x: rect.maxX - tempValue, y: rect.minY + tempValue),
                    radius: tempValue,
                    startAngle: 1.5 * CGFloat.pi,
                    endAngle: 0,
                    clockwise: true)
            }
            /// 画右下角圆弧
            tempValue = min(maxRadius,abs(rightBottom))
            if rightBottom < 0 {
                path.addArc(
                    withCenter: CGPoint(x: rect.maxX, y: rect.maxY),
                    radius: tempValue,
                    startAngle: 1.5 * CGFloat.pi,
                    endAngle: CGFloat.pi,
                    clockwise: false)
            } else {
                path.addArc(
                    withCenter: CGPoint(x: rect.maxX - tempValue, y: rect.maxY - tempValue),
                    radius: tempValue,
                    startAngle: 0,
                    endAngle: 0.5 * CGFloat.pi,
                    clockwise: true)
            }
            /// 画左下角圆弧
            tempValue = min(maxRadius,abs(leftBottom))
            if leftBottom < 0 {
                path.addArc(
                    withCenter: CGPoint(x: rect.minX, y: rect.maxY),
                    radius: tempValue,
                    startAngle: 0,
                    endAngle: 1.5 * CGFloat.pi,
                    clockwise: false)
            } else {
                path.addArc(
                    withCenter: CGPoint(x: rect.minX + tempValue, y: rect.maxY - tempValue),
                    radius: tempValue,
                    startAngle: 0.5 * CGFloat.pi,
                    endAngle: CGFloat.pi,
                    clockwise: true)
            }
            path.close()
            return path
        }
    }
    
    // 圆角位置
    public enum Position {
        case leftTop
        case rightTop
        case leftBottom
        case rightBottom
    }
    // 圆角描述
    public var position: Position
    public var value: CGFloat
}

