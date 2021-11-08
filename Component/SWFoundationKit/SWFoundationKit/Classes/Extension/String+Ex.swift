//
//  String+Ex.swift
//  SWFoundationKit
//
//  Created by ice on 2019/8/14.
//

import Foundation
import CommonCrypto

// MARK: - Data

extension String {
    /// 返回UTF8字符集的Data对象
    public var data: Data {
        return self.data(using: .utf8, allowLossyConversion: false)!
    }
}

extension Data {
    /// 返回UTF8字符串
    public var string: String {
        return String(data: self, encoding: .utf8) ?? ""
    }
}

// MARK: URL encode/decode

extension String {
    /// URL编码
    public var urlEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet(charactersIn: "!*'\\\"();:@&=+$,/?%#[]% ").inverted) ?? self
    }
    /// URL解码
    public var urlDecoded: String {
        return self.removingPercentEncoding ?? self
    }
}

// MARK: Base64

extension String {
    /// 字符串的BASE64值
    public var base64: String {
        return data.base64EncodedString()
    }
    
    /// 解码BASE64字符串
    /// - Parameter base64String: BASE64字符串
    public init(base64String: String) {
        self = Data(base64Encoded: base64String)?.string ?? ""
    }
}

// MARK: Digest

extension String {
    /// 获取当前字符串的md5值
    /// - Returns: md5字符串
    public func md5() -> String {
        return data.md5.hexString
    }
    
    /// 获取当前字符串的sha1值
    /// - Returns: sha1字符串
    public func sha1() -> String {
        return data.sha1.hexString
    }
}

// MARK: - Trim

extension String {
    /// 删除前后空白符（包含空格、Tab、回车、换行符）
    public var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    /// 删除字符串中的空格
    /// - Returns: 不包含空格的字符串
    public func removeExtraSpaces() -> String {
        var data  = ""
        var numberOfSpace = 0
        let items = self.components(separatedBy: " ")
        for item in items{
            if item == " "{
                numberOfSpace = numberOfSpace + 1
            }else{
                numberOfSpace = 0
            }
            if numberOfSpace == 1 || numberOfSpace == 0 {
                data =  data + item
            }
        }
        return data
    }
}

// MARK: - 类型转换

extension String {
    /// 转换成`Int`类型的值
    public var intValue: Int {
        return (self as NSString).integerValue
    }
    
    /// 转换成`Float`类型的值
    public var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    /// 转换成`Double`类型的值
    public var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    
    /// 转换成`Bool`类型的值
    public var boolValue: Bool {
        return (self as NSString).boolValue
    }
    
    /// 转换成`Int64`类型的值
    public var int64Value: Int64 {
        return (self as NSString).longLongValue
    }
}

// MARK: Get the size of the text

extension String {
    /// 计算制定字体大小的文字显示尺寸（系统默认字体）
    public func size(fontSize: CGFloat, width: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        return size(font: UIFont.systemFont(ofSize: fontSize), width: width)
    }
    
    /// 计算制定字体的文字显示尺寸
    public func size(font: UIFont, width: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle.copy()
        ]
        
        return (self as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
    }
}

// MARK: Substring
extension String {
    public func index(at position: Int) -> Index? {
        if position < 0 {
            return nil
        }
        return index(startIndex, offsetBy: position, limitedBy: endIndex)
    }
    
    public func substring(_ fromIndex: Int, _ toIndex: Int = Int.max) -> String? {
        let len = count
        var start: Int
        var end: Int
        if fromIndex < 0 {
            start = len + fromIndex
            end = len
        } else {
            start = fromIndex
            if toIndex < 0 {
                end = len + toIndex
            } else {
                end = toIndex
            }
        }
        
        if start > end {
            return nil
        }
        
        return self[start..<min(end, len)]
    }
    
    public subscript(range: ClosedRange<Int>) -> String? {
        get {
            return self[range.lowerBound..<range.upperBound+1]
        }
        set {
            self[range.lowerBound..<range.upperBound+1] = newValue
        }
    }
    
