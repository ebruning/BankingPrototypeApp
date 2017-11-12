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

class CheckDepositHomeViewController: BaseViewController {
    
    @IBOutlet weak var countryNameLabel: UILabel!
    
    @IBOutlet weak var frontContainerView: ViewShadow!
    
    @IBOutlet weak var frontInstructionLabel: UILabel!
    
    @IBOutlet weak var frontProcessedImageView: UIImageView!
    
    @IBOutlet weak var frontPageControl: UIPageControl!
    
    @IBOutlet weak var backContainerView: ViewShadow!
    
    @IBOutlet weak var backInstructionLabel: UILabel!
    
    @IBOutlet weak var backProcessedImageViewTop: UIImageView!

    @IBOutlet weak var backProcessedImageViewBottom: UIImageView!

    @IBOutlet weak var depositButton: UIButton!
    
    @IBOutlet weak var selectionOverlayVisualEffectView: UIVisualEffectView!
    
    
    //Post data retrieval parameters
    
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var payeeNameText: UITextField!
    @IBOutlet weak var checkNumberText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var larCarMatchImageView: UIImageView!
    
    @IBOutlet weak var checkDataFieldsContainerView: UIView!

    //Check quality related controls
    
    @IBOutlet weak var checkQualityCommandContainerView: UIView!
    
    @IBOutlet weak var checkQualityPopupView: CustomView!
    
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

    
    //Check quality alert banner related controls

    @IBOutlet weak var alertBanner: ViewShadow!
    
    //@IBOutlet weak var alertBannerLabel: UILabel!

    
    enum Direction {
        case RIGHT
        case LEFT
    }

    private lazy var overlayView: WaitIndicatorView! = {
        let overlayView = WaitIndicatorView()
        return overlayView
    }()

    
    //Mark: - Delegate
    var delegate: CheckDepositHomeViewControllerDelegate?
    
    var account: AccountsMaster?
    
    private var backProcessedImage: UIImage!
    
    private var frontProcessedImagePath: String!
    
    private var backProcessedImagePath: String!
    
    private var tapGestureRecognizerForFrontContainer: UITapGestureRecognizer!
    private var tapGestureRecognizerForBackContainer: UITapGestureRecognizer!
    
    private var frontContainerSwipeRightRecogizer: UISwipeGestureRecognizer! = nil
    private var frontContainerSwipeLeftRecogizer: UISwipeGestureRecognizer! = nil
    
    private var documentSide: DocumentSide = DocumentSide.FRONT
    
    private var checkData: kfxCheckData! = nil
    private var checkIQAData: kfxCheckIQAData! = nil

    //private var backProcessedImage: UIImage!
    
    //Check quality alert banner relatd variables
    private var bannerTimer: Timer! = nil
    // a sound ID
    private let systemSoundID: SystemSoundID = 1052

    private var viewingForTheFirstTime: Bool = true
    
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
        
        customizeNavigationBar()
        
        addTapGestureRecognizers()
        
        frontProcessedImageView.isHidden = true
        backProcessedImageViewTop.isHidden = true
        backProcessedImageViewBottom.isHidden = true

        frontPageControl.currentPage = 0
        
