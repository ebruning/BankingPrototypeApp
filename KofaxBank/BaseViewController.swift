//
//  BaseViewController.swift
//  KofaxBank
//
//  Created by Rupali on 03/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    var blurredView: UIImageView!

    var blurEffectView: UIVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    func createBlurViewInBackground() {
        //listen to notifications of the app states
        NotificationCenter.default.addObserver(self, selector: #selector(createScreenshotBlur), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeScreenshotBlur), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            }

    
    // Mark: - Screenshot blurring notification callback methods
    func createScreenshotBlur()  {
        //is device greater than 8
        if IOS_8_OR_LATER {

            // if #available(iOS 8.0, *) {  //--one way of checking OS version number
            
            /*
            //Another way to check and compare OS version is
            if  floor(NSFoundationVersionNumber) >= (NSFoundationVersionNumber_iOS_8_0) {
                
            }
            */

            if !UIAccessibilityIsReduceTransparencyEnabled() {
                self.view.backgroundColor = UIColor.clear
                let blurEffect = UIBlurEffect.init(style: .dark)
                blurEffectView = UIVisualEffectView.init(effect: blurEffect)
                blurEffectView.frame = self.view.bounds
                blurEffectView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
            
                self.view.addSubview(blurEffectView)
            }
            else {
                self.view.backgroundColor = UIColor.black
            }
            
        } else {
            var blurredImage = UIImageEffects.imageByApplyingLightEffect(to: takeSnapshotOfView(view: self.view))
            
            if self.blurredView == nil {
                self.blurredView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            }
            self.blurredView.contentMode = UIViewContentMode.scaleToFill
            self.blurredView.image = blurredImage
            self.view.addSubview(self.blurredView)
            blurredImage = nil
        }
        

    }
    
    func removeScreenshotBlur() {
        if IOS_8_OR_LATER {
            if (blurEffectView != nil) {
                self.blurEffectView.removeFromSuperview()
            }
            else {
                self.view.backgroundColor = UIColor.clear
            }
        } else {
            self.blurredView.removeFromSuperview()
        }
        
    }

    
    
    func takeSnapshotOfView(view: UIView) -> UIImage! {
        
        let reductionFactor: CGFloat = 1.25
        UIGraphicsBeginImageContext(CGSize.init(width: view.frame.size.width/reductionFactor, height: view.frame.size.height/reductionFactor))
        
        let isSnapShotViewAvailable = view.drawHierarchy(in: CGRect.init(x: 0, y: 0, width: view.frame.size.width/reductionFactor, height: view.frame.size.height/reductionFactor), afterScreenUpdates: false)
        
        
        if isSnapShotViewAvailable {
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            return image
        }
        
        UIGraphicsEndImageContext()
        return nil
    }
}

