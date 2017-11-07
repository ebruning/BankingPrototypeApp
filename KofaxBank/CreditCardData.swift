//
//  CreditCardData.swift
//  KofaxBank
//
//  Created by Rupali on 28/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import Foundation

class CreditCardData {
    private var _cardNumber: String = ""
    private var _type: String = ""
    private var _expiryDate = Date()
    private var _userID: String = ""
    private var _statementDate = Date()
    private var _dueDate = Date()
    private var _creditLimit: Float = 0.0
    private var _availableBalance: Float = 0.0
    private var _currentSpening: Float = 0.0

    var cardNumber: String {
        get {
            return _cardNumber
        } set {
            _cardNumber = newValue
        }
    }
    
    var type: String {
        get {
            return _type
        } set {
            _type = newValue
        }
    }
    
    var expiryDate: Date {
        get {
            return _expiryDate
        } set {
            _expiryDate = newValue
        }
    }

    
    var userID: String {
        get {
            return _userID
        } set {
            _userID = newValue
        }
    }
    
    var statementDate: Date {
        get {
            return _statementDate
        } set {
            _statementDate = newValue
        }
    }

    var dueDate: Date {
        get {
            return _dueDate
        } set {
            _dueDate = newValue
        }
    }

    var creditLimit: Float {
        get {
            return _creditLimit
        } set {
            _creditLimit = newValue
        }
    }

    var availableBalance: Float {
        get {
            return _availableBalance
        } set {
            _availableBalance = newValue
        }
    }

    var currentSpening: Float {
        get {
            return _currentSpening
        } set {
            _currentSpening = newValue
        }
    }

}
