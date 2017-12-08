//
//  ImageCaptureViewController.swift
//  KofaxBank
//
//  Created by Rupali on 03/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

protocol ImageCaptureControllerDelegate {

    func imageCaptured(image: kfxKEDImage)
    func cancelCamera()
    func onRegionUpdated(regionProperties: RegionProperties)
}

class ImageCaptureViewController: BaseCaptureViewController, kfxKUIImageCaptureControlDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RegionControlDelegate {
    

    @IBOutlet weak var settingsView: UIVisualEffectView!
    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var forceCaptureButton: UIButton!
    @IBOutlet weak var torchButton: UIButton!
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerCommandView: UIView!
    
    @IBOutlet weak var regionButton: UIButton!
    
    //Mark: - Constants
    let LOWEREND_DEVICE_HEIGHT: CGFloat = 480.0
    let IMAGEMODE_LOWEREND_DEVICE_HEIGHT: CGFloat = 390.0
    let DEFAULTSTABILITYDELAY: Int32 = 95

    //Mark: - Delegate
    var delegate: ImageCaptureControllerDelegate?

    //Mark: - ImageCaptureControl
//    @IBOutlet weak var captureControl: kfxKUIImageCaptureControl!
    private var captureControl: kfxKUIImageCaptureControl!

   // var  overlay: KFXPageOverlayLayer!    //TODO: add these files to draw page detection rectangle on viewfinder

    //Mark: - Variables
    private var myImage: kfxKEDImage?
    
    //var baseCriteriaHolder: kfxKUIDocumentBaseCaptureExperienceCriteriaHolder!
    private var baseCaptureExperience: kfxKUIDocumentBaseCaptureExperience!
    //var baseDetectionSettings: kfxKEDDocumentBaseDetectionSettings!
    
    private var isBaseCaptureExperienceInitialized: Bool = false
    private var didViewReappeared: Bool = false

    private var captureOptions: CaptureOptions!
    private var experienceOptions: ExperienceOptions!

    private var regionProperties: RegionProperties! = nil
    
    private var showRegionOption: Bool = true
    
    //MARK: - navigationbar variables
    
    private var wasNavigationHidden: Bool = false
    private var oldBarTintColor: UIColor!
    private var oldStatusBarStyle: UIStatusBarStyle!

    //Mark: - Initializer
    
