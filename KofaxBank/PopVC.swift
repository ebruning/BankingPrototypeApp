//
//  PopVC.swift
//  KofaxBank
//
//  Created by Rupali on 28/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

protocol PopoverDelegate {
    func popoverRowSelectedWith(rowIndex: Int)
}

class PopVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!

    // MARK:- Delegate
    var delegate: PopoverDelegate?


    var cellHeight: CGFloat = 40
    var dataArr = [PopViewData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func loadPopupView(dataArr: [PopViewData]!) {
        if (dataArr != nil) {
            self.dataArr = dataArr
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count    //TODO: test cast to check when dataarray is null
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "popCell", for: indexPath) as? PopViewCell{
            
            cell.configureCell(image_name: dataArr[indexPath.row].imageName, title: dataArr[indexPath.row].titleText, subTitle: dataArr[indexPath.row].subTitleText)
            
            return cell
        }
        else {
            return PopViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.popoverRowSelectedWith(rowIndex: indexPath.row)
        
        dismiss(animated: false, completion: nil)
    }
}
