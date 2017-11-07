//
//  FloatingButton.swift
//  KofaxBank
//
//  Created by Rupali on 23/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

@IBDesignable class FloatingButton: UIButton {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
 
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    @IBInspectable var shadowColor: UIColor = UIColor.white {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }

    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 0){
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable var bgColor: UIColor = UIColor.lightGray {
        didSet {
            layer.backgroundColor = bgColor.cgColor
        }
    }

    
}
