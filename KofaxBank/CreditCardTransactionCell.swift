//
//  CreditCardTransactionCell.swift
//  KofaxBank
//
//  Created by Rupali on 02/11/17.
//  Copyright © 2017 kofax. All rights reserved.
//

//
//  AccountTransactionCell.swift
//  KofaxBank
//
//  Created by Rupali on 23/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class CreditCardTransactionCell: UITableViewCell {
    
    @IBOutlet weak var transactionIDLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var venderLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    func configureCell(transaction: CreditCardTransactions) {
        venderLabel.text = transaction.vender
        //amountLabel.text = String(format: "%.2f", transaction.amount)
        
        let formattedString: String! = Utility.formatCurrency(format: CurrencyType.DOLLER.rawValue, amount: transaction.amount)!

        if formattedString != nil {
            if let transactionType = transaction.type {
                if transactionType.caseInsensitiveCompare("Credit") == ComparisonResult.orderedSame{
                    amountLabel.textColor = UIColor.init(rgb: 0x1E5826) //dark shade of green for credit
                    amountLabel.text = formattedString
                } else {
                    amountLabel.textColor = UIColor.red
                    amountLabel.text = "(" + formattedString + ")"
                }
            }
        }

        if transaction.transactionId != nil {
            transactionIDLabel.text = transaction.transactionId
        }
        
        
        //descriptionLabel.text = transaction.description
        
        if let date = transaction.date {
            let dateStr = Utility.dateToFormattedString(format: LongDateFormat, date: date as Date)
            
            transactionDateLabel.text = dateStr
        }
        else {
            //if date is empty, add current date
            transactionDateLabel.text = ""
        }
    }
}
