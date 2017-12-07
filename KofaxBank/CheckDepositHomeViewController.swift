//
//  CheckDepositHomeViewController.swift
//  KofaxBank
//
//  Created by Rupali on 11/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import AVFoundation

protocol CheckDepositHomeViewControllerDelegate {
    
    func showCamera(side: DocumentSide)
    func showGallery(side: DocumentSide)
    func checkDeposited()
    func checkDepositCancelled()
}

class CheckDepositHomeViewController: BaseViewController, UITextFieldDelegate, UITabBarControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var countryNameLabel: UILabel!
    
    @IBOutlet weak var frontContainerView: ViewShadow!
    
    @IBOutlet weak var frontCaptureButton: UIButton!
    
    @IBOutlet weak var frontInstructionLabel: UILabel!
    
    @IBOutlet weak var frontProcessedImageView: UIImageView!
    
    @IBOutlet weak var frontPageControl: UIPageControl!
    
    @IBOutlet weak var backContainerView: ViewShadow!
    
    @IBOutlet weak var backCaptureButton: UIButton!
    
    @IBOutlet weak var backInstructionLabel: UILabel!
    
    @IBOutlet weak var backProcessedImageViewTop: UIImageView!

    @IBOutlet weak var backProcessedImageViewBottom: UIImageView!

    @IBOutlet weak var depositButton: UIButton!
    
    @IBOutlet weak var checkDataHeaderLabel: UILabel!
    
    //Post data retrieval parameters
    
    @IBOutlet weak var amountText: UITextField!
    //@IBOutlet weak var payeeNameText: UITextField!
    @IBOutlet weak var checkNumberText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    //@IBOutlet weak var larCarMatchImageView: UIImageView!
    
    @IBOutlet weak var checkDataFieldsContainerView: UIView!

    //Check quality related controls
    
    
    @IBOutlet weak var checkQualityPopupView: UIVisualEffectView!
    
    @IBOutlet weak var imgTornEdgesGreen: UIImageView!
    @IBOutlet weak var imgTornEdgesRed: UIImageView!
    
    @IBOutlet weak var imgTornCornersGreen: UIImageView!
    @IBOutlet weak var imgTornCornersRed: UIImageView!
    
    @IBOutlet weak var imgSkewedGreen: UIImageView!
    @IBOutlet weak var imgSkewedRed: UIImageView!
    
    @IBOutlet weak var imgNotLightGreen: UIImageView!
    @IBOutlet weak var imgNotLightRed: UIImageView!
    
    @IBOutlet weak var imgNotDarkGreen: UIImageView!
    @IBOutlet weak var imgNotDarkRed: UIImageView!
    
    @IBOutlet weak var imgDimensionMismatchGreen: UIImageView!
    @IBOutlet weak var imgDimensionMismatchRed: UIImageView!
    
    @IBOutlet weak var imgFocusedGreen: UIImageView!
    @IBOutlet weak var imgFocusedRed: UIImageView!

    @IBOutlet weak var imgCarLarMatchGreen: UIImageView!
    @IBOutlet weak var imgCarLarMatchRed: UIImageView!

    
    //Check quality alert banner related controls

    @IBOutlet weak var alertBanner: ViewShadow!
    
    //@IBOutlet weak var alertBannerLabel: UILabel!

    
    enum Direction {
        case RIGHT
        case LEFT
    }

    private lazy var waitIndicator: WaitIndicatorView! = {
        let waitIndicator = WaitIndicatorView()
        return waitIndicator
    }()

    
    //Mark: - Delegate
    var delegate: CheckDepositHomeViewControllerDelegate?
    
    //Mark: - Public variables

    var account: AccountsMaster?

    //Mark: - Private variables

    private var backProcessedImage: UIImage!
    
    private var frontProcessedImagePath: String!
    
    private var backProcessedImagePath: String!
    
    private var frontContainerSwipeRightRecogizer: UISwipeGestureRecognizer! = nil
    private var frontContainerSwipeLeftRecogizer: UISwipeGestureRecognizer! = nil
    
    private var documentSide: DocumentSide = DocumentSide.FRONT
    
    private var checkData: kfxCheckData! = nil
    private var checkIQAData: kfxCheckIQAData! = nil

    
    //Check quality alert banner relatd variables
    private var bannerTimer: Timer! = nil
    // a sound ID
    private let systemSoundID: SystemSoundID = 1052

    private var viewingForTheFirstTime: Bool = true
    
    //private let scrollContentInset: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
    
    //MARK: - navigationbar variables
    
    private var wasNavigationHidden: Bool = false
    private var oldBarTintColor: UIColor!
    private var oldStatusBarStyle: UIStatusBarStyle!


    //MARK: status bar visibility
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: statusbar content color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frontProcessedImageView.isHidden = true
        backProcessedImageViewTop.isHidden = true
        backProcessedImageViewBottom.isHidden = true

        frontPageControl.isHidden = true
        frontPageControl.currentPage = 0
        
        depositButton.isHidden = true
        
