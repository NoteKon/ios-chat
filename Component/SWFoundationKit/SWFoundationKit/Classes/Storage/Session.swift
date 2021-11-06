//
//  Session.swift
//  Swiften
//

import Foundation
import CoreLocation

open class Session: LocalStorage {
    public static let shared = Session()
    
    /// 计数器
    open var tick: Int {
        let result = int(forKey: "TICK")
        set((result + 1) % Int.max, forKey: "TICK")
        return result
    }
    
    /// 设备ID（UDID）
    open var deviceId: String {
        get {
            if let udid = string(forKey: "UDID") {
                return udid
            }
            let udid = UDID().udidString
            set(udid, forKey: "UDID")
            return udid
        }
        set {
            set(newValue, forKey: "UDID")
        }
    }
    
    /// Token
    open var token: String {
        get {
            return string(forKey: "TOKEN") ?? ""
        }
        set {
            set(newValue, forKey: "TOKEN")
        }
    }
    
    /// 定位信息
    open var location: CLLocation {
        get {
            let latitude = double(forKey: "LATITUDE")
            let longitude = double(forKey: "LONGITUDE")
            return CLLocation(latitude: latitude, longitude: longitude)
        }
        set {
            write {
                self.set(newValue.coordinate.latitude, forKey: "LATITUDE")
                self.set(newValue.coordinate.longitude, forKey: "LONGITUDE")
            }
        }
    }
    
    /// 城市信息
    open var city: String! {
        get {
            return string(forKey: "CITY")
        }
        set {
            set(newValue, forKey: "CITY")
        }
    }
    
}
