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
    
    private func customizeNavigationBar() {
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        //remove back button title from navigationbar
        navigationController?.navigationBar.backItem?.title = ""
        let backImage = UIImage(named: "back_white")!
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "logout_white"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        customizeNavigationBar()
    }
    
    func logout() {
    }

}