    public subscript(range: Range<Int>) -> String? {
        get {
            guard let start = index(at: range.lowerBound),
                  let end = index(at: range.upperBound)
            else {
                return nil
            }
            return String(self[start..<end])
        }
        set {
            guard let start = index(at: range.lowerBound),
                  let end = index(at: range.upperBound)
            else {
                return
            }
            if let value = newValue {
                replaceSubrange(start..<end, with: value)
            } else {
                removeSubrange(start..<end)
            }
        }
    }
    
    public subscript(range: PartialRangeFrom<Int>) -> String? {
        get {
            guard range.lowerBound >= 0 && range.lowerBound < count else {
                return nil
            }
            return self[range.lowerBound..<count]
        }
        set {
            guard range.lowerBound >= 0 && range.lowerBound < count else {
                return
            }
            self[range.lowerBound..<count] = newValue
        }
    }
    
    public subscript(range: PartialRangeThrough<Int>) -> String? {
        get {
            guard range.upperBound >= 0 && range.upperBound < count else {
                return nil
            }
            return self[0...range.upperBound]
        }
        set {
            guard range.upperBound >= 0 && range.upperBound < count else {
                return
            }
            self[0...range.upperBound] = newValue
        }
    }
    
    public subscript(range: PartialRangeUpTo<Int>) -> String? {
        get {
            guard range.upperBound >= 0 && range.upperBound < count else {
                return nil
            }
            return self[0..<range.upperBound]
        }
        set {
            guard range.upperBound >= 0 && range.upperBound < count else {
                return
            }
            self[0..<range.upperBound] = newValue
        }
    }
    
    public subscript(position: Int) -> Character? {
        get {
            guard let index = index(at: position) else {
                return nil
            }
            return self[index]
        }
        set {
            guard let index = index(at: position) else {
                return
            }
            if let value = newValue {
                replaceSubrange(index...index, with: String(value))
            } else {
                remove(at: index)
            }
        }
    }
}

