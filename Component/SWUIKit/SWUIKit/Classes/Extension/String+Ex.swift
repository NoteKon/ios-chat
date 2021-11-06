//
//  String+Ex.swift
//  SWUIKit
//
//  Created by huang on 2019/10/25.
//

import Foundation

public extension String {
    var isValidPassword: Bool {
        if count < 8 || count > 20 {
            return false
        }
        let pattern = "^(?=.*[0-9])(?=.*[A-Z])(?=.*[a-z])(.*)$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: self)
    }
    
    static func isValidPassword(_ string: String?) -> Bool {
        if let string = string {
            return string.isValidPassword
        }
        return false
    }
}

public extension String {
    
    /// 将字符串中的特殊字符串修改颜色或字体返回富文本
    /// - Parameters:
    ///   - matchStrs: 特殊需要修改的多个字符串
    ///   - font: 修改的字体
    ///   - textColor: 修改的颜色
    func attributedString(for matchStrs: [String]?, font: UIFont? = nil, textColor: UIColor? = nil) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: self)
        guard let subStrs = matchStrs, subStrs.count != 0, (font != nil || textColor != nil) else {
            return attrString
        }
        subStrs.forEach { (subStr) in
            let ranges = self.ranges(of: subStr)
            if ranges.count > 0 {
                var attr = [NSAttributedString.Key: Any]()
                if let font = font {
                    attr[.font] = font
                }
                if let textColor = textColor {
                    attr[.foregroundColor] = textColor
                }
                ranges.forEach { (range) in
                    attrString.setAttributes(attr, range: range)
                }
            }
        }
        return attrString
    }
    
    // MARK: - Private
    /// 获取字符串中特定字符串的 NSRange
    /// - Parameter string: 需要获取范围的特定字符串
    private func ranges(of matchStr: String) -> [NSRange] {
        var allLocation = [Int]() //所有起点
        let matchStrLength = (matchStr as NSString).length  //currStr.characters.count 不能正确统计表情
        let arrayStr = self.components(separatedBy: matchStr)
        var currLoc = 0
        arrayStr.forEach { currStr in
            currLoc += (currStr as NSString).length
            allLocation.append(currLoc)
            currLoc += matchStrLength
        }
        allLocation.removeLast()
        return allLocation.map { NSRange(location: $0, length: matchStrLength) }
    }
}

public extension String {
    
    func rangOfSubStr(str: String) -> NSRange {
        let nsrangeArr = self.ranges(of: str)
        if nsrangeArr.count > 0 {
            return nsrangeArr[0]
        }
        return NSRange(location: 0, length: 0)
    }
    
    /// Range 转换成 NSRange
    /// - Parameter range: Range
    func toNSRange(_ range: Range<String.Index>) -> NSRange {
        guard let from = range.lowerBound.samePosition(in: utf16), let to = range.upperBound.samePosition(in: utf16) else {
            return NSRange(location: 0, length: 0)
        }
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from), length: utf16.distance(from: from, to: to))
    }
    
    /// NSRange 转换成 Range
    /// - Parameter range: NSRange
    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex) else { return nil }
        guard let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: self) else { return nil }
        guard let to = String.Index(to16, within: self) else { return nil }
        return from ..< to
    }
}

public extension String {
    
    /// 去除字符串首尾的空格
    func headTailNoSpace() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    /// 是否是空串
//    static func isEmpty(_ text: String?) -> Bool {
//        guard let text = text else { return true }
//        return text.isEmpty
//    }
    
    func textSize(font: UIFont, maxSize: CGSize) -> CGSize {
        return self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil).size
    }
}

public extension String {
    func toTimeInterval(formate: String = "yyyy-MM-dd HH:mm") -> TimeInterval? {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = formate
        
        let date = dateFormatter.date(from: self)
        let timeInterval = date?.timeIntervalSince1970 ?? 0
        return timeInterval * 1000
    }
    
    
    func characterCount() -> Int {
        
        let cfEncoding = CFStringEncodings.GB_18030_2000
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
        let gbkData = self.data(using: String.Encoding(rawValue: encoding))
        return gbkData?.count ?? 0
    }
}

public extension String {
    func countByUtf16() -> Int {
        var totalCount = 0
        for char in self {
            var addCount = char.utf16.count
            // 判断中文
            if char >= "\u{4E00}" && char <= "\u{9FA5}" {
                addCount = 1
            } else if addCount > 2 {
                addCount = 2
            }
            
            totalCount += addCount
        }
        
        return totalCount
    }
}
