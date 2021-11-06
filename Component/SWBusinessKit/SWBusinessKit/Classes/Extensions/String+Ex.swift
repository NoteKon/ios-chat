//
//  String+Ex.swift
//  SWBusinessKit
//
//  Created by ice on 2019/12/11.
//

import Foundation

extension String {
    public static func matchCacheKey(for urlString: String?) -> String? {
        let pattern = "(.com|.cn)/(.*)\\?"
        var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        } catch {
            
        }
        
        if let result = regex?.firstMatch(in: urlString ?? "", options: [], range: NSRange(location: 0, length: urlString?.count ?? 0)) {
            //去掉前面的amazonaws和后面的？
            let range = NSRange(location: result.range.location + 5, length: result.range.length - 6)
            let resultString = (urlString as NSString?)?.substring(with: range)
            return resultString
        }
        
        return nil
    }
}

extension String {
    /// 包含数字、字母、特殊字符串 长度8到16位,至少包含1个数字1个字母
     public func isValidPassword() -> Bool {
        let pwd =  "^(?=.*\\d)(?=.*[a-zA-Z]).{8,}$"
        let regextestpwd = NSPredicate(format: "SELF MATCHES %@",pwd)
        if (regextestpwd.evaluate(with: self) == true) {
            return true
        } else {
            return false
        }
    }
}

extension String {
    /// 指定关键词高亮
    /// - Parameter keyString: 关键词
    /// - Parameter keyColor: 高亮颜色
    /// - Parameter isLineThrough: 是否下划线
    public func setKeyColor(keyString:[String],keyColor:UIColor,isLineThrough:Bool = false) -> NSAttributedString{
        let strFullText:String = self
        var dicAttr:[NSAttributedString.Key:Any]?
        let attributeString = NSMutableAttributedString.init(string: strFullText)
        //不需要改变的文本
        let _: NSRange = NSString.init(string: strFullText).range(of: String.init(strFullText))
        //需要改变的文本
        var index:Int = 0
        for item in keyString {
            //range = NSString.init(string: strFullText).range(of: item)
            let ranges = self.rangeOfString(string: NSString.init(string: strFullText), andInString: item)
            
            for range in ranges {
                dicAttr = [
                    NSAttributedString.Key.foregroundColor:keyColor
                ]
                
                if isLineThrough {
                    dicAttr?[NSAttributedString.Key.underlineStyle] = NSNumber.init(value: 1)
                }
                
                if range.location + range.length <= strFullText.count {
                    attributeString.addAttributes(dicAttr!, range: range)
                }
            }
            
            index += 1
        }
        return attributeString
    }
    
    
    /// 获取字符出现的位置信息(支持多次位置获取)
    /// - Parameter string: 原始文本
    /// - Parameter inString: 需要查找的字符
    public func rangeOfString(string:NSString,
                              andInString inString:String) -> [NSRange] {
        
        var arrRange = [NSRange]()
        var _fullText = string
        var rang:NSRange = _fullText.range(of: inString)
        
        while rang.location != NSNotFound {
            var location:Int = 0
            if arrRange.count > 0 {
                if arrRange.last!.location + arrRange.last!.length < string.length {
                    location = arrRange.last!.location + arrRange.last!.length
                }
            }
            
            _fullText = NSString.init(string: _fullText.substring(from: rang.location + rang.length))
            
            if arrRange.count > 0 {
                rang.location += location
            }
            arrRange.append(rang)
            
            rang = _fullText.range(of: inString)
        }
        
        return arrRange
    }
}

/// eg: let str = "Hello World"
/// eg: let range = str.range(of: "Hello")?.nsRange(in: str)
extension RangeExpression where Bound == String.Index  {
    public func nsRange<S: StringProtocol>(in string: S) -> NSRange { .init(self, in: string) }
}

extension StringProtocol {
    public func nsRange<S: StringProtocol>(of string: S, options: String.CompareOptions = [], range: Range<Index>? = nil, locale: Locale? = nil) -> NSRange? {
        self.range(of: string,
                   options: options,
                   range: range ?? startIndex..<endIndex,
                   locale: locale ?? .current)?
            .nsRange(in: self)
    }
    public func nsRanges<S: StringProtocol>(of string: S, options: String.CompareOptions = [], range: Range<Index>? = nil, locale: Locale? = nil) -> [NSRange] {
        var start = range?.lowerBound ?? startIndex
        let end = range?.upperBound ?? endIndex
        var ranges: [NSRange] = []
        while start < end,
              let range = self.range(of: string,
                                     options: options,
                                     range: start..<end,
                                     locale: locale ?? .current) {
            ranges.append(range.nsRange(in: self))
            start = range.lowerBound < range.upperBound ? range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return ranges
    }
}
