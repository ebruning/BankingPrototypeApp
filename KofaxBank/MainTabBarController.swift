//
//  MainTabBarController.swift
//  KofaxBank
//
//  Created by Rupali on 27/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        customizeScreenControls()

        customizeNavigationBar()
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
        
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "logout_white"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    


    
    func logout() {
        
    }

}
