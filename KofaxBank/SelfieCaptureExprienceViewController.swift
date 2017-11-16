//
//  SelfieCaptureExprienceViewController.swift
//  KofaxBank
//
//  Created by Rupali on 07/11/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

protocol  SelfieCaptureExprienceViewControllerDelegate {
    func selfieCapturedWithImage(image: UIImage!)
    func cancelledSelfieCapture()
}

class SelfieCaptureExprienceViewController: UIViewController, kfxKUIImageCaptureControlDelegate {

    @IBOutlet weak var instructionsContainer: UIVisualEffectView!

    @IBOutlet weak var captureViewContainer: UIView!
    
    @IBOutlet weak var instructionsTitle: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!

    //MARK: - Public variables
    
    var delegate: SelfieCaptureExprienceViewControllerDelegate? = nil
    
    //MARK: - Private variables
    
    private var imageCaptureControl: kfxKUIImageCaptureControl! = nil
    private var captureExperience: KFXSelfieCaptureExperience! = nil
    
    
    private var wasNavigationHidden: Bool = false
    private var oldBarTintColor: UIColor!
    private var oldStatusBarStyle: UIStatusBarStyle!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeScreenControls()
        
        customizeNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        initializeCaptureControl()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        freeCaptureControl()
    }

    //MARK: Private methods
    
    private func customizeScreenControls() {
        let screenStyler = AppStyleManager.sharedInstance()?.get_app_screen_styler()
        let buttonStyler = AppStyleManager.sharedInstance()?.get_button_styler()
        
        instructionsTitle.textColor = screenStyler?.get_accent_color()
        continueButton = buttonStyler?.configure_primary_button(continueButton)
    }
    
    private func customizeNavigationBar() {
        
        oldStatusBarStyle = UIApplication.shared.statusBarStyle
        oldBarTintColor = navigationController?.navigationBar.tintColor
        
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        wasNavigationHidden = (self.navigationController?.navigationBar.isHidden)!
        
        //new back button
        let newBackButton = UIBarButtonItem.init(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onCancelPressed))
        
        self.navigationItem.leftBarButtonItem=newBackButton
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func restoreNavigationBar() {
        UIApplication.shared.statusBarStyle = oldStatusBarStyle
        navigationController?.navigationBar.tintColor = oldBarTintColor
        navigationController?.setNavigationBarHidden(wasNavigationHidden, animated: false)
    }
    
    let SCREEN_PADDING: CGFloat = 60.0
    
    private func initializeCaptureControl() {
        if (self.imageCaptureControl != nil) {
            return;
        }
        self.imageCaptureControl = kfxKUIImageCaptureControl(frame: CGRect.init(x: 0, y: 0, width: self.captureViewContainer.bounds.width, height: self.captureViewContainer.bounds.height - SCREEN_PADDING))

        kfxKUIImageCaptureControl.initializeControl()

        self.imageCaptureControl.delegate = self
        self.imageCaptureControl.setCameraType(kfxKUIFrontCamera)
        
        createSelfieCaptureExperienceWithCaptureControl(captureControl: self.imageCaptureControl)
        
        self.captureViewContainer.addSubview(self.imageCaptureControl)
    }
    
    private func createSelfieCaptureExperienceWithCaptureControl(captureControl: kfxKUIImageCaptureControl) {

        let criteria = KFXSelfieCaptureExperienceCriteriaHolder.init()
        
        let selfieDetectionSettings = KFXSelfieDetectionSettings.init()
        
        criteria.selfieDetectionSettings = selfieDetectionSettings
        
        self.captureExperience = KFXSelfieCaptureExperience.init(captureControl: captureControl, criteria: criteria)
        
        self.captureExperience.outerViewfinderColor = UIColor.white
        self.captureExperience.frameColor = UIColor.red
        
        self.captureExperience.userInstruction.font = UIFont.systemFont(ofSize: 18)
        self.captureExperience.eyesBlinkInstruction.font = UIFont.systemFont(ofSize: 18)
    }
    
    private func freeCaptureControl() {
        if self.captureExperience != nil {
            self.captureExperience.stopCapture()
            self.captureExperience = nil
        }
        if self.imageCaptureControl != nil {
            self.imageCaptureControl.delegate = nil
            self.imageCaptureControl.removeFromSuperview()
            self.imageCaptureControl = nil
        }
    }
    

    private func closeScreen() {
        self.restoreNavigationBar()
        self.freeCaptureControl()
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //Mark: Navigation button actions
    
    func onCancelPressed() {
        delegate?.cancelledSelfieCapture()
        closeScreen()
    }

    
    @IBAction func onContinueButtonClick(_ sender: UIButton) {
        captureViewContainer.isHidden = false
        instructionsContainer.isHidden = true
        
        self.captureExperience.perform(#selector(self.captureExperience.takePicture), with: nil, afterDelay: 2.0)
    }
    
    
    //MARK: ImageCaptureControl Delegate
    
    func imageCaptureControl(_ imageCaptureControl: kfxKUIImageCaptureControl!, imageCaptured image: kfxKEDImage!) {
        print("Selfie Captured with image == \(image)")
        
        if image != nil {
            delegate?.selfieCapturedWithImage(image: image.getBitmap())
        }
        
        closeScreen()
    }
}
