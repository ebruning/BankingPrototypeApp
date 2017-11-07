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
    
    let TIMEOUT_INTERVAL = 2.0
    
    var timer = Timer()
    
    //override statusbar method to hide it
    override var prefersStatusBarHidden: Bool {
        
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        navigationController?.setNavigationBarHidden(true, animated: false)
        //navigationController?.isNavigationBarHidden = true
        
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        runTimer()
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: TIMEOUT_INTERVAL, target: self, selector: (#selector(handleTimeoutEvent)), userInfo: nil, repeats: false)
    }
    
    func handleTimeoutEvent() {
        
        timer.invalidate()
        
        launchNextScreen()
        
    }
    
    
    func launchNextScreen() {
        
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

