//
//  SWAES128.swift
//  SWFoundationKit
//
//  Created by ice on 2019/9/9.
//

import Foundation
import CommonCrypto

public class SWAES128 {
    public static func encrypt(str: String?, key: String, iv: String) -> String {
        if let origStr = str,
            let originData = origStr.data(using: .utf8),
            let resultData = aes128(operation: kCCEncrypt, data: originData, key: key, iv: iv) {
            return resultData.base64EncodedString()
        }
        return ""
    }
    
    public static func decrypt(str: String?, key: String, iv: String) -> String {
        if let origStr = str,
            let originData = origStr.data(using: .utf8),
            let decodeData = Data(base64Encoded: originData),
            let resultData = aes128(operation: kCCDecrypt, data: decodeData, key: key, iv: iv),
            let resultString = String(data: resultData, encoding: .utf8) {
            return resultString
        }
        return ""
    }
    
    public static func encrypt(data: Data?, key: String, iv: String) -> Data? {
        return aes128(operation: kCCEncrypt, data: data, key: key, iv: iv)
    }
    
    public static func decrypt(data: Data?, key: String, iv: String) -> Data? {
        return aes128(operation: kCCDecrypt, data: data, key: key, iv: iv)
    }
    
    static func aes128(operation: Int, data: Data?, key: String, iv: String) -> Data? {
        if let originData = data,
            let keyData = key.data(using: .utf8),
            let cryptData = NSMutableData(length: Int(originData.count) + kCCBlockSizeAES128) {
        
            let keyLength = size_t(kCCKeySizeAES128)
            let op: CCOperation = UInt32(operation)
            let algorithm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options: CCOptions = UInt32(kCCOptionPKCS7Padding)
            var numBytesEncrypted: size_t = 0
            
            let cryptStatus = CCCrypt(op, algorithm, options, (keyData as NSData).bytes, keyLength, iv, (originData as NSData).bytes, originData.count, cryptData.mutableBytes, cryptData.length, &numBytesEncrypted)
            
            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = numBytesEncrypted
                if operation == kCCDecrypt {
                    return PKCS7PaddingDecode(cryptData) as Data
                }
                return cryptData as Data
            }
        }
        return nil
    }
    
    static func PKCS7PaddingDecode(_ data: NSData) -> NSData {
        if data.length <= 0 {
            return data
        }
        let lastByte = data.bytes.load(fromByteOffset: data.length - 1, as: UInt8.self)
        var len = Int(lastByte)
        if len < 1 || len > 32 {
            len = 0
        }
        if len > 0 && (data.length - len) > 0 {
            let resultData = NSData(bytes: data.bytes, length: data.length - len)
            return resultData
        }
        return data
    }
}
