//
//  MoreViewController.swift
//  KofaxBank
//
//  Created by Rupali on 28/07/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import MessageUI
import CoreData

class MoreViewController: UIViewController, UITabBarControllerDelegate, MFMailComposeViewControllerDelegate {

    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var userProfileButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    //MARK: Private variables

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        customizeScreenControls()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        customizeScreenControls()
    }

    //MARK: UITabBar delegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController != self {
            
        }
    }
    
    
    private func customizeScreenControls() {
        let appStyler = AppStyleManager.sharedInstance()
        
        let screenStyler = appStyler?.get_app_screen_styler()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        infoButton.backgroundColor = screenStyler?.get_accent_color()
        userProfileButton.backgroundColor = screenStyler?.get_accent_color()
        locationButton.backgroundColor = screenStyler?.get_accent_color()
        contactUsButton.backgroundColor = screenStyler?.get_accent_color()
        resetButton.backgroundColor = screenStyler?.get_accent_color()
        settingsButton.backgroundColor = screenStyler?.get_accent_color()
        
        //appStyler?.get_button_styler().configure_primary_button(addAccountFloatingButton)
    }

    
    // Screen UIButton actions
    
    @IBAction func onInfoClicked(_ sender: UIButton) {
        print("onInfoClicked")
        
        showApplicationInformation()
    }

    @IBAction func onUserProfileClicked(_ sender: UIButton) {
        print("onUserProfileClicked")
        
        showUserProfile()
    }

    @IBAction func onSettingsClicked(_ sender: UIButton) {
             print("onNotificationClicked")
        
        let stylerManager = AppStyleManager.sharedInstance()
        stylerManager?.showStyler(self.navigationController)
    }

    @IBAction func onContactUsClicked(_ sender: UIButton) {
        
        print("onContactUsClicked")
        showEmailComposer()
    }
    
    @IBAction func onLocationClicked(_ sender: UIButton) {
             print("onLocationClicked")
        
        showLocation()
    }

    @IBAction func onResetClicked(_ sender: UIButton) {
             print("onResetClicked")
        
            //resetAllData()
        
            Utility.showAlert(onViewController: self, titleString: "", messageString: "Data reset complete")
    }


    //About (Info)
    
    private func showApplicationInformation() {
        Utility.showAlert(onViewController: self, titleString: "Kofax Bank", messageString: "Version 1.0")
    }

    
    //User profile
    
    private func showUserProfile() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserProfile")
        
        present(vc, animated: true, completion: nil)
    }
    

    //Contact Us
    
    private func showEmailComposer() {
        if MFMailComposeViewController.canSendMail() {
            let mailer = MFMailComposeViewController()
            mailer.mailComposeDelegate = self
            
            mailer.setSubject("Customer: Lucy Tate")
            mailer.setToRecipients(NSArray.init(object: "rupali.ghate@kofax.com") as? [String])
            
            mailer.setMessageBody("", isHTML: false)
            
            mailer.modalPresentationStyle = .formSheet
            
            present(mailer, animated: true, completion: nil)
        }
    }
    
    //Email composer

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //Location
    
    private func showLocation() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Map")
        
        present(vc, animated: true, completion: nil)
    }
    
    
    //Reset data
    
    func resetAllData(){
        
        let entities = ["CreditCardTransactions", "CreditCardMaster", "CheckTransactions", "BillTransactions", "BillerMaster", "AccountTransactionMaster", "AccountMaster", "UserMaster"]
        
        
        for entity in entities {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteAllReq = NSBatchDeleteRequest(fetchRequest: request)
            
            do { try context.execute(deleteAllReq) }
            catch { print(error) }    }
        
        
        Utility.checkDataStore()
    }
    
    
    
}