//        self.tabBarController?.delegate = self
        
//        scrollView.contentInset = scrollContentInset
//        scrollView.scrollIndicatorInsets = scrollContentInset
        registerForKeyboardNotifications()
        
        customizeScreenControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        customizeNavigationBar()
        //self.tabBarController?.delegate = self

    }
    
    
    // MARK: private methods
    
    private func customizeScreenControls() {
        let screenStyler = AppStyleManager.sharedInstance()?.get_app_screen_styler()
        
        let buttonStyler = AppStyleManager.sharedInstance()?.get_button_styler()

        let accentColor = screenStyler?.get_accent_color()
        
        checkDataHeaderLabel.backgroundColor = accentColor
        depositButton = buttonStyler?.configure_primary_button(depositButton)
        
        frontPageControl.currentPageIndicatorTintColor = accentColor
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
    
    //MARK TabBar controller delegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController != self {
            print("New tab selected!")
            //clear()
            //markForRefresh = true
        }
    }
    

    func onCancelPressed() {
        Utility.showAlertWithCallback(onViewController: self, titleString: "Abort", messageString: "This will cancel the check deposit process.\n\nDo you want to continue?", positiveActionTitle: "Yes", negativeActionTitle: "No", positiveActionResponse: {
            print("Positive response selected")
            
            self.delegate?.checkDepositCancelled()

            self.restoreNavigationBar()

            self.clearScreenData()
            
            self.navigationController?.popViewController(animated: true)

        }, negativeActionResponse: {
            print("Negative response selected")
        })
    }
    
    // MARK: Tap gesture methods
    
    // MARK: Capture Buttons callbacks
    
    @IBAction func handleFrontSideCaptureButton(_ sender: UIButton) {
        print("Enter: handleTapOnFrontContainer")
        documentSide = DocumentSide.FRONT
        delegate?.showCamera(side: documentSide)
    }
    
    @IBAction func handleBackSideCaptureButton(_ sender: UIButton) {
        print("Enter: handleTapOnBackContainer")
        documentSide = DocumentSide.BACK
        delegate?.showCamera(side: documentSide)
    }
    
    
    func displayFrontImage(image: kfxKEDImage!, isProcessed: Bool){
        if image != nil {
            
            if !isProcessed {
/*
                //Mark: Feedback
                 //using scaled image only for raw preview
                let scaledImg = resizeImage(image: image.getBitmap(), newWidth: frontRawImageView.bounds.width)
                frontRawImageView.image = scaledImg
                frontRawImageView.isHidden = false
                frontInstructionLabel.isHidden = true
*/
            }
            else {
                //Using full sized processed image instead of scaled image here
                frontProcessedImageView.image = image.getBitmap()
                frontProcessedImageView.isHidden = false
//              addSwipeGestureListenerFront()    //MARK: Feedback
                frontCaptureButton.isHidden = true
                frontInstructionLabel.isHidden = true
                
                //display back image containerview for user to capture back side of the check
                backContainerView.isHidden = false
            }
        }
    }
    
    func displayBackImage(image: kfxKEDImage!, isProcessed: Bool){
        if image != nil {
            //let scaledImg = resizeImage(image: image.getBitmap(), newWidth: backRawImageView.bounds.width)
            
            if !isProcessed {
/*
                //MARK: Feedback
                //using scaled image only for raw preview
                let scaledImg = resizeImage(image: image.getBitmap(), newWidth: backRawImageView.bounds.width)
                backRawImageView.image = scaledImg
                backRawImageView.isHidden = false
                backInstructionLabel.isHidden = true
*/
            }
            else
            {
                //Using full sized processed image instead of scaled image here
                if backProcessedImageViewBottom.image == nil {
                    self.backProcessedImage = image.getBitmap()
                    backProcessedImageViewBottom.image = image.getBitmap()
                    backProcessedImageViewBottom.isHidden = false
                    
                    backCaptureButton.isHidden = true
                    backInstructionLabel.isHidden = true

                } else {
                    backProcessedImageViewTop.image = backProcessedImage //backProcessedImageViewBottom.image
                    self.backProcessedImage = nil
                }
            }
        }
    }
    
    private func resetFront() {
        DispatchQueue.main.async {
            self.removeSwipeGestureFront()

            self.frontProcessedImagePath = nil

            self.frontProcessedImageView.image = nil
            self.frontProcessedImageView.isHidden = true

            self.frontInstructionLabel.isHidden = false
            self.frontCaptureButton.isHidden = false
        }
    }
    
    private func resetBack() {
        DispatchQueue.main.async {

            self.backProcessedImagePath = nil
            self.backProcessedImage = nil
            
            self.backProcessedImageViewTop.image = nil
            self.backProcessedImageViewTop.isHidden = true

            self.backProcessedImageViewBottom.image = nil
            self.backProcessedImageViewBottom.isHidden = true

            self.backInstructionLabel.isHidden = false
            self.backCaptureButton.isHidden = false
            
            self.backContainerView.isHidden = false

        }
    }
