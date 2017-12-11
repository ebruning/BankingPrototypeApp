//
//  Constants.swift
//  KofaxBank
//
//  Created by Rupali on 08/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import Foundation

//class Constants {
    // MARK: Userdefaults keys


typealias LoginComplete = ((Data?) -> Void)
typealias LoginFailed = ((Int) -> Void)
typealias LogoutComplete = (() -> Void)
typealias LogoutFailed = ((Int) -> Void)

//let applicationAccentColor: UIColor = AppStyleManager.sharedInstance().get_app_screen_styler().get_accent_color()
//let applicationAccentColor: UIColor = UIColor(red:1.00, green:0.77, blue:0.09, alpha:1.0)  //#FFC518 (musterd yellow)
let applicationTextColor: UIColor = UIColor(red:1.00, green:1.0, blue:1.0, alpha:1.0)

let applicationRedColor: UIColor = UIColor.init(rgb: 0xDD0004)
let applicationGreenColor: UIColor = UIColor.init(rgb: 0x1E7F26)
let applicationOrangeColor: UIColor = UIColor.init(rgb: 0xF5923E)

enum TransactionType: String {
    case DEBIT = "Debit"
    case CREDIT = "Credit"
}


enum CurrencyType: String {
    case DOLLER = "$"
    case POUND = "£"
    case EURO = "€"
}

enum ImageType: String {
    case FRONT_RAW = "frontRawImage"
    case FRONT_PROCESSED = "frontProcessedImage"
    case BACK_RAW = "backRawImage"
    case BACK_PROCESSED = "backProcessedImage"
}

enum CommandOptions {
    case CANCEL
    case RETAKE
    case USE
    case NONE
    case CAMERA
    case GALLERY
}

enum DocumentSide: Int {
    case FRONT
    case BACK
}

enum AppComponent {
    case CHECK
    case BILL
    case IDCARD
    case CREDITCARD
}


/*
enum ServerType: Int {
    case KTA
    case RTTI
}
*/
/*enum MimeType: String {
    case MIME_TYPE_TIFF = "tiff"
    case MIME_TYPE_JPEG = "jpeg"
}*/


let applicationCurrency = CurrencyType.DOLLER


let ShortDateFormatWithDay: String = "dd.MMM"
let ShortDateFormatWithMonth = "dd.MMM.yyyy"
let LongDateFormatWithNumericMonth: String = "MM.dd.yyyy"
let ShortDateFormatWithoutDay: String = "MM.yy"
let LongDateFormatWithNumericMonthAndTime: String = "MM.dd.yyyy hh:mm a"
let LongDateFormatWithTime = "dd.MMM.yyyy hh:mm a"
let InformalDateFormat = "MMM dd, yyyy"

//Creditcard costants
let STATUS_PENDING_FOR_APPROVAL = "Pending for approval"
let STATUS_ACTIVE = "Active"
let STATUS_EXPIRED = "Expired"

// KVO keys
//let KVOMenuKeyPathToObserve = "navigationbarShowMenu"


//NSUserDefaults keys
let KEY_VERY_FIRST_LOGIN: String = "keyVeryFirstLogin"

let KEY_TOUCH_ID_STATUS: String = "TouchIDStatus"
let DEFAULT_TOUCH_ID_STATUS: Bool! = nil

//for BillPay Settings
let KEY_BILLPAY_SERVER_URL: String = "keyBillPayServerURL"
let KEY_BILLPAY_PROCESS_IDENTITY_NAME: String = "keyBillPayProcessIdentityName"
let KEY_BILLPAY_SESSION_ID: String = "keyBillPaySessionID"
let KEY_BILLPAY_CAPTURE_GUIDANCE: String = "keyBillPayCaptureGuidance"


let DEFAULT_BILLPAY_SERVER_URL: String = "http://t4cgm8rclt1mnw5.asia.kofax.com/totalagility/services/sdk/"
let DEFAULT_BILLPAY_PROCESS_IDENTITY_NAME: String = "KofaxBillPaySync"
let DEFAULT_BILLPAY_SESSION_ID: String = "C640521793431F4486D4EF1586672385"
let DEFAULT_BILLPAY_CAPTURE_GUIDANCE: Bool = true

