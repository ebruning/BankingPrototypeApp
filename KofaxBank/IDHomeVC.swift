//
//  IDHomeVC.swift
//  KofaxBank
//
//  Created by Rupali on 03/10/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

protocol IDHomeVCDelegate {
    func authenticateWithSelfie(idData: kfxIDData)
    func onIDHomeDoneWithData(idData: kfxIDData)
//    func onIDHomeDoneWithoutData()
    func onIDHomeCancel()
}

 class IDHomeVC: UIViewController, IDDataViewControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var warningContainer: UIView!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var warningIcon: UIImageView!

    @IBOutlet weak var frontContainerView: CustomView!
    
    @IBOutlet weak var frontImageView: UIImageView!

    @IBOutlet weak var backImageViewTop: UIImageView!
    
    @IBOutlet weak var backContainerView: CustomView!
    
    @IBOutlet weak var backImageViewBottom: UIImageView!

    @IBOutlet weak var backImagePreviewLabel: UILabel!

    @IBOutlet weak var dataFieldsInstructionLabel: UILabel!
    
    @IBOutlet weak var fieldsContainerView: UIView!

    @IBOutlet weak var pageControl: UIPageControl!

//    @IBOutlet weak var waitIndicatorContainerVaiw: UIView!

    @IBOutlet weak var idNumberField: UITextField!
    
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!

    @IBOutlet weak var dobField: UITextField!

    @IBOutlet weak var addressField: UITextField!

    
    @IBOutlet weak var viewMoreButton: UIButton!
    
    private var _frontImageFilePath: String!
    
    private var _backImageFilePath: String!
    
    private var idData: kfxIDData!
    
    private var dataReadInProgress = false
    
    private var frontContainerSwipeRightRecogizer: UISwipeGestureRecognizer! = nil

    private var frontContainerSwipeLeftRecogizer: UISwipeGestureRecognizer! = nil

    

    private lazy var waitindicatorView: WaitIndicatorView! = {
        let waitindicatorView = WaitIndicatorView()
        return waitindicatorView
    }()

    
    //MARK: Public variables
    
    var authenticationResultModel: AuthenticationResultModel! = nil

    var frontImageFilePath: String {
        get {
            return _frontImageFilePath
        } set {
            _frontImageFilePath = newValue
        }
    }
    
    var backImageFilePath: String! {
        get {
            return _backImageFilePath
        } set {
            _backImageFilePath = newValue
        }
    }
    
    var delegate: IDHomeVCDelegate?
    
    
    //MARK: Navigationbar related parameters
    private var wasNavigationHidden: Bool = false
    
    private var oldBarTintColor: UIColor!
    
    private var oldStatusBarStyle: UIStatusBarStyle!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeScreenControls()
        
        customizeNavigationBar()
    }
    
    //MARK: Public methods
    func imageReady(side: DocumentSide) {
        DispatchQueue.main.async {
            if side == .FRONT {
                self.displayFrontImage()
            } else {
                self.backImagePreviewLabel.isHidden = true
                self.displayBackImage()
            }
        }
    }
    
    func idDataFetchBegun() {
        dataReadInProgress = true
        
        showWaitIndicator()
    }
    
    func idDataNotAvailable(err: AppError!) {
        var alertTitle: String! = ""
        var alertMessage: String! = ""
        
        dataReadInProgress = false
        hideWaitIndicator()
        
        if self.backImageFilePath != nil && self.backImageFilePath.characters.count > 0 {
            self.pageControl.isHidden = false
            self.backContainerView.isHidden = true
            self.addSwipeGestureListenerFront()
        }
        
        self.idData = nil
        
        if err != nil {
            if err.title != nil {
                alertTitle = err.title
            }
            
            if err.message != nil {
                alertMessage = err.message
            }
        }
        //hideWaitIndicator()
        DispatchQueue.main.async {
          //  self.hideWaitIndicator()
            
            Utility.showAlert(onViewController: self, titleString: alertTitle, messageString: alertMessage)
        }
    }
    
    func idDataAvailable(idData: kfxIDData) {
        self.idData = idData
        
        dataReadInProgress = false
        
        hideWaitIndicator()

        DispatchQueue.main.async {
            
            self.viewMoreButton.isHidden = false
            self.backContainerView.isHidden = true

            if self.backImageFilePath != nil && self.backImageFilePath.characters.count > 0 {
                self.backImageViewTop.image = self.backImageViewBottom.image
                self.pageControl.isHidden = false
                self.addSwipeGestureListenerFront()
            }

            if self.idData != nil {
                self.displayDataFields()
                
                if self.shouldAuthenticateWithSelfie() {
                    if self.authenticationResultModel == nil {
                        Utility.showAlert(onViewController: self, titleString: "Verification Error", messageString: "Could not receive ID verification results.\n\nPlease try again.")
                    }
                    else {
                        self.updateNavigationButtonItems(title: "Authenticate")
                    }
                } else {
                    self.updateNavigationButtonItems(title: "Done")
                }
            } else {
                Utility.showAlert(onViewController: self, titleString: "", messageString: "Could not read data from ID.\n\nPlease try again")
            }
            
            if self.authenticationResultModel != nil {
                self.updateWarningLabel(verificationStatus: self.authenticationResultModel.authenticationResult)
            }
        }
    }
    
    
    

    func selfieAuthenticationBegun() {
        showWaitIndicator()
    }

    func selfieAuthenticationEnded() {
        hideWaitIndicator()
    }

    private func updateVisibilityAuthenticationWarningView(shouldHide: Bool) {
        //if authenticationResultModel == nil {
        warningContainer.isHidden = shouldHide
    }

    
    //MARK: TAP Gesture Recognizer Methods
    
    @IBAction func onFieldTapGesture(_ sender: UITapGestureRecognizer) {
        displayIDDataViewControllerScreen()
    }
    
    
    //MARK: Private methods

    private func customizeScreenControls() {
        let screenStyler = AppStyleManager.sharedInstance().get_app_screen_styler()
        dataFieldsInstructionLabel.backgroundColor = screenStyler?.get_accent_color()
    }

    private func customizeNavigationBar() {
        oldStatusBarStyle = UIApplication.shared.statusBarStyle
        oldBarTintColor = navigationController?.navigationBar.tintColor
        
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        
        let newBackButton = UIBarButtonItem.init(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onCancelButtonClick))
            
        self.navigationItem.leftBarButtonItem=newBackButton
        
        wasNavigationHidden = (navigationController?.navigationBar.isHidden)!
        
        //show navigation bar
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    
    private func updateNavigationButtonItems(title: String!) {
        if title != nil {
            
            var rightBarButtonItem: UIBarButtonItem! = nil
            if title.caseInsensitiveCompare("Done") == ComparisonResult.orderedSame {
                
                rightBarButtonItem = UIBarButtonItem.init(title: title, style: .plain, target: self, action: #selector(onDoneBarButtonClicked))
            } else if title.caseInsensitiveCompare("Authenticate") == ComparisonResult.orderedSame {
                rightBarButtonItem = UIBarButtonItem.init(title: title, style: .plain, target: self, action: #selector(onAuthenticateBarButtonClicked))
            }
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
        } else {
            
        }
    }

    func onDoneBarButtonClicked() {
            if areAllRequiredFieldsAvailable() {
                delegate?.onIDHomeDoneWithData(idData: idData)
                self.navigationController?.popViewController(animated: true)
        }
    }

    func onAuthenticateBarButtonClicked() {
        if areAllRequiredFieldsAvailable() {
            delegate?.authenticateWithSelfie(idData: self.idData)
        } else {
            Utility.showAlert(onViewController: self, titleString: "Empty Fields", messageString: "One or more required fields are empty. Please fill all the details before saving.")
        }
    }
    
    

    private func areAllRequiredFieldsAvailable() -> Bool {
        if idData == nil {
            return false
        }
        if idData.firstName.value == nil || idData.lastName.value == nil || idData.address.value == nil || idData.city.value ==  nil || idData.state.value == nil || idData.country.value == nil || idData.zip.value == nil || idData.dateOfBirth.value == nil {
            return false
        }
        return true
    }
    
    private func shouldAuthenticateWithSelfie() -> Bool {
        var shouldAuthenticate = false
        let mobileIDVersion = UserDefaults.standard.value(forKey: KEY_ID_MOBILE_ID_VERSION) as! String
        
        if mobileIDVersion == MobileIDVersion.VERSION_2X.rawValue {
            shouldAuthenticate = true
        }
        
        return shouldAuthenticate
        
    }
    
    var verificationStatus: String! =  nil
    
    private func updateWarningLabel(verificationStatus: String!) {
        if verificationStatus == nil {
            updateVisibilityAuthenticationWarningView(shouldHide: true)
        } else {
            
            self.verificationStatus = verificationStatus.capitalized

            updateVisibilityAuthenticationWarningView(shouldHide: false)

            if verificationStatus.caseInsensitiveCompare("FAILED") == ComparisonResult.orderedSame {
                warningContainer.backgroundColor = UIColor.red
                warningLabel.text = "DOCUMENT IS INVALID"
                warningIcon.image = UIImage(named: "warning")
            } else if verificationStatus.caseInsensitiveCompare("Attention") == ComparisonResult.orderedSame {
                warningContainer.backgroundColor = UIColor.orange
                warningLabel.text = "DOCUMENT APPEARS TO BE AUTHENTIC, BUT NEEDS ATTENTION"
                warningIcon.image = UIImage(named: "warning")
            } else if verificationStatus.caseInsensitiveCompare("Passed") == ComparisonResult.orderedSame {
                warningContainer.backgroundColor = applicationGreenColor
                warningLabel.text = "DOCUMENT IS VERIFIED"
                warningIcon.image = UIImage(named: "checkmark_yellow")
            }
        }
    }
    
    
    func onCancelButtonClick() {
        
        var title: String!
        var message: String!
        
        if idData != nil {
            title = "Abort"
            message = "This will cancel the ID Authentication process.\n\nDo you want to continue?"
        } else {
            title = "Abort"
            message = "Do you want to close the screen?"
        }
        
        Utility.showAlertWithCallback(onViewController: self, titleString: title, messageString: message, positiveActionTitle: "Yes", negativeActionTitle: "No", positiveActionResponse: {
            print("Positive response selected")
            
            self.delegate?.onIDHomeCancel()
            
            self.restoreNavigationBar()
            self.navigationController?.popViewController(animated: true)
            
        }, negativeActionResponse: {
            print("Negative response selected")
        })
    }
    
    private func restoreNavigationBar() {
        UIApplication.shared.statusBarStyle = oldStatusBarStyle
        navigationController?.navigationBar.tintColor = oldBarTintColor
        navigationController?.setNavigationBarHidden(wasNavigationHidden, animated: false)
    }
    
    private func displayFrontImage() {
        if _frontImageFilePath != nil {
            displayImage(toImageView: frontImageView, fromFileContent: _frontImageFilePath)
        }
    }
    
    private func displayBackImage() {
        if _backImageFilePath != nil {
            displayImage(toImageView: backImageViewBottom, fromFileContent: _backImageFilePath)
            displayImage(toImageView: backImageViewTop, fromFileContent: _backImageFilePath)
            backContainerView.isHidden = false
        }
    }
    
    private func displayImage(toImageView: UIImageView, fromFileContent: String) {
        
        var image = UIImage.init(contentsOfFile: fromFileContent)
        
        if image != nil {
            //let scaledImage = resizeImage(image: image?.getBitmap(), newWidth: toImageView.bounds.width)
            toImageView.image = image
            image = nil
        }
    }
    
    
    private func displayDataFields() {
        guard let data = idData else { return  }
        
        self.displayTextFields(data: data)
    }

    private func displayTextFields(data: kfxIDData) {
        
        if data.idNumber != nil && data.idNumber.value != nil {
         
            idNumberField.text = data.idNumber.value
        }
        
        if data.firstName != nil && data.firstName.value != nil {

            firstNameField.text = data.firstName.value
        }
        
        if data.lastName != nil && data.lastName.value != nil {
            
            lastNameField.text = data.lastName.value
        }
        
        if data.dateOfBirth != nil && data.dateOfBirth.value != nil {
            
            dobField.text = data.dateOfBirth.value
        }
        
        if data.address != nil && data.address.value != nil {
        
            addressField.text = data.address.value
        }
        
        fieldsContainerView.isHidden = false
    }
    
    // MARK: SwipeGestureRecognizer methods
    
    func addSwipeGestureListenerFront() {
        // add swipe-left recognizer
        if frontContainerSwipeLeftRecogizer == nil {
            frontContainerSwipeLeftRecogizer = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGestureFront))
            frontContainerSwipeLeftRecogizer.direction = UISwipeGestureRecognizerDirection.left
        }
        frontContainerView.addGestureRecognizer(frontContainerSwipeLeftRecogizer)
        
        // add swipe-right recognizer
        if frontContainerSwipeRightRecogizer == nil {
            frontContainerSwipeRightRecogizer = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGestureFront))
            frontContainerSwipeRightRecogizer.direction = UISwipeGestureRecognizerDirection.right
        }
        frontContainerView.addGestureRecognizer(frontContainerSwipeRightRecogizer)
    }
    
    
    private func removeSwipeGestureFront() {
        if frontContainerView.gestureRecognizers != nil && frontContainerSwipeLeftRecogizer != nil {
            frontContainerView.removeGestureRecognizer(frontContainerSwipeLeftRecogizer)
            frontContainerView.removeGestureRecognizer(frontContainerSwipeRightRecogizer)
        }
    }
    
    func respondToSwipeGestureFront(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swipe Right...")
                showPrevious()
                
                pageControl.currentPage = 0
                break
            case UISwipeGestureRecognizerDirection.left:
                print("Swipe Left...")
                pageControl.currentPage = 1
                showNext()
                break
                
            default:
                break
            }
        }
    }
    
    func showNext() {
        if backImageViewTop.isHidden {
            backImageViewTop.isHidden = false
            frontImageView.isHidden = true
        }
    }
    
    func showPrevious() {
        if frontImageView.isHidden {
            frontImageView.isHidden = false
            backImageViewTop.isHidden = true
        }
    }
    

    
    //MARK: Command button action
    
    @IBAction func viewMoreFields(_ sender: UIButton) {
        displayIDDataViewControllerScreen()
    }
    
    private func displayIDDataViewControllerScreen() {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "IDDataView") as! IDDataViewController
        vc.idData = self.idData
        vc.delegate = self
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: IDDataViewControllerDelegate method
    func IDDataSaved(idData: kfxIDData) {
        self.idData = idData
        displayTextFields(data: self.idData)
    }

    
    //MARK: Wait indicator methods
    
    private func showWaitIndicator() {
        DispatchQueue.main.async {
            self.waitindicatorView.displayView(onView: self.view)
        }
    }
    
    private func hideWaitIndicator() {
        DispatchQueue.main.async {
            self.waitindicatorView.hideView()
        }
    }
    

}
