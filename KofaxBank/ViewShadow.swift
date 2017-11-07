//
//  ViewShadow.swift
//  KofaxBank
//
//  Created by Rupali on 27/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

@IBDesignable class ViewShadow: UIView {

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setShadow()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setShadow()
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    
    func setShadow() {
        self.layer.shadowOffset = CGSize.init(width: 3, height: 3)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.gray.cgColor
        //self.layer.shadowRadius = 5
        self.layer.masksToBounds = false
    }
}
