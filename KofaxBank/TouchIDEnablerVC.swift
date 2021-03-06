//
//  TouchIDEnablerVC.swift
//  KofaxBank
//
//  Created by Rupali on 06/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//
// Class to enable touch ID. Viewcontroller associated with this class is displayed during very first launch of application.

import UIKit

class TouchIDEnablerVC: UIViewController {
 
/*    private var _alreadyAuthenticated: Bool = false
    
    var alreadyAuthenticated: Bool {
        get {
            return _alreadyAuthenticated
        } set {
            _alreadyAuthenticated = newValue
        }
    }
*/
    @IBOutlet weak var touchIDButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        customizeScreenControls()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func customizeScreenControls() {
        let appStyler = AppStyleManager.sharedInstance()
        
        touchIDButton = appStyler?.get_button_styler().configure_primary_button(touchIDButton)
        skipButton = appStyler?.get_button_styler().configure_secondary_button(skipButton)
    }
    
    @IBAction func enableTouchIDButtonClicked(_ sender: UIButton) {
    
        //toggle touch status
        UserDefaults.standard.set(true, forKey: KEY_TOUCH_ID_STATUS)
        
        print("Current Touch ID value: \(UserDefaults.standard.bool(forKey: KEY_TOUCH_ID_STATUS))")
        
        Utility.showAlert(onViewController: self, titleString: "Touch ID Enabled", messageString: nil)
        
        launchHomeScreenAsFirstScreen()
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        launchHomeScreenAsFirstScreen()
    }
    
    
    func launchHomeScreenAsFirstScreen(){

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        navigationController?.pushViewController(vc, animated: true)
        
        /**
         Important: set next viewcontroller as base(first) viewcontroller after touchIDEnabler screen is closed.
         This will prevent the new first viewcontroller to go back to touchIDEnabler screen agian.
         */
        let newViewControllersSequenceArray: NSMutableArray = NSMutableArray(object: vc)
        navigationController?.setViewControllers(newViewControllersSequenceArray as! [UIViewController], animated: false)
    }

    
    
}

