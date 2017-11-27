//
//  SplashVC.swift
//  KofaxBank
//
//  Created by Rupali on 06/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import Foundation

class SplashVC: UIViewController {
    
    @IBOutlet weak var splashBackgroundImageView: UIImageView!
    
    @IBOutlet weak var splashLogoImageView: UIImageView!
    
    @IBOutlet weak var appTitleLabel: UILabel!
    
    @IBOutlet weak var appSubTitleLabel1: UILabel!
    @IBOutlet weak var appSubTitleLabel2: UILabel!
    @IBOutlet weak var appSubtitleDotLabel: UILabel!
    @IBOutlet weak var appTitleDividerLineView: UIView!
    
    @IBOutlet weak var footerLogoImageView: UIImageView!
    
    @IBOutlet weak var footerTextLabel: UILabel!
    
    private let TIMEOUT_INTERVAL = 2.0
    
    private var timer: Timer!
    
    
    //override statusbar method to hide it
    override var prefersStatusBarHidden: Bool {
        
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        customizeScreenControls()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set default background image
        runTimer()
    }

    
    private func customizeScreenControls() {
        
        let splashStyler = AppStyleManager.sharedInstance()?.get_splash_styler()
        
        let accentColor = AppStyleManager.sharedInstance()?.get_app_screen_styler().get_accent_color()

        self.view = splashStyler?.configure_view_background(self.view)
        self.splashLogoImageView = splashStyler?.configure_app_logo(splashLogoImageView)
        
        self.appTitleLabel = splashStyler?.configure_app_title(appTitleLabel)
        
        self.appSubTitleLabel1.textColor = accentColor
        self.appSubTitleLabel2.textColor = accentColor
        
        //self.appTitleDividerLineView.backgroundColor = accentColor
        //self.appSubtitleDotLabel.textColor = accentColor
        
        self.footerLogoImageView = splashStyler?.configure_footer_logo(footerLogoImageView)
    }
    
    
    private func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: TIMEOUT_INTERVAL, target: self, selector: (#selector(handleTimeoutEvent)), userInfo: nil, repeats: false)
    }
    
    func handleTimeoutEvent() {
        
        timer.invalidate()
        
        launchNextScreen()
        
    }
    
    
    private func launchNextScreen() {
        
        // Use fade animation to launch HomeViewController
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionFade //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
        //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom

        self.navigationController?.view.layer.add(transition, forKey: nil)
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: false)
        
        /**
         Important: set next viewcontroller as base(first) viewcontroller after splash screen is close.
         This will prevent the new first viewcontroller to go back to splash screen agian.
         */
        let newViewControllersSequenceArray: NSMutableArray = NSMutableArray(object: vc)
        navigationController?.setViewControllers(newViewControllersSequenceArray as! [UIViewController], animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        timer.invalidate()
        dismiss(animated: false, completion: nil)
    }
    
    
}

