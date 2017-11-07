//
//  BillData.swift
//  KofaxBank
//
//  Created by Rupali on 25/07/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class BillData: NSObject {

    private var _accountTitle: String!
    private var _accountNumber: String!
    private var _accontBalance: Double = 0.0
    
    var accountTitle: String {
        get {
            return _accountTitle
        } set {
            _accountTitle = newValue
        }
    }

    
}
