//
//  SWKeyChain+Ex.swift
//  SWBusinessKit
//
//  Created by ice on 2019/9/26.
//

import Foundation
import SWFoundationKit

private let UUIDKey = "uuid"
private let SigninWithAppleEmailKey = "sign_in_with_apple_email"
private let SigninWithAppleFirstNameKey = "sign_in_with_apple_firstName"
private let SigninWithAppleLastNameKey = "sign_in_with_apple_lastName"

extension SWKeyChain {
    public static func getUUID() -> String {
        return getUUID(key: UUIDKey)
    }
    
    public static func getSigninWithAppleEmail() -> String {
        /// 从Keychain寻找
        if let email = SWKeyChain.getValue(key: SigninWithAppleEmailKey), !email.isEmpty {
            return email
        }
        /// 从UserDefaults寻找
        if let email = UserDefaults.standard.string(forKey: SigninWithAppleEmailKey), !email.isEmpty {
            return email
        }
        
        return ""
    }
    
    public static func saveSigninWithAppleEmail(_ email: String) {
        SWKeyChain.saveValue(value: email, key: SigninWithAppleEmailKey)
        UserDefaults.standard.set(email, forKey: SigninWithAppleEmailKey)
    }
    
    public static func getSigninWithAppleFirstName() -> String {
        /// 从Keychain寻找
        if let firstName = SWKeyChain.getValue(key: SigninWithAppleFirstNameKey), !firstName.isEmpty {
            return firstName
        }
        /// 从UserDefaults寻找
        if let firstName = UserDefaults.standard.string(forKey: SigninWithAppleFirstNameKey), !firstName.isEmpty {
            return firstName
        }
        
        return ""
    }
    
    public static func saveSigninWithAppleFirstName(_ firstName: String) {
        SWKeyChain.saveValue(value: firstName, key: SigninWithAppleFirstNameKey)
        UserDefaults.standard.set(firstName, forKey: SigninWithAppleFirstNameKey)
    }
    
    public static func getSigninWithAppleLastName() -> String {
        /// 从Keychain寻找
        if let lastName = SWKeyChain.getValue(key: SigninWithAppleLastNameKey), !lastName.isEmpty {
            return lastName
        }
        /// 从UserDefaults寻找
        if let lastName = UserDefaults.standard.string(forKey: SigninWithAppleLastNameKey), !lastName.isEmpty {
            return lastName
        }
        
        return ""
    }
    
    public static func saveSigninWithAppleLastName(_ lastName: String) {
        SWKeyChain.saveValue(value: lastName, key: SigninWithAppleLastNameKey)
        UserDefaults.standard.set(lastName, forKey: SigninWithAppleLastNameKey)
    }
}
