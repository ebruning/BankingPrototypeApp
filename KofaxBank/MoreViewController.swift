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

    private var accentColor: UIColor? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customizeScreenControls()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.delegate = self
        customizeScreenControls()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.delegate = nil
    }

    //MARK: UITabBar delegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController != self {
            
        }
    }
    
    
    private func customizeScreenControls() {
        let appStyler = AppStyleManager.sharedInstance()
        
        self.accentColor = appStyler?.get_app_screen_styler().get_accent_color()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        infoButton.backgroundColor = accentColor
        infoButton.customizeBorderColor(color: accentColor!)
        
        userProfileButton.backgroundColor = accentColor
        userProfileButton.customizeBorderColor(color: accentColor!)
        
        locationButton.backgroundColor = accentColor
        locationButton.customizeBorderColor(color: accentColor!)
        
        contactUsButton.backgroundColor = accentColor
        contactUsButton.customizeBorderColor(color: accentColor!)
        
        resetButton.backgroundColor = accentColor
        resetButton.customizeBorderColor(color: accentColor!)
        
        settingsButton.backgroundColor = accentColor
        settingsButton.customizeBorderColor(color: accentColor!)
    }

    
    // Screen UIButton actions
    @IBAction func buttonTouchDownEvent(_ sender: UIButton) {
        sender.backgroundColor = UIColor.init(rgb: 0xD8D8D8)  //light gray
    }

    @IBAction func buttonDragExitEvent(_ sender: UIButton) {
        sender.backgroundColor = self.accentColor
    }
    
    @IBAction func onInfoClicked(_ sender: UIButton) {
        print("onInfoClicked")
        sender.backgroundColor = self.accentColor
        
        showApplicationInformation()
    }

    @IBAction func onUserProfileClicked(_ sender: UIButton) {
        print("onUserProfileClicked")
        sender.backgroundColor = self.accentColor
        
        showUserProfile()
    }

    @IBAction func onSettingsClicked(_ sender: UIButton) {
             print("onNotificationClicked")
        sender.backgroundColor = self.accentColor
        
        let stylerManager = AppStyleManager.sharedInstance()
        stylerManager?.showStyler(self.navigationController)
    }

    @IBAction func onContactUsClicked(_ sender: UIButton) {
        
        print("onContactUsClicked")
        sender.backgroundColor = self.accentColor
        showEmailComposer()
    }
    
    @IBAction func onLocationClicked(_ sender: UIButton) {
             print("onLocationClicked")
        sender.backgroundColor = self.accentColor
        
        showLocation()
    }

    @IBAction func onResetClicked(_ sender: UIButton) {
             print("onResetClicked")
        sender.backgroundColor = self.accentColor
        
        Utility.showAlertWithCallback(onViewController: self, titleString: "Reset All Data", messageString: "All the application data will be reset to the original values.\n\nDo you want to continue?", positiveActionTitle: "Continue", negativeActionTitle: "Cancel", positiveActionResponse: {
            
            self.resetAllData()
            
            Utility.showAlert(onViewController: self, titleString: "", messageString: "Data reset complete")
            
        }, negativeActionResponse: {
            
        })
    }


    //About (Info)
    
    private func showApplicationInformation() {
        Utility.showAlert(onViewController: self, titleString: "Kofax Bank", messageString: "Version 1.0")
    }

    
    //User profile
    
    private func showUserProfile() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserProfile")
        
        let navController = UINavigationController.init(rootViewController: vc)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.backgroundColor = UIColor.clear
        
        self.present(navController, animated: true, completion: nil)
    }
    

    //Contact Us
    
    private func showEmailComposer() {
        if MFMailComposeViewController.canSendMail() {
            let mailer = MFMailComposeViewController()
            mailer.mailComposeDelegate = self
            
            mailer.setSubject("Customer: Lucy Tate")
            mailer.setToRecipients(NSArray.init(object: "") as? [String])
            
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
        
        let entity = "UserMaster"
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        do {
            let users = try context.fetch(request)

            for user in users {
                context.delete(user as! NSManagedObject)    //deleting 'usermaster' record will delete all other table data, this is because of the 'delete rule' applied in entities. All the entities are directly/indirectly related with userMaster.
            }
        } catch {
            
        }
        
        Utility.loadDatabaseWithDefaultsIfEmpty()
        Utility.resetUserDefaults()
    }
    
    
//    func resetAllData(){
//        
//        let entities = ["UserMaster"]
//
//        for entity in entities {
//            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//            let deleteAllReq = NSBatchDeleteRequest(fetchRequest: request)
//            
//            do {
//                try context.execute(deleteAllReq)
//            }
//            catch {
//                print(error)
//            }
//        }
//        
//        Utility.loadDatabaseWithDefaultsIfEmpty()
//    }
//    
    
}
