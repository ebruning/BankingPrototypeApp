//
//  AccountTransactionHistoryVC.swift
//  KofaxBank
//
//  Created by Rupali on 23/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData

class AccountTransactionHistoryVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var appLogoImage: UIImageView!

    @IBOutlet weak var bannerContainerView: UIView!

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet var tableHeadingLabels: [UILabel]!

    @IBOutlet var instructionsView: UIView!
    
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var accountNumber: UILabel!
    @IBOutlet weak var accountBalance: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    
    var account: AccountsMaster?
    
    private var fetchResultController: NSFetchedResultsController<AccountTransactionMaster>!

    private var selectedTableRowIndex: Int = 0
    
    private var accentColor = UIColor()
    
    //MARK: statusbar content color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        customizeNavigationBar()

        instructionsView.isHidden = false
        tableView.isHidden = true

        attemptFetch() //default sort is with date

        updateAccountDetailsOnBanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customizeScreenControls()
    }
    
    override func viewDidAppear(_ animated: Bool) {

        //return if table is already loaded
        if fetchResultController != nil {
            if tableView.isHidden {
                
                if tableView.delegate == nil {
                    tableView.delegate = self
                    tableView.dataSource = self
                    tableView.reloadData()
                }

                updateTableVisibility()
            }
        }
    }

    
    private func customizeScreenControls() {
        let appStyler = AppStyleManager.sharedInstance()
        
        let splashStyler = appStyler?.get_splash_styler()
        let screenStyler = appStyler?.get_app_screen_styler()
        
        appLogoImage = splashStyler?.configure_app_logo(appLogoImage)
        bannerContainerView = screenStyler?.configure_primary_view_background(bannerContainerView)
        
        self.accentColor = (screenStyler?.get_accent_color())!
        
        //highlight default date label with accent color
       // dateLabel.textColor = accentColor
    }
    

    // MARK: Private methods

    private func customizeNavigationBar() {

/*        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.tintColor = UIColor.white
        
        //remove back button title from navigationbar
        navigationController?.navigationBar.backItem?.title = ""
        let backImage = UIImage(named: "back_white")!
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
  */
        navigationController?.setNavigationBarHidden(false, animated: false)
    }


    private func updateAccountDetailsOnBanner() {
        if account == nil {
            return
        }
        accountName.text = account?.accounttype
        
        accountNumber.text = Utility.maskString(nonMaskedString: account?.accountNumber, visibleCharacterCount: 4)

        if let balance = account?.balance {
            accountBalance.text =  Utility.formatCurrency(format: CurrencyType.DOLLER.rawValue, amount: balance)
        }
        else {
            accountBalance.text =  applicationCurrency.rawValue + "0.00"
        }
    }
    
    
    private func updateTableVisibility() {
        if fetchResultController != nil && (fetchResultController.fetchedObjects?.count)! > 0 {
            tableView.isHidden = false
            instructionsView.isHidden = true
        } else {
            tableView.isHidden = true
            instructionsView.isHidden = false
        }
    }
    
/*    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            }catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
 */

    
    // Mark: Tableview delegates/methods

    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let section = fetchResultController?.sections {
            return section.count
        }

        return 0
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = fetchResultController?.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }

        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTransactionCell", for: indexPath) as! AccountTransactionCell
        
        configureCell(cell: cell, indexPath: indexPath)
            
        return cell
    }
    
    func configureCell(cell: AccountTransactionCell, indexPath: IndexPath){
        let transaction = fetchResultController.object(at: indexPath)
        cell.configureCell(transaction: transaction)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTableRowIndex = indexPath.row
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            if let objs = self.fetchResultController.fetchedObjects, objs.count > 0 {
                let transaction = objs[indexPath.row]
                context.delete(transaction)
                
                if (transaction.type?.caseInsensitiveCompare("debit") == ComparisonResult.orderedSame) {
                    self.account?.balance += (transaction.billTransaction?.amountDue)! // add transaction amount to balance
                } else {
                    self.account?.balance -= (transaction.checkTransaction?.amount)! // deduct transaction amount from balance
                }
                ad.saveContext()
                
                //hide tableview if all rows are deleted
                self.updateTableVisibility()
            }

            /*let context = self.fetchResultController.managedObjectContext
            let section = indexPath.section
            let currentRow = indexPath.row
            for index in 0...currentRow {
                let indexPathToDelete = IndexPath(row: index, section: section)
                let objectToDelete = self.fetchResultController.object(at: indexPathToDelete) as NSManagedObject
                context.delete(objectToDelete)
            }
            do {
                try context.save()
            } catch let error as NSError {
                print(error)
            }
*/

        }
        return [delete]
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            print("Delete Style!")
        }

    }
    
    //CoreData methods
    
    func attemptFetch() {
        DispatchQueue.global().async {
        _ = self.fetchAccountTransactions()
        }
    }

    func fetchAccountTransactions() -> Int {
        var recordCount = 0

        let sortKey = "dateOfTransaction"
        
        let fetchRequest: NSFetchRequest<AccountTransactionMaster> = AccountTransactionMaster.fetchRequest()
        
        if account?.accountNumber != nil {
            fetchRequest.predicate = NSPredicate(format: "account == %@", account!)
            
/*            if(sortKey == nil) {
               sortKey = "dateOfTransaction"    //default
            }
*/
            let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]

            var controller: NSFetchedResultsController! = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            do {
                try controller.performFetch()
                if controller.fetchedObjects != nil && (controller.fetchedObjects?.count)! > 0 {
                    recordCount = (controller.fetchedObjects?.count)!
                }
            } catch {
                let error = error as NSError
                print("\(error)")
            }
            
            if fetchResultController != nil {
                fetchResultController.delegate = nil
            }
            fetchResultController = controller
            fetchResultController.delegate = self
            
            controller = nil
        }
        return recordCount
    }

    // Mark: CoreData delegates
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
                updateAccountDetailsOnBanner()
            }
            break
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            updateAccountDetailsOnBanner()
            break
            
        default:
            break
        }
    }

        // Mark: Tap Gesture Recognizer delegates
    
    @IBAction func sortTransactionsForDate(_ sender: UITapGestureRecognizer) {
        
        for label in tableHeadingLabels {
            label.textColor = UIColor.white
        }

        //highlight label with accent color
        dateLabel.textColor = accentColor
        
        _ = fetchAccountTransactions()
        
        //reload table data after fetch
        tableView.reloadData()
    }
    
    @IBAction func sortTransactionsForType(_ sender: UITapGestureRecognizer) {

        for label in tableHeadingLabels {
            label.textColor = UIColor.white
        }
        
        //highlight label with accent color
        typeLabel.textColor = accentColor

        _ = fetchAccountTransactions()
        
        //reload table data after fetch
        tableView.reloadData()
    }

    @IBAction func sortTransactionsForAmount(_ sender: UITapGestureRecognizer) {

        for label in tableHeadingLabels {
            label.textColor = UIColor.white
        }
        

        //highlight label with accent color
        amountLabel.textColor = accentColor

        _ = fetchAccountTransactions()
        
        //reload table data after fetch
        tableView.reloadData()
    }
    
    @IBAction func deleteTransaction(_ sender: UIButton) {
        if let objs = self.fetchResultController.fetchedObjects, objs.count > 0 {
            
            let obj = objs[selectedTableRowIndex]
            context.delete(obj)
            ad.saveContext()
        }
    }
    
}
