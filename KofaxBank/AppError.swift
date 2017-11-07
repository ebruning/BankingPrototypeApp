//
//  AppError.swift
//  KofaxBank
//
//  Created by Rupali on 04/09/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
class AppError: NSObject {
    
    private var _title: String!
    private var _message: String!
    
    var title: String! {
        get{
            return _title
        } set {
            _title = newValue
        }
    }
    
    
    var message: String! {
        get {
            return _message
        } set {
            _message = newValue
        }
    }
    
    override init() {
        
    }
}
