//
//  CreditCardTransactionData.swift
//  KofaxBank
//
//  Created by Rupali on 28/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import Foundation

class CreditCardTransactionData {
    private var _cardNumber: String!
    private var _transactionID: String!
    private var _type: TransactionType!
    private var _amount: Double = 0
    //private var _currencyType: CurrencyType = CurrencyType.DOLLER
    private var _vender: String!
    private var _venderCategory: String!
    private var _date: Date!
    private var _description: String!
    
    var cardNumber: String{
        get {
            return _cardNumber
        } set {
            _cardNumber = newValue
        }
    }

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
    var vender: String {
        get {
            return _vender
        } set {
            _vender = newValue
        }
    }
    
    var venderCategory: String {
        get {
            return _venderCategory
        } set {
            _venderCategory = newValue
        }
    }
    
    var date: Date {
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
}
