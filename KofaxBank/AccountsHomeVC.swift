//
//  AccountsHomeVC.swift
//  KofaxBank
//
//  Created by Rupali on 22/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData

class AccountsHomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate  {

    @IBOutlet weak var tableView: UITableView!
    
    private let MAX_VISIBLE_CELL_COUNT: Int = 2
    
    private var backImage: UIImage!
    
    private var fetchResultController: NSFetchedResultsController<AccountsMaster>!
    
    private var fetchResultControllerCC: NSFetchedResultsController<CreditCardMaster>!
    
    //MARK: status bar visibility
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    //MARK: statusbar content color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
        fetchAccounts()
        fetchCreditCardAccounts()

        tableView.dataSource = self
        tableView.delegate = self
    }

    
    private func customizeNavigationBar() {

        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.image = nil
    }
    
    
    func menuBarButtonClicked() {
        print("Clicked!")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        customizeNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {

    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            }catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    // MARK: - TableView Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
/*        if let section = fetchResultController?.sections {
            return section.count
        }
*/
       return 2
        
//        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    let sectionHeaderTitleArray = ["BANKING ACCOUNT", "CREDIT CARD ACCOUNT"]
    let sectionHeaderImageArray = ["Account", "Card Black"]

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect.init(x:0, y:0, width: 200, height:30))
        returnedView.backgroundColor = UIColor.init(rgb: 0xD8D8D8)
        
        let imageIcon = UIImage.init(named: sectionHeaderImageArray[section])
        let iconImageView = UIImageView.init(image: imageIcon)
        iconImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        iconImageView.contentMode = UIViewContentMode.scaleAspectFit

        returnedView.addSubview(iconImageView)

        iconImageView.centerYAnchor.constraint(equalTo: returnedView.centerYAnchor).isActive = true

        iconImageView.centerYAnchor.constraint(equalTo: returnedView.centerYAnchor).isActive = true
        
        let label = UILabel(frame: CGRect(x:0, y:0, width:250, height:30))
        label.text = self.sectionHeaderTitleArray[section]
        returnedView.addSubview(label)
        
        let trailing = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: returnedView, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0)
        
        returnedView.addConstraint(trailing)

        
        return returnedView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return accountArray.count
        if section == 0 {
            if let sections = fetchResultController?.sections {
                let sectionInfo = sections[section]
                return sectionInfo.numberOfObjects
            }
        } else if section == 1 {
            return 1
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("cell count \(indexPath.row)")

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountCell
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountCell
            configureCreditCardCell(cell: cell, indexPath: indexPath)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "BANKING ACCOUNTS"
        } else {
            return "CREDIT CARD ACCOUNTS"
        }
    }

        
    func configureCell(cell: AccountCell, indexPath: IndexPath) {
        
        let account = fetchResultController.object(at: indexPath)
        cell.configureCell(account: account)
    }

    func configureCreditCardCell(cell: AccountCell, indexPath: IndexPath) {
        
        let ccAccount = fetchResultControllerCC.fetchedObjects?[indexPath.row]
        cell.configureCellForCreditCardAccount(card: ccAccount!)
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //open credit card tab when tapped on credit-card row
        if indexPath.section != 0 {
            self.tabBarController?.selectedIndex = 1
            return
        }

        if let objs = fetchResultController.fetchedObjects, objs.count > 0 {
            
            let account = objs[indexPath.row]
            performSegue(withIdentifier: "AccountTransactionSegue", sender: account)
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AccountTransactionSegue" {
            if let destination = segue.destination as? AccountTransactionHistoryVC {
                if let account = sender as? AccountsMaster {
                    destination.account = account
                }
            }
        }
    }

    var idManager = IDManager()
    @IBAction func addNewAccount(_ sender: UIButton) {
        
//        let vc = IDSettingsViewController.init(nibName: "IDSettingsViewController", bundle: nil)
//        self.navigationController?.pushViewController(vc, animated: true)

//        let vc = RegionViewController.init(nibName: "RegionViewController", bundle: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
        idManager.loadManager(navigationController: self.navigationController!)
    }
    
    // Mark: CoreData methods
    
    func fetchAccounts() {
        let fetchRequest: NSFetchRequest<AccountsMaster> = AccountsMaster.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "accountNumber", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self  //IMP for reloading the data after any changes into the database
        
        self.fetchResultController = controller
        
        do {
            try controller.performFetch()
            
        } catch {
            let error = error as NSError
            print("\(error)")
            
            //TODO: Return and display error  on screen.
        }
    }
    
    func fetchCreditCardAccounts() {
        let fetchRequest: NSFetchRequest<CreditCardMaster> = CreditCardMaster.fetchRequest()
        let dateSort = NSSortDescriptor(key: "expDate", ascending: true)
        fetchRequest.sortDescriptors = [dateSort]

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self  //IMP for reloading the data after any changes into the database
        
        self.fetchResultControllerCC = controller
        
        do {
            try controller.performFetch()
            
        } catch {
            let error = error as NSError
            print("\(error)")
            
            //TODO: Return and display error  on screen.
        }
    }

    
    /*
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
            if let indexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case .update:
            if let indexPath = newIndexPath {
                let cell = tableView.cellForRow(at: indexPath) as! AccountCell
                configureCell(cell: cell, indexPath: indexPath)
            }
            break
        
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        }
        
    }

*/
    
}
