//
//  BaseCaptureViewController.swift
//  KofaxBank
//
//  Created by Rupali on 03/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

typealias CameraStatus = ((Bool) -> Void)

class BaseCaptureViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createBlurViewInBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        BaseCaptureViewController.checkCameraAccess(statusHandler: { status in
            
            if status == true {
                self.performSelector(onMainThread: #selector(self.initializeControl), with: nil, waitUntilDone: true)
            } else {
                Utility.showAlert(onViewController: self, titleString: "Allow Camera Access", messageString: "To capture documents with your device,allow application to use your camera \n \n Settings->Privacy->Camera")
            }
        })
    }

    func initializeControl() {
        
    }
    
    //TODO: Check if KMD where to call this function
    
    class func checkCameraAccess(statusHandler: @escaping CameraStatus) {
        
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if authStatus == AVAuthorizationStatus.authorized {
            statusHandler(true)
        }
        else if authStatus == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler:{ (granted: Bool) in
                
                if granted {
                    print("camera access granted")
                } else {
                    print("camera access NOT granted")
                }
                
                granted ? statusHandler(true) : statusHandler(false)
            })
        } else { //if authStatus == AVAuthorizationStatus.restricted {
            statusHandler(false)
        }
    }
    
    func isFlashAvailable() -> Bool {
        
        let captureDeviceClass: AnyClass! = NSClassFromString("AVCaptureDevice")
        
        if captureDeviceClass != nil {
            let device: AVCaptureDevice! = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            if (device?.hasFlash)! || (device?.hasTorch)! {
                print("Device has flash!!")
                return true
            }
        }
        print("Device has NO flash!!")
        return false
    }
    
}
