//
//  CreditCardHomeVC.swift
//  KofaxBank
//
//  Created by Rupali on 27/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData


class CreditCardHomeVC: BaseViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, CreditCardManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var cardInfoPopover: UIView!

    @IBOutlet weak var cardNumberLabel: UILabel!
    
    @IBOutlet weak var cardStatusLabel: UILabel!
    
    @IBOutlet weak var cardTypeLabel: UILabel!
    @IBOutlet weak var expDateLabel: UILabel!
    @IBOutlet weak var dueAmountLabel: UILabel!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var floatingButton: FloatingButton!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: Private variables
    
    //fileprivate var fetchResultControllerCCMaster: NSFetchedResultsController<CreditCardMaster>!
    
    private var fetchResultControllerTransactions: NSFetchedResultsController<CreditCardTransactions>!
    
    fileprivate var cards = [CreditCardMaster]()
    
    private var creditCardManager: CreditCardManager! = nil

    private var openedTableCell: CreditCardTransactionCell! = nil

    private var selectedTableRowIndex: Int = 0
    
    private var idManager: IDManager? = nil

    private var cardStatus: String! = STATUS_ACTIVE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attemptFetch()

        self.tableView.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
       // loadCardDataArrayForPopover(creditCards: creditCards)

        cardStatus = updateSceenAsPerCardStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        customizeNavigationBar()

        updateCardBanner(index: 0)
        
        //return if table is already loaded

        if cardStatus != STATUS_PENDING_FOR_APPROVAL && tableView.isHidden {
//            tableView.isHidden = false
//            infoLabel.isHidden = true
            updateTableVisibility()
            //tableView.reloadData()
        }
        
        if cardStatus ==  STATUS_EXPIRED {
            floatingButton.isHidden = false
            
            Utility.showAlertWithCallback(onViewController: self, titleString: "Attention", messageString: "Your credit card is not valid anymore.\nPlease request a new card. \n\n If a new card is aready issued, use 'Activate Now' button to start activication process. You can also use option on screen to activate it later.", positiveActionTitle: "Activate Now", negativeActionTitle: "Maybe later", positiveActionResponse: {
              
                self.initiateCardActivation()
                
            }, negativeActionResponse: {
                
            })
            
        }
    }
    
    var rightBarButtonItem: UIBarButtonItem! = nil
    
    private func customizeNavigationBar() {
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.tintColor = UIColor.white

        //show vertical menu option (vertical dots) on right side of navigationbar
        //if rightBarButtonItem == nil {
            rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "Menu Vertical white"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(showSettingsPopup))
       // }
        navigationController?.navigationBar.topItem?.setRightBarButtonItems([(navigationController?.navigationBar.topItem?.rightBarButtonItem)!, rightBarButtonItem], animated: false)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    private func updateTableVisibility() {
        if fetchResultControllerTransactions != nil && (fetchResultControllerTransactions.fetchedObjects?.count)! > 0 {
            tableView.isHidden = false
           // infoLabel.isHidden = true
        } else {
            tableView.isHidden = true
            infoLabel.text = "No Transactions"
            infoLabel.isHidden = false
        }
    }

    
    private func updateSceenAsPerCardStatus() -> String! {
        
        if cards.count == 0 {
            return STATUS_ACTIVE
        }
        //TODO: what if card record does not contain issue date?
/*
         //compare expdate of card with current date
        let card = cards[0]
        
        let today = Date()
        
        guard let expDate = card.expDate else {
            print("Error: Card issue date is empty!")
            return true
        }
        
        if today > expDate as Date {
            expired = true
        }
*/
        let cardStatus = cards[0].cardStatus
        
        if cardStatus == STATUS_EXPIRED {
            self.floatingButton.isHidden = false
            self.cardStatusLabel.isHidden = false
            self.cardStatusLabel.textColor = applicationRedColor
            self.infoLabel.isHidden = true
          //  self.infoLabel.text = "This card is expired. If you have received a new card from bank, select 'Card Activation' button above to activate the card."
        } else if cardStatus == STATUS_PENDING_FOR_APPROVAL {
            self.floatingButton.isHidden = true
            self.cardStatusLabel.text = "Pending Approval"
            self.cardStatusLabel.textColor = applicationOrangeColor
            self.cardStatusLabel.isHidden = false
            self.infoLabel.text = "Approval for activation is pending for this card.\n\nYou should be able to use it after positive confirmation is received from the bank."
            self.infoLabel.isHidden = false
        } else if cardStatus == STATUS_ACTIVE {
            self.floatingButton.isHidden = true
            self.cardStatusLabel.isHidden = true
            self.infoLabel.isHidden = true
        }

        return cardStatus
    }
    
    
    private func initiateCardActivation() {
        DispatchQueue.global().async {
            
            if self.creditCardManager == nil {
                self.creditCardManager = CreditCardManager.init()
                
                
            }
            //creditCardManager.loadManagerWithCamera(navigationController: self.navigationController!)
            self.creditCardManager.loadManager(navigationController: self.navigationController!)
            self.creditCardManager.delegate = self
        }
    }
    
    //NavigationbarButtonItem selector event
    func showSettingsPopup() {
        let vc = IDSettingsViewController.init(nibName: "IDSettingsViewController", bundle: nil)
        
        let navController = UINavigationController.init(rootViewController: vc)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.backgroundColor = UIColor.clear
        
        self.present(navController, animated: true, completion: nil)
        //self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //Card information view methods
    

    @IBAction func showCardInformation(_ sender: UITapGestureRecognizer) {
        cardInfoPopover.isHidden = false
    }
    
     @IBAction func hideCardInformation(_ sender: UITapGestureRecognizer) {
        
        cardInfoPopover.isHidden = true
    }
    
    
    @IBAction func requestSupplementaryCard(_ sender: UIButton) {

        initiateCardActivation()
        
        /*        if idManager != nil {
            idManager?.unloadManager()
        } else {
            idManager = IDManager.init()
        }

        idManager?.loadManager(navigationController: self.navigationController!)
*/
    }
    
    @IBAction func previousButtonClicked(_ sender: UIButton) {
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
    }
    
    
    
    
    
    // Tableview delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let section = fetchResultControllerTransactions.sections {
            return section.count
        }

        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = fetchResultControllerTransactions.sections {
            
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditCardTransactionCell", for: indexPath) as! CreditCardTransactionCell

        configureCell(cell: cell, indexPath: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CreditCardTransactionCell
        
        openedTableCell = cell
        selectedTableRowIndex = indexPath.row
        //tableViewHeightConstraint.constant += 40
        //tableView.cellForRow(at: indexPath)?.changeHeight(toHeight: 140)
  
        //cell.showCommandBarView(tableView: tableView)
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        /*
        if openedTableCell == nil {
            return
        }
        let cell = tableView.cellForRow(at: indexPath) as! CreditCardTransactionCell

        cell.hideCommandBarView(tableView: tableView)
        */
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /*
        if openedTableCell != nil  && cell == openedTableCell {
            openedTableCell.hideCommandBarView(tableView: tableView)
            openedTableCell = nil
        }
 */
    }

    func configureCell(cell: CreditCardTransactionCell, indexPath: IndexPath) {
        
        let transaction = fetchResultControllerTransactions.object(at: indexPath)
        cell.configureCell(transaction: transaction)
    }

    // CoreData methods
    
    func attemptFetch() {

        fetchCreditCardMasterRecords()
        if cards.count > 0 {
            fetchTransactions()
        }
        //_ = fetchCardsPendingForApprovals()
    }

    func fetchCreditCardMasterRecords() {
        cards.removeAll()

        //fetch credit card master records
        var fetchRequest: NSFetchRequest<CreditCardMaster>! = CreditCardMaster.fetchRequest()
        //TODO: add condition for pending card
        do {
            self.cards = try context.fetch(fetchRequest)
        } catch {
            let error = error as NSError
            print("\(error)")
        }
        
        fetchRequest = nil
    }
    
    private func fetchTransactions() {
        let fetchRequest: NSFetchRequest<CreditCardTransactions> = CreditCardTransactions.fetchRequest()
        
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        fetchRequest.predicate = NSPredicate(format: "creditcard == %@", cards[0])

        var controller: NSFetchedResultsController! = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try controller.performFetch()
            
            if fetchResultControllerTransactions != nil {
                fetchResultControllerTransactions.delegate = nil
                fetchResultControllerTransactions = nil
            }
            
            fetchResultControllerTransactions = controller
            fetchResultControllerTransactions.delegate = self

        } catch {
            let error = error as NSError
            print("\(error)")
        }
        
        controller = nil
    }

    
    
