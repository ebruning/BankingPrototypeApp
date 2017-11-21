//
//  MainTabBarController.swift
//  KofaxBank
//
//  Created by Rupali on 27/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UIPopoverPresentationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("****** MainTabbarController: viewWillAppear")
        customizeScreenControls()
        //customizeNavigationBar()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("****** MainTabbarController: viewDidAppear")
    }
        
    private func customizeScreenControls() {
        
        let screenStyler = AppStyleManager.sharedInstance()?.get_app_screen_styler()
        
        self.tabBar.tintColor = screenStyler?.get_accent_color()
    }
    
    private func customizeNavigationBar() {
        
        UIApplication.shared.isStatusBarHidden = false
        
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.tintColor = UIColor.white
        
        //remove back button title from navigationbar
        navigationController?.navigationBar.backItem?.title = ""
        let backImage = UIImage(named: "back_white")!
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        
        let logoutBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "logout_white"), style: UIBarButtonItemStyle.plain, target: self, action: nil)
        
        let menuBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "Menu Vertical white"), style: UIBarButtonItemStyle.plain, target: self, action: nil)

        self.navigationItem.rightBarButtonItems = [logoutBarButtonItem, menuBarButtonItem]
    }
    

 }
