//
//  CreditCardDataPreviewViewController.swift
//  KofaxBank
//
//  Created by Rupali on 31/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData

protocol CreditCardDataPreviewDelegate {
    func creditCardOnDataSaved(data: kfxCreditCardData)
    func creditCardOnCancelData()
}


class CreditCardDataPreviewViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageContainerView: ViewShadow!
    
    @IBOutlet weak var imagePlaceholderLabel: UILabel!

    @IBOutlet weak var rawImageView: UIImageView!

    @IBOutlet weak var processedImageView: UIImageView!
    
    @IBOutlet weak var cardNumberTextField: UITextField!
    
    @IBOutlet weak var expMonthTextField: UITextField!
    
    @IBOutlet weak var expYearTextField: UITextField!

    @IBOutlet weak var companyTextField: UITextField!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var activateButton: UIButton!


    //MARK - Public variables
    
    var rawImagePath: String! = nil
    
    var processedImagePath: String! = nil

    var cardData: kfxCreditCardData! = nil

    //TODO: Temp variable
    private var cardCompanyField: kfxDataField?
    
    //Mark: - Delegate

    var delegate: CreditCardDataPreviewDelegate?
    

    //MARK: - Private variables
    
    private var wasNavigationHidden: Bool = false
    private var oldBarTintColor: UIColor!
    private var oldStatusBarStyle: UIStatusBarStyle!

    private lazy var waitIndicator: WaitIndicatorView! = {
        let waitIndicator = WaitIndicatorView()
        return waitIndicator
    }()
    
    private var cardkData: kfxCreditCardData! = nil
    
    private var swipeRightRecogizer: UISwipeGestureRecognizer! = nil

    private var swipeLeftRecogizer: UISwipeGestureRecognizer! = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()

        customizeNavigationBar()

        rawImageView.isHidden = true
        processedImageView.isHidden = true
        imagePlaceholderLabel.isHidden = false

        showWaitIndicator()
        
        registerForKeyboardNotifications()

        //self.automaticallyAdjustsScrollViewInsets = false

        rawImageReady()
    }
    
    // MARK: Public mathods

    func rawImageReady() {
       // displayRawImagePreview()
    }

    func processedImageReady() {
        DispatchQueue.main.async {
            self.displayProcessedImagePreview()
         //   self.addSwipeGestureListeners()
        }
    }
    
    func cardDataNotAvailable(err: AppError!) {
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
        
        DispatchQueue.main.async {
            //disable activation button
            self.activateButton.isUserInteractionEnabled = false
            
            self.hideWaitIndicator()

            self.hideWaitIndicator()
            Utility.showAlert(onViewController: self, titleString: alertTitle, messageString: alertMessage)
        }
    }
    
    
    func cardDataAvailable(cardData: kfxCreditCardData, company: kfxDataField!) {
        self.cardData = cardData
        self.cardCompanyField = company
        self.hideWaitIndicator()
        self.showCardData()
    }


    // MARK: Private mathods

    
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
            
            //TODO: temp code. if only processed image should be shown
            imagePlaceholderLabel.isHidden = true
            rawImageView.isHidden = true
            processedImageView.isHidden = false
            pageControl.isHidden = true
        }
    }
    
    private func displayImage(toImageView: UIImageView, fromFileContent: String) {
        var image = UIImage.init(contentsOfFile: fromFileContent)
        if image != nil {
            let scaledImg = resizeImage(image: image, newWidth: toImageView.bounds.width)
            toImageView.image = scaledImg
            image = nil
        }
    }
    
    //TODO: This is a common function across multiple files. put it in a single place
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
    
    // MARK: - Navigationbar methods
    
    private func customizeScreenControls() {
        let buttonStyler = AppStyleManager.sharedInstance().get_button_styler()
        
        activateButton = buttonStyler?.configure_primary_button(activateButton)
    }

    
    private func customizeNavigationBar() {
        
        //navigationController?.navigationBar.topItem?.title = "Supplementary Card"
        
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
        //self.navigationController?.popViewController(animated: true)
        Utility.showAlertWithCallback(onViewController: self, titleString: "Abort", messageString: "This will cancel the process of adding supplementary card.\n\nDo you want to continue?", positiveActionTitle: "YES", negativeActionTitle: "NO", positiveActionResponse: {
            print("Positive response selected")

            self.dismiss(animated: true, completion: {
                self.restoreNavigationBar()
            })

        }, negativeActionResponse: {
            print("Negative response selected")
        })
    }
    
    // MARK: GestureRecognizer callback
    
    @IBAction func onScreenTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    // MARK: - Private methods
    
    private func showCardData() {
        DispatchQueue.main.async {
            if self.cardData != nil {
//                if self.cardData.name != nil, let fieldValue = self.cardData.name.value {
//                    self.cardHolderNameTextField.text = fieldValue.trimmingCharacters(in: NSCharacterSet.whitespaces)
//                }
                if self.cardData.cardNumber != nil, let fieldValue = self.cardData.cardNumber.value {
                    self.cardNumberTextField.text = fieldValue.trimmingCharacters(in: .whitespaces)
                }
                if self.cardData.expirationMonth != nil, let fieldValue = self.cardData.expirationMonth.value {
                    self.expMonthTextField.text = fieldValue
                }
                else {
                    //self.expMonthTextField.text = "9"
                }
 
                if self.cardData.expirationYear != nil, let fieldValue = self.cardData.expirationYear.value {
                    self.expYearTextField.text = fieldValue.trimmingCharacters(in: .whitespaces)
                }
                else {
                    //self.expYearTextField.text = "17"
                }

                if self.companyTextField != nil && self.cardCompanyField?.value != nil {
                    self.companyTextField.text = self.cardCompanyField?.value
                }

/*                if self.cardData.cvv != nil, let fieldValue = self.cardData.cvv.value {
                    self.cvvTextField.text = fieldValue
                    //self.cvvTextField.text = "123"
                }
                else {
                    //self.cvvTextField.text = "123"
                }
*/
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

    
    // MARK - Navigation button actions
    
    @IBAction func submitForValidation(_ sender: CustomButton) {
        print("Done button clicked.......")
        let saved = saveData()
        if saved {
            //close screen
            delegate?.creditCardOnDataSaved(data: cardData)
            //self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: {
                self.restoreNavigationBar()
            })
        }
    }
    
    // MARK: - Private methods

    private func saveData() -> Bool {
        var isSaved: Bool! = false
        if areAllFieldsPresent() == true {
            if cardData == nil {
                cardData = kfxCreditCardData.init()
            }
//            cardData.name.value = cardHolderNameTextField.text
            cardData.cardNumber.value = cardNumberTextField.text
            cardData.expirationMonth.value = expMonthTextField.text
            cardData.expirationYear.value = expYearTextField.text
            
            var fetchRequest: NSFetchRequest<CreditCardMaster>! = CreditCardMaster.fetchRequest()
            //TODO: add condition for active card
            do {
                var cards = try context.fetch(fetchRequest)
                let newCard = cards[0]
                //newCard.availableBalance = 0
//                newCard.cardHolderName = cardHolderNameTextField.text //UserDefaults.standard.value(forKey: "applicationUserName") as? String
                newCard.cardNumber = cardNumberTextField.text
                
                if cardCompanyField != nil && cardCompanyField?.value != nil {
                    newCard.company = cardCompanyField?.value
                } else {
                    newCard.company = ""
                }
                
                //newCard.creditLimit = 0.0
                //newCard.dueAmount = 0.0
                newCard.cardStatus = STATUS_ACTIVE
                newCard.expDate = Utility.convertStringToDate(format: ShortDateFormatWithoutDay, dateStr: expMonthTextField.text! + "-" + expYearTextField.text!) as NSDate
                
                //save card
                ad.saveContext()
                
                isSaved = true
                //cards.removeAll()
            } catch {
                Utility.showAlert(onViewController: self, titleString: "Error", messageString: "Failed to save data.")
                let error = error as NSError
                print("\(error)")
            }

            fetchRequest = nil
        } else {
            Utility.showAlert(onViewController: self, titleString: "Empty Fields", messageString: "All the fields are required to save data.")
        }
        return isSaved
    }
    
    
    private func areAllFieldsPresent() -> Bool {
        var present: Bool = true
        
        if cardNumberTextField.text == "" || expMonthTextField.text == "" || expYearTextField.text == "" {
            present = false
        }
        
        return present
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
        
        let contentInset: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, (kbSize?.height)!, 0.0)
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
