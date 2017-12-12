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

class IDDataViewController: UITableViewController, UITextFieldDelegate {

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
//    private var wasNavigationHidden: Bool = false
//    
//    private var oldBarTintColor: UIColor!
//    
//    private var oldStatusBarStyle: UIStatusBarStyle!
    

    override func viewDidLoad() {
        super.viewDidLoad()

//        customizeNavigationBar()
        setupScreenControls()

        if idData != nil {
            displayFields()
        }
        setupDatePicker()
    }

    //MARK: Private methods
    
    private func setupScreenControls() {
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(mainViewOnTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func mainViewOnTap() {
        self.view.endEditing(true)
    }
    private func customizeNavigationBar() {
//        oldStatusBarStyle = UIApplication.shared.statusBarStyle
//        oldBarTintColor = navigationController?.navigationBar.tintColor
        
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        if idData != nil {
            let rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(onSaveButtonClicked))
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
        }

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        //navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: #selector(onCancelButtonClicked))
        
//        wasNavigationHidden = (navigationController?.navigationBar.isHidden)!
        //show navigation bar
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customizeNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        restoreNavigationBar()
    }
/*
    private func restoreNavigationBar() {
        UIApplication.shared.statusBarStyle = oldStatusBarStyle
        navigationController?.navigationBar.tintColor = oldBarTintColor
        navigationController?.setNavigationBarHidden(wasNavigationHidden, animated: false)
    }
*/
    
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
        
        if idData.idNumber.confidence < 0.80 {
            idNumberField.textColor = UIColor.red
        }
        
        firstNameField.text = idData.firstName.value
        
        if idData.firstName.confidence < 0.80 {
            firstNameField.textColor = UIColor.red
        }

        middleNameField.text = idData.middleName.value

        if idData.middleName.confidence < 0.80 {
            middleNameField.textColor = UIColor.red
        }

        lastNameField.text = idData.lastName.value

        if idData.lastName.confidence < 0.80 {
            lastNameField.textColor = UIColor.red
        }

        addressField.text = idData.address.value

        if idData.address.confidence < 0.80 {
            addressField.textColor = UIColor.red
        }

        cityField.text = idData.city.value

        if idData.city.confidence < 0.80 {
            cityField.textColor = UIColor.red
        }

        stateField.text = idData.state.value

        if idData.state.confidence < 0.80 {
            stateField.textColor = UIColor.red
        }

        zipField.text = idData.zip.value
        
        if idData.zip.confidence < 0.80 {
            zipField.textColor = UIColor.red
        }

        countryField.text = idData.country.value

        if idData.country.confidence < 0.80 {
            countryField.textColor = UIColor.red
        }

        if idData.dateOfBirth != nil && idData.dateOfBirth.value != nil {
        
            dob = Utility.convertStringToDate(format: "yyyy-MM-dd", dateStr: idData.dateOfBirth.value)
            
            if dob != nil {
                let dateStr = Utility.dateToFormattedString(format: LongDateFormatWithNumericMonth, date: dob!) //TODO: The date format should be updated based on the country
                
                dobField.text = dateStr
            } else {
        dobField.text = idData.dateOfBirth.value
            }

        if idData.dateOfBirth.confidence < 0.80 {
            dobField.textColor = UIColor.red
        }
        }

        genderField.text = idData.gender.value

        if idData.gender.confidence < 0.80 {
            genderField.textColor = UIColor.red
        }

        eyesField.text = idData.eyes.value

        if idData.eyes.confidence < 0.80 {
            eyesField.textColor = UIColor.red
        }

        hairField.text = idData.hair.value

        if idData.hair.confidence < 0.80 {
            hairField.textColor = UIColor.red
        }

        heightField.text = idData.height.value

        if idData.height.confidence < 0.80 {
            heightField.textColor = UIColor.red
        }

        weightField.text = idData.weight.value

        if idData.weight.confidence < 0.80 {
            weightField.textColor = UIColor.red
        }

        nationalityField.text = idData.nationality.value

        if idData.nationality.confidence < 0.80 {
            nationalityField.textColor = UIColor.red
        }
        
        countryShortField.text = idData.countryShort.value

        if idData.countryShort.confidence < 0.80 {
            countryShortField.textColor = UIColor.red
        }

        if idData.issueDate != nil && idData.issueDate.value != nil {
            
            issueDate = Utility.convertStringToDate(format: "yyyy-MM-dd", dateStr: idData.issueDate.value)
            
            if issueDate != nil {
                let dateStr = Utility.dateToFormattedString(format: LongDateFormatWithNumericMonth, date: issueDate!)//TODO: The date format should be updated based on the country
                
                issueDateField.text = dateStr
            } else {
        issueDateField.text = idData.issueDate.value
            }

        if idData.issueDate.confidence < 0.80 {
            issueDateField.textColor = UIColor.red
        }
        }

        if idData.expirationDate != nil && idData.expirationDate.value != nil {
            
            expDate = Utility.convertStringToDate(format: "yyyy-MM-dd", dateStr: idData.expirationDate.value)
            
            if expDate != nil {
                let dateStr = Utility.dateToFormattedString(format: LongDateFormatWithNumericMonth, date: expDate!)//TODO: The date format should be updated based on the country
                
                expDateField.text = dateStr
            } else {
        expDateField.text = idData.expirationDate.value
            }

        if idData.expirationDate.confidence < 0.80 {
            expDateField.textColor = UIColor.red
        }
        }

        barcodeReadField.text = idData.isBarcodeRead == true ? "Yes" : "No"

        ocrReadField.text = idData.isOcrRead == true ? "Yes" : "No"

        idVerificationField.text = idData.isIDVerified == true ? "Yes" : "No"

        
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
//        restoreNavigationBar()
        delegate = nil
        self.navigationController?.popViewController(animated: true)
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
        dobField.inputAccessoryView = toolbar
        
        // add datepicker to textField
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        
        dobField.inputView = datePicker
        
        issueDateField.inputAccessoryView = toolbar
        issueDateField.inputView = datePicker
        
        expDateField.inputAccessoryView = toolbar
        expDateField.inputView = datePicker
    }
    
    var activeDateViewField: UITextField! = nil
    var dob: Date! = nil
    var issueDate: Date! = nil
    var expDate: Date! = nil


    func doneDatePicker() {
        print("Done datepicker")

        //dismiss date picker dialog
        self.view.endEditing(true)

        
        if activeDateViewField == nil {
            return
        }
        
        let picker = self.activeDateViewField.inputView as! UIDatePicker
        let dateFromPicker = Utility.dateToFormattedString(format: LongDateFormatWithNumericMonth, date: picker.date)
        
        self.activeDateViewField.text = dateFromPicker
        
        if activeDateViewField == dobField {
            dob = picker.date
        } else if activeDateViewField == issueDateField {
            issueDate = picker.date
        } else if activeDateViewField == expDateField {
            expDate = picker.date
        }
    }
    

    
    // MARK: Textfield delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == dobField || textField == issueDateField || textField == expDateField {
            activeDateViewField = textField
            
            if textField == dobField && dob != nil {
                (textField.inputView as! UIDatePicker).date = dob
            } else if textField == issueDateField && issueDate != nil {
                (textField.inputView as! UIDatePicker).date = issueDate
            } else if textField == expDateField && expDate != nil {
                (textField.inputView as! UIDatePicker).date = expDate
            }
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}
