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

let applicationAccentColor: UIColor = UIColor(red:1.00, green:0.77, blue:0.09, alpha:1.0)  //#FFC518 (musterd yellow)
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

enum ComponentType {
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
let LongDateFormat: String = "MM.dd.yyyy"
let ShortDateFormatWithoutDay: String = "MM.yy"
let LongDateFormatWithNumericMonthAndTime: String = "MM.dd.yyyy hh:mm a"
let LongDateFormatWithTime = "dd.MMM.yyyy hh:mm a"

//Creditcard costants
let STATUS_PENDING_FOR_APPROVAL = "Pending for approval"
let STATUS_ACTIVE = "Active"
let STATUS_EXPIRED = "Expired"

//NSUserDefaults keys
let EverLoggedInPast: String = "EverLoggedInPast"

let TouchIDStatus: String = "TouchIDStatus"




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