/*
    func fetchCardsPendingForApprovals() {
        let fetchRequest: NSFetchRequest<CreditCardMaster> = CreditCardMaster.fetchRequest()

        let dateSort = NSSortDescriptor(key: "cardAddedDate", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
       //let pending: Bool = true
       //fetchRequest.predicate = NSPredicate(format: "pendingApproval == %@", pending.description)

        var controller: NSFetchedResultsController! = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        do {
            try controller.performFetch()
        } catch {
            let error = error as NSError
            print("\(error)")
        }
        
        if fetchResultControllerCCMaster != nil {
            fetchResultControllerCCMaster.delegate = nil
        }
        
        fetchResultControllerCCMaster = controller
        fetchResultControllerCCMaster.delegate = self

        controller = nil
    }
*/
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
            }
            break
        
        case .delete:
            //if let indexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath!], with: .fade)
            //}
            break

            
        //case NSFetchRsultChangeUpdate:
//            break
        default:
            break
        }
    }

    
    //MARK: CreditCardManagerDelegate
    
    func cardSubmittedForActivation(cardData: kfxCreditCardData) {
        DispatchQueue.main.async {
            self.tableView.isHidden = true
            self.cardStatusLabel.isHidden = false
            self.cardStatusLabel.textColor = applicationOrangeColor
            self.cardStatusLabel.text = "Pending Activation"
            self.infoLabel.text = "Approval for activation is pending for this card.\n\nYou should be able to use it after positive confirmation is received from the bank."
            self.infoLabel.isHidden = false
            self.floatingButton.isHidden = true

            //self.cardNumberLabel.text = cardData.cardNumber.value
            self.fetchCreditCardMasterRecords()
            self.updateBanner(forCard: self.cards[0])
        }
    }

    // Remove pending card entry button delegate
    
    @IBAction func removePendingCard(_ sender: UIButton) {
        print("removePendingCard...")
       
        if let objs = self.fetchResultControllerTransactions.fetchedObjects, objs.count > 0 {

            let obj = objs[selectedTableRowIndex]
            context.delete(obj)
            ad.saveContext()

            //hide tableview if all rows are deleted
            self.updateTableVisibility()
        }
    }
    
    @IBAction func activateCard(_ sender: UIButton) {
        print("activateCard...")
        
        if idManager != nil {
            idManager?.unloadManager()
            //idManager = nil
        }
        else {
            idManager = IDManager.init()
        }

        idManager?.loadManager(navigationController: self.navigationController!)
    }

    // Activate card button delegate
}


extension CreditCardHomeVC: PopoverDelegate {
    
    //Popuppover selection delegate
    
    func popoverRowSelectedWith(rowIndex: Int) {
        print("\(rowIndex) was selected on popover")
        
        updateCardBanner(index: rowIndex )
        
    }
    
    func updateCardBanner(index: Int) {
        if cards.count > 0 {
            let card = cards[index]
            updateBanner(forCard: card)
        }
    }
    
        
    
        /*
        accountNumberLabel.text = creditCards[index].cardNumber
        dueAmountLabel.text = String.init(format: "%0.2f", creditCards[index].currentSpening)
        dueDateLabel.text = Utility.formatDate(format: "dd.mm.yy", date: creditCards[index].dueDate)
        statementDateLabel.text = Utility.formatDate(format: "dd.mm.yy", date: creditCards[index].statementDate)
        */
    }

