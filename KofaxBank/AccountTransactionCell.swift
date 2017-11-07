//
//  AccountTransactionCell.swift
//  KofaxBank
//
//  Created by Rupali on 23/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class AccountTransactionCell: UITableViewCell {

    @IBOutlet weak var venderLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func configureCell(transaction: AccountTransactionMaster) {
        var amount: Double = 0
        
        if transaction.type == TransactionType.DEBIT.rawValue {
            amount = (transaction.billTransaction?.amountDue)!
            venderLabel.text = transaction.billTransaction?.name
        } else {
            amount = (transaction.checkTransaction?.amount)!
            venderLabel.text = transaction.checkTransaction?.payee
        }
        //amountLabel.text = String(format: "%.2f", transaction.amount)
        
        let formattedString: String! = Utility.formatCurrency(format: CurrencyType.DOLLER.rawValue, amount: amount)!
        if formattedString != nil {
            if let transactionType = transaction.type {
                if transactionType.caseInsensitiveCompare("credit") == ComparisonResult.orderedSame{
                    amountLabel.textColor = UIColor.init(rgb: 0x1E5826) //dark shade of green for credit
                    amountLabel.text = formattedString
                } else {
                    amountLabel.textColor = UIColor.red
                    amountLabel.text = "(" + formattedString + ")"
                }
            }
        }
/*
        //MARK: Feedback
        if let transactionType = transaction.type {
            if transactionType.caseInsensitiveCompare("credit") == ComparisonResult.orderedSame{
                typeLabel.text = "CR."
            }
            else {
                typeLabel.text = "DB."
            }
        }
*/
        
        
        if let date = transaction.dateOfTransaction {
            let dateStr = Utility.dateToFormattedString(format: LongDateFormat, date: date as Date)
            
            dateLabel.text = dateStr
        }
        else {
            //if date is empty, add current date
            dateLabel.text = Utility.dateToFormattedString(format: LongDateFormat, date: Date())
        }
    }   
}
