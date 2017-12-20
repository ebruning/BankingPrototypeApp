//
//  SettingsHomeViewController.swift
//  KofaxBank
//
//  Created by Rupali on 20/12/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class SettingsHomeViewController: UIViewController {
    
    @IBOutlet weak var touchIDSwitch: UISwitch!
    
    @IBOutlet weak var customViewBill: CustomView!
    
    @IBOutlet weak var customViewCheck: CustomView!
    
    @IBOutlet weak var customViewCreditCard: CustomView!
    
    @IBOutlet weak var customViewID: CustomView!
    
    
    //Settings popup
    private var settingsPopup: SettingsPopupViewController!

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        customizeNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTouchIDSwitch()
    }

    private func customizeNavigationBar() {
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.tintColor = UIColor.lightGray
        //self.navigationController?.navigationBar.backgroundColor = UIColor.black
        
        //new back button
        let closeButton = UIBarButtonItem.init(image: UIImage.init(named: "cross_gray"), style: .plain, target: self, action: #selector(closeScreen))
        
        self.navigationItem.rightBarButtonItem = closeButton
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func closeScreen() {
        dismiss(animated: true, completion: nil)
    }

    private func updateTouchIDSwitch() {
        touchIDSwitch.setOn(false, animated: false)
        
        guard let touchIDStatus = UserDefaults.standard.value(forKey: KEY_TOUCH_ID_STATUS) else {
            return
        }
        
        if touchIDStatus as? Bool == true {
            touchIDSwitch.setOn(true, animated: false)
        }
    }

    @IBAction func themeOptionOnTap(_ sender: UITapGestureRecognizer) {
        showAppStyler()
    }

    @IBAction func touchIDSwitchValueChanged(_ sender: UISwitch) {
        
        UserDefaults.standard.set(sender.isOn, forKey: KEY_TOUCH_ID_STATUS)
    }

    @IBAction func moduleOptionOnTap(_ sender: UITapGestureRecognizer) {
        
        var appComponent: AppComponent!
        
        if sender == customViewBill.gestureRecognizers?[0] {
            
            print("Bill selected")
            appComponent = AppComponent.BILL
            
        } else if sender == customViewCheck.gestureRecognizers?[0] {
            
            print("Check selected")
            appComponent = AppComponent.CHECK
            
        } else if sender == customViewCreditCard.gestureRecognizers?[0] {
            
            print("Creditcard selected")
            appComponent = AppComponent.CREDITCARD
            
        } else if sender == customViewID.gestureRecognizers?[0] {
            
            print("ID selected")
            appComponent = AppComponent.IDCARD
        }
        if appComponent != nil {
            showSettingsPopup(appComponent: appComponent!)
        }
    }

    private func showAppStyler() {
        let stylerManager = AppStyleManager.sharedInstance()
        stylerManager?.showStyler(self.navigationController)
    }
    
    func showSettingsPopup(appComponent: AppComponent) {
        self.settingsPopup = SettingsPopupViewController(nibName: "SettingsPopupViewController", bundle: nil)
        
        self.settingsPopup.applicationComponentName = appComponent
        
        self.addChildViewController(self.settingsPopup)
        self.settingsPopup.view.frame = self.view.frame
        
        self.view.addSubview(self.settingsPopup.view)
        self.settingsPopup.view.alpha = 0
        self.settingsPopup.didMove(toParentViewController: self)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.settingsPopup.view.alpha = 1
        }, completion: nil)
        
    }
    

    private func closeSettingsPopup() {
        if settingsPopup != nil {
            settingsPopup.close()
            settingsPopup.removeFromParentViewController()
        }
    }
    
}
