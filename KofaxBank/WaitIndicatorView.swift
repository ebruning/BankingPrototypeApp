//
//  WaitIndicatorView.swift
//  KofaxBank
//
//  Created by Rupali on 12/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class WaitIndicatorView: UIView {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var view: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /* Cince this class is a subclass of UIView, both the init methods are required in order to use our custom class in live rendering */
    //used for unarchieving the view
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        
    }


    func setupView() {
        
        loadFromNib()
        
        /// Adds a shadow to our view
        self.view.layer.cornerRadius = 8.0
        //self.view.backgroundColor = UIColor.white
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOpacity = 0.5
        self.view.layer.shadowRadius = 4.0
        self.view.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.visualEffectView.layer.cornerRadius = self.view.layer.cornerRadius
        self.visualEffectView.layer.masksToBounds = true
        
        //Be warned: generating shadows dynamically is expensive, because iOS has to draw the shadow around the exact shape of your view's contents. If you can, set the shadowPath property to a specific value so that iOS doesn't need to calculate transparency dynamically. For example, this creates a shadow path equivalent to the frame of the view:
        
        self.view.layer.shadowPath = UIBezierPath(rect: self.view.bounds).cgPath

        //Alternatively, ask iOS to cache the rendered shadow so that it doesn't need to be redrawn:
        
        //containerView.layer.shouldRasterize = true

    }
    
    private func loadFromNib() {
        Bundle.main.loadNibNamed("WaitIndicatorView", owner: self, options: nil)

        self.containerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func displayView(onView: UIView) {
        self.alpha = 0.0
        onView.addSubview(self.containerView)
        
        self.containerView.leftAnchor.constraint(equalTo: onView.leftAnchor).isActive = true
        self.containerView.rightAnchor.constraint(equalTo: onView.rightAnchor).isActive = true
        self.containerView.bottomAnchor.constraint(equalTo: onView.bottomAnchor).isActive = true
        self.containerView.topAnchor.constraint(equalTo: onView.topAnchor).isActive = true

    }

    func hideView() {
        DispatchQueue.main.async() {
            self.containerView.removeFromSuperview()
        }
    }
    
    deinit {
        print("Deinitialized WaitIndicator")
    }
    
}
