//
//  IDDataViewController.swift
//  KofaxBank
//
//  Created by Rupali on 27/10/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

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
        
        let rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(onSaveButtonClicked))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
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

        self.navigationController?.popViewController(animated: true)
    }

    
    func onCancelButtonClicked() {
        restoreNavigationBar()
        self.navigationController?.popViewController(animated: true)
    }

}
