//
//  AccountsHomeVC.swift
//  KofaxBank
//
//  Created by Rupali on 22/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData

class AccountsHomeVC: UIViewController, UITabBarControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, IDManagerDelegate  {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var tableHeader: UILabel!

    @IBOutlet weak var appLogoImage: UIImageView!
    
    //Banner parameters
    
    @IBOutlet weak var bannerView: UIView!
    
    @IBOutlet weak var bannerContentsView: UIView!
    
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!

    @IBOutlet weak var bannerContentsViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var bannerBackgroundImage: UIImageView!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var stackViewUserDetails: UIStackView!
    
    

    //User Details
    
    @IBOutlet weak var greetingMessage: UILabel!
    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var telephoneNumberLabel: UILabel!
    
    @IBOutlet weak var emailAddressLabel: UILabel!
    
    @IBOutlet weak var addAccountFloatingButton: UIButton!
    
    //Bell notification 
    
    @IBOutlet weak var bellBadge: UIButton!

    //tableview
    private let MAX_VISIBLE_CELL_COUNT: Int = 2
    
    private var backImage: UIImage!

    //coredata
    private var fetchResultController: NSFetchedResultsController<AccountsMaster>! = nil
    
    private var fetchResultControllerCC: NSFetchedResultsController<CreditCardMaster>! = nil
    
    //banner
    private let SCREEN_HEIGHT: Double = Double(UIScreen.main.bounds.size.height)
    
    private let BANNER_AREA_PERCENT = 30.0

    private var topScrollOffset: CGFloat = 0
    
    private var bottomScrollOffset: CGFloat = 0
    
    private var bannerInnerOffset: CGFloat = 0

    
    //Others
//    private var markForRefresh = true
    
    private var oldAccentColor: UIColor? = nil
    
    private var currentAccentColor: UIColor? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPanGestureRecognizerOnBannerView()

        initScreenParams()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        self.tabBarController?.delegate = self

        if requestedProfileImport {
            initiateProfileImport(navController: self.navigationController!)
            requestedProfileImport = false
        }
        