/*
    func initializeWaitIndicator(withMessage: String!) {
        DispatchQueue.main.async {
            if let msg = withMessage {
                self.overlayView.messageLabel.text = msg
            }
        }
    }
  */
    func showWaitIndicator() {
        DispatchQueue.main.async {
            self.waitIndicator.displayView(onView: self.view)
        }
    }
    
    private func hideWaitIndicator() {
        DispatchQueue.main.async {
            self.waitIndicator.hideView()
        }
    }
    
    func extractionBegun() {
        showWaitIndicator()
    }
    
    func handleError(checkSide: DocumentSide) {
        DispatchQueue.main.async {
            if (checkSide == DocumentSide.FRONT) {
                self.resetFront()
            } else {
                self.resetBack()
            }
        }
    }
    
    func checkDataNotAvailable() {
        DispatchQueue.main.async {
            self.hideWaitIndicator()
            
            Utility.showAlert(onViewController: self, titleString: "Data read failed", messageString: "Could not read data from check. Please try again.")
            self.resetFront()
            self.resetBack()
        }
    }

    
    func checkDataAvailable(checkData: kfxCheckData, checkIQAData: kfxCheckIQAData) {
        self.checkData = checkData
        self.checkIQAData = checkIQAData

        DispatchQueue.main.async {
            self.hideWaitIndicator()

            self.performPostDataRetrievalTasks()
            self.depositButton.isHidden = false
        }
    }
    
    
    private func performPostDataRetrievalTasks() {
        
        //self.displayBackImage(image: nil, isProcessed: true)
        if self.backProcessedImage != nil {
            self.backProcessedImageViewTop.image = self.backProcessedImage
            self.frontPageControl.isHidden = false
            self.addSwipeGestureListenerFront()
        }
        self.backContainerView.isHidden = true
        self.backProcessedImageViewBottom.image = nil
        
        self.displayFieldData()
        
        
        if areAllCheckParamsGood(checkIQData: checkIQAData) == false {
            viewingForTheFirstTime = true
            displayAlertBannerOnTop()
        }
    }

