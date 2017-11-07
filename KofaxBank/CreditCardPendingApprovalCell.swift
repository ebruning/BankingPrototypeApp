//
//  CreditCardPendingApprovalCell.swift
//  KofaxBank
//
//  Created by Rupali on 28/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class CreditCardPendingApprovalCell: UITableViewCell {

    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var issueDateLabel: UILabel!
    @IBOutlet weak var expDateLabel: UILabel!
    @IBOutlet weak var commandButtonContainerView: UIStackView!
    
    func configureCell(card: CreditCardMaster) {
        
        cardNumberLabel.text = card.cardNumber
        companyLabel.text = card.company
        
        if card.expDate != nil {
            expDateLabel.text = "\(Utility.formatDate(format: ShortDateFormatWithoutDay, date: card.expDate as Date!))"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

 
    func hideCommandBarView(tableView: UITableView) {
        self.commandButtonContainerView.isHidden = true
        
    }
    
    func showCommandBarView(tableView: UITableView) {
        self.commandButtonContainerView.isHidden = false
    }
}