    init(options: CaptureOptions, experienceOptions: ExperienceOptions, regionProperties: RegionProperties!, showRegionSelection: Bool) {

        super.init(nibName: nil, bundle: nil)

        self.captureOptions = options
        self.experienceOptions = experienceOptions

        self.showRegionOption = showRegionSelection
     
        self.regionProperties = regionProperties
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNeedsStatusBarAppearanceUpdate()

        customizeNavigationBar()

        if showRegionOption == false {
            regionButton.isHidden = true
        } else {
            updateRegionImage()
        }
    }

    
    private func customizeNavigationBar() {
        oldStatusBarStyle = UIApplication.shared.statusBarStyle
        oldBarTintColor = navigationController?.navigationBar.tintColor
        
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        wasNavigationHidden = (self.navigationController?.navigationBar.isHidden)!
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func restoreNavigationBar() {
        UIApplication.shared.statusBarStyle = oldStatusBarStyle
        navigationController?.navigationBar.tintColor = oldBarTintColor
        navigationController?.setNavigationBarHidden(wasNavigationHidden, animated: false)
    }

    func updateOverlay() {
        //self.over
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //forceCaptureButton.isUserInteractionEnabled = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        freeCaptureControl()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    
    override func initializeControl() {
        if self.captureControl == nil {
            self.captureControl = CaptureFactory.getImageCaptureControl(frame: calculateFrame())
            self.setCaptureControlOptions()
            
            self.view.addSubview(self.captureControl)

            self.forceCaptureButton.isHidden = false
            
            self.baseCaptureExperience = CaptureFactory.getCaptureExperience(captureControl: captureControl, experienceOptions: experienceOptions)
            
            //self.baseCaptureExperience.addObserver(self, forKeyPath: "tutorialEnabled", options: NSKeyValueObservingOptions.new, context: nil)
            
            self.setCaptureExperienceOptions()
            
            self.baseCaptureExperience.takePicture()
            
            //self.torchButton.isHidden = self.showTorchButton()
            
            self.footerView.superview?.bringSubview(toFront: self.footerView)
            self.topBar.superview?.bringSubview(toFront: self.topBar)
        }
    }
    
    func calculateFrame() -> CGRect {
        
        let captureViewHeight = (UIScreen.main.bounds.size.height <= LOWEREND_DEVICE_HEIGHT && self.captureOptions.useVideoFrame == false) ? IMAGEMODE_LOWEREND_DEVICE_HEIGHT : UIScreen.main.bounds.height
        
        let freeScreenHeight = UIScreen.main.bounds.height - self.footerCommandView.bounds.size.height
        var yOffset: CGFloat = 0.0
        
        if captureViewHeight > freeScreenHeight {
            yOffset = self.footerCommandView.bounds.size.height - (captureViewHeight - freeScreenHeight) / 2.0 - self.topBar.bounds.size.height
        }
        
        let frame: CGRect = CGRect.init(x: 0.0, y: -yOffset, width: UIScreen.main.bounds.size.width, height: freeScreenHeight)
        return frame
    }
    

    
    func showTorchButton() -> Bool {
        if self.isFlashAvailable() {
            return true
        }
        return false
    }


    func setCaptureControlOptions() {
        self.captureControl.useVideoFrame = self.captureOptions.useVideoFrame
        //self.captureControl.stabilityDelay = DEFAULTSTABILITYDELAY
        self.captureControl.delegate = self
        
        if self.captureOptions.showAutoTorch == true {
            self.captureControl.flash = kfxKUITorchAuto
        }
    }
    
    
    func setCaptureExperienceOptions() {
        self.baseCaptureExperience.tutorialEnabled = experienceOptions.doShowGuidingDemo!
        
        if (self.baseCaptureExperience.tutorialEnabled) {
         //   addGestureRecognizerToCaptureControl(action: #selector(self.tapOnCaptureControl(tapGesture:)));
            self.addGestureRecognizerToCaptureControl()
        }

        if self.experienceOptions.tutorialSampleImage != nil {
            self.baseCaptureExperience.tutorialSampleImage = self.experienceOptions.tutorialSampleImage
        }
        
        self.configureCaptureExperienceMessages(messages: self.experienceOptions.messages)
    }

    func addGestureRecognizerToCaptureControl() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnCaptureControl))
        tapGesture.numberOfTapsRequired = 1
        self.captureControl.addGestureRecognizer(tapGesture)
    }
    
    func configureCaptureExperienceMessages(messages: ExperienceMessages!) {
        if messages != nil {
        self.baseCaptureExperience.zoomInMessage.message = messages.moveCloserMessage.characters.count != 0 ? messages.moveCloserMessage :self.baseCaptureExperience.zoomInMessage.message
        self.baseCaptureExperience.holdSteadyMessage.message = messages.holdSteadyMessage.characters.count != 0 ? messages.holdSteadyMessage :self.baseCaptureExperience.holdSteadyMessage.message
        self.baseCaptureExperience.userInstruction.message = messages.userInstruction.characters.count != 0 ? messages.userInstruction :self.baseCaptureExperience.userInstruction.message
        self.baseCaptureExperience.capturedMessage.message = messages.capturedMessage.characters.count != 0 ? messages.capturedMessage :self.baseCaptureExperience.capturedMessage.message
        self.baseCaptureExperience.zoomOutMessage.message = messages.zoomOutMessage.characters.count != 0 ? messages.zoomOutMessage :self.baseCaptureExperience.zoomOutMessage.message
        self.baseCaptureExperience.centerMessage.message = messages.centerMessage.characters.count != 0 ? messages.centerMessage :self.baseCaptureExperience.centerMessage.message
        self.baseCaptureExperience.holdParallelMessage.message = messages.holdParallelMessage.characters.count != 0 ? messages.holdParallelMessage : self.baseCaptureExperience.holdParallelMessage.message
        self.baseCaptureExperience.rotateMessage.message = messages.orientationMessage.characters.count != 0 ? messages.orientationMessage : self.baseCaptureExperience.rotateMessage.message
        }
        setOrientaionForCaptureExperienceMessages()
    }
    
    func setOrientaionForCaptureExperienceMessages() {
        let orientation: kfxKUIMessageOrientation
        
        if self.experienceOptions.portraitMode == true {
            orientation = kfxKUIMessageOrientationPortrait
        } else {
            orientation = kfxKUIMessageOrientationLandscapeLeft
        }
        
        if self.experienceOptions.portraitMode == true {
            self.baseCaptureExperience.zoomInMessage.orientation = orientation
            self.baseCaptureExperience.holdSteadyMessage.orientation = orientation
            self.baseCaptureExperience.userInstruction.orientation = orientation
            self.baseCaptureExperience.capturedMessage.orientation = orientation
            self.baseCaptureExperience.zoomOutMessage.orientation = orientation
            self.baseCaptureExperience.centerMessage.orientation = orientation
            self.baseCaptureExperience.holdParallelMessage.orientation = orientation
            self.baseCaptureExperience.rotateMessage.orientation = orientation
            self.baseCaptureExperience.tutorialDismissMessage.orientation = orientation
        }
    }
    
    func hideCaptureExperienceMessages() {
        self.baseCaptureExperience.centerMessage.hidden = true
        self.baseCaptureExperience.zoomOutMessage.hidden = true
        self.baseCaptureExperience.zoomInMessage.hidden = true
        self.baseCaptureExperience.holdSteadyMessage.hidden = true
        self.baseCaptureExperience.userInstruction.hidden = true
        self.baseCaptureExperience.capturedMessage.hidden = true
        self.baseCaptureExperience.holdParallelMessage.hidden = true
        self.baseCaptureExperience.rotateMessage.hidden = true

    }
    
    
    // Mark: - Button actions
    
    @IBAction func onTorchButtonClicked(_ sender: UIButton)
    {
        if(self.captureControl.flash == kfxKUITorch) {
            sender.setImage(UIImage.init(named: "torch_off.png"), for: UIControlState.normal)
            self.captureControl.flash = kfxKUIFlashOff
        }
        else
        {
            sender.setImage(UIImage.init(named: "torch_on.png"), for: UIControlState.normal)
            self.captureControl.flash = kfxKUITorch
        }
        
        //[sender setSelected:!sender.isSelected]
    }
    
    @IBAction func onForceCaptureButtonClicked(_ sender: UIButton) {
        self.captureControl.forceTakePicture()
        sender.isUserInteractionEnabled = false
    }
    
    @IBAction func onSettingsButtonClicked(_ sender: UIButton) {
    }
    
    @IBAction func onCancelButtonClicked(_ sender: UIButton) {
        
        self.freeCaptureControl()
        self.delegate?.cancelCamera()
        self.restoreNavigationBar()
        //self.dismiss(animated: true, completion: nil)
    }

    // Mark: - TapgestureRecognizer callbacks
    func tapOnCaptureControl(tapGesture: UITapGestureRecognizer) {
        self.baseCaptureExperience.tutorialEnabled = false
    }
    
    
    // Mark: - ImageCaptureControl Delegate Methods
    func imageCaptureControl(_ imageCaptureControl: kfxKUIImageCaptureControl!, imageCaptured image: kfxKEDImage!) {
        restoreNavigationBar()
        self.delegate?.imageCaptured(image: image)
    }
    
    //MARK: Region related methods
    
    var regionController: RegionController?
    
    @IBAction func onRegionButtonClicked(_ sender: UIButton) {
  
        self.regionController = RegionController()

        let result = self.regionController?.showRegionSelection(launcherViewConroller: self, andRegionProperties: self.regionProperties)
        
        if result == false {
            Utility.showAlert(onViewController: self, titleString: "Error", messageString: "Could not launch region selection.")
            regionController = nil
        }else {
            self.regionController?.delegate = self
        }

//        let vc = RegionViewController(nibName: "RegionViewController", bundle: nil)
//        vc.currentRegionProperties = self.regionProperties
        
//        let nc = UINavigationController.init(rootViewController: vc)
//        present(nc, animated: true, completion: nil)
    }
    
    func regionSelectorDidCancel() {
        print("No new region selected")
    }
    
    func regionSelectorDidSaveNewRegion(regionProperties: RegionProperties) {
        print("New region selected")
        self.regionProperties = regionProperties
        updateRegionImage()
        delegate?.onRegionUpdated(regionProperties: self.regionProperties)
    }

    private func updateRegionImage() {
        if regionProperties != nil && regionProperties.flagName != "" {
            //regionButton.imageView?.image = UIImage.init(named: regionProperties.flagName)
            regionButton.setImage(UIImage.init(named: regionProperties.flagName), for: UIControlState.normal)
        } else {
            
        }
    }
    
    func freeCaptureControl() {
        
        if(self.captureControl != nil) {
            self.captureControl.removeFromSuperview()
            self.captureControl.delegate = nil
            self.captureControl = nil
        }
        
        if(self.baseCaptureExperience != nil) {
            //self.baseCaptureExperience.removeObserver(self, forKeyPath: "tutorialEnabled", context: nil)
            self.baseCaptureExperience = nil
        }
    }
    
    deinit {
        torchButton = nil
        cancelButton = nil
        topBar = nil
        footerCommandView = nil
        footerView = nil
        forceCaptureButton = nil

        freeCaptureControl()
    }
}


