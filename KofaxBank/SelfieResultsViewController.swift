//
//  SelfieResultsViewController.swift
//  KofaxBank
//
//  Created by Rupali on 08/11/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

protocol SelfieResultsViewControllerDelegate {
    func submitWithSelfieResults()
    func backFromSelfieResultScreen()
    func sendPushNotificationServiceOnSelfiVerification()
}

class SelfieResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var headshotImageView: UIImageView!
    
    @IBOutlet weak var selfieImageView: UIImageView!
    
    @IBOutlet weak var notificationContainer: CustomView!
    
    @IBOutlet weak var notificationIcon: UIImageView!
    
    @IBOutlet weak var notificationLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var submitButtonContainer: UIVisualEffectView!
    
    @IBOutlet weak var submitButton: CustomButton!
    
    //MARK Public veriables
    
    var delegate: SelfieResultsViewControllerDelegate? = nil

    var selfieImage: UIImage? = nil

    
    //MARK: - Private variables

    private var selfieVerificationResult: SelfieVerificationResultModel! = nil

    private var datasourceArray: NSArray! = nil
    
    private var wasNavigationHidden: Bool = false
    private var oldBarTintColor: UIColor!
    private var oldStatusBarStyle: UIStatusBarStyle!

    
    init (selfieResults: SelfieVerificationResultModel) {
        super.init(nibName: nil, bundle: nil)

        self.selfieVerificationResult  = selfieResults
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeScreenControls()
        
        customizeNavigationBar()
        
        if selfieImage != nil {
            selfieImageView.image = selfieImage 
        }
        
        
        var headshotImage = Utility.getImage(base64String: self.selfieVerificationResult.headShotBase64ImageString)
        
        if headshotImage != nil {
            self.headshotImageView.image = headshotImage
            
            headshotImage = nil
        }
        
        let path = Bundle.main.path(forResource: "SelfieResult", ofType: "plist")
        if path != nil {
            let data = NSDictionary(contentsOfFile: path!)
            self.datasourceArray = data?.value(forKey: "keysArray") as! NSArray
        }
        
        if selfieVerificationResult != nil && self.selfieVerificationResult.errorInfo != nil && self.selfieVerificationResult.errorInfo.characters.count > 0 {
            Utility.showAlert(onViewController: self, titleString: "Verification failed", messageString: self.selfieVerificationResult.errorInfo)
        } else {
            //Call push notification service call when match result is equal to "Attention".
            if self.selfieVerificationResult.selfieMatchResult.caseInsensitiveCompare("Attention") == ComparisonResult.orderedSame {
                
                //TODO: finich this flow of push notification in next release
                delegate?.sendPushNotificationServiceOnSelfiVerification()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if tableView.delegate == nil {
        tableView.register(UINib(nibName: "SelfieResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "SelfieResultsTableViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.reloadData()
        }
        
        updateSelfieMatchResultStatusNotification()
    }
    
    
    
    // MARK: - Navigationbar methods
    
    private func customizeScreenControls() {
        let buttonStyler = AppStyleManager.sharedInstance()?.get_button_styler()
        
        buttonStyler?.configure_primary_button(submitButton)
    }

    private func customizeNavigationBar() {
        oldStatusBarStyle = UIApplication.shared.statusBarStyle
        oldBarTintColor = navigationController?.navigationBar.tintColor
        
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        wasNavigationHidden = (self.navigationController?.navigationBar.isHidden)!
        
        //new back button
        let newBackButton = UIBarButtonItem.init(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onBackPressed))
        
        self.navigationItem.leftBarButtonItem=newBackButton
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        
    }
    
    private func restoreNavigationBar() {
        UIApplication.shared.statusBarStyle = oldStatusBarStyle
        navigationController?.navigationBar.tintColor = oldBarTintColor
        navigationController?.setNavigationBarHidden(wasNavigationHidden, animated: false)
    }
    
    //Mark: Navigation button actions
    
    func onBackPressed() {
        
        Utility.showAlertWithCallback(onViewController: self, titleString: "Abort", messageString: "This will reset the verification results.\n\nDo you want to continue?", positiveActionTitle: "YES", negativeActionTitle: "NO", positiveActionResponse: {
            print("Positive response selected")
            
            self.delegate?.backFromSelfieResultScreen()
            
            self.closeScreen()

        }, negativeActionResponse: {
            print("Negative response selected")
        })
    }
    
    private func updateSelfieMatchResultStatusNotification() {
        if self.selfieVerificationResult != nil && self.selfieVerificationResult.selfieMatchResult != nil {
            
            if self.selfieVerificationResult.selfieMatchResult.caseInsensitiveCompare("PASS") == ComparisonResult.orderedSame {
//                self.notificationContainer.backgroundColor = applicationGreenColor
                self.notificationLabel.text = "SELFIE VERIFICATION PASSED"
                self.notificationIcon.image = UIImage(named: "checkmark_green")
            } else if self.selfieVerificationResult.selfieMatchResult.caseInsensitiveCompare("ATTENTION") == ComparisonResult.orderedSame {
//                self.notificationContainer.backgroundColor = applicationOrangeColor
                self.notificationLabel.text = "SELFIE VERIFICATION NEEDS ATTENTION"
                self.notificationIcon.image = UIImage(named: "warning")
            } else {
//                self.notificationContainer.backgroundColor = applicationRedColor
                self.notificationLabel.text = "SELFIE VERIFICATION FAILED"
                self.notificationIcon.image = UIImage(named: "alert_round")
            }
            self.notificationContainer.isHidden = false
        }
    }
    
    private func closeScreen() {
        self.cleanUp()
        
        self.restoreNavigationBar()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func cleanUp() {
        self.delegate = nil
        self.selfieImage = nil
        self.selfieVerificationResult = nil
    }
    
    //MARK: Tableview methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datasourceArray != nil {
            return self.datasourceArray.count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SelfieResultsTableViewCell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelfieResultsTableViewCell", for: indexPath) as! SelfieResultsTableViewCell
        
        print("Selfie verification result ===> \(selfieVerificationResult)")
        
        let title = (self.datasourceArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "name") as! String
        let key = (self.datasourceArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "key") as! String
        
        var value: String! = nil
        
            if title.caseInsensitiveCompare("Document Test") == ComparisonResult.orderedSame {
                
                //TODO: display results of "Document test"

            } else if title.caseInsensitiveCompare("Document Image Analysis") == ComparisonResult.orderedSame {
                
                //TODO: display results of "Document image analysis"
                
            } else if title.caseInsensitiveCompare("Match Score") == ComparisonResult.orderedSame {
                
                //TODO: Fix below statement
                
                print("\(self.selfieVerificationResult.value(forKey: key) as! String)")
                
                //let score = self.selfieVerificationResult.value(forKey: key) as! Double
                //value = String(format: "%.02f", score)
            }
            else {
                value = self.selfieVerificationResult.value(forKey: key) as! String
            }
        
            cell.configureCell(title: title, value: value)
        
        return cell
        
        }
    
    //MARK: Submit button action
    
    @IBAction func onSubmitButtonClicked(_ sender: UIButton) {
        delegate?.submitWithSelfieResults()
        
        cleanUp()
        restoreNavigationBar()
    }
}