/*
    private func showCheckDataPreviewScreen(justExtracted: Bool) {

        let vc = CheckDataPreviewViewController.init(nibName: "CheckDataPreviewViewController", bundle: nil)
        
        let navController = UINavigationController.init(rootViewController: vc)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.backgroundColor = UIColor.clear
    
        if (self.checkData != nil && self.checkIQAData != nil) {
            vc.checkData = self.checkData
            vc.checkIQData = self.checkIQAData
        }

        vc.viewingForTheFirstTime = justExtracted
        vc.delegate = self

        self.present(navController, animated: true, completion: nil)
    }
*/

    
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
                
                frontPageControl.currentPage = 0
                break
            case UISwipeGestureRecognizerDirection.left:
                print("Swipe Left...")
                frontPageControl.currentPage = 1
                showNext()
                break

            default:
                break
            }
        }
    }
    
    func showNext() {
            if backProcessedImageViewTop.isHidden {
                backProcessedImageViewTop.isHidden = false
                frontProcessedImageView.isHidden = true
            }
    }
    
    func showPrevious() {
        if frontProcessedImageView.isHidden {
            frontProcessedImageView.isHidden = false
            backProcessedImageViewTop.isHidden = true
        }
    }
    
    
    private func addCheckDetailsToPersistentStorage() {
        
        //save to persistent storage
        
        if self.checkData == nil {
            self.checkData = kfxCheckData()
            
            self.checkData.amount = kfxDataField()
            self.checkData.car = kfxDataField()
            self.checkData.checkNumber = kfxDataField()
            self.checkData.date = kfxDataField()
            self.checkData.micr = kfxDataField()
            self.checkData.payeeName = kfxDataField()
            self.checkData.reasonForRejection = kfxDataField()
            self.checkData.restrictiveEndorsement = kfxDataField()
            self.checkData.restrictiveEndorsementPresent = kfxDataField()
            self.checkData.usable = kfxDataField()
        }
        
        self.checkData.amount.value = amountText.text
        self.checkData.checkNumber.value = checkNumberText.text
        self.checkData.date.value = dateText.text
        //self.checkData.payeeName.value = payeeNameText.text
        
        let checkTransaction = CheckTransactions(context: context)
        checkTransaction.payee = self.checkData.payeeName.value
        checkTransaction.accountNumber = account?.accountNumber
        checkTransaction.amount = Double(self.checkData.amount.value)!
        checkTransaction.comment = "Check with number - \(self.checkData.checkNumber.value!) deposited"
        checkTransaction.checkNumber = self.checkData.checkNumber.value
        checkTransaction.paymentDate = Utility.convertStringToDate(format: LongDateFormatWithNumericMonth, dateStr: self.checkData.date.value)! as NSDate
        
        print("Formatted date from sring ==>\(Utility.convertStringToDate(format: LongDateFormatWithNumericMonth, dateStr: self.checkData.date.value)!))")
        
        let transaction = AccountTransactionMaster(context: context)
        transaction.account = account
        transaction.type = TransactionType.CREDIT.rawValue
        transaction.checkTransaction = checkTransaction
        transaction.dateOfTransaction = Date() as NSDate

        checkTransaction.transactionMaster = transaction

        transaction.checkTransaction = checkTransaction
        
        account?.balance = account!.balance + checkTransaction.amount
        
        account?.addToTransactions(transaction)
        
        //save check data
        ad.saveContext()
    }

    // MARK: Button Actions
    
    @IBAction func showCountrySelection(_ sender: UIButton) {
        
    }
    
    @IBAction func depositCheck(_ sender: UIButton) {
        
        if (self.frontProcessedImageView.image == nil || self.backProcessedImageViewTop.image == nil) {
            Utility.showAlert(onViewController: self, titleString: "Insufficient information", messageString: "Both sides of the check required to deposit the check.")
            return
        }
        
        if account == nil {
            Utility.showAlert(onViewController: self, titleString: "No Account Found", messageString: "Account cannot be empty.\nPlease make sure proper account is selected to deposit the check into.")
            return
        }
        
        if areAllFieldsPresent() == false {
            Utility.showAlert(onViewController: self, titleString: "Empty Fields", messageString: "One or more check details are missing.\n\nMake sure all the details are filled before depositing the check.")
            return
        }

        self.addCheckDetailsToPersistentStorage()

        self.delegate?.checkDeposited()
        
        self.restoreNavigationBar()

        self.clearScreenData()

        //close this viewcontroller
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onGalleryOptionClicked(_ sender: UIButton) {
        delegate?.showGallery(side: documentSide)
    }
    
    
    //MARK: Post check-data retrieval methods (merged from CheckDataPreviewController. Deleted the CheckDataPreviewController screen.)
    
    private func displayFieldData() {
        
        if checkData != nil {

            checkDataFieldsContainerView.isHidden = false
            
            amountText.text = checkData.amount.value
            print("checkData.amount confidence ==> \(self.checkData.amount.confidence)")

            if checkData.amount.confidence < 0.80 {
                amountText.textColor = UIColor.red
            }
//            payeeNameText.text = checkData.payeeName.value
            
            checkNumberText.text = checkData.checkNumber.value
            print("checkData.checkNumber confidence ==> \(self.checkData.checkNumber.confidence)")
            if checkData.checkNumber.confidence < 0.80 {
                checkNumberText.textColor = UIColor.red
            }
            
            //validate date before displaying
            if Utility.validateDate(format: LongDateFormatWithNumericMonth, dateStr: checkData.date.value) == true {
                dateText.text = checkData.date.value
            } else {
                dateText.text = ""
            }
            
            if checkData.date.confidence < 0.80 {
                dateText.textColor = UIColor.red
            }
            print("checkData.date confidence ==> \(self.checkData.date.confidence)")

            
            setupDatePicker()
        }
        if checkIQAData != nil {
            if checkIQAData.imageDimensionMismatch.value.caseInsensitiveCompare("true") == ComparisonResult.orderedSame {
                imgDimensionMismatchRed.isHidden = false
                imgDimensionMismatchGreen.isHidden = true
            }
            
            if checkIQAData.foldedOrTornDocumentCorners.value.caseInsensitiveCompare("true") == ComparisonResult.orderedSame {
                imgTornCornersRed.isHidden = false
                imgTornCornersGreen.isHidden = true
            }
            
            if checkIQAData.foldedOrTornDocumentEdges.value.caseInsensitiveCompare("true") == ComparisonResult.orderedSame {
                imgTornEdgesRed.isHidden = false
                imgTornEdgesGreen.isHidden = true
            }
            
            if checkIQAData.imageTooDark.value.caseInsensitiveCompare("true") == ComparisonResult.orderedSame {
                imgNotDarkRed.isHidden = false
                imgNotDarkGreen.isHidden = true
            }
            
            if checkIQAData.imageTooLight.value.caseInsensitiveCompare("true") == ComparisonResult.orderedSame {
                imgNotLightRed.isHidden = false
                imgNotLightGreen.isHidden = true
            }
            
            if checkIQAData.outOfFocus.value.caseInsensitiveCompare("true") == ComparisonResult.orderedSame {
                imgFocusedRed.isHidden = false
                imgFocusedGreen.isHidden = true
            }
            
            if checkIQAData.documentSkew.value.caseInsensitiveCompare("true") == ComparisonResult.orderedSame {
                imgSkewedRed.isHidden = false
                imgSkewedGreen.isHidden = true
            }
            
            if checkData.car.value == checkData.lar.value {
                imgCarLarMatchGreen.isHidden = false
                imgCarLarMatchRed.isHidden = true
            } else {
                imgCarLarMatchGreen.isHidden = true
                imgCarLarMatchRed.isHidden = false
            }
        }
    }

    private func areAllCheckParamsGood(checkIQData: kfxCheckIQAData) -> Bool {
        var isGood: Bool = true
        
        if let fieldValue = checkIQData.foldedOrTornDocumentEdges.value {
            isGood = (fieldValue.caseInsensitiveCompare("false") == ComparisonResult.orderedSame) ? true : false
        }
        else if let fieldValue = checkIQData.foldedOrTornDocumentCorners.value {
            isGood = (fieldValue.caseInsensitiveCompare("false") == ComparisonResult.orderedSame) ? true : false
        }
        else if let fieldValue = checkIQData.documentSkew.value {
            isGood = (fieldValue.caseInsensitiveCompare("false") == ComparisonResult.orderedSame) ? true : false
        }
        else if let fieldValue = checkIQData.imageTooDark.value {
            isGood = (fieldValue.caseInsensitiveCompare("false") == ComparisonResult.orderedSame) ? true : false
        }
        else if let fieldValue = checkIQData.imageTooLight.value {
            isGood = (fieldValue.caseInsensitiveCompare("false") == ComparisonResult.orderedSame) ? true : false
        }
        else if let fieldValue = checkIQData.imageDimensionMismatch.value {
            isGood = (fieldValue.caseInsensitiveCompare("false") == ComparisonResult.orderedSame) ? true : false
        }
        else if let fieldValue = checkIQData.outOfFocus.value {
            isGood = (fieldValue.caseInsensitiveCompare("false") == ComparisonResult.orderedSame) ? true : false
        } else {
            isGood = checkData.car.value == checkData.lar.value
        }
        
        return isGood
    }
    
    
    // MARK: BannerAlert methods
    
    private func displayAlertBannerOnTop() {
        
        //animate the warning if data is being shown for the very first time
        if viewingForTheFirstTime {
            // alertNotificationTopBanner.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {_ in
                UIView.animate(withDuration: 1, animations: {
                    self.alertBanner.frame.origin.y = 60
                }, completion:  {(finished: Bool) in
                    self.viewingForTheFirstTime = false
                } )
            })
            //play sound to get user attention to the error
            AudioServicesPlayAlertSound(systemSoundID)
        } else {
            //show warning without animating
            self.alertBanner.frame.origin.y = 60
        }
    }
    
    func bannerTimeout() {
        UIView.animate(withDuration: 1, animations: {
            //slide up the banner off the screen from top
            self.alertBanner.frame.origin.y -= self.alertBanner.bounds.height
        })
    }
    
    
    private func stopBannerTimer() {
        if bannerTimer != nil {
            bannerTimer.invalidate()
            bannerTimer = nil
        }
    }
    
    private func areAllFieldsPresent() -> Bool {
        var present: Bool = true
        
        if amountText.text == "" || checkNumberText.text == "" || dateText.text == "" {
            present = false
        }
        
        return present
    }
    
    private func showCheckQualityPopupView() {
        checkQualityPopupView.alpha = 0
        checkQualityPopupView.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.checkQualityPopupView.alpha = 1
        }, completion: nil)
        
    }
    
    private func hideCheckQualityPopupView() {
        //checkQualityPopupView.view.alpha = 1
        //checkQualityPopupView.isHidden = false
        UIView.animate(withDuration: 25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.checkQualityPopupView.alpha = 0
            self.checkQualityPopupView.isHidden = true
        }, completion: nil)
    }
    
    // MARK - Tap gesture callback
    
    @IBAction func onViewTapGesture(_ sender: UITapGestureRecognizer) {
        
        if checkQualityPopupView.isHidden == false {
            hideCheckQualityPopupView()
        }
        self.view.endEditing(true)
    }
    
    //MARK:
    
    @IBAction func onCheckQualityButtonClicked(_ sender: UIButton) {
        if checkIQAData != nil {
            showCheckQualityPopupView()
        }
    }


    // MARK : date picker methods
    
    func setupDatePicker() {
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton, doneButton], animated: false)
        
        // add toolbar to textField
        dateText.inputAccessoryView = toolbar
        // add datepicker to textField
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        dateText.inputView = datePicker
    }
    
    func doneDatePicker() {
        print("Done datepicker")
        
        let picker = self.dateText.inputView as! UIDatePicker
        self.dateText.text = Utility.dateToFormattedString(format: LongDateFormatWithNumericMonth, date: picker.date)
        
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    
    
    func cancelDatePicker() {
        print("Cancel datepicker")
        
        //dismiss date picker dialog
        self.view.endEditing(true)
    }

    
    private func clearScreenData() {
        self.stopBannerTimer()
        self.backProcessedImage = nil
        self.delegate = nil
        self.checkData = nil
        self.checkIQAData = nil
        self.waitIndicator = nil
        self.account = nil
    }
    
    
    
    
    // MARK: Scrollview and keyboard methods
    
    private var scrollViewYPos: CGFloat = 0
    private var activeField: UITextField! = nil
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /*  Function to shift scrollview up when keyboard appears
     Called when the UIKeyboardDidShowNotification is sent.
     */
    func keyboardWillBeShown(notification: NSNotification) {
        
        let info: NSDictionary = notification.userInfo! as NSDictionary
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        let contentInset: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 20, 0.0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        var rect: CGRect = self.view.frame
        rect.size.height -= (kbSize?.height)!
        if (activeField) != nil {
            if !rect.contains(activeField!.frame.origin) {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
    }
    
    /* Function to move scrollview to its initial position when keyboard disappears.
     Called when the UIKeyboardWillHideNotification is sent.
     */
    
    func keyboardWillBeHidden(notification: NSNotification) {
        
        // let info: NSDictionary = notification.userInfo! as NSDictionary
        //   let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        // let contentInset: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -(kbSize?.height)!, 0.0)
        var contentInset: UIEdgeInsets = UIEdgeInsets.zero
        contentInset.top += scrollViewYPos
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        //self.automaticallyAdjustsScrollViewInsets = false
    }
    
    // MARK: Textfield delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        textField.textColor = UIColor.init(rgb: 0x525054)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if its a last text fiel (done key), dismiss the keyboard
        dismissKeyboard()
        return true
    }

}
