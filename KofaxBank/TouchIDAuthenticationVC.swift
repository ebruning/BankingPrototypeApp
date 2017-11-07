//
//  TouchIDAuthenticationVC.swift
//  KofaxBank
//
//  Created by Rupali on 06/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//
// Class to handle all the operations related to touch ID authentication

import UIKit
import LocalAuthentication

class TouchIDAuthenticationVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }

    @IBAction func authenticateButtonPressed(_ sender: Any) {
        let context = LAContext()
        
        var error: NSError?
        
        //check if TouchID is available on device
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Are you the devie owner", reply: {(success, error) in
                DispatchQueue.main.async {
                    
                    if error != nil {
                        switch error!._code {
                        case LAError.Code.systemCancel.rawValue:
                            self.notifyUser(titleString: "Session cancelled", bodyString: error?.localizedDescription)
                            
                        case LAError.Code.userCancel.rawValue:
                            self.notifyUser(titleString: "Please try again", bodyString: error?.localizedDescription)
                            
                        case LAError.Code.userFallback.rawValue:
                            self.notifyUser(titleString: "Authentication", bodyString: "Password option selected")
                        default:
                            self.notifyUser(titleString: "Authentication failed", bodyString: error?.localizedDescription)
                        }
                    }
                    else {
                        //self.notifyUser(titleString: "Authentication successful", bodyString: "You now have full access")
                       self.launchHomeScreenAsFirstScreen()
                    }
                }
            })
        } else {
            //Device cannot use TouchID
            switch error!.code {
                
            case LAError.Code.touchIDNotEnrolled.rawValue:
                //The user has not enrolled any fingerprints into TouchID on the device
                notifyUser(titleString: "Touch ID is not enrolled", bodyString: error?.localizedDescription)
                
            case LAError.Code.passcodeNotSet.rawValue:
                //The user has not yet configured a passcode on the device.
                notifyUser(titleString: "A passcode has not been set", bodyString: error?.localizedDescription)
                
            default:
                //The device does not have a TouchID fingerprint scanner (LAError.touchIDNotAvailable)
                notifyUser(titleString: "TouchID not available", bodyString: error?.localizedDescription)
            }
        }
    }
    
    func notifyUser(titleString:String, bodyString:String?) {
        let alert = UIAlertController(title: titleString, message: bodyString, preferredStyle: UIAlertControllerStyle.alert)
        
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }

    
    func launchHomeScreenAsFirstScreen(){
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let vc = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        
        let vc = HomeVC(nibName: "HomeScreen", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        
        /**
         Important: set next viewcontroller as base(first) viewcontroller after login screen is closed.
         This will prevent the new first viewcontroller to go back to login screen agian.
         */
        let newViewControllersSequenceArray: NSMutableArray = NSMutableArray(object: vc)
        navigationController?.setViewControllers(newViewControllersSequenceArray as! [UIViewController], animated: false)
        
        
        //dismiss(animated: true, completion: nil)
    }

}

