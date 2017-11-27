//
//  LoginVC.swift
//  KofaxBank
//
//  Created by Rupali on 06/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    
    @IBOutlet weak var splashLogoImageView: UIImageView!
    @IBOutlet weak var appTitleLabel: UILabel!
    
    @IBOutlet weak var appSubTitleLabel1: UILabel!
    @IBOutlet weak var appSubTitleLabel2: UILabel!
    @IBOutlet weak var appSubtitleDotLabel: UILabel!
    @IBOutlet weak var appTitleDividerLineView: UIView!

    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var textFieldViewContainer1: UIView!
    @IBOutlet weak var textFieldViewContainer2: UIView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    /// Overlayview that is being displayed when the user tries to log in
    private lazy var waitIndicator: WaitIndicatorView! = {
        let waitIndicator = WaitIndicatorView()
        return waitIndicator
    }()
 
    
    //let overlayView = WaitIndicatorView()
    
    //override statusbar method to hide it
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        customizeScreenControls()

        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        
        textFieldViewContainer1.customizeBorderColor(color: UIColor.lightGray)
        textFieldViewContainer2.customizeBorderColor(color: UIColor.lightGray)
        
    }
    
    private func customizeScreenControls() {
        let splashStyler = AppStyleManager.sharedInstance()?.get_splash_styler()
        
        let accentColor = AppStyleManager.sharedInstance()?.get_app_screen_styler().get_accent_color()

        self.view = splashStyler?.configure_view_background(self.view)
        self.splashLogoImageView = splashStyler?.configure_app_logo(splashLogoImageView)

        self.appTitleLabel = splashStyler?.configure_app_title(appTitleLabel)
        
        self.appSubTitleLabel1.textColor = accentColor
        self.appSubTitleLabel2.textColor = accentColor
        
        //self.appTitleDividerLineView.backgroundColor = accentColor
        //self.appSubtitleDotLabel.textColor = accentColor

        self.welcomeLabel.textColor = accentColor
        
        //login button
        loginButton = AppStyleManager.sharedInstance()?.get_button_styler().configure_primary_button(loginButton)
    }

    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        view.endEditing(true)
       // login()
        let notAFirstTimeLogin = false;
        self.launchNextScreen(isFirstTimeLogin: !notAFirstTimeLogin)
    }
    
    
    func login() {
       
        if Utility.isConnectedToNetwork() == false {
            Utility.showAlert(onViewController: self, titleString: "Network Error", messageString: "Make sure mobile has a working connection before login.")
            
            return
        }
        
        let usernameText: String = usernameTextField.text!
        let passwordText: String = passwordTextField.text!
        
        //check if either username or password fields are empty, if so, display error
        if(usernameText.characters.count == 0 || passwordText.characters.count == 0) {
            Utility.showAlert(onViewController: self, titleString: "Invalid credentials", messageString: "User name and password cannot be empty.")
        }
        else {
            showWaitIndicator()

            let serverManager = ServerManager.shared
            
            do {
                try serverManager.login(username: "KMDUSER", password: "DemoPassword", successHandler: { data in
                //try serverManager.login(username: usernameText, password: passwordText, completed: {
                    print("Login completed!");
                    
                    //do {
                     //   let parsedData = NSString(data: (data)!, encoding: String.Encoding.utf8.rawValue)
                        
                       // let sessionID = parsedData["sessionID"] as! [String:Any]
                        
                        //for (key, value) in parsedData {
                          //  print("Key ==> \(key) - \(value) ")
                        //}
                        
                   // }
                    

                    
                    let jsonString = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: Any]
                   // print("\(String(describing: jsonString))")
                    
                    for (key, value) in jsonString! {
                        print("Key ==> \(key) - \(value) ")
                        let data = jsonString?["d"] as! [String:Any]

                        let sessionId: String! = data["SessionId"] as! String
                        
                        if sessionId != nil {
                            UserDefaults.standard.set(sessionId, forKey: "SessionId")
                            print(sessionId)
                        }
                        
/*                        for (key1, value1) in data {
                            print("Key1 ==> \(key1) - \(value1) ")
                        }
*/
                    }

                    self.hideWaitIndicator()
                    
                    self.handleLoginSuccess()
                    
                }, failureHandler: { statusCode in
                    print("Login failed with error code\(String(describing: statusCode))");
                
                        var message: String!
                        if (statusCode != 0) {
                            message = "status code: \(statusCode)"
                        }
                        self.hideWaitIndicator()
                        Utility.showAlert(onViewController: self, titleString: "Login Failed", messageString: message)
                })
            }catch {
                hideWaitIndicator()

                print(error.localizedDescription)
                Utility.showAlert(onViewController: self, titleString: "Login Error", messageString: error.localizedDescription)
            }
        }
    }
    
    //MARK: Wait indicator methods
    
    private func showWaitIndicator() {
        DispatchQueue.main.async {
            self.waitIndicator.displayView(onView: self.view)
        }
    }
    
    private func hideWaitIndicator() {
        DispatchQueue.main.async {
            self.waitIndicator.hideView()
        }
    }

    
    func handleLoginSuccess() {

        //if the key is not yet set in userdeault then its a very first login of user
        let notAFirstTimeLogin = Utility.isKeyPresentInUserDefaults(key: EverLoggedInPast)
        
        //set userdefault with the value that user is logged into application atleast once
        UserDefaults.standard.set(true, forKey: EverLoggedInPast)

        DispatchQueue.main.async {

            self.launchNextScreen(isFirstTimeLogin: !notAFirstTimeLogin)
        }
    }
    
    func launchNextScreen(isFirstTimeLogin: Bool) {

       // if  isFirstTimeLogin == true {
            //display Touch ID screen asking use if he wishes to enable it before proceeding
            performSegue(withIdentifier: "TouchIDEnablerVC", sender: nil)
        //} else {
            
            //if user had logged in in the past, then display home screen
            //performSegue(withIdentifier: "HomeVC", sender: nil)
            //launchHomeScreenAsFirstScreen()
        //}
    }
    
    func launchHomeScreenAsFirstScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        navigationController?.pushViewController(vc, animated: true)

//        let vc = HomeVC(nibName: "HomeScreen", bundle: nil)
//        self.navigationController?.pushViewController(vc, animated: true)

        /**
         Important: set next viewcontroller as base(first) viewcontroller after login screen is closed.
         This will prevent the new first viewcontroller to go back to login screen agian.
         */
        let newViewControllersSequenceArray: NSMutableArray = NSMutableArray(object: vc)
        navigationController?.setViewControllers(newViewControllersSequenceArray as! [UIViewController], animated: false)
        
        //dismiss(animated: true, completion: nil)
    }
    
    //
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }
    
}