// MARK: - 正则表达式
extension String {
    /// 判断当前字符串是否是合法的Email格式
    /// - Returns: 是否是合法的Email格式
    public func isEmail() -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return pred.evaluate(with: self)
    }
    
    /// 判断当前字符串是否是合法的URL格式
    /// - Returns: 是否是合法的URL格式
    public func isUrl() -> Bool {
        let regex = "http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return pred.evaluate(with: self)
    }
    
    /// 判断字符是否是数字
    public func isDigit() -> Bool {
        let str =  "^[0-9*]$"
        let regextest = NSPredicate(format: "SELF MATCHES %@",str)
        if (regextest.evaluate(with: self) == true) {
            return true
        } else {
            return false
        }
    }
    
    /// 判断是否电话号码
    /// - Returns: 是否电话号码
    public func isPhoneNumber() -> Bool {
        let MOBILE = "^((13[0-9])|(15[0-9])|(17[0,0-9])|(19[0,0-9])|(18[0,0-9]))\\d{8}$"
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@", MOBILE)
        return regextestmobile.evaluate(with: self)
    }
    
    /// 判断当前字符串是否是合法的中国国内电话格式
    /// - Returns: 是否是合法的中国国内电话格式
    public func isCNPhoneNumber() -> Bool {
        let MOBILE = "^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$"
        let CM = "^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$"
        let CU = "^1(3[0-2]|5[256]|8[56])\\d{8}$"
        let CT = "^1((33|53|8[09])[0-9]|349)\\d{7}$"
        let PHS = "^0(10|2[0-5789]|\\d{3})\\d{7,8}$"
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@", MOBILE)
        let regextestcm = NSPredicate(format: "SELF MATCHES %@", CM)
        let regextestcu = NSPredicate(format: "SELF MATCHES %@", CU)
        let regextestct = NSPredicate(format: "SELF MATCHES %@", CT)
        let regextestphs = NSPredicate(format: "SELF MATCHES %@", PHS)
        
        return regextestmobile.evaluate(with: self) || regextestphs.evaluate(with: self) || regextestct.evaluate(with: self) || regextestcu.evaluate(with: self) || regextestcm.evaluate(with: self)
    }
    
    /// 判断当前字符串是否是包含中文
    /// - Returns: 是否是包含中文
    public func containsChinese() -> Bool {
        return range(of: "\\p{Han}", options: .regularExpression) != nil
    }
    
    /// 判断当前字符串是否是包含Emoji
    /// - Returns: 是否是包含Emoji
    public func containsEmoji() -> Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                0x1F680...0x1F6FF, // Transport and Map
                0x2600...0x26FF,   // Misc symbols
                0x2700...0x27BF,   // Dingbats
                0xFE00...0xFE0F,   // Variation Selectors
                0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                0x1F1E6...0x1F1FF: // Flags
                return true
            default:
                continue
            }
        }
        return false
    }
    
    
    /// 判断是否包含某个子字符串
    /// - Parameters:
    ///   - str: 子字符串
    ///   - flag: 是否忽略大小写
    /// - Returns: 判断结果
    public func contain(str: String, flag: Bool = false) -> Bool {
        if flag {
            return self.range(of: str, options: .caseInsensitive) != nil
        }
        return self.range(of: str) != nil
    }
    
    /// 比较两个版本号
    /// - Parameters:
    ///   - version1: 版本号1
    ///   - version2: 版本号2
    /// - Returns: 两个版本号相同，则返回`0`，如果`version1`>`version2`，则返回`1`，否则返回`-1`
    public static func compareVersion(_ version1: String, _ version2: String) -> Int {
        var version1Components = version1.components(separatedBy: ".")
        var version2Components = version2.components(separatedBy: ".")
        
        let difference = abs(version1Components.count - version2Components.count)
        let array = Array(repeating: "0", count: difference)
        
        if version1Components.count > version2Components.count {
            version2Components.append(contentsOf: array)
        } else if version2Components.count > version1Components.count {
            version1Components.append(contentsOf: array)
        }
        
        for (n1, n2) in zip(version1Components, version2Components) {
            let number1 = Int(n1)!
            let number2 = Int(n2)!
            
            if number1 > number2 {
                return 1
            } else if number2 > number1 {
                return -1
            }
        }
        
        return 0
    }
    
    /// 判断字符串是否为空字符串
    /// - Parameter text: 字符串
    /// - Returns: 是否为空字符串
    public static func isEmpty(_ text: String?) -> Bool {
        guard let text = text else { return true }
        return text.isEmpty
    }
    
    /// 判断字符串是否非空字符串
    /// - Parameter text: 字符串
    /// - Returns: 是否非空字符串
    public static func isNotEmpty(_ text: String?) -> Bool {
        return !isEmpty(text)
    }
    
    /// 汉子转成拼音
    /// - Parameter separator: 分隔符
    /// - Returns: 拼音字符串
    public func toPinyin(separator: String = " ") -> String {
        let hans1 = self.applyingTransform(StringTransform.mandarinToLatin, reverse: false)
        let hans2 = hans1?.applyingTransform(StringTransform.stripDiacritics, reverse: false)
        let result = hans2?.replacingOccurrences(of: " ", with: separator)
        return result ?? self
    }
}

extension String {
    /// 字符串按 gap个数字，使用 seperator 字符分隔
    /// - Parameters:
    ///   - gap: 分隔数字
    ///   - seperator: 分隔的字符
    /// - Returns: 按指定数字、字符分隔的字符串
    public func showInComma(gap: Int = 3, seperator: Character = ",") -> String {
        var temp = self
        /// 字符串长度
        let count = temp.count
        /// 需要插入的分隔符数量
        let sepNum = count / gap
        /// 数量小于1，不插入
        guard sepNum >= 1 else {
            return temp
        }
        
        for i in 1...sepNum {
            /// 计算插入位置
            let index = count - gap * i
            guard index != 0 else {
                break
            }
            /// 插入分隔符
            temp.insert(seperator, at: temp.index(temp.startIndex, offsetBy: index))
        }
        return temp
    }
}