        loadUserDetails()
        
    }
    

    private func setupPanGestureRecognizerOnBannerView() {
        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(move(_:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.minimumNumberOfTouches = 1
        
        bannerView.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func initScreenParams() {
        //calculate height of banner based on decided percentage w.r.t. main screen height
        topScrollOffset = CGFloat((BANNER_AREA_PERCENT/100.0) * SCREEN_HEIGHT)
        
        //canculate bottom offset upto where banner can be dragged down (in this case upto the beginning of bottom bar).
        bottomScrollOffset = (self.tabBarController?.tabBar.frame.origin.y)!
        
        //inner offset is the bottom space(gap) between bannerContentView and banner view.
        bannerInnerOffset = bannerViewHeight.constant - bannerContentsViewHeight.constant
    }
    
    private var user: UserMaster! = nil
    
    private func loadUserDetails() {
        user = nil
        
        user = fetchUser()
            
        if user != nil {
            
            if user.avatar != nil {
                avatar.image = UIImage(data: user.avatar! as Data)
            }
            
            greetingMessage.text = "Welcome, " + user.firstname! + ( (user.lastname != nil && user.lastname != "") ? (" " + user.lastname!) : "")
            
            var addressStr = user.address! + "\n"
            
            if user.city != nil {
                addressStr = addressStr + user.city! + " "
            }

            if user.state != nil {
                addressStr = addressStr + user.state! + " "
            }
            
            if user.zip != nil {
                addressStr = addressStr + user.zip!
            }
            
            if user.country != nil {
                addressStr = addressStr + "\n" + user.country!
            }

            addressLabel.text = addressStr
            
            if user.phone != nil {
                telephoneNumberLabel.text = user.phone
            }
            
            if user.email != nil {
                emailAddressLabel.text = user.email
            }
        }
    }
    
    private func fetchUser() -> UserMaster! {
        
        var user: UserMaster! = nil
        
        let fetchRequest: NSFetchRequest<UserMaster>! = UserMaster.fetchRequest()
        
        do{
            let users = try context.fetch(fetchRequest)
            if users.count > 0 {
                user = users[0]
            }
        } catch {
            print("\(error)")
        }
        
        return user
    }

    //MARK TabBar controller delegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController != self {
           clear()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("****** AccountsHomeVC: viewWillAppear")
        
/*        if self.tabBarController?.delegate == nil {
            self.tabBarController?.delegate = self
        }
*/
        customizeScreenControls()
        
        customizeNavigationBar()
    
        //set initial height of banner while launching screen
        bannerViewHeight.constant = topScrollOffset
        
        //adjust height of bannerContentView as per the new height of bannerView
        bannerContentsViewHeight.constant = bannerViewHeight.constant - bannerInnerOffset
        
        //adjust top margin of tableheader label as per the height of bannerview
        tableHeader.topAnchor.constraint(equalTo: (tableHeader.superview?.topAnchor)!, constant: bannerContentsView.frame.origin.y + bannerContentsViewHeight.constant).isActive = true

        //adjust top margin of tableview as per the position of the bannerview
//        tableView.topAnchor.constraint(equalTo: (tableView.superview?.topAnchor)!, constant: bannerContentsView.frame.origin.y + bannerContentsViewHeight.constant).isActive = true
        
        stackViewUserDetails.alpha = 0
        visualEffectView.alpha = 0.27
        
//        if markForRefresh {
            
            updateBellBadge()
            
            fetchAccounts()
            fetchCreditCardAccounts()
//            markForRefresh = false

            if tableView.delegate == nil {
                tableView.dataSource = self
                tableView.delegate = self
                oldAccentColor = currentAccentColor
            } else {
                tableView.reloadData()
                
                if isThemeChanged() {
                    oldAccentColor = currentAccentColor
                }
            }
//        }
    //}
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.delegate = nil
    }
    
    private func clear() {
        self.tabBarController?.delegate = nil
    }


    //update the count on the red bagde on bell image to show/hide number of (dummy)notifations received.
    private func updateBellBadge() {
        if user != nil {
            if user.profileupdatestatus == false {
                bellBadge.titleLabel?.text = "1"
                bellBadge.isHidden = false
            } else {
                bellBadge.isHidden = true
            }
        }
    }


    private func isThemeChanged() -> Bool {
        return oldAccentColor != currentAccentColor
    }


    private func customizeScreenControls() {
        let appStyler = AppStyleManager.sharedInstance()
        
        let splashStyler = appStyler?.get_splash_styler()
        let screenStyler = appStyler?.get_app_screen_styler()
        
        appLogoImage = splashStyler?.configure_app_logo(appLogoImage)
        bannerContentsView = screenStyler?.configure_primary_view_background(bannerContentsView)

        currentAccentColor = screenStyler?.get_accent_color()
        
        addAccountFloatingButton.backgroundColor = currentAccentColor
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
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            }catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    //MARK: PanGestureRecognizer selector method
    func move(_ sender: UIPanGestureRecognizer) {
        
        let currentPoint = sender.location(in: self.bannerView.superview)
        
        let currentYPosition = currentPoint.y
        let percentage = currentYPosition/CGFloat(SCREEN_HEIGHT)
        
        if percentage >= 0.70 {
            //show user details completly when banner is dragged sufficiently down
            stackViewUserDetails.alpha = 1.0
        } else if percentage <= 0.30 {
            //hide user details completly when banner is dragged sufficiently up
            stackViewUserDetails.alpha = 0.0
        } else {
            stackViewUserDetails.alpha = percentage
        }
        
        visualEffectView.alpha = fabs(percentage)
        
        // update heights of banner-view and banner-content-view as per pan value on screen
        UIView.animate(withDuration: 0.01, animations: {
            if (currentYPosition > self.topScrollOffset) && (currentYPosition <= self.bottomScrollOffset) {
                self.bannerViewHeight.constant = currentYPosition
                self.bannerContentsViewHeight.constant = self.bannerViewHeight.constant - self.bannerInnerOffset
            } else if currentYPosition < self.topScrollOffset {
                self.bannerViewHeight.constant = self.topScrollOffset
                self.bannerContentsViewHeight.constant = self.bannerViewHeight.constant - self.bannerInnerOffset
            }
        }, completion: nil)
    }
    
    
    // MARK: - TableView Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
/*        if let section = fetchResultController?.sections {
            return section.count
        }
*/
       return 2
        
//        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    let sectionHeaderTitleArray = ["BANKING ACCOUNT", "CREDIT CARD ACCOUNT"]
    //let sectionHeaderImageArray = ["account", "card_black"]

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect.init(x:0, y:0, width: 200, height:30))
        returnedView.backgroundColor = UIColor.init(rgb: 0xD8D8D8)
        
        /*
        let imageIcon = UIImage.init(named: sectionHeaderImageArray[section])
        let iconImageView = UIImageView.init(image: imageIcon)
        iconImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        iconImageView.contentMode = UIViewContentMode.scaleAspectFit

        returnedView.addSubview(iconImageView)

        iconImageView.centerYAnchor.constraint(equalTo: returnedView.centerYAnchor).isActive = true

        iconImageView.centerYAnchor.constraint(equalTo: returnedView.centerYAnchor).isActive = true
        */
        let label = UILabel(frame: CGRect(x:0, y:0, width:250, height:30))
        label.text = self.sectionHeaderTitleArray[section]
        returnedView.addSubview(label)
        
        let trailing = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: returnedView, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0)
        
        returnedView.addConstraint(trailing)

        
        return returnedView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return accountArray.count
        if section == 0 {
            if let sections = fetchResultController?.sections {
                let sectionInfo = sections[section]
                return sectionInfo.numberOfObjects
            }
        } else if section == 1 {
            return 1
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("cell count \(indexPath.row)")

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountCell
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountCell
            configureCreditCardCell(cell: cell, indexPath: indexPath)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "BANKING ACCOUNTS"
        } else {
            return "CREDIT CARD ACCOUNTS"
        }
    }

        
    func configureCell(cell: AccountCell, indexPath: IndexPath) {
        
        let account = fetchResultController.object(at: indexPath)
        cell.configureCell(account: account)
    }

    func configureCreditCardCell(cell: AccountCell, indexPath: IndexPath) {
        
        let ccAccount = fetchResultControllerCC.fetchedObjects?[indexPath.row]
        cell.configureCellForCreditCardAccount(card: ccAccount!)
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //open credit card tab when tapped on credit-card row
        if indexPath.section != 0 {
            self.tabBarController?.selectedIndex = 3
            return
        }

        if let objs = fetchResultController.fetchedObjects, objs.count > 0 {
            
            let account = objs[indexPath.row]
            performSegue(withIdentifier: "AccountTransactionSegue", sender: account)
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AccountTransactionSegue" {
            if let destination = segue.destination as? AccountTransactionHistoryVC {
                if let account = sender as? AccountsMaster {
                    destination.account = account
                }
            }
        }
    }

    //var idManager = IDManager()
    
    @IBAction func addNewAccount(_ sender: UIButton) {
    
//        let vc = BillDataPreviewViewController.init(nibName: "BillDataPreviewViewController", bundle: nil)
//        self.navigationController?.pushViewController(vc, animated: true)

//        let vc = IDSettingsViewController.init(nibName: "IDSettingsViewController", bundle: nil)
//        self.navigationController?.pushViewController(vc, animated: true)

//        let vc = RegionViewController.init(nibName: "RegionViewController", bundle: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
        
//        idManager.loadManager(navigationController: self.navigationController!)
    }

    // Mark: CoreData methods
    
    func fetchAccounts() {
        if fetchResultController == nil {
            let fetchRequest: NSFetchRequest<AccountsMaster> = AccountsMaster.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "accountNumber", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
        
            let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
          //  controller.delegate = self  //IMP for reloading the data after any changes into the database
        
            self.fetchResultController = controller
        }

        do {
            try self.fetchResultController.performFetch()
        } catch {
            let error = error as NSError
            print("\(error)")
            
            Utility.showAlert(onViewController: self, titleString: "Account Fetch Error", messageString: "Error occurred while fetching accounts.")
        }
    }
    
    func fetchCreditCardAccounts() {
        if fetchResultControllerCC == nil {
            let fetchRequest: NSFetchRequest<CreditCardMaster> = CreditCardMaster.fetchRequest()
            let dateSort = NSSortDescriptor(key: "expDate", ascending: true)
            fetchRequest.sortDescriptors = [dateSort]

            let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
            //controller.delegate = self  //IMP for reloading the data after any changes into the database
        
            self.fetchResultControllerCC = controller
        }
        
        do {
            try self.fetchResultControllerCC.performFetch()
        } catch {
            let error = error as NSError
            print("\(error)")
            
            Utility.showAlert(onViewController: self, titleString: "Credit Card Fetch Error", messageString: "Error occurred while fetching credit card account.")
        }
    }

    
