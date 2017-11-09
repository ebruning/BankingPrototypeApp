//
//  IDHomeVC.swift
//  KofaxBank
//
//  Created by Rupali on 03/10/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

protocol IDHomeVCDelegate {
    func authenticateWithSelfie()
    func onIDHomeDoneWithData(idData: kfxIDData)
    func onIDHomeDoneWithoutData()
    func onIDHomeCancel()
}

 class IDHomeVC: UITableViewController {

    @IBOutlet weak var warningContainer: UIView!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var warningIcon: UIImageView!

    @IBOutlet weak var frontImageView: UIImageView!
    
    @IBOutlet weak var backImageTableRow: UITableViewCell!
    
    @IBOutlet weak var backImageView: UIImageView!

    @IBOutlet weak var backImagePreviewLabel: UILabel!
    @IBOutlet weak var authenticateButton: CustomButton!

    @IBOutlet weak var waitIndicatorContainerVaiw: UIView!

    @IBOutlet weak var idNumberField: UITextField!
    
    @IBOutlet weak var firstNameField: UITextField!

    //@IBOutlet weak var v: UIView!
    
    @IBOutlet weak var viewMoreButton: UIButton!
    
    private var _frontImageFilePath: String!
    
    private var _backImageFilePath: String!
    
    private var idData: kfxIDData!
    
    private var displayMore = false
    
    private var dataReadInProgress = false


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
        
        customizeNavigationBar()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
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
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func idDataNotAvailable(err: AppError!) {
        var alertTitle: String! = ""
        var alertMessage: String! = ""
        
        dataReadInProgress = false
        
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
            
            self.tableView.reloadData()
            
            Utility.showAlert(onViewController: self, titleString: alertTitle, messageString: alertMessage)
        }
    }
    
    func idDataAvailable(idData: kfxIDData) {
        self.idData = idData
        
        dataReadInProgress = false
        
        DispatchQueue.main.async {
            if authenticationResultModel == nil {
            self.updateNavigationButtonItems()
            } else {
                authenticateButton.
            }
            
            self.tableView.reloadData()

            self.displayDataFields()
            
            self.viewMoreButton.isHidden = false
            
            if self.shouldAuthenticateWithSelfie() {
                self.authenticateButton.isHidden = false
            }
            self.waitIndicatorContainerVaiw.isHidden = true
            if self.authenticationResultModel != nil {
                self.updateWarningLabel(verificationStatus: self.authenticationResultModel.authenticationResult)
            }
            
        }
    }


    //MARK: TableView Methods
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight: CGFloat = 70
        
        switch indexPath.row {
        
        case 0:
            if authenticationResultModel == nil {
                rowHeight = 0
            }
            break
        case 1:
            rowHeight = 150
            break
            
        case 2:
            if backImageFilePath == nil || backImageFilePath.characters.count == 0 {
                rowHeight = 0
            } else {
                rowHeight = 150
            }
            break
            
        case 3:
            if !dataReadInProgress {
                if(idData != nil && shouldAuthenticateWithSelfie() == true) {
                    rowHeight = 70
                } else {
                rowHeight = 0
            }
            }
            break

        default:
            // if not data available, no dot display fields rows and 'view more' option
            if indexPath.row != 1 && idData == nil {
                rowHeight = 0
            }
            break
        }
        return rowHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //show ID Data viewcontroller when tapped on any fields row of table (not the rows containing images)
        if indexPath.row > 3 {
            displayIDDataViewControllerScreen()
        }
    }
    
    
    //MARK: Private methods

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

    
    private func updateNavigationButtonItems() {
        let rightBarButtonItem = UIBarButtonItem.init(title: "Done", style: .plain, target: self, action: #selector(onDoneButtonClick))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
//        let newBackButton = UIBarButtonItem.init(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onCancelButtonClick))
//        
//        self.navigationItem.leftBarButtonItem = newBackButton
    }

    func onDoneButtonClick() {
        if idData != nil {
            delegate?.onIDHomeDoneWithData(idData: idData)
        } else {
            delegate?.onIDHomeDoneWithoutData()
        }
    }

    private func shouldAuthenticateWithSelfie() -> Bool {
        var shouldAuthenticate = false
        let mobileIDVersion = UserDefaults.standard.value(forKey: KEY_ID_MOBILE_ID_VERSION) as! String
        
        if mobileIDVersion == ServerVersion.VERSION_2X.rawValue {
            shouldAuthenticate = true
        }
        
        return shouldAuthenticate
        
    }

    private func updateWarningLabel(verificationStatus: String!) {
        if verificationStatus == nil {
            warningContainer.isHidden = true
        } else {
            warningContainer.isHidden = false
            if verificationStatus.caseInsensitiveCompare("FAILED") == ComparisonResult.orderedSame {
                warningContainer.backgroundColor = UIColor.red
                warningLabel.text = "DOCUMENT IS INVALID"
                warningIcon.image = UIImage(named: "warning")
            } else if verificationStatus.caseInsensitiveCompare("Attention") == ComparisonResult.orderedSame {
                warningContainer.backgroundColor = UIColor.orange
                warningLabel.text = "DOCUMENT APPEARS TO BE AUTHENTIC, BUT NEEDS ATTENTION"
                warningIcon.image = UIImage(named: "warning")
            } else if verificationStatus.caseInsensitiveCompare("Passed") == ComparisonResult.orderedSame {
                warningContainer.backgroundColor = UIColor.green
                warningLabel.text = "DOCUMENT IS VERIFIED"
                warningIcon.image = UIImage(named: "checkmark_yellow")
            }
        }
    }
    
    
    func onCancelButtonClick() {
        Utility.showAlertWithCallback(onViewController: self, titleString: "Abort", messageString: "This will cancel the ID Authentication process.\n\nDo you want to continue?", positiveActionTitle: "YES", negativeActionTitle: "NO", positiveActionResponse: {
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
            displayImage(toImageView: backImageView, fromFileContent: _backImageFilePath)
            self.tableView.reloadData()
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
    
    //TODO: This is a common function across multiple files. put it in a single place
    private func resizeImage(image: UIImage!, newWidth: CGFloat) -> UIImage! {
        
        if image == nil {
            return nil
        }
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize.init(width: newWidth, height: newHeight))
        image.drawAsPattern(in: CGRect.init(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private func displayDataFields() {
        guard let data = idData else { return  }
        
        self.displayTextFields(data: data)
    }

    private func displayTextFields(data: kfxIDData) {
        
        idNumberField.text = data.idNumber.value
        
        firstNameField.text = data.firstName.value
        
        if displayMore == false {
           // return
        }
/*
        middleNameField.text = data.middleName.value
        
        lastNameField.text = data.lastName.value
        
        addressField.text = data.address.value
        
        cityField.text = data.city.value
        
        stateField.text = data.state.value
        
        zipField.text = data.zip.value
        
        countryField.text = data.country.value
        
        dobField.text = data.dateOfBirth.value
        
        genderField.text = data.gender.value
        
        eyesField.text = data.eyes.value
        
        hairField.text = data.eyes.value
        
        heightField.text = data.height.value
        
        weightField.text = data.weight.value
        
        nationalityField.text = data.nationality.value
        
        //classField.text = data.c
        
        countryShortField.text = data.countryShort.value
        
        issueDateField.text = data.issueDate.value
        
        expDateField.text = data.expirationDate.value
        
        barcodeReadField.text = data.isBarcodeRead == true ? "Yes" : "No"
        
        ocrReadField.text = data.isOcrRead == true ? "Yes" : "No"
        
        idVerificationField.text = data.isIDVerified == true ? "Yes" : "No"
        
        //productVersionField.text = data
        
        confidenceRatingField.text = String.init(format: "%2.0",  data.documentVerificationConfidenceRating)
 */
    }
    
    
    //MARK: Command button action
    
    @IBAction func viewMoreFields(_ sender: UIButton) {
        displayIDDataViewControllerScreen()
    }
    
    private func displayIDDataViewControllerScreen() {
        displayMore = !displayMore
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "IDDataView") as! IDDataViewController
        vc.idData = self.idData
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func onAuthenticateButtonClicked(_ sender: UIButton) {
//        let vc = SelfieCaptureExprienceViewController(nibName: "SelfieCaptureExprienceViewController", bundle: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
        
        delegate?.authenticateWithSelfie()
    }
}
