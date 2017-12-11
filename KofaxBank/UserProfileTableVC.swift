//
//  UserProfileTableVC.swift
//  KofaxBank
//
//  Created by Rupali on 06/07/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData

class UserProfileTableVC: UITableViewController, UINavigationControllerDelegate,
UIImagePickerControllerDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var avatarEditLabel: UILabel!

    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var birthdateText: UITextField!
    
    @IBOutlet weak var phoneNumberText: UITextField!
    
    @IBOutlet weak var emailText: UITextField!
    
    //@IBOutlet weak var addressText: UITextView!
    @IBOutlet weak var addressText: UITextField!
    
    @IBOutlet weak var cityText: UITextField!
    
    @IBOutlet weak var stateText: UITextField!
    
    @IBOutlet weak var countryText: UITextField!
    
    @IBOutlet weak var zipText: UITextField!
    
    
    //MARK: Private variables
    
    private var user: UserMaster! = nil

    private var editingHasBegun: Bool = false

    private var didAvatarChange: Bool = false
    
    private var dob: NSDate! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeNavigationBar()
        
        user = fetchUserDetails()
        
        if user != nil {
            displayUserDetails(user: user!)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(mainViewOnTap(_:)))
        self.tableView.addGestureRecognizer(tapGestureRecognizer)
        
        setupDatePicker()
        
        updateFieldAccess()
    }
    
    private func customizeNavigationBar() {
     
        let leftItem = UIBarButtonItem.init(image: UIImage(named: "cross_gray"), style: .plain, target: self, action: #selector(close))
        let rightItem = UIBarButtonItem.init(image: UIImage(named: "edit_gray"), style: .plain, target: self, action: #selector(toggleEdit))
        
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        self.navigationItem.leftBarButtonItem = leftItem
        
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func fetchUserDetails() -> UserMaster! {
        
        
        let fetchRequest: NSFetchRequest<UserMaster> = UserMaster.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            if users.count > 0 {
                user = users[0]
            }
        } catch {
            print("ERror while fetching user data:\(error.localizedDescription)")
        }
        
        return user
    }
    
    private func displayUserDetails(user: UserMaster) {
        
        //name
        var name = user.firstname! + " "
        
        //if user.middlename != nil {
           // name = name + user.middlename! + " "
        //}
        
        if user.lastname != nil {
            name = name + user.lastname!
        }
        
        nameText.text = name
        
        //address
        if user.address != nil {
            addressText.text = user.address!
        }

        if user.city != nil {
            cityText.text = user.city!
        }
        
        if user.state != nil {
            stateText.text = user.state!
        }
        
        if user.zip != nil {
            zipText.text = user.zip!
        }
        
        if user.country != nil {
            countryText.text = user.country!
        }

        //phone
        if user.phone != nil {
            phoneNumberText.text = user.phone
        }
        
        //email
        if user.email != nil {
            emailText.text = user.email
        }
        
        if user.birthdate != nil {
            birthdateText.text = Utility.dateToFormattedString(format: InformalDateFormat, date: user.birthdate! as Date)
        }
        
        //avatar 
        
        if user.avatar != nil {
            avatarImageView.image = UIImage.init(data: user.avatar! as Data)
        }
    }
    
    func toggleEdit() {

        editingHasBegun = !editingHasBegun
        
        if editingHasBegun == false {
            
            if isAnyFieldEmpty() {
                Utility.showAlert(onViewController: self, titleString: "Empty Fields", messageString: "Fill all the user details before saving")
                return
            }
            else {
                saveUserData()
                self.navigationItem.rightBarButtonItem?.image = UIImage(named: "edit_gray")
            }
        }

        updateFieldAccess()
        
        if editingHasBegun == true {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "checkmark_gray")
            nameText.becomeFirstResponder()
        }
    }

    private func updateFieldAccess() {
        
        if editingHasBegun {
            avatarEditLabel.isHidden = false
        } else {
            avatarEditLabel.isHidden = true
        }

        nameText.isUserInteractionEnabled = editingHasBegun
        addressText.isUserInteractionEnabled = editingHasBegun
        cityText.isUserInteractionEnabled = editingHasBegun
        stateText.isUserInteractionEnabled = editingHasBegun
        countryText.isUserInteractionEnabled = editingHasBegun
        zipText.isUserInteractionEnabled = editingHasBegun
        phoneNumberText.isUserInteractionEnabled = editingHasBegun
        emailText.isUserInteractionEnabled = editingHasBegun
        birthdateText.isUserInteractionEnabled = editingHasBegun
        avatarImageView.isUserInteractionEnabled = editingHasBegun
    }
    
    
    private func isAnyFieldEmpty() -> Bool {
        return nameText.text == "" || phoneNumberText.text == "" || birthdateText.text == "" ||
            addressText.text == "" || cityText.text == "" || stateText.text == "" || countryText.text == "" || zipText.text == ""
    }
    
    
     func close() {
        dismiss(animated: true, completion: nil)
    }
    
    
    private func saveUserData() {
        
        if (nameText.text?.characters.count)! > 0 {
            let name = nameText.text
            
            let namePart = name?.components(separatedBy: " ")
            
            user.firstname = namePart?[0]
            
            if namePart != nil && (namePart?.count)! > 1 {
                user.lastname = namePart?[(namePart?.count)! - 1]
            } else {
                user.lastname = ""
            }
        }
        
        user.address = addressText.text
        user.city = cityText.text
        user.state = stateText.text
        user.country = countryText.text
        user.zip = zipText.text
        
        if dob != nil {
            user.birthdate = dob
        }

        user.phone = phoneNumberText.text
        
        user.email = emailText.text
        
        
        if didAvatarChange {
            if avatarImageView.image != nil {
                let thumbnail = Utility.resizeImage(image: avatarImageView.image, newWidth: avatarImageView.bounds.width)
                
                if thumbnail != nil {
                    user.avatar = UIImagePNGRepresentation(thumbnail!)! as NSData
                }
            }
            didAvatarChange = false
        }
        ad.saveContext()
    }
    
    
    @IBAction func mainViewOnTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func avatarOnTapGesture(_ sender: UITapGestureRecognizer) {
        showGallery()
    }
    
    
    //MARK: Image gallery methods
    
    func showGallery() {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.present(picker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.delegate = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.delegate = nil
        
        var image: UIImage? = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        avatarImageView.image = image
        
        image = nil
        picker.dismiss(animated: true, completion: nil)
        
        didAvatarChange = true
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
        birthdateText.inputAccessoryView = toolbar
        // add datepicker to textField
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        birthdateText.inputView = datePicker
    }
    
    func doneDatePicker() {
        print("Done datepicker")
        
        let picker = self.birthdateText.inputView as! UIDatePicker
        self.birthdateText.text = Utility.dateToFormattedString(format: InformalDateFormat, date: picker.date)
        
        //user.birthdate = picker.date as NSDate
        dob = picker.date as NSDate
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    
    
    func cancelDatePicker() {
        print("Cancel datepicker")
        
        //dismiss date picker dialog
        self.view.endEditing(true)
    }

}
