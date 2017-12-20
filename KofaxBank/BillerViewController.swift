//
//  BillerViewController.swift
//  KofaxBank
//
//  Created by Rupali on 02/11/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData

//protocol BillerViewControllerDelegate {
//}

class BillerViewController: UIViewController, UITabBarControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, BillManagerDelegate {

    @IBOutlet weak var appLogoImage: UIImageView!

    @IBOutlet weak var bannerContentsView: UIView!

    @IBOutlet weak var payButton: UIButton!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var pickerContainerView: CustomView!

    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var pickerDoneButton: UIButton!

    @IBOutlet weak var payeeField: UITextField!
    
    @IBOutlet weak var accountField: UITextField!
    
    @IBOutlet weak var amountTextField: UITextField!

    
    //MARK: - Public variables
    
    //var delegate: BillerViewControllerDelegate?

    //MARK: - Private variables

    private enum SelectionType: String {
        case ACCOUNT
        case BILLER
    }

    private var billManager: BillManager? = nil

//    private var wasNavigationHidden: Bool = false
//    private var oldBarTintColor: UIColor!
//    private var oldStatusBarStyle: UIStatusBarStyle!

    private var accounts = [AccountsMaster]()
    private var billers = [BillerMaster]()
    
    private var selectionType: SelectionType = SelectionType.ACCOUNT
    
    private var selectedAccount: AccountsMaster! = nil
    private var selectedBiller: BillerMaster! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        customizeScreenControls()
        customizeNavigationBar()
        initialize()
        
