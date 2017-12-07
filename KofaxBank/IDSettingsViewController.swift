//
//  IDSettingsViewController.swift
//  KofaxBank
//
//  Created by Rupali on 05/10/17.
//  Copyright © 2017 kofax. All rights reserved.
//

//import CoreFoundation

import UIKit
import AVFoundation

class IDSettingsViewController: UIViewController {
    
    @IBOutlet weak var stackViewCameraSettings: UIStackView!
    @IBOutlet weak var stackViewImageProcessSettings: UIStackView!
    @IBOutlet weak var stackViewServerSettings: UIStackView!
    
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var imageProcessImage: UIImageView!
    @IBOutlet weak var serverImage: UIImageView!
    
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var imageProcessLabel: UILabel!
    @IBOutlet weak var serverLabel: UILabel!
    
    private var accentColor = UIColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accentColor = AppStyleManager.sharedInstance().get_app_screen_styler().get_accent_color()
        
        customizeNavigationBar()
    }
    
    private func customizeNavigationBar() {
        
//        oldStatusBarStyle = UIApplication.shared.statusBarStyle
//        oldBarTintColor = navigationController?.navigationBar.tintColor
        
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.tintColor = UIColor.white
        
        //wasNavigationHidden = (self.navigationController?.navigationBar.isHidden)!
        
        //new back button
        let doneButton = UIBarButtonItem.init(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onDonePressed))
        
        self.navigationItem.rightBarButtonItem = doneButton
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    //MARK: Navigationbar done button callback
    
    func onDonePressed() {
        dismiss(animated: true, completion: {
            self.unload()
        })
        
    }
    
    //MARK: UITapGestureRecognizer callbacks
    
    @IBAction func onCameraSettingsSelected(_ sender: UITapGestureRecognizer) {

        if stackViewCameraSettings.isHidden {
            cameraImage.image = UIImage.init(named: "camera_yellow_round")
            imageProcessImage.image = UIImage.init(named: "gallery_white_round")
            serverImage.image = UIImage.init(named: "cloud_white")
            
            cameraLabel.textColor = accentColor
            imageProcessLabel.textColor = applicationTextColor
            serverLabel.textColor = applicationTextColor

            stackViewCameraSettings.isHidden = false
            stackViewImageProcessSettings.isHidden = true
            stackViewServerSettings.isHidden = true
        }
    }
    
    @IBAction func onImageProcessorSettingsSelected(_ sender: UITapGestureRecognizer) {

        if stackViewImageProcessSettings.isHidden {
            imageProcessImage.image = UIImage.init(named: "gallery_yellow_round")
            cameraImage.image = UIImage.init(named: "camera_white_round")
            serverImage.image = UIImage.init(named: "cloud_white")

            imageProcessLabel.textColor = accentColor
            cameraLabel.textColor = applicationTextColor
            serverLabel.textColor = applicationTextColor

            stackViewImageProcessSettings.isHidden = false
            stackViewCameraSettings.isHidden = true
            stackViewServerSettings.isHidden = true
        }
    }
    
    @IBAction func onServerSettingsSelected(_ sender: UITapGestureRecognizer) {
    
        if stackViewServerSettings.isHidden {
            serverImage.image = UIImage.init(named: "cloud_yellow")
            cameraImage.image = UIImage.init(named: "camera_white_round")
            imageProcessImage.image = UIImage.init(named: "gallery_white_round")

            serverLabel.textColor = accentColor
            imageProcessLabel.textColor = applicationTextColor
            cameraLabel.textColor = applicationTextColor

            stackViewServerSettings.isHidden = false
            stackViewImageProcessSettings.isHidden = true
            stackViewCameraSettings.isHidden = true
        }

    }
    
    //MAR: Unload
    
    func unload() {
        // clear any parameters
    }
    
}
