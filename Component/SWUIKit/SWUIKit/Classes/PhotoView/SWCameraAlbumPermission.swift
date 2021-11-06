//
//  SWCameraAlbumPermission.swift
//  VVLife
//
//  Created by vv on 2019/8/26.
//  Copyright © 2019 vv. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

public class SWCameraAlbumPermission {
    public typealias PermissionClosure = () -> Void
    
    public class func cameraPermission(authorizedClosure: PermissionClosure?, deniedClosure: PermissionClosure?) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        // .notDetermined  .authorized  .restricted  .denied
        if authStatus == .notDetermined {
            // 第一次触发授权 alert
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                self.cameraPermission(authorizedClosure: authorizedClosure, deniedClosure: deniedClosure)
            })
        } else if authStatus == .authorized {
            DispatchQueue.main.async {
                authorizedClosure?()
            }
        } else {
            DispatchQueue.main.async {
                deniedClosure?()
            }
        }
    }
    
    public class func albumPermission(authorizedClosure: PermissionClosure?, deniedClosure: PermissionClosure?) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        
        // .notDetermined  .authorized  .restricted  .denied
        if authStatus == .notDetermined {
            // 第一次触发授权 alert
            PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) -> Void in
                self.albumPermission(authorizedClosure: authorizedClosure, deniedClosure: deniedClosure)
            }
        } else if authStatus == .authorized {
            DispatchQueue.main.async {
                authorizedClosure?()
            }
        } else {
            DispatchQueue.main.async {
                deniedClosure?()
            }
        }
    }
    
    public class func authorizeToMicrophone(authorizedClosure: PermissionClosure?, deniedClosure: PermissionClosure?) {
        let recordingSession = AVAudioSession.sharedInstance()
        switch recordingSession.recordPermission {
        case .granted:
            //已授权
            DispatchQueue.main.async {
                authorizedClosure?()
            }
            
        case .denied:
            //拒绝授权
            DispatchQueue.main.async {
                deniedClosure?()
            }
            
        case .undetermined:
            //请求授权
            recordingSession.requestRecordPermission(){ allowed in
                self.authorizeToMicrophone(authorizedClosure: authorizedClosure, deniedClosure: deniedClosure)
            }
        default: break
        }
    }
}
