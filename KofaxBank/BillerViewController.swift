//
//  BillerViewController.swift
//  KofaxBank
//
//  Created by Rupali on 02/11/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData

protocol BillerViewControllerDelegate {
}


class BillerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerContainerView: CustomView!

    @IBOutlet weak var pickerView: UIPickerView!

//    @IBOutlet weak var floatingContainerView: UIView!

    @IBOutlet weak var payeeButton: UIButton!
    
    @IBOutlet weak var accountButton: UIButton!
    
    @IBOutlet weak var amountTextField: UITextField!

    //MARK: - Public variables
    
    var delegate: BillerViewControllerDelegate?
    
    //MARK: - Private variables

    private enum SelectionType: String {
        case ACCOUNT
        case BILLER
    }

    private var billManager: BillManager? = nil

    private var wasNavigationHidden: Bool = false
    private var oldBarTintColor: UIColor!
    private var oldStatusBarStyle: UIStatusBarStyle!

    private var accounts = [AccountsMaster]()
    private var billers = [BillerMaster]()
    
    private var selectionType: SelectionType = SelectionType.ACCOUNT
    
    private var selectedAccount: AccountsMaster! = nil
    private var selectedBiller: BillerMaster! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initialize()
        
        fetchAccounts()
        fetchBillers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clear()
    }

    private func initialize() {
        customizeNavigationBar()

        selectedBiller = nil
        selectedAccount = nil
        selectionType = SelectionType.ACCOUNT
    }
    
    private func clear() {
        //restoreNavigationBar()
        accounts.removeAll()
        billers.removeAll()
        self.selectedBiller = nil
        
        if self.billManager != nil {
            self.billManager?.delegate = nil
            self.billManager = nil
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

    var amount: Double = 0
    
    @IBAction func onPayButtonPressed(_ sender: UIButton) {
        
        if amountTextField.text != "" {
            amount = Double.init(amountTextField.text!)!
        }
        
        
        if selectedAccount != nil && selectedBiller != nil && amount > 0 {
            
            if selectedAccount.balance > amount {
                
                let billTransaction = BillTransactions(context: context)
                billTransaction.name = payeeButton.titleLabel?.text
                billTransaction.accountNumber = accountButton.titleLabel?.text
                billTransaction.amountDue = self.amount
                billTransaction.billDate = Date() as NSDate
                billTransaction.comment = "Bill paid for existing biller"
                
                selectedBiller.addToBillTransactions(billTransaction)
                selectedAccount?.balance = selectedAccount!.balance - self.amount
    
                let transaction = AccountTransactionMaster(context: context)
                transaction.account = selectedAccount
                transaction.type = TransactionType.DEBIT.rawValue
                transaction.billTransaction = billTransaction
                transaction.dateOfTransaction = Date() as NSDate
                
                //save bill data
                ad.saveContext()
                
                Utility.showAlert(onViewController: self, titleString: "", messageString: "Bill is paid.")
                amountTextField.text = ""
                selectedAccount = nil
                selectedBiller = nil
            } else {
                Utility.showAlert(onViewController: self, titleString: "Insufficient Balance", messageString: "Make sure your account has enough balance to pay the bill.")
            }
        } else {
            Utility.showAlert(onViewController: self, titleString: "Required Fields Found Empty", messageString: "Make sure all the details are filled before you continue.")
        }
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
    
    private func fetchBillers() {
        var fetchRequest: NSFetchRequest<BillerMaster>! = BillerMaster.fetchRequest()
        
        do{
            billers = try context.fetch(fetchRequest)
        } catch {
            print("\(error)")
        }

        fetchRequest = nil
    }


/*
    private func closeScreen() {
        
        //TODO: find place to clean data
        
        accounts.removeAll()
        billers.removeAll()

        navigationController?.popViewController(animated: true)
    }
*/
    @IBAction func selectPayee(_ sender: UIButton) {
        pickerContainerView.isHidden = false
        
        selectionType = SelectionType.BILLER
        
        if billers.count > 0 {
//            pickerViewSelectedRow = 0
            pickerView.reloadAllComponents()
            pickerView.selectRow(0, inComponent: 0, animated: true)
        } else {
            Utility.showAlert(onViewController: self, titleString: "", messageString: "No Billers Available")
        }
    }

    @IBAction func selectAccount(_ sender: UIButton) {
        pickerContainerView.isHidden = false
        
        selectionType = SelectionType.ACCOUNT

        if accounts.count > 0 {
//            pickerViewSelectedRow = 0
            pickerView.reloadAllComponents()
            pickerView.selectRow(0, inComponent: 0, animated: true)
        } else {
            Utility.showAlert(onViewController: self, titleString: "", messageString: "No Accounts Available")
        }
    }

    @IBAction func openBillPayScreen(_ sender: UIButton) {
        if selectedAccount  == nil {
            Utility.showAlert(onViewController: self, titleString: "Ampty Account", messageString: "Select account before paying new bill.")
        } else {
            if billManager == nil {
                billManager = BillManager()
                billManager?.loadManager(navigationController: self.navigationController!)
            }
            billManager?.account = selectedAccount
            billManager?.paybillWithNewBiller(account: selectedAccount)
        }
    }

    @IBAction func onTapGesture(_ sender: UITapGestureRecognizer) {
        pickerContainerView.isHidden = true
        amountTextField.endEditing(true)
    }
    

    //MARK: Pickerview delegates
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if selectionType == SelectionType.ACCOUNT {
            return accounts.count
        } else if selectionType == SelectionType.BILLER {
            return billers.count
        }
    return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if selectionType == SelectionType.ACCOUNT {
            return accounts[row].accountNumber
        } else if selectionType == SelectionType.BILLER {
                return billers[row].name
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
        
        if selectionType == SelectionType.ACCOUNT {
            selectedAccount = accounts[pickerViewSelectedRow]
            accountButton.titleLabel?.text = selectedAccount.accountNumber
        } else if selectionType == SelectionType.BILLER {
            selectedBiller = billers[pickerViewSelectedRow]
            payeeButton.titleLabel?.text = selectedBiller.name
        }

        pickerContainerView.isHidden = true
    }
    
    
}
