//
//  IDDataViewController.swift
//  KofaxBank
//
//  Created by Rupali on 27/10/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

protocol  IDDataViewControllerDelegate {
    func IDDataSaved(idData: kfxIDData)
}
class IDDataViewController: UITableViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var singatureImage: UIImageView!
    
    @IBOutlet weak var idNumberField: UITextField!
    
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var middleNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBOutlet weak var addressField: UITextField!
    
    @IBOutlet weak var cityField: UITextField!
    
    @IBOutlet weak var stateField: UITextField!
    
    @IBOutlet weak var zipField: UITextField!
    
    @IBOutlet weak var countryField: UITextField!
    
    @IBOutlet weak var dobField: UITextField!
    
    @IBOutlet weak var genderField: UITextField!
    
    @IBOutlet weak var eyesField: UITextField!
    
    @IBOutlet weak var hairField: UITextField!
    
    @IBOutlet weak var heightField: UITextField!
    
    @IBOutlet weak var weightField: UITextField!
    
    @IBOutlet weak var nationalityField: UITextField!
    
    @IBOutlet weak var classField: UITextField!
    
    @IBOutlet weak var countryShortField: UITextField!
    
    @IBOutlet weak var issueDateField: UITextField!
    
    @IBOutlet weak var expDateField: UITextField!
    
    @IBOutlet weak var barcodeReadField: UITextField!
    
    @IBOutlet weak var ocrReadField: UITextField!
    
    @IBOutlet weak var idVerificationField: UITextField!
    
    @IBOutlet weak var productVersionField: UITextField!
    
    @IBOutlet weak var confidenceRatingField: UITextField!

    //MARK: Public variables
    
    var delegate: IDDataViewControllerDelegate? = nil
    
    //MARK: Private variables
    
    var idData: kfxIDData! = nil

    //MARK: Navigationbar related parameters
    private var wasNavigationHidden: Bool = false
    
    private var oldBarTintColor: UIColor!
    
    private var oldStatusBarStyle: UIStatusBarStyle!
    

    override func viewDidLoad() {
        super.viewDidLoad()

//        customizeNavigationBar()

        if idData != nil {
            displayFields()
        }
    }

    //MARK: Private methods
    
    private func customizeNavigationBar() {
        oldStatusBarStyle = UIApplication.shared.statusBarStyle
        oldBarTintColor = navigationController?.navigationBar.tintColor
        
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        if idData != nil {
        let rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(onSaveButtonClicked))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        //navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: #selector(onCancelButtonClicked))
        
        wasNavigationHidden = (navigationController?.navigationBar.isHidden)!
        //show navigation bar
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customizeNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        restoreNavigationBar()
    }

    private func restoreNavigationBar() {
        UIApplication.shared.statusBarStyle = oldStatusBarStyle
        navigationController?.navigationBar.tintColor = oldBarTintColor
        navigationController?.setNavigationBarHidden(wasNavigationHidden, animated: false)
    }
    
    
    private func displayFields() {
        if idData.faceImageId != nil {
            displayProfileImage(dataString: idData.faceImageId)
        }
        
        if idData.signatureImageId != nil {
            displaySignatureImage(dataString: idData.signatureImageId)
        }
        
        displayTextFields()
    }
    
    private func displayProfileImage(dataString: String!) {
        if dataString != nil && dataString.characters.count > 0 {
            let data = NSData.init(base64Encoded: dataString, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            
            if data != nil {
                profileImage.image = UIImage.init(data: data! as Data)
            }
        }
    }
    
    
    private func displaySignatureImage(dataString: String!) {
        if dataString != nil && dataString.characters.count > 0 {
            let data = NSData.init(base64Encoded: dataString, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            
            if data != nil {
                singatureImage.image = UIImage.init(data: data! as Data)
            }
        }
    }

    
    private func displayTextFields() {
        
        idNumberField.text = idData.idNumber.value
        
        firstNameField.text = idData.firstName.value
        
         middleNameField.text = idData.middleName.value
         
         lastNameField.text = idData.lastName.value
         
         addressField.text = idData.address.value
         
         cityField.text = idData.city.value
         
         stateField.text = idData.state.value
         
         zipField.text = idData.zip.value
         
         countryField.text = idData.country.value
         
         dobField.text = idData.dateOfBirth.value
         
         genderField.text = idData.gender.value
         
         eyesField.text = idData.eyes.value
         
         hairField.text = idData.eyes.value
         
         heightField.text = idData.height.value
         
         weightField.text = idData.weight.value
         
         nationalityField.text = idData.nationality.value
         
         //classField.text = data.c
         
         countryShortField.text = idData.countryShort.value
         
         issueDateField.text = idData.issueDate.value
         
         expDateField.text = idData.expirationDate.value
         
         barcodeReadField.text = idData.isBarcodeRead == true ? "Yes" : "No"
         
         ocrReadField.text = idData.isOcrRead == true ? "Yes" : "No"
         
         idVerificationField.text = idData.isIDVerified == true ? "Yes" : "No"
         
         //productVersionField.text = data
         
         confidenceRatingField.text = String.init(format: "%2.0",  idData.documentVerificationConfidenceRating)
    }

    
    func onSaveButtonClicked() {
        if areAllRequiredFieldsAvailable() {

            updateIDObject()
            delegate?.IDDataSaved(idData: idData)
            delegate = nil
        self.navigationController?.popViewController(animated: true)
        } else {
            Utility.showAlert(onViewController: self, titleString: "Empty Fields", messageString: "One or more required fields are empty. Please fill all the details before saving.")
        }
    }

    
    private func areAllRequiredFieldsAvailable() -> Bool {
        if firstNameField.text?.characters.count == 0 || lastNameField.text?.characters.count == 0 || addressField.text?.characters.count == 0 || cityField.text?.characters.count == 0 || stateField.text?.characters.count == 0 || countryField.text?.characters.count == 0 || zipField.text?.characters.count == 0 || dobField.text?.characters.count == 0 {
                return false
        }
        return true
    }
    
    private func updateIDObject() {
        
        idData.idNumber.value = idNumberField.text
        
        idData.firstName.value = firstNameField.text
        
        idData.middleName.value = middleNameField.text

        idData.lastName.value = lastNameField.text
        
        idData.address.value = addressField.text

        idData.city.value = cityField.text
        
        idData.state.value = stateField.text
        
        idData.zip.value = zipField.text

        idData.country.value = countryField.text
        
        idData.dateOfBirth.value = dobField.text

        idData.gender.value = genderField.text
        
        idData.issueDate.value = issueDateField.text

        idData.expirationDate.value = expDateField.text
    }
    func onCancelButtonClicked() {
        restoreNavigationBar()
        delegate = nil
        self.navigationController?.popViewController(animated: true)
    }

}
