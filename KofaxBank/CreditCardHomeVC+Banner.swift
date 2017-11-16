//
//  CreditCardHomeVC+Banner.swift
//  KofaxBank
//
//  Created by Rupali on 05/07/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

extension  CreditCardHomeVC  {
    
    func updateBanner(forCard: CreditCardMaster) {

        cardNumberLabel.text = forCard.cardNumber
        
        //dueAmountLabel.text = String.init(format: "%.2f", forCard.dueAmount)
        dueAmountLabel.text = Utility.formatCurrency(format: CurrencyType.DOLLER.rawValue, amount: forCard.dueAmount)
        
        if forCard.company != nil {
            cardTypeLabel.text = forCard.company?.uppercased()
        }
        
        if let expiryDate = forCard.expDate {
            expDateLabel.text = "\(Utility.dateToFormattedString(format: ShortDateFormatWithoutDay, date: expiryDate as Date))"
        }
    }

    
}
