//
//  String+QRCode.swift
//  Pods
//
//  Created by ice on 2020/5/9.
//

import UIKit

extension String {
    
    /// 从字符串生成二维码图片
    /// - Parameter size: 图片大小
    /// - Parameter correctionLevel: 纠错率（"L":7%, "M":15%, "Q":25%, "H":30%）
    /// - Note: 始终返回正方形，即使参数size不是正方形
    public func toQRCodeImage(size: CGSize, correctionLevel: String = "Q") -> UIImage? {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        let data = self.data(using: .utf8, allowLossyConversion: true)
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        
        guard let ciImage = filter?.outputImage else { return nil }
        
        let extent = ciImage.extent.integral
        let scale = min(size.width/extent.width, size.height/extent.height)
        
        //创建bitmap（正方形）
        let width = Int(extent.width * scale)
        let height = Int(extent.height * scale)
        let cs = CGColorSpaceCreateDeviceGray()
        let cgContext = CGContext(data: nil, width: width, height: height,
                                  bitsPerComponent: 8, bytesPerRow: 0, space: cs,
                                  bitmapInfo: CGImageAlphaInfo.none.rawValue)
        let ciContext = CIContext(options: nil)
        let cgImage = ciContext.createCGImage(ciImage, from: extent)
        
        guard let context = cgContext, let bitmapImage = cgImage else { return nil }
        
        context.interpolationQuality = .none
        context.scaleBy(x: scale, y: scale)
        context.draw(bitmapImage, in: extent)
        
        //保存图片
        if let scaledImage = context.makeImage() {
            return UIImage(cgImage: scaledImage)
        }
        
        return nil
    }
}

