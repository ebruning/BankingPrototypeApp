//
//  DocumentsHomeVC.swift
//  KofaxBank
//
//  Created by Rupali on 27/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class DocumentsHomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customizeNavigationBar()
    }

    private func customizeNavigationBar() {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        navigationController?.navigationBar.tintColor = UIColor.darkGray
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
