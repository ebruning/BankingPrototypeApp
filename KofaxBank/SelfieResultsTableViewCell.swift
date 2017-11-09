//
//  SelfieResultsTableViewCell.swift
//  KofaxBank
//
//  Created by Rupali on 08/11/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class SelfieResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    
    func configureCell(title: String, value: String!) {
        titleLabel.text = title
        
        valueLabel.text = value == nil ? "" : value
    }
    
    
}
