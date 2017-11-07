//
//  MoreViewController.swift
//  KofaxBank
//
//  Created by Rupali on 28/07/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        customizeNavigationBar()
    }
    
    @IBAction func resetData(_ sender: UIButton) {
        
    }

    private func customizeNavigationBar() {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        navigationController?.navigationBar.tintColor = UIColor.darkGray
    }

}
