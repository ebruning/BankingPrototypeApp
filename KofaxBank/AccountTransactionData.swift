//
//  AccountTransactionData.swift
//  KofaxBank
//
//  Created by Rupali on 23/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import Foundation

class AccountTransactionData {
 
    private var _transactionID: String!
    private var _type: TransactionType!
    private var _amount: Double = 0
  //  private var _currencyType: CurrencyType = CurrencyType.DOLLER
    private var _payeeName: String = ""
    private var _date: String!
    private var _description: String = ""
    private var _checkNumber: String = ""
    
    var transactionID: String{
        get {
            return _transactionID
        } set {
            _transactionID = newValue
        }
    }
    
    var type: TransactionType {
        get {
            return _type;
        } set {
            _type = newValue
        }
    }
    
    var amount: Double {
        get {
            return _amount
        } set {
            _amount = newValue
        }
    }
/*
    var currencyType: CurrencyType {
        get {
            return _currencyType
        } set {
            _currencyType = newValue
        }
    }
*/
    var payeeName: String {
        get {
            return _payeeName
        } set {
            _payeeName = newValue
        }
    }
    
    var date: String {
        get {
            return _date
        } set {
            _date = newValue
        }
    }
    
    var description: String {
        get {
            return _description
        } set {
            _description = newValue
        }
    }

    var checkNumber: String {
        get {
            return _checkNumber
        } set {
            _checkNumber = newValue
        }
    }

    
    init(transactionDict: [String: Any]) {
        
        if let id = transactionDict["id"] as? String {
            self.transactionID = id
        }
        
        if let type = transactionDict["type"] as? String {
            self.type = TransactionType(rawValue: type)!
        }
        
        if let amount = transactionDict["amount"] as? Double {
            self.amount = amount
            //self.amount = Utility.formatCurrency(format: CurrencyType.DOLLER.rawValue , amount: amount)
        }
        
/*        if let currency = transactionDict["currency"] as? String {
            self.currencyType = CurrencyType(rawValue: currency)!
        }
*/
        if let payeeName = transactionDict["payee"] as? String {
            self.payeeName = payeeName
        }

        if let date = transactionDict["date"] as? String {
            self.date = date
        }

        if let description = transactionDict["description"] as? String {
            self.description = description
        }
        
        if let checkNumber = transactionDict["checknumber"] as? String {
            self.checkNumber = checkNumber
        }

    }

}

