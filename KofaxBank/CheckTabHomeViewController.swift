//
//  CheckTabHomeViewController.swift
//  KofaxBank
//
//  Created by Rupali on 12/11/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData

class CheckTabHomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CheckDepositManagerDelegate {

    @IBOutlet weak var pickerContainerView: CustomView!
    
    @IBOutlet weak var pickerView: UIPickerView!

    @IBOutlet weak var dateButton: UIButton!
    
    @IBOutlet weak var accountButton: UIButton!
    
    //MARK: Private variables
    private var wasNavigationHidden: Bool = false
    private var oldBarTintColor: UIColor!
    private var oldStatusBarStyle: UIStatusBarStyle!
    
    private var accounts = [AccountsMaster]()

    private var selectedAccount: AccountsMaster! = nil
    
    private var checkManager: CheckDepositManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initialize()
        
        fetchAccounts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clear()
    }
    
    private func initialize() {
        customizeNavigationBar()
        
        print("Date is ===> \( Utility.dateToFormattedString(format: ShortDateFormatWithMonth, date: Date()))")
        
        dateButton.titleLabel?.text = Utility.dateToFormattedString(format: ShortDateFormatWithMonth, date: Date())
        
        selectedAccount = nil
    }
    
    private func clear() {
        //restoreNavigationBar()
        accounts.removeAll()
        self.selectedAccount = nil

        if self.checkManager != nil {
            self.checkManager?.delegate = nil
            self.checkManager = nil
        }
    }

    private func customizeNavigationBar() {
        
        oldStatusBarStyle = UIApplication.shared.statusBarStyle
        oldBarTintColor = navigationController?.navigationBar.tintColor
        
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.tintColor = UIColor.white
        
        wasNavigationHidden = (self.navigationController?.navigationBar.isHidden)!
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func restoreNavigationBar() {
        UIApplication.shared.statusBarStyle = oldStatusBarStyle
        navigationController?.navigationBar.tintColor = oldBarTintColor
        navigationController?.setNavigationBarHidden(wasNavigationHidden, animated: false)
    }
    
    private func fetchAccounts() {
        var fetchRequest: NSFetchRequest<AccountsMaster>! = AccountsMaster.fetchRequest()
        
        do {
            accounts = try context.fetch(fetchRequest)
        } catch {
            print("\(error)")
        }
        fetchRequest = nil
    }
    
    @IBAction func selectAccount(_ sender: UIButton) {
        pickerContainerView.isHidden = false
        
        if accounts.count > 0 {
            //            pickerViewSelectedRow = 0
            pickerView.reloadAllComponents()
            pickerView.selectRow(0, inComponent: 0, animated: true)
        } else {
            Utility.showAlert(onViewController: self, titleString: "", messageString: "No Accounts Available")
        }
    }

    @IBAction func openCheckDepositScreen(_ sender: UIButton) {
        if selectedAccount  == nil {
            Utility.showAlert(onViewController: self, titleString: "Ampty Account", messageString: "Select account to deposit check into.")
        } else {
            if checkManager == nil {
                checkManager = CheckDepositManager()
                checkManager?.loadManager(navigationController: self.navigationController!)
                self.checkManager?.delegate = nil
            }
            checkManager?.account = selectedAccount
        }
    }
    //MARK: Pickerview delegates
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accounts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if accounts.count >= row {
            return accounts[row].accountNumber
        }
        return ""
    }

    var pickerViewSelectedRow: Int = 0
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        pickerViewSelectedRow = row
        
        print("selected : \(row)")
    }
    
    @IBAction func onPickerViewDoneButtonClick(_ sender: UIButton) {
        
        pickerViewSelectedRow = pickerView.selectedRow(inComponent: 0)
        
        selectedAccount = accounts[pickerViewSelectedRow]
        accountButton.titleLabel?.text = selectedAccount.accountNumber
        
        pickerContainerView.isHidden = true
    }
    
    
    //MARK: CheckDepositManagerDelegate
    
    func checkDepositFailed(error: AppError!) {
        print("Check Deposit Failed")
    }
    
    func checkDepositComplete() {
        print("Check Deposit Complete")
        
        //TODO: You can take care of coredata update of check data here instead of checkManger if required.
    }
    
    func checkDepositCancelled() {
        print("Check Deposit Cancelled")
    }
}
