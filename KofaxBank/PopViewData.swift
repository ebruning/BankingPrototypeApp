//
//  PopViewData.swift
//  KofaxBank
//
//  Created by Rupali on 28/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class PopViewData {
    private var _imageName: String!
    private var _titleText: String!
    private var _subTitleText: String!

    
    var imageName: String {
        get{
            return _imageName
        } set {
            _imageName = newValue
        }
    }
    
    var titleText: String {
        get {
            return _titleText
        } set {
            _titleText = newValue
        }
    }
    
    var subTitleText: String {
        get {
            return _subTitleText
        } set {
            _subTitleText = newValue
        }
    }


}
