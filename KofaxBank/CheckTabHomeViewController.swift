//
//  CheckTabHomeViewController.swift
//  KofaxBank
//
//  Created by Rupali on 12/11/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData

class CheckTabHomeViewController: UIViewController, UITabBarControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CheckDepositManagerDelegate {

    @IBOutlet weak var appLogoImage: UIImageView!
    
    @IBOutlet weak var bannerContentsView: UIView!
        
    @IBOutlet weak var cameraButton: UIButton!

    @IBOutlet weak var pickerContainerView: CustomView!
    
    @IBOutlet weak var pickerView: UIPickerView!

    @IBOutlet weak var pickerDoneButton: UIButton!
    
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
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customizeScreenControls()
        initialize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.delegate = nil
        self.pickerView.delegate = nil
    }
    
    private func initialize() {
        customizeNavigationBar()
        
        dateButton.titleLabel?.text = Utility.dateToFormattedString(format: ShortDateFormatWithMonth, date: Date())

        if self.accounts.count == 0 {
            fetchAccounts()
            selectedAccount = nil
        }

        self.tabBarController?.delegate = self
        self.pickerView.delegate = self
    }
    
    private func clear() {
        accounts.removeAll()
        self.selectedAccount = nil

        if self.checkManager != nil {
            self.checkManager?.delegate = nil
            self.checkManager = nil
        }
    }

    private func customizeScreenControls() {
        let appStyler = AppStyleManager.sharedInstance()
        
        let splashStyler = appStyler?.get_splash_styler()
        let screenStyler = appStyler?.get_app_screen_styler()
        
        appLogoImage = splashStyler?.configure_app_logo(appLogoImage)
        bannerContentsView = screenStyler?.configure_primary_view_background(bannerContentsView)
        
        let accentColor = screenStyler?.get_accent_color()

        cameraButton.backgroundColor = accentColor
        pickerDoneButton.backgroundColor = accentColor
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
        
        accounts.removeAll()

        do {
            accounts = try context.fetch(fetchRequest)
        } catch {
            print("\(error)")
        }
        fetchRequest = nil
    }
    
    //MARK Tabbar controller delegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if viewController != self {
            print("New viewcontroller selected!")
            clear()
        }
    }

    //Screen command button actions
    
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
                self.checkManager = CheckDepositManager()
            }
            if self.checkManager?.delegate == nil {
                self.checkManager?.delegate = self
            }
            checkManager?.account = selectedAccount
            checkManager?.loadManager(navigationController: self.navigationController!)
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
        selectedAccount = nil
    }
    
    func checkDepositComplete() {
        print("Check Deposit Complete")
        
        Utility.showAlert(onViewController: self, titleString: "Check is deposited", messageString: "The amount will reflect in your account once the check is processed.")
        
        selectedAccount = nil

        fetchAccounts()
        
        //TODO: You can take care of coredata update of check data here instead of checkManger if required.
    }
    
    func checkDepositCancelled() {
        print("Check Deposit Cancelled")
        selectedAccount = nil
    }
}