        //MARK: Feedback
        frontPageControl.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        customizeNavigationBar()
    }
    
    
    // MARK: private methods
    
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
    

    func onCancelPressed() {
        Utility.showAlertWithCallback(onViewController: self, titleString: "Abort", messageString: "This will cancel the check deposit process.\n\nDo you want to continue?", positiveActionTitle: "YES", negativeActionTitle: "NO", positiveActionResponse: {
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
    
    private func addTapGestureRecognizers() {
        addTapGestureRecognizerFront()
        addTapGestureRecognizerBack()
    }
    
    func addTapGestureRecognizerFront() {
        //add tap gesture recognizer to front container
        tapGestureRecognizerForFrontContainer = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapOnFrontContainer))
        
        frontContainerView.addGestureRecognizer(tapGestureRecognizerForFrontContainer)
        frontContainerView.isUserInteractionEnabled = true
    }

    func addTapGestureRecognizerBack() {
        //add tap gesture recognizer to back container
        tapGestureRecognizerForBackContainer = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapOnBackContainer))
        
        backContainerView.addGestureRecognizer(tapGestureRecognizerForBackContainer)
        backContainerView.isUserInteractionEnabled = true
    }
    
    private func removeTapGestureRecognizer(fromView: UIView, gestureRecognizer: UITapGestureRecognizer) {
        fromView.removeGestureRecognizer(gestureRecognizer)
    }
    
    private func hideOverlay() {
        selectionOverlayVisualEffectView.isHidden = true
        //show navigation on hiding overlay
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func showOverlay() {
        //hide navigation bar on showing overlay
        navigationController?.setNavigationBarHidden(true, animated: false)
        selectionOverlayVisualEffectView.isHidden = false
    }
    
    // MARK: TapGesture recognizer callbacks
    
    func handleTapOnFrontContainer(_ sender: UITapGestureRecognizer) {
        print("Enter: handleTapOnFrontContainer")
        
        documentSide = DocumentSide.FRONT
        showOverlay()
    }
    
    func handleTapOnBackContainer(_ sender: UITapGestureRecognizer) {
        print("Enter: handleTapOnBackContainer")
        
        documentSide = DocumentSide.BACK
        showOverlay()
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
                frontInstructionLabel.isHidden = true   //MARK: Feedback
            }
            //frontContainerView.removeGestureRecognizer(tapGestureRecognizerForFrontContainer)
            removeTapGestureRecognizer(fromView: frontContainerView, gestureRecognizer: tapGestureRecognizerForFrontContainer)
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
            else {
                //Using full sized processed image instead of scaled image here
                if backProcessedImageViewBottom.image == nil {
                    self.backProcessedImage = image.getBitmap()
                    backProcessedImageViewBottom.image = image.getBitmap()
                    backProcessedImageViewBottom.isHidden = false
                    backInstructionLabel.isHidden = true    //MARK: Feedback

                    removeTapGestureRecognizer(fromView: backContainerView, gestureRecognizer: tapGestureRecognizerForBackContainer)
                } else {
                    backProcessedImageViewTop.image = backProcessedImage //backProcessedImageViewBottom.image
                    self.backProcessedImage = nil
                    //backProcessedImageViewTop.isHidden = false
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
            self.addTapGestureRecognizerFront()
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
            self.backContainerView.isHidden = false
            
            self.addTapGestureRecognizerBack()
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
            self.overlayView.displayView(onView: self.view)
        }
    }
    
    private func hideWaitIndicator() {
        DispatchQueue.main.async {
            self.overlayView.hideView()
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
        
        self.checkQualityCommandContainerView.isHidden = false
        
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
    
    private func resizeImage(image: UIImage!, newWidth: CGFloat) -> UIImage! {
        if (image == nil) {
            return nil
        }
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize.init(width: newWidth, height: newHeight))
        image.draw(in:(CGRect.init(x: 0, y: 0, width: newWidth, height: newHeight)))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
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
    
    
    private func addCheckDetailsToPersistentStorage(data: kfxCheckData) {
        //save to persistent storage
        let checkTransaction = CheckTransactions(context: context)
        checkTransaction.payee = data.payeeName.value
        checkTransaction.accountNumber = account?.accountNumber
        checkTransaction.amount = Double(data.amount.value)!
        checkTransaction.comment = "Check with number - \(data.checkNumber.value!) deposited"
        checkTransaction.checkNumber = data.checkNumber.value
        checkTransaction.paymentDate = Utility.convertStringToDate(format: LongDateFormatWithNumericMonth, dateStr: data.date.value)! as NSDate
        
        print("Formatted date from sring ==>\(Utility.convertStringToDate(format: LongDateFormatWithNumericMonth, dateStr: data.date.value)!))")
        
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
            Utility.showAlert(onViewController: self, titleString: "Check Data Empty", messageString: "Both sides of the check required to deposit the check.")
            return
        }

            self.addCheckDetailsToPersistentStorage(data: self.checkData)
            
        Utility.showAlertWithCallback(onViewController: self, titleString: "Check is deposited", messageString: "The amount will reflect in your account once the check is processed.", positiveActionTitle: "OK", negativeActionTitle: nil, positiveActionResponse: {
            self.clearScreenData()
            
            self.delegate?.checkDeposited()

            self.restoreNavigationBar()
            
            //close this viewcontroller
            self.navigationController?.popViewController(animated: true)

        }, negativeActionResponse: {
        
        })
    }

    @IBAction func onCameraOptionClicked(_ sender: UIButton) {
        delegate?.showCamera(side: documentSide)
        hideOverlay()
    }

    @IBAction func onGalleryOptionClicked(_ sender: UIButton) {
        delegate?.showGallery(side: documentSide)
        hideOverlay()
    }
    
    @IBAction func closeOverlay(_ sender: UIButton) {
        hideOverlay()
    }

    
    
    //MARK: Post check-data retrieval methods (merged from CheckDataPreviewController. Deleted the CheckDataPreviewController screen.)
    
    private func displayFieldData() {
        
        if checkData != nil {

            checkDataFieldsContainerView.isHidden = false
            
            amountText.text = checkData.amount.value
            payeeNameText.text = checkData.payeeName.value
            checkNumberText.text = checkData.checkNumber.value
            //carText.text = checkData.car.value
            //larText.text = checkData.lar.value
            
            if checkData.car.value == checkData.lar.value {
                larCarMatchImageView.image = UIImage(named: "checkmark_green_50")
            } else {
                larCarMatchImageView.image = UIImage(named:"cross_red_50")
            }
            larCarMatchImageView.isHidden = false
            
            //validate date before displaying
            // TODO: may have to change the date format based on the country.
            if Utility.validateDate(format: LongDateFormatWithNumericMonth, dateStr: checkData.date.value) == true {
                dateText.text = checkData.date.value
            } else {
                dateText.text = ""
            }
            
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
    
    //TODO: call this method while closing screen
    
    private func stopBannerTimer() {
        if bannerTimer != nil {
            bannerTimer.invalidate()
            bannerTimer = nil
        }
    }
    
    private func areAllFieldsPresent() -> Bool {
        var present: Bool = true
        
        if amountText.text == "" || payeeNameText.text == "" || checkNumberText.text == "" || dateText.text == "" {
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
    
    @IBAction func onCheckQualityLabelTapGesture(_ sender: UITapGestureRecognizer) {
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
        self.backProcessedImage = nil
        self.delegate = nil
        self.checkData = nil
        self.checkIQAData = nil
        self.overlayView = nil
        self.account = nil
    }
}
