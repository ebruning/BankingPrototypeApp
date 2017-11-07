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
    
    
    
}
