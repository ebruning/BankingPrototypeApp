//
//  MoreViewController.swift
//  KofaxBank
//
//  Created by Rupali on 28/07/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

import MessageUI

class MoreViewController: UIViewController, UITabBarControllerDelegate, MFMailComposeViewControllerDelegate {

    
    //MARK: Private variables

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {

    }

    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController != self {
            
        }
    }
    
    @IBAction func onInfoClicked(_ sender: UIButton) {
        print("onInfoClicked")
        
        showApplicationInformation()
    }

    private func showApplicationInformation() {
        Utility.showAlert(onViewController: self, titleString: "Kofax Bank", messageString: "Version 1.0")
    }
    
    
    @IBAction func onUserProfileClicked(_ sender: UIButton) {
        print("onUserProfileClicked")
        
        showUserProfile()
    }

    @IBAction func onNotificationClicked(_ sender: UIButton) {
             print("onNotificationClicked")
        
        Utility.showAlertWithCallback(onViewController: self, titleString: "You have received 1 message", messageString: "You are required to update your profile.\n\nYou can take picure of your valid ID to update your profile details.", positiveActionTitle: "Update Now", negativeActionTitle: "Later", positiveActionResponse: {
            
            
        }, negativeActionResponse: {
            
            
        })
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

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //Location
    
    private func showLocation() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Map")
        
        present(vc, animated: true, completion: nil)
    }
    
    
    //User profile
    private func showUserProfile() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserProfile")
        
        present(vc, animated: true, completion: nil)
    }
    
    
}