        fetchAccounts()
        fetchBillers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.tabBarController?.delegate = self
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.tabBarController?.delegate = nil
        self.pickerView.delegate = nil
    }

    private func initialize() {

        reset()

        selectionType = SelectionType.ACCOUNT
        
        self.pickerView.delegate = self
    }
    
    private func reset() {
        self.selectedBiller = nil
        self.selectedAccount = nil
        self.amountTextField.text = ""

        self.payeeField.text = ""
        self.accountField.text = ""
    }
    
    private func clear() {
        //restoreNavigationBar()
        accounts.removeAll()
        billers.removeAll()
        
        if self.billManager != nil {
            self.billManager?.delegate = nil
            self.billManager = nil
        }
        
        self.tabBarController?.delegate = nil
    }
    
    
    private func customizeScreenControls() {
        let appStyler = AppStyleManager.sharedInstance()
        
        let splashStyler = appStyler?.get_splash_styler()
        let screenStyler = appStyler?.get_app_screen_styler()
        
        appLogoImage = splashStyler?.configure_app_logo(appLogoImage)
        bannerContentsView = screenStyler?.configure_primary_view_background(bannerContentsView)
        
        let accentColor = screenStyler?.get_accent_color()
        
        cameraButton.backgroundColor = accentColor
        payButton.backgroundColor = accentColor
        pickerDoneButton.backgroundColor = accentColor
    }
    
    
    private func customizeNavigationBar() {

        UIApplication.shared.isStatusBarHidden = false
        
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.tintColor = UIColor.white
        
        //remove back button title from navigationbar
        navigationController?.navigationBar.backItem?.title = ""
        let backImage = UIImage(named: "back_white")!
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        
        let logoutBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "logout_white"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(logout))
        
         self.tabBarController?.navigationItem.rightBarButtonItem = logoutBarButtonItem
 
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func logout() {
        print("Logout!!!")
    }
    
    //MARK Tabbar controller delegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if viewController != self {
            print("New viewcontroller selected!")
            clear()
        }
    }
    
    @IBAction func onPayButtonPressed(_ sender: UIButton) {
        
        var amount: Double = 0.0
        
        if amountTextField.text != "" {
            amount = Double.init(amountTextField.text!)!
        }
        
        
        if selectedAccount != nil && selectedBiller != nil && amount > 0 {
            
            if selectedAccount.balance > amount {
                
                let billTransaction = BillTransactions(context: context)
                billTransaction.name = payeeField.text
                billTransaction.accountNumber = accountField.text
                billTransaction.amountDue = amount
                billTransaction.billDate = Date() as NSDate
                billTransaction.comment = "Bill paid for existing biller"
                
                selectedBiller.addToBillTransactions(billTransaction)
                selectedAccount?.balance = selectedAccount!.balance - amount
    
                let transaction = AccountTransactionMaster(context: context)
                transaction.account = selectedAccount
                transaction.type = TransactionType.DEBIT.rawValue
                transaction.billTransaction = billTransaction
                transaction.dateOfTransaction = Date() as NSDate

                //save bill data
                ad.saveContext()

                Utility.showAlert(onViewController: self, titleString: "", messageString: "Bill is paid.")
                
                reset()
            } else {
                Utility.showAlert(onViewController: self, titleString: "Insufficient Balance", messageString: "Make sure your account has enough balance to pay the bill.")
            }
        } else {
            Utility.showAlert(onViewController: self, titleString: "Required Fields Found Empty", messageString: "Make sure all the details are filled before you continue.")
        }
    }

    private func fetchAccounts() {
        
        accounts.removeAll()
        
        var fetchRequest: NSFetchRequest<AccountsMaster>! = AccountsMaster.fetchRequest()
        
        do {
            accounts = try context.fetch(fetchRequest)
        } catch {
            print("\(error)")
        }
        fetchRequest = nil
    }
    
    private func fetchBillers() {
        
        billers.removeAll()

        var fetchRequest: NSFetchRequest<BillerMaster>! = BillerMaster.fetchRequest()
        
        do{
            billers = try context.fetch(fetchRequest)
        } catch {
            print("\(error)")
        }

        fetchRequest = nil
    }


    @IBAction func selectPayee(_ sender: UITapGestureRecognizer) {
        pickerContainerView.isHidden = false
        
        selectionType = SelectionType.BILLER
        
        if billers.count > 0 {
            pickerView.reloadAllComponents()
            pickerView.selectRow(0, inComponent: 0, animated: true)
        } else {
            Utility.showAlert(onViewController: self, titleString: "", messageString: "No Billers Available")
        }
    }
    @IBAction func selectAccount(_ sender: UITapGestureRecognizer) {
        pickerContainerView.isHidden = false
        
        selectionType = SelectionType.ACCOUNT
        
        if accounts.count > 0 {
            pickerView.reloadAllComponents()
            pickerView.selectRow(0, inComponent: 0, animated: true)
        } else {
            Utility.showAlert(onViewController: self, titleString: "", messageString: "No Accounts Available")
        }
    }


    @IBAction func openBillPayScreen(_ sender: UIButton) {
        if selectedAccount  == nil {
            Utility.showAlert(onViewController: self, titleString: "Empty Account", messageString: "Select account before paying new bill.")
        } else {
            if billManager == nil {
                billManager = BillManager()
            }
            billManager?.loadManager(navigationController: self.navigationController!)
            billManager?.account = selectedAccount
            billManager?.paybillWithNewBiller(account: selectedAccount)
            if billManager?.delegate == nil {
                billManager?.delegate = self
            }
        }
    }

    @IBAction func onTapGesture(_ sender: UITapGestureRecognizer) {
        pickerContainerView.isHidden = true
        amountTextField.endEditing(true)
    }
    

    //MARK: BillManagerDelegate methods
    
    func billPaymentCancelled() {
        
    }
    
    func billPaymentFailed(error: AppError!) {
        var title: String = ""

        var message: String = "Bill Payment failed"
        
        if error != nil {
            message = error.message
            title = error.title
        }
        
        Utility.showAlert(onViewController: self, titleString: title, messageString: message)
    }
    
    func billPaymentSucceded() {
        fetchAccounts()
        fetchBillers()
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
            accountField.text = selectedAccount.accountNumber
        } else if selectionType == SelectionType.BILLER {
            selectedBiller = billers[pickerViewSelectedRow]
            payeeField.text = selectedBiller.name
        }

        pickerContainerView.isHidden = true
    }
    
    
    //MARK: Setting popup methods and delegate
    

    
}
