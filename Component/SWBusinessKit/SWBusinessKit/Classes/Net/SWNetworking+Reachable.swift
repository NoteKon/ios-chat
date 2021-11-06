//
//  SWNetworking+Reachable.swift
//  Pods
//
//  Created by ice on 2020/5/7.
//

import Foundation
import Alamofire
import CoreTelephony

public let SWReachabilityChangedNotification = Notification.Name("SWReachabilityChangedNotification")

public enum SWConnectionType {
    case wifi
    case g2
    case g3
    case g4
}

public enum SWReachabilityStatus: CustomStringConvertible, Equatable {
    case unknown
    case notReachable
    case reachable(SWConnectionType)
    
    public var description: String {
        switch self {
        case .unknown, .notReachable:
            return "NONE"
        case .reachable(.wifi):
            return "WIFI"
        case .reachable(.g2):
            return "2G"
        case .reachable(.g3):
            return "3G"
        case .reachable(.g4):
            return "4G"
        }
    }
    
    public var intValue: Int {
        switch self {
        case .unknown:
            return -1
        case .notReachable:
            return 0
        case .reachable(.wifi):
            return 2
        default:
            return 1
        }
    }
    
    public var reachableViaWWAN: Bool {
        switch self {
        case .reachable(.g2),
             .reachable(.g3),
             .reachable(.g4):
            return true
        default:
            return false
        }
    }
    
    public var reachableViaWIFI: Bool {
        switch self {
        case .reachable(.wifi):
            return true
        default:
            return false
        }
    }
    
    public var reachable: Bool {
        return reachableViaWIFI || reachableViaWWAN
    }
}

extension SWNetworking {
    private static var _reachabilityStatus: SWReachabilityStatus = .unknown
    private static let _reachabilityManager = NetworkReachabilityManager()
    
    public static func reachabilityStatus() -> SWReachabilityStatus {
        return _reachabilityStatus
    }
    
    public static func initReachability() {
        _reachabilityManager?.startListening(onUpdatePerforming: { (status) in
            let networkInfo = CTTelephonyNetworkInfo()
            updateReachabilityStatus(afStatus: status, radioType: networkInfo.currentRadioAccessTechnology)
        })

        NotificationCenter.default.addObserver(forName: .CTRadioAccessTechnologyDidChange, object: nil, queue: nil) { (note) in
            let currentRadioAccessTechnology = note.object as? String
            updateReachabilityStatus(afStatus: _reachabilityManager!.status, radioType: currentRadioAccessTechnology)
        }
    }
    
    private static func updateReachabilityStatus(afStatus: NetworkReachabilityManager.NetworkReachabilityStatus,
                                                 radioType: String?) {
        var status: SWReachabilityStatus
        switch (afStatus, radioType) {
        case (.unknown, _):
            status = .unknown
        case (.notReachable, _):
            status = .notReachable
        case (.reachable(.ethernetOrWiFi), _):
            status = .reachable(.wifi)
        case (.reachable(.cellular), CTRadioAccessTechnologyLTE):
            status = .reachable(.g4)
        case (.reachable(.cellular), CTRadioAccessTechnologyEdge),
             (.reachable(.cellular), CTRadioAccessTechnologyGPRS):
            status = .reachable(.g2)
        default:
            status = .reachable(.g3)
        }
        
        if _reachabilityStatus != status {
            _reachabilityStatus = status
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: SWReachabilityChangedNotification, object: _reachabilityStatus)
            }
        }
    }
}
