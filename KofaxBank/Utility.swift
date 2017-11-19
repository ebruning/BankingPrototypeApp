//
//  Utility.swift
//  KofaxBank
//
//  Created by Rupali on 12/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit
import CoreData

//is device greater than 8
let IOS_8_OR_LATER: Bool = floor(NSFoundationVersionNumber) >= (NSFoundationVersionNumber_iOS_8_0)

class Utility {
    
    typealias PositiveActionResponse = () -> Void
    typealias NegativeActionResponse = () -> Void

    //is device greater than 8
/*
    class func isiOS8OrGreater() -> Bool {
        
        let systemVersion: UInt = UInt.init(UIDevice.current.systemVersion)!
        
        return systemVersion >= 8
    }
   */
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return isReachable && !needsConnection
    }

    
     class func showAlert(onViewController: UIViewController, titleString: String, messageString: String!) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: titleString as String, message: messageString as String!, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            
            alert.addAction(okAction)
            
            onViewController.present(alert, animated: true, completion: nil)
        }
    }

    
    class func showAlertWithCallback(onViewController: UIViewController, titleString: String, messageString: String!, positiveActionTitle: String, negativeActionTitle: String!, positiveActionResponse: @escaping PositiveActionResponse, negativeActionResponse: @escaping NegativeActionResponse) {
        DispatchQueue.main.async {

        let alert = UIAlertController(title: titleString as String, message: messageString as String!, preferredStyle: UIAlertControllerStyle.alert)
        
        if negativeActionTitle != nil {
            let nAction = UIAlertAction(title: negativeActionTitle, style: UIAlertActionStyle.cancel, handler: { action in
                negativeActionResponse()
            })
            alert.addAction(nAction)
        }
        let pAction = UIAlertAction(title: positiveActionTitle, style: UIAlertActionStyle.default, handler: { action in
            positiveActionResponse()
        })
        alert.addAction(pAction)
        
        onViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    
    class func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    

    class func getDateFormatter(format: String) -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = format
        
        //use current timezone
        //TODO: time zone is not being updating properply. comeback to this later.
        df.timeZone =  TimeZone.current //Locale(identifier: "en_IN_POSIX")
        return df
    }
    
    
    class func formatDate(format: String, date: Date) -> Date {
        let df = getDateFormatter(format: format)
        return convertStringToDate(format: format, dateStr: df.string(from: date))
    }
    
    class func dateToFormattedString(format: String, date: Date) -> String { //TODO: write test case to check with invalid date
        let df = getDateFormatter(format: format)
        return df.string(from: date);
    }
    
    
    class func convertStringToDate(format: String!, dateStr: String!) -> Date! {
        var newDate: Date! = nil

        if format != nil {
            let df = getDateFormatter(format: format)
            //df.locale = Locale(identifier: "en_IN")
            newDate = df.date(from: dateStr)
        }
        return newDate
    }
    
    
    class func validateDate(format: String!, dateStr: String!) -> Bool {
        
        var isValid = false
        
        let newDate = convertStringToDate(format: format, dateStr: dateStr)
        if newDate != nil {
            print("date is valid")
            isValid = true
        } else {
            print("date is invalid")
        }
        return isValid
    }
    

    class func formatCurrency(format: String!, amount: Double!) -> String! {
        
        if amount == nil {
            return nil
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        
        if format != nil {
            //numberFormatter.currencySymbol = format
        }
        
        numberFormatter.locale = Locale(identifier: "en_US")
        //en_US - USA
        //au_AU - Australia
        //en_IN - India
        //en_UK - English in UK
        //en_EU - Europe
        //en_FR - english in France
        //https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPInternational/LanguageandLocaleIDs/LanguageandLocaleIDs.html#//apple_ref/doc/uid/10000171i-CH15-SW1
        
        
        
        let formattedNumberString = numberFormatter.string(from: NSNumber(floatLiteral: amount))
        
        return formattedNumberString
    }
    
    class func mapSDKStatus(status: Int) -> NSError {
        let dictUserInfo: NSMutableDictionary = NSMutableDictionary.init()
        dictUserInfo.setValue(kfxError.findErrDesc(Int32(status)), forKey: NSLocalizedDescriptionKey)
        return NSError.init(domain: "", code: status, userInfo: dictUserInfo as? [AnyHashable : Any])
    }
    
    
    // method used for (generally) masking account numbers.
    class func maskString(nonMaskedString: String!, visibleCharacterCount: Int) -> String! {
        var maskedString: String! = nil
        
        if nonMaskedString == nil {
            return maskedString
        }
        else if visibleCharacterCount >= nonMaskedString.characters.count {
            return maskedString
        }

        let conditionIndex = nonMaskedString.characters.count - visibleCharacterCount
        maskedString = String(nonMaskedString.characters.enumerated().map { (index, element) -> Character in
            return index < conditionIndex ? "x" : element
        })
        print("Masked String: ", maskedString) //e.g. xxxxxxx789
        
        return maskedString
    }
    
    
    
    class func getImage(base64String: String!) -> UIImage! {
        
        var outputImage: UIImage! = nil
        
        if base64String == nil || base64String.characters.count == 0 {
                return nil;
            }
        
        let imgData = NSData(base64Encoded: base64String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) as Data!
        
        if imgData != nil {
            outputImage = UIImage(data: imgData!)
        }
        
        return outputImage
    }
    
    
    class func loadDatabaseWithDefaultsIfEmpty() {
        
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

    
    
   class func loadSampleUserDetails() {
        
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
            if let birthDate:Date? = Utility.convertStringToDate(format: LongDateFormatWithNumericMonth, dateStr: (userObject["birthdate"] as? String)) {   //TODO: put this null check for every date field
                user.birthdate = birthDate! as NSDate
            }
            
            user.phone = userObject["phone"] as? String
            user.email = userObject["email"] as? String
            user.address = userObject["address"] as? String
            user.city = userObject["city"] as? String
            user.state = userObject["state"] as? String
            user.country = userObject["country"] as? String
            user.zip = userObject["zip"] as? String
            
            //add accounts
            let accountArray = userObject.value(forKey: "accounts") as! NSArray
            
            for index in 0...accountArray.count-1 {
                let accountMaster = AccountsMaster(context: context)
                
                let aObject = accountArray[index] as! [String : AnyObject]
                
                accountMaster.accountNumber = aObject["accountnumber"] as? String
                accountMaster.openingDate = Utility.convertStringToDate(format: LongDateFormatWithNumericMonth, dateStr: (aObject["openingdate"] as? String))! as NSDate //aObject["openingdate"] as? NSDate
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
                        transaction.dateOfTransaction = Utility.convertStringToDate(format: LongDateFormatWithNumericMonth, dateStr: (tObject["date"] as? String))! as NSDate
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
                                
                                user.addToBillers(billerMasterObj!)
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
                
                ccMaster.expDate = Utility.convertStringToDate(format: LongDateFormatWithNumericMonth, dateStr: ccObject["expdate"] as? String) as NSDate?//ccObject["expdate"] as? NSDate
                
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
                    transaction.date = Utility.convertStringToDate(format: LongDateFormatWithNumericMonth, dateStr: (tObject["date"] as? String))! as NSDate//tObject["date"] as? NSDate
                    transaction.amount = (tObject["amount"] as! NSString).doubleValue
                    transaction.vender = tObject["vender"] as? String
                    transaction.venderCategory = tObject["vendercategory"] as? String
                    transaction.transactionDescription = tObject["description"] as? String
                    transaction.type = tObject["type"] as? String
                    
                    //transaction.creditcard = ccMaster
                    ccMaster.addToTransactions(transaction)
                }
            }
            ad.saveContext()
            
        } catch {
            fatalError("Error in loading sample data")
        }
    }
    

    class func retrieveBillerMasterObject(forName: String) -> BillerMaster! {
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

    
}
