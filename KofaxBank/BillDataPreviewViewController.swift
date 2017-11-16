//
//  BillDataPreviewViewController.swift
//  KofaxBank
//
//  Created by Rupali on 25/07/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData

protocol BillDataPreviewDelegate {
    func billPreviewOnDataSaved(data: kfxBillData)
    func billPreviewOnCancelData()
}

class BillDataPreviewViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageContainerView: ViewShadow!
    
    @IBOutlet weak var imagePlaceholderLabel: UILabel!
    
    @IBOutlet weak var rawImageView: UIImageView!
    
    @IBOutlet weak var processedImageView: UIImageView!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var accountNumberTextField: UITextField!
    
    @IBOutlet weak var dueDateTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var address1TextField: UITextField!
    
    @IBOutlet weak var address2TextField: UITextField!
    
    @IBOutlet weak var cityTextField: UITextField!
    
    @IBOutlet weak var stateTextField: UITextField!
    
    @IBOutlet weak var zipTextField: UITextField!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var payBillButton: UIButton!

    
    //MARK - Public variables
    var rawImagePath: String! = nil
    
    var processedImagePath: String! = nil
    
    var billData: kfxBillData? = nil
    
    var account: AccountsMaster?

    //Mark: - Delegate
    
    var delegate: BillDataPreviewDelegate?

    //MARK: - Private variables

    private var wasNavigationHidden: Bool = false
    private var oldBarTintColor: UIColor!
    private var oldStatusBarStyle: UIStatusBarStyle!

    private lazy var waitIndicator: WaitIndicatorView! = {
        let waitIndicator = WaitIndicatorView()
        return waitIndicator
    }()
    
    private var swipeRightRecogizer: UISwipeGestureRecognizer! = nil
    
    private var swipeLeftRecogizer: UISwipeGestureRecognizer! = nil

    private let scrollContentInset: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 200, 0.0)
    
    //MARK: statusbar content color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        customizeScreenControls()

        customizeNavigationBar()
        
        rawImageView.isHidden = true
        processedImageView.isHidden = true
        imagePlaceholderLabel.isHidden = false
        
        scrollView.contentInset = scrollContentInset
        scrollView.scrollIndicatorInsets = scrollContentInset
        
        showWaitIndicator()
        
        registerForKeyboardNotifications()
        
        //displayRawImagePreview()
        
        pageControl.isHidden = true
    }

    // MARK: Public mathods
    
    func rawImageReady() {
//        displayRawImagePreview()
    }
    
    func processedImageReady() {
        DispatchQueue.main.async {
            self.displayProcessedImagePreview()
            //self.addSwipeGestureListeners()
            //self.pageControl.isHidden = false
        }
    }

    func billDataNotAvailable(err: AppError!) {
        var alertTitle: String! = ""
        var alertMessage: String! = ""
        
        
        if err != nil {
            if err.title != nil {
                alertTitle = err.title
            }
            
            if err.message != nil {
                alertMessage = err.message
            }
        }
        hideWaitIndicator()
        DispatchQueue.main.async {
            self.hideWaitIndicator()
            Utility.showAlert(onViewController: self, titleString: alertTitle, messageString: alertMessage)
        }
    }
    
    
    func billDataAvailable(billData: kfxBillData) {
        self.billData = billData
        self.hideWaitIndicator()
        self.showBillData()
    }
    
    
    // MARK: - Private Methods

    private func clear() {
        if imageContainerView != nil {
            if swipeLeftRecogizer != nil {
                imageContainerView.removeGestureRecognizer(swipeLeftRecogizer)
            }
            if swipeRightRecogizer != nil {
                imageContainerView.removeGestureRecognizer(swipeRightRecogizer)
            }
        }
        
        swipeLeftRecogizer = nil
        swipeRightRecogizer = nil
        
        rawImagePath = nil
        processedImagePath = nil
        
        self.billData = nil
        self.account = nil
        self.delegate = nil
    }
    
    private func displayRawImagePreview() {
        if rawImagePath != nil {
            displayImage(toImageView: rawImageView, fromFileContent: rawImagePath)
            rawImageView.isHidden = false
            imagePlaceholderLabel.isHidden = true
        }
    }
    
    private func displayProcessedImagePreview() {
        if processedImagePath != nil {
            displayImage(toImageView: processedImageView, fromFileContent: processedImagePath)
            processedImageView.isHidden = false
            //TODO: temp code. if only processed image should be shown
            imagePlaceholderLabel.isHidden = true
            //pageControl.currentPage = 0
        }
    }
    
    private func displayImage(toImageView: UIImageView, fromFileContent: String) {
        let image = UIImage.init(contentsOfFile: fromFileContent)
        if image != nil {
            let scaledImg = resizeImage(image: image, newWidth: processedImageView.bounds.width)
            toImageView.image = scaledImg
        }
    }
    
    
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

    
    private func showBillData() {
        DispatchQueue.main.async {
            
            if self.billData != nil {
                print("\n\nAmount => \(self.billData!.amount.value)")
                print("AccountNumber => \(self.billData!.accountNumber.value)")
                print("dueDate => \(self.billData!.dueDate.value)")
                print("Name => \(self.billData!.name.value)")
                print("phoneNumber => \(self.billData!.phoneNumber.value)")
                print("addressLine1 => \(self.billData!.addressLine1.value)")
                print("addressLine2 => \(self.billData!.addressLine2.value)")
                print("city => \(self.billData!.city.value)")
                print("state = >\(self.billData!.state.value)")
                print("zip => \(self.billData!.zip.value)")

                self.amountTextField.text = self.billData!.amount.value
                self.accountNumberTextField.text = self.billData!.accountNumber.value
                self.dueDateTextField.text = self.billData!.dueDate.value
                self.nameTextField.text = self.billData!.name.value
                self.phoneNumberTextField.text = self.billData!.phoneNumber.value
                self.address1TextField.text = self.billData!.addressLine1.value
                self.address2TextField.text = self.billData!.addressLine2.value
                self.cityTextField.text = self.billData!.city.value
                self.stateTextField.text = self.billData!.state.value
                self.zipTextField.text = self.billData!.zip.value
            }
        }
    }
    
   
    private func showWaitIndicator() {
        DispatchQueue.main.async {
            self.waitIndicator.displayView(onView: self.view)
        }
    }
    
    private func hideWaitIndicator() {
        DispatchQueue.main.async {
            self.waitIndicator.hideView()
        }
    }

    
    // MARK: - Navigationbar methods

    private func customizeScreenControls() {
        let buttonStyler = AppStyleManager.sharedInstance().get_button_styler()
        
        //payBillButton.backgroundColor = screenStyler?.get_accent_color()
        payBillButton = buttonStyler?.configure_primary_button(payBillButton)
    }
    
    
    private func customizeNavigationBar() {
        navigationController?.navigationBar.topItem?.title = "Bill Information"
        
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
    
    //Mark: Navigation button actions
    
    func onCancelPressed() {

        Utility.showAlertWithCallback(onViewController: self, titleString: "Abort", messageString: "This will cancel the process of bill payment.\n\nDo you want to continue?", positiveActionTitle: "YES", negativeActionTitle: "NO", positiveActionResponse: {
            print("Positive response selected")

            self.delegate?.billPreviewOnCancelData()

            self.account = nil

            //self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: {
                self.clear()
                self.restoreNavigationBar()
            })
        }, negativeActionResponse: {
            print("Negative response selected")
        })
    }

    let isNewBiller: Bool = true
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        print("Save button clicked.......")
        
        if saveData() {
            account = nil
            
            if isNewBiller {
                Utility.showAlertWithCallback(onViewController: self, titleString: "Bill Paid", messageString: "Bill is paid.\n\nA new biller is detected.\n\nDo you want to save this biller for future transactions?", positiveActionTitle: "Save", negativeActionTitle: "Don't Save", positiveActionResponse: {

                    self.saveBiller(billData: self.billData!)
                    
                    Utility.showAlertWithCallback(onViewController: self, titleString: "Biller Saved", messageString: "You can make future payments without scanning the coupon for this biller.", positiveActionTitle: "OK", negativeActionTitle: nil, positiveActionResponse: {
                        self.delegate?.billPreviewOnDataSaved(data: self.billData!)
                        
                        //close screen
                        //self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: {
                            self.clear()
                            self.restoreNavigationBar()
                        })
                    }, negativeActionResponse: {
                    
                    })

                }, negativeActionResponse: {
                    
                    self.delegate?.billPreviewOnDataSaved(data: self.billData!)
                    
                    //close screen
                    //self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: {
                        self.clear()
                        self.restoreNavigationBar()
                    })
                })
            }
            
        }
    }
    
    private func saveBiller(billData: kfxBillData) {
    //    var fetchRequest: NSFetchRequest<BillerMaster>! = BillerMaster.fetchRequest()
        //TODO: add condition for pending card

            let newBiller = BillerMaster(context: context)
            newBiller.name = billData.name.value

            //save biller
            ad.saveContext()
    }
    
    
    private func saveData() -> Bool{

        var saved: Bool = false
        
        if !areRequiredFieldsPresent() {
            return saved
        }

        if let amountStr = amountTextField.text {
            let amt = Double(amountStr)
            
            if isAccountBalanceSufficient(amount: amt!) {
                
                //reload the billData object first
                
                if self.billData == nil {
                    self.billData = kfxBillData()
                }
                
                if (self.billData?.amount == nil) {
                    self.billData?.amount = kfxDataField()
                }
                self.billData?.amount.value = amountTextField.text
                
                if (self.billData?.name == nil) {
                    self.billData?.name = kfxDataField()
                }
                self.billData?.name.value = nameTextField.text

                if (self.billData?.accountNumber == nil) {
                    self.billData?.accountNumber = kfxDataField()
                }
                self.billData?.accountNumber.value = accountNumberTextField.text
                
                if (self.billData?.addressLine1 == nil) {
                    self.billData?.addressLine1 = kfxDataField()
                }
                self.billData?.addressLine1.value = address1TextField.text

                if (self.billData?.addressLine2 == nil) {
                    self.billData?.addressLine2 = kfxDataField()
                }
                self.billData?.addressLine2.value = address2TextField.text

                if (self.billData?.city == nil) {
                    self.billData?.city = kfxDataField()
                }
                self.billData?.city.value = cityTextField.text
                
                if (self.billData?.state == nil) {
                    self.billData?.state = kfxDataField()
                }
                self.billData?.state.value = stateTextField.text
                
                if (self.billData?.zip == nil) {
                    self.billData?.zip = kfxDataField()
                }
                self.billData?.zip.value = zipTextField.text

                if (self.billData?.phoneNumber == nil) {
                    self.billData?.phoneNumber = kfxDataField()
                }
                self.billData?.phoneNumber.value = phoneNumberTextField.text


                //create BillTransaction coreData object
                let billTransaction = BillTransactions(context: context)

                billTransaction.amountDue = amt!
                billTransaction.comment = "Bill paid - \(nameTextField.text!)"
                billTransaction.name = nameTextField.text  //TODO: take payee name from extracted data.

                billTransaction.accountNumber = accountNumberTextField.text
                billTransaction.addressLine1 = address1TextField.text
                billTransaction.addressLine2 = address2TextField.text

                billTransaction.city = cityTextField.text
                billTransaction.state = stateTextField.text
                billTransaction.zip = zipTextField.text
                billTransaction.phoneNumber = phoneNumberTextField.text

                let transactionMaster = AccountTransactionMaster(context: context)
                transactionMaster.account = account
                transactionMaster.dateOfTransaction = Date() as NSDate
                transactionMaster.type = TransactionType.DEBIT.rawValue
                transactionMaster.billTransaction = billTransaction

                account?.balance = account!.balance - amt!

                //save bill data
                ad.saveContext()
                saved = true
            }
        }
        
        return saved
    }
    
    private func areRequiredFieldsPresent() -> Bool {
        var present: Bool = true
        
        if amountTextField.text == "" || accountNumberTextField.text == "" || nameTextField.text == "" {
            present = false
            
            Utility.showAlert(onViewController: self, titleString: "Empty Fields", messageString: "Amount, Account Number and Name should not be empty.")
        }

        return present
    }

    private func isAccountBalanceSufficient(amount: Double) -> Bool {
        
        var isSufficient: Bool = true
        
        if account!.balance - amount < 0 {
            Utility.showAlert(onViewController: self, titleString: "Insufficient Balance", messageString: "Make sure your account has enough balance to pay the bill.")
            isSufficient = false
        }

        return isSufficient
    }
    
    
    
    //Mark: tap gesture callback

    @IBAction func onViewTapGesture(_ sender: UITapGestureRecognizer) {
        mainView.endEditing(true)
    }
    
    // MARK: SwipeGestureRecognizer methods
    
    private func addSwipeGestureListeners() {
        // add swipe-left recognizer
        if swipeLeftRecogizer == nil {
            swipeLeftRecogizer = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeLeftRecogizer.direction = UISwipeGestureRecognizerDirection.left
        }
        imageContainerView.addGestureRecognizer(swipeLeftRecogizer)
        
        // add swipe-right recognizer
        if swipeRightRecogizer == nil {
            swipeRightRecogizer = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeRightRecogizer.direction = UISwipeGestureRecognizerDirection.right
        }
        imageContainerView.addGestureRecognizer(swipeRightRecogizer)
    }
    
    private func removeSwipeGestureRecognizers() {
        if imageContainerView.gestureRecognizers != nil && swipeLeftRecogizer != nil {
            imageContainerView.removeGestureRecognizer(swipeLeftRecogizer)
            imageContainerView.removeGestureRecognizer(swipeRightRecogizer)
        }
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swipe Right...")
                showPrevious()
                
                pageControl.currentPage = 0
            case UISwipeGestureRecognizerDirection.left:
                print("Swipe Left...")
                pageControl.currentPage = 1
                showNext()
            default:
                break
            }
        }
    }
    
    func showNext() {
        if processedImageView.isHidden {
            processedImageView.isHidden = false
            rawImageView.isHidden = true
        }
    }
    
    func showPrevious() {
        if rawImageView.isHidden {
            rawImageView.isHidden = false
            processedImageView.isHidden = true
        }
    }

    // MARK: Scrollview and keyboard methods
    
    //override var automaticallyAdjustsScrollViewInsets: Bool = true
    
    private var scrollViewYPos: CGFloat = 70
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
        
        let contentInset: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, (kbSize?.height)! + 50, 0.0)
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
        scrollView.contentInset = scrollContentInset
        scrollView.scrollIndicatorInsets = scrollContentInset
        
        self.automaticallyAdjustsScrollViewInsets = true
    }
    
    
    
    
    // MARK: Textfield delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
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
