//
//  UIView+ customization.swift
//  KofaxBank
//
//  Created by Rupali on 06/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

extension UIView {
    func customizeBorderColor(color: UIColor) {
        
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5   
    }
    
    func changeHeight(toHeight: CGFloat) {
        let width = self.bounds.width
        let x = self.frame.origin.x
        let y = self.frame.origin.y
        
        self.frame = CGRect.init(x: x, y: y, width: width, height: toHeight)
    }
}
