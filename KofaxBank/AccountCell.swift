//
//  AccountCell.swift
//  KofaxBank
//
//  Created by Rupali on 22/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {

    @IBOutlet weak var accountTitleLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var accountStatusLabel: UILabel!
  
    private func customizeScreenControls() {
        let screenStyler = AppStyleManager.sharedInstance().get_app_screen_styler()
        accountTitleLabel.textColor = screenStyler?.get_accent_color()
    }
    
    func configureCell(account: AccountsMaster) {
        customizeScreenControls()
        
        accountTitleLabel.text = account.accounttype
        
        //accountNumberLabel.text = account.accountNumber
        accountNumberLabel.text = Utility.maskString(nonMaskedString: account.accountNumber, visibleCharacterCount: 4)
        //let numberFormatter = NumberFormatter()
        //numberFormatter.numberStyle = NumberFormatter.Style.currency
        //numberFormatter.currencyCode = "USD"    //"GBP" - Pound, "EUR" - Euro
        
        let formattedString = Utility.formatCurrency(format: CurrencyType.DOLLER.rawValue, amount: account.balance)

        if formattedString != nil {
            //accountBalanceLabel.text =  String(format: "%.2f", account.balance)
            accountBalanceLabel.text = formattedString
        } else {
            accountBalanceLabel.text = "$0.0"
        }
    }
    
    func configureCellForCreditCardAccount(card: CreditCardMaster) {
        
        customizeScreenControls()
        
        accountTitleLabel.text = "Credit Card"

        accountNumberLabel.text = Utility.maskString(nonMaskedString: card.cardNumber, visibleCharacterCount: 4)
        
        let formattedString = Utility.formatCurrency(format: CurrencyType.DOLLER.rawValue, amount: card.availableBalance)
        accountBalanceLabel.text = formattedString
        
        if card.cardStatus != STATUS_ACTIVE {
            if card.cardStatus == STATUS_EXPIRED {
                accountStatusLabel.textColor = applicationRedColor
                accountStatusLabel.text = "Expired"
            } else if card.cardStatus == STATUS_PENDING_FOR_APPROVAL  {
                accountStatusLabel.textColor = applicationOrangeColor
                accountStatusLabel.text = "Pending"
            }
            accountStatusLabel.isHidden = false
        } else {
            accountStatusLabel.text = ""
            accountStatusLabel.isHidden = true
        }
    }

    

    
}
