//
//  AppDelegate.swift
//  KofaxBank
//
//  Created by Rupali on 30/05/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        customizeNavigationBar(application: application)
        
        //TODO: move license check at appropriate place
        // Set Kofax SDK license. Replace the MyLicenseString below with your license string.
        if(kfxLicense.setMobileSDK("COPY LICENSE KEY HERE")
            == false) {
            print("Error: Kofax license is not valid or expired!");
        }
        
        checkDataStore()
        
        loadDefaults()
        return true
    }
    
    func customizeNavigationBar(application: UIApplication) {
        //make navigationbar transparent
        let navigationController = application.windows[0].rootViewController as! UINavigationController
        
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.backgroundColor = UIColor.clear
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "KofaxBank")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func checkDataStore() {
        
        let fetchRequest: NSFetchRequest<UserMaster> = UserMaster.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            
            if count == 0 {
                // if core data is empty, insert user information in care data
                loadSampleUserDetails()
            }
        }catch {
            fatalError("Error in fetching user sample data!")
        }
    }
    
    func loadSampleUserDetails() {
        
        let url = Bundle.main.url(forResource: "sample_data", withExtension: "json")
        
        do {
            let data = try Data.init(contentsOf: url!)
            
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            print("jsonResult : \(jsonResult)")
            
            let userObject = jsonResult.value(forKey: "user") as! NSDictionary
            
            
            // let user = NSEntityDescription.insertNewObject(forEntityName: "UserMaster", into: context) as! UserMaster
            
            let user = UserMaster(context: context)
            
            user.firstname = userObject["firstname"] as? String
            user.middlename = userObject["middlename"] as? String
            
            user.lastname = userObject["lastname"] as? String
            if let birthDate:Date? = Utility.convertStringToDate(format: LongDateFormat, dateStr: (userObject["birthdate"] as? String)) {   //TODO: put this null check for every date field
                user.birthdate = birthDate! as NSDate
            }
            
            user.phone = userObject["phone"] as? String
            user.email = userObject["email"] as? String
            user.address = userObject["city"] as? String
            
            
            //add accounts
            let accountArray = userObject.value(forKey: "accounts") as! NSArray
            
            for index in 0...accountArray.count-1 {
                let accountMaster = AccountsMaster(context: context)
                
                let aObject = accountArray[index] as! [String : AnyObject]
                
                accountMaster.accountNumber = aObject["accountnumber"] as? String
                accountMaster.openingDate = Utility.convertStringToDate(format: LongDateFormat, dateStr: (aObject["openingdate"] as? String))! as NSDate //aObject["openingdate"] as? NSDate
                accountMaster.accounttype = aObject["type"] as? String
                accountMaster.balance = (aObject["balance"] as! NSString).doubleValue
                
                //    accountMaster.user = user
                user.addToAccounts(accountMaster)
                
                //add transactions
                let transactionArray = aObject["transactions"] as! NSArray
                
                for index1 in 0...transactionArray.count-1 {
                    let tObject = transactionArray[index1] as! [String : AnyObject]

                    let transaction = AccountTransactionMaster(context: context)
                    transaction.account = accountMaster
                    transaction.type = tObject["type"] as? String
                    
                    if (tObject["date"] as? String != nil) {
                        transaction.dateOfTransaction = Utility.convertStringToDate(format: LongDateFormat, dateStr: (tObject["date"] as? String))! as NSDate
                    }

                    if transaction.type == TransactionType.DEBIT.rawValue {
                        let billTransaction = BillTransactions(context: context)
                        
                        billTransaction.amountDue = (tObject["amount"] as! NSString).doubleValue
                        billTransaction.billDate = nil
                        billTransaction.dueDate = nil
                        billTransaction.name = tObject["payeename"] as? String
                        billTransaction.comment = tObject["comment"] as? String
                        billTransaction.transactionMaster = transaction
                        
                        transaction.billTransaction = billTransaction
                        
                        if billTransaction.name != nil {
                            var billerMasterObj = retrieveBillerMasterObject(forName: billTransaction.name!)

                            if billerMasterObj == nil {
                                billerMasterObj = BillerMaster(context: context)
                                billerMasterObj?.name = billTransaction.name
                            }
                            billerMasterObj?.addToBillTransactions(billTransaction)
                        }
                    }
                    else {
                        let checkTransaction = CheckTransactions(context: context)
                        checkTransaction.checkNumber =  tObject["checknumber"] as? String
                        checkTransaction.payee = tObject["payeename"] as? String
                        checkTransaction.comment = tObject["comment"] as? String
                        checkTransaction.paymentDate = nil
                        checkTransaction.amount = (tObject["amount"] as! NSString).doubleValue
                        checkTransaction.transactionMaster = transaction

                        transaction.checkTransaction = checkTransaction
                    }
                    accountMaster.addToTransactions(transaction)
                }
            }
            
            //add credit card
            let ccArray = userObject.value(forKey: "creditcards") as! NSArray
            
            for index in 0...ccArray.count-1 {
                let ccMaster = CreditCardMaster(context: context)
                
                let ccObject = ccArray[index] as! [String : AnyObject]
                
                ccMaster.cardNumber = ccObject["cardnumber"] as? String
                ccMaster.company = ccObject["company"] as? String
                
                ccMaster.expDate = Utility.convertStringToDate(format: LongDateFormat, dateStr: ccObject["expdate"] as? String) as NSDate?//ccObject["expdate"] as? NSDate
                
                print("Formatted exp DAte-----> \(Utility.dateToFormattedString(format: LongDateFormatWithTime, date: ccMaster.expDate! as Date))")
                
                ccMaster.creditLimit = (ccObject["creditlimit"] as! NSString).doubleValue
                ccMaster.availableBalance = (ccObject["availablebalance"] as! NSString).doubleValue
                ccMaster.dueAmount = (ccObject["dueamount"] as! NSString).doubleValue
                ccMaster.cardStatus = ccObject["cardstatus"] as? String

                //ccMaster.user = user
                user.addToCreditcard(ccMaster)
                
                //add credit card transactions
                let transactionArray = ccObject["transactions"] as! NSArray
                
                for index1 in 0...transactionArray.count-1 {
                    let transaction = CreditCardTransactions(context: context)
                    
                    let tObject = transactionArray[index1] as! [String : AnyObject]
                    
                    transaction.transactionId = tObject["id"] as? String
                    transaction.date = Utility.convertStringToDate(format: LongDateFormat, dateStr: (tObject["date"] as? String))! as NSDate//tObject["date"] as? NSDate
                    transaction.amount = (tObject["amount"] as! NSString).doubleValue
                    transaction.vender = tObject["vender"] as? String
                    transaction.venderCategory = tObject["vendercategory"] as? String
                    transaction.transactionDescription = tObject["description"] as? String
                    transaction.type = tObject["type"] as? String
                    
                    //transaction.creditcard = ccMaster
                    ccMaster.addToTransactions(transaction)
                }
            }
            self.saveContext()
            
        } catch {
            fatalError("Error in loading sample data")
        }
    }


    private func retrieveBillerMasterObject(forName: String) -> BillerMaster! {
        var billerMasterObj: BillerMaster! = nil
        
        let fetchRequest: NSFetchRequest<BillerMaster> = BillerMaster.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", forName)
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var controller: NSFetchedResultsController! = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try controller.performFetch()
            if controller.fetchedObjects != nil && (controller.fetchedObjects?.count)! > 0 {
                let recordCount = (controller.fetchedObjects?.count)!
                billerMasterObj = controller.fetchedObjects?[0]
                
                print("Number if existing billers found in billMaster are: \(recordCount)")
            } else {
                print("NO existing billers found in billMaster")
            }

        } catch {
            let error = error as NSError
            print("\(error)")
        }

        controller = nil
        
        return billerMasterObj
    }
    
    
    
    private func loadDefaults() {
        
        if UserDefaults.standard.value(forKey: KEY_DEFAULTS_LOADED) != nil {
            return
        }
        
        //region properties
        UserDefaults.standard.setValue(ID_DEFAULT_REGION_PROPERTIES_MODEL_FILE, forKey: KEY_ID_REGION_PLIST_FILE_NAME)
        
        UserDefaults.standard.setValue(ID_DEFAULT_REGION_PROPERTIES_REGION_NAME, forKey: KEY_ID_REGION_NAME)
        UserDefaults.standard.setValue(ID_DEFAULT_REGION_PROPERTIES_COUNTRY_CODE, forKey: KEY_ID_COUNTRY_CODE)
        UserDefaults.standard.setValue(ID_DEFAULT_REGION_PROPERTIES_COUNTRY_DISPLAY_NAME, forKey: KEY_ID_COUNTRY_NAME)
        UserDefaults.standard.setValue(ID_DEFAULT_REGION_PROPERTIES_FLAG_IMAGE_NAME, forKey: KEY_ID_REGION_FLAG_NAME)
        UserDefaults.standard.setValue(ID_DEFAULT_REGION_PROPERTIES_IMAGE_RESIZE, forKey: KEY_ID_IMAGE_RESIZE)
        
        
        //Mobile ID Version - default 2x
        UserDefaults.standard.set(ServerVersion.VERSION_2X.rawValue, forKey: KEY_ID_MOBILE_ID_VERSION)
        
        UserDefaults.standard.setValue(true, forKey: KEY_DEFAULTS_LOADED)
    }

}





let ad = UIApplication.shared.delegate as! AppDelegate
let context = ad.persistentContainer.viewContext