//for Check Settings
let KEY_CHECK_SERVER_URL: String = "keyCheckDepositServerURL"
let KEY_CHECK_PROCESS_IDENTITY_NAME: String = "keyCheckDepositProcessIdentityName"
let KEY_CHECK_SESSION_ID: String = "keyCheckDepositSessionID"
let KEY_CHECK_CAPTURE_GUIDANCE: String = "keyCheckCaptureGuidance"


let DEFAULT_CHECK_SERVER_URL: String = "http://t4cgm8rclt1mnw5.asia.kofax.com/totalagility/services/sdk/"
let DEFAULT_CHECK_PROCESS_IDENTITY_NAME: String = "KofaxCheckDepositSync"
let DEFAULT_CHECK_SESSION_ID: String = "C640521793431F4486D4EF1586672385"
let DEFAULT_CHECK_CAPTURE_GUIDANCE: Bool = true

//for Credit Card Settings
let KEY_CREDIT_CARD_URL: String = "keyCreditCardServerURL"
let KEY_CREDIT_CARD_PROCESS_IDENTITY_NAME: String = "keyCreditCardProcessIdentityName"
let KEY_CREDIT_CARD_SESSION_ID: String = "keyCreditCardSessionID"
let KEY_CREDIT_CARD_CAPTURE_GUIDANCE: String = "keyCreditCardCaptureGuidance"

let DEFAULT_CREDIT_CARD_SERVER_URL: String = "http://t4cgm8rclt1mnw5.asia.kofax.com/totalagility/services/sdk/"
let DEFAULT_CREDIT_CARD_PROCESS_IDENTITY_NAME: String = "KofaxCardCaptureSync"
let DEFAULT_CREDIT_CARD_SESSION_ID: String = "C640521793431F4486D4EF1586672385"
let DEFAULT_CREDIT_CARD_CAPTURE_GUIDANCE: Bool = true

//for ID Settings
let KEY_ID_SERVER_URL: String = "keyIDServerURL"
let KEY_ID_PROCESS_IDENTITY_NAME_1X: String = "keyIDProcessIdentityName1x"
let KEY_ID_PROCESS_IDENTITY_NAME_2X: String = "keyIDProcessIdentityName2x"
let KEY_ID_SESSION_ID: String = "keyIDSessionID"
let KEY_ID_MOBILE_ID_VERSION: String = "keyIDMobileIDVersion"
let KEY_ID_AUTHENTICATION_URL: String = "keyIDAuthenticationURL"
let KEY_ID_AUTHENTICATION_PROCESS_IDENTITY_NAME: String = "keyIDAuthenticationProcessIdentityName"
let KEY_ID_CAPTURE_GUIDANCE: String = "keyIDCaptureGuidance"

let DEFAULT_ID_SERVER_URL: String = "http://ktaperf02.kofax.com/TotalAgility/Services/SDK"
let DEFAULT_ID_PROCESS_IDENTITY_NAME_1X: String = "KofaxMobileIDSync"
let DEFAULT_ID_PROCESS_IDENTITY_NAME_2X: String = "KofaxMobileIDCaptureSync"
let DEFAULT_ID_SESSION_ID: String = "C640521793431F4486D4EF1586672385"
let DEFAULT_ID_MOBILE_ID_VERSION: String = MobileIDVersion.VERSION_2X.rawValue
let DEFAULT_ID_AUTHENTICATION_URL: String = "https://mobiledemo4.kofax.com/TotalAgility/Services/Sdk/JobService.svc/json/CreateJobSyncWithDocuments"
let DEFAULT_ID_AUTHENTICATION_PROCESS_IDENTITY_NAME: String = "KofaxMobileIdFacialRecognition"
let DEFAULT_ID_CAPTURE_GUIDANCE: Bool = true


//Server Response Codes

let REQUEST_SUCCESS = 200
let REQUEST_FAILURE = 500
let REQUEST_TIMEDOUT = -1001
let NONETWORK = -1009
let ODE_CLASSIFICATION_ERROR = 49163
let ODE_INSUFFICIENT_VOLUME_LICENSE = 28717
let CLASSIFICATION_ERROR_TYPE = "Classification"
let KTA_CLASSIFICATION_ERROR_CODE = 300
let EXTRACTION_FAILED_TAG = 9999


let STATIC_SERVER_FIELDS = "fields"





