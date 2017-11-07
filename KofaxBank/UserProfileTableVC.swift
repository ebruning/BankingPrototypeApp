//
//  UserProfileTableVC.swift
//  KofaxBank
//
//  Created by Rupali on 06/07/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class UserProfileTableVC: UITableViewController {

    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var birthdateText: UITextField!
    
    @IBOutlet weak var phoneNumberText: UITextField!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var addressText: UITextView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var editButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func editDetails(_ sender: UIButton) {
        
    }

    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