/*
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .delete:
            if let indexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case .update:

            if let indexPath = newIndexPath {
                let cell = tableView.cellForRow(at: indexPath) as! AccountCell
                if indexPath.section == 0 {
                    configureCell(cell: cell, indexPath: indexPath)
                } else {
                    configureCreditCardCell(cell: cell, indexPath: indexPath)   //TODO: not updating credit card correctly
                }
            }
            break
        
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        }
        
    }
*/
    //Bell Notification badge on click 
    
    @IBAction func onNotificationClicked(_ sender: UIButton) {
        print("onNotificationClicked")
        
        showNotification()
    }
    
    // Notification
    
    private func showNotification() {
        
        if user != nil && user.profileupdatestatus == false {
            Utility.showAlertWithCallback(onViewController: self, titleString: "You have received 1 message", messageString: "You are required to update your profile.\n\nYou can take picture of your valid ID to update your profile details.", positiveActionTitle: "Update Now", negativeActionTitle: "Later", positiveActionResponse: {
                
                self.readUserID()
                
            }, negativeActionResponse: {
                

            })
        } else {
            Utility.showAlert(onViewController: self, titleString: "", messageString: "You have no new notifications.")
        }
    }
    
    
    private var idManager: IDManager! = nil
    
    private func readUserID() {
        if idManager != nil {
            idManager.unloadManager()
            idManager = nil
        }

        idManager = IDManager()
        idManager.delegate = self
        idManager.loadManager(navigationController: self.navigationController!)
    }

    //MARK: IDManager Delegate methods
    
    func IDDataReadCancelled() {
        print("User ID read was cancelled")
    }
    
    func IDDataReadFailed(error: AppError!) {
        
        var msg = String()
        if error != nil && error.message != nil {
            msg = error.message
        }
        print("User ID read failed with error: \(msg)")
    }
    
    func IDDataReadCompleteWithSelfieVerification(idData: kfxIDData!) {
        print("User ID read complete WITH selfie verification")
//        loadUserDetails()
        
        if idData.address != nil && idData.address.value != nil {
            print("New adress in idData is NOT empty. :)")
        } else {
            print("Error: New adress in idData is empty!")
            addressLabel.text = ""
        }
    }
    
    func IDDataReadCompleteWithoutSelfieVerification(idData: kfxIDData!) {
        print("User ID read complete WITHOUT selfie verification")
//        loadUserDetails()
        
        Utility.showAlert(onViewController: self, titleString: "Profile Details Updated", messageString: "\nYou can slide down your profile picture to see the details.")
    }
    //MARK: Profile import method
    
    private func initiateProfileImport(navController: UINavigationController) {
        let visibleViewController = navController.visibleViewController
        
        Utility.showAlertWithCallback(onViewController: visibleViewController!, titleString: "Profile Import Notification", messageString: "\nA new profile is waiting to be imported.\n\nDo you want to continue?", positiveActionTitle: "Import", negativeActionTitle: "Cancel", positiveActionResponse: {
            
            //import profile
            if (urlOfProfileBeingImported?.absoluteString.characters.count)! > 0 {
                
                AppStyleManager.sharedInstance().import_profile(navController, fileUrl: urlOfProfileBeingImported)
                
                Utility.showAlert(onViewController: visibleViewController!, titleString: "Profile Import Complete", messageString: "\nPlease see profile page to use new profile.")
            } else {
                Utility.showAlert(onViewController: visibleViewController!, titleString: "Profile Import Error", messageString: "Profile url is invalid or empty.")
            }
            
            requestedProfileImport = false
            
        }, negativeActionResponse: {
            
        })
    }
    
}
