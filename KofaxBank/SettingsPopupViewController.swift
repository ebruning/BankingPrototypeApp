//
//  PopOverViewController.swift
//  KofaxBank
//
//  Created by Rupali on 20/11/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class SettingsPopupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var serverUrlField: UITextField!
    
    @IBOutlet weak var processIdentityNameField: UITextField!
    
    @IBOutlet weak var sessionIDField: UITextField!
    
    @IBOutlet weak var mobileIDVersionContainer: CustomView!
    
    @IBOutlet weak var mobileIDVersionSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var stackContainerForIDSettings: UIStackView!
    
    @IBOutlet weak var authenticationContainerViewFor2X: UIStackView!
    
    @IBOutlet weak var authenticationURLField: UITextField!
    
    @IBOutlet weak var authenticationProcessIdentityNameField: UITextField!
    
    @IBOutlet weak var parentViewHeight: NSLayoutConstraint!
    
    //@IBOutlet weak var outerContainerHeight: NSLayoutConstraint!
    
    //MARK: Public variables
    
    var applicationComponentName: AppComponent = AppComponent.BILL
    
    //MARK: Private variables
    
    private var wasNavigationHidden: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            hideNavigationBar()
            initialize()
        
            loadFields(forAppComponent: applicationComponentName)
    }
    
    private var currentMobileIDVersion = String()
    
    
    @IBAction func onSegmentedControlSelection(_ sender: UISegmentedControl) {
        print("onSegmentedControlSelection:: \(sender.selectedSegmentIndex)")
    
        //segment control is valid only for ID component as it displays MobileID verion number
        
        saveIDSetings()

        currentMobileIDVersion = sender.selectedSegmentIndex == 0 ? MobileIDVersion.VERSION_1X.rawValue : MobileIDVersion.VERSION_2X.rawValue

        loadID()
    }

    //MARK: UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    // MARK: Public methods

    func close() {
        
        self.view.endEditing(true)
        
        //reset navigationbar visibility to same as it was before this screen was shown
        self.navigationController?.setNavigationBarHidden(wasNavigationHidden, animated: false)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.view.alpha = 0
            self.dismiss(animated: true, completion: nil)
        }, completion: nil)
        
    }

    // MARK: Private methods

    private func initialize() {
        stackContainerForIDSettings.isHidden = true
        parentViewHeight.constant = 195
    }

    
    // MARK: Private methods

    private func hideNavigationBar() {
        wasNavigationHidden = (self.navigationController?.isNavigationBarHidden)!
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func loadFields(forAppComponent: AppComponent) {
        
        var title: String!
        
        switch forAppComponent {
        case .BILL:
            title = "Bill Payment Settings"
            
            loadBill()
            break
            
        case .CHECK:
            title = "Check Deposit Settings"
            
            loadCheck()
            break

        case .CREDITCARD:
            title = "Credit Card Settings"
            
            loadCreditCard()
            break

        case .IDCARD:
            title = "ID card Settings"
            
            if UserDefaults.standard.value(forKey: KEY_ID_MOBILE_ID_VERSION) != nil {
                currentMobileIDVersion = (UserDefaults.standard.value(forKey: KEY_ID_MOBILE_ID_VERSION) as? String)!
            }
            loadID()
            break
        }
        
        if title != nil {
            titleLabel.text = title!
        }
    }

    private func loadBill() {
        serverUrlField.text = UserDefaults.standard.value(forKey: KEY_BILLPAY_SERVER_URL) as? String
        processIdentityNameField.text = UserDefaults.standard.value(forKey: KEY_BILLPAY_PROCESS_IDENTITY_NAME) as? String
        sessionIDField.text = UserDefaults.standard.value(forKey: KEY_BILLPAY_SESSION_ID) as? String
    }
    
    private func loadCheck() {
        serverUrlField.text = UserDefaults.standard.value(forKey: KEY_CHECK_SERVER_URL) as? String
        processIdentityNameField.text = UserDefaults.standard.value(forKey: KEY_CHECK_PROCESS_IDENTITY_NAME) as? String
        sessionIDField.text = UserDefaults.standard.value(forKey: KEY_CHECK_SESSION_ID) as? String
    }
    
    private func loadCreditCard() {
        serverUrlField.text = UserDefaults.standard.value(forKey: KEY_CREDIT_CARD_URL) as? String
        processIdentityNameField.text = UserDefaults.standard.value(forKey: KEY_CREDIT_CARD_PROCESS_IDENTITY_NAME) as? String
        sessionIDField.text = UserDefaults.standard.value(forKey: KEY_CREDIT_CARD_SESSION_ID) as? String
    }
    
    private func loadID() {
        stackContainerForIDSettings.isHidden = false
        serverUrlField.text = UserDefaults.standard.value(forKey: KEY_ID_SERVER_URL) as? String
        sessionIDField.text = UserDefaults.standard.value(forKey: KEY_ID_SESSION_ID) as? String
        
        if currentMobileIDVersion == MobileIDVersion.VERSION_1X.rawValue {  // Mobile ID -- 1.x
            
            mobileIDVersionSegmentedControl.selectedSegmentIndex = 0
            processIdentityNameField.text = UserDefaults.standard.value(forKey: KEY_ID_PROCESS_IDENTITY_NAME_1X) as? String
            
            //hide authentication fields container
            authenticationContainerViewFor2X.isHidden = true
            
            parentViewHeight.constant = 260
        } else {    // Mobile ID -- 2.x
            mobileIDVersionSegmentedControl.selectedSegmentIndex = 1
            processIdentityNameField.text = UserDefaults.standard.value(forKey: KEY_ID_PROCESS_IDENTITY_NAME_2X) as? String
            
            authenticationURLField.text =  UserDefaults.standard.value(forKey: KEY_ID_AUTHENTICATION_URL) as? String
            authenticationProcessIdentityNameField.text =  UserDefaults.standard.value(forKey: KEY_ID_AUTHENTICATION_PROCESS_IDENTITY_NAME) as? String
            
            //Show authentication fields container
            authenticationContainerViewFor2X.isHidden = false
            parentViewHeight.constant = 409
        }
    }
    
    private func saveSettings() {
        
        //save for bill
        if applicationComponentName == AppComponent.BILL {
        
            saveBillSetings()
            
        } else if applicationComponentName == AppComponent.CHECK {
            
            saveCheckSetings()
            
        } else if applicationComponentName == AppComponent.CREDITCARD {
            
            saveCreditCardSetings()
            
        } else if applicationComponentName == AppComponent.IDCARD {
            
            saveIDSetings()
        }
        
    }
    
    private func saveBillSetings() {
        UserDefaults.standard.set(serverUrlField.text, forKey: KEY_BILLPAY_SERVER_URL)
        UserDefaults.standard.set(processIdentityNameField.text, forKey: KEY_BILLPAY_PROCESS_IDENTITY_NAME)
        UserDefaults.standard.set(sessionIDField.text, forKey: KEY_BILLPAY_SESSION_ID)
    }

    private func saveCheckSetings() {
        UserDefaults.standard.set(serverUrlField.text, forKey: KEY_CHECK_SERVER_URL)
        UserDefaults.standard.set(processIdentityNameField.text, forKey: KEY_CHECK_PROCESS_IDENTITY_NAME)
        UserDefaults.standard.set(sessionIDField.text, forKey: KEY_CHECK_SESSION_ID)
    }
    
    private func saveCreditCardSetings() {
        UserDefaults.standard.set(serverUrlField.text, forKey: KEY_CREDIT_CARD_URL)
        UserDefaults.standard.set(processIdentityNameField.text, forKey: KEY_CREDIT_CARD_PROCESS_IDENTITY_NAME)
        UserDefaults.standard.set(sessionIDField.text, forKey: KEY_CREDIT_CARD_SESSION_ID)
    }

    private func saveIDSetings() {
        UserDefaults.standard.set(serverUrlField.text, forKey: KEY_ID_SERVER_URL)
        UserDefaults.standard.set(sessionIDField.text, forKey: KEY_ID_SESSION_ID)
        UserDefaults.standard.set(currentMobileIDVersion, forKey: KEY_ID_MOBILE_ID_VERSION)

        if currentMobileIDVersion == MobileIDVersion.VERSION_1X.rawValue {
            UserDefaults.standard.set(processIdentityNameField.text, forKey: KEY_ID_PROCESS_IDENTITY_NAME_1X)

        } else {
            UserDefaults.standard.set(processIdentityNameField.text, forKey: KEY_ID_PROCESS_IDENTITY_NAME_2X)
            UserDefaults.standard.set(authenticationURLField.text, forKey: KEY_ID_AUTHENTICATION_URL)
            UserDefaults.standard.set(authenticationProcessIdentityNameField.text, forKey: KEY_ID_AUTHENTICATION_PROCESS_IDENTITY_NAME)
        }
    }

    @IBAction func popupOnTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func mainViewOnTap(_ sender: UITapGestureRecognizer) {
        saveSettings()
        close()
    }
    

}
