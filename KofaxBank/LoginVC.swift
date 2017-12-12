//
//  LoginVC.swift
//  KofaxBank
//
//  Created by Rupali on 06/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var splashLogoImageView: UIImageView!
    @IBOutlet weak var appTitleLabel: UILabel!
    
    @IBOutlet weak var appSubTitleLabel1: UILabel!
    @IBOutlet weak var appSubTitleLabel2: UILabel!
    @IBOutlet weak var appSubtitleDotLabel: UILabel!
    @IBOutlet weak var appTitleDividerLineView: UIView!

    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var loginFieldsContainer: UIVisualEffectView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    private var touchIDStatus: Bool = false
    
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        customizeScreenControls()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(viewOnTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        updateScreen()
    }


    func viewOnTap() {
        self.view.endEditing(true)
    }
    
    private func updateScreen() {
        let status = UserDefaults.standard.value(forKey: KEY_TOUCH_ID_STATUS)
        
        if status != nil {
             touchIDStatus = status  as! Bool
        }

        //if touch ID is already enabled
        if isTouchIdAvailableOnDevice() && touchIDStatus == true {
            //display alert asking to scan touch ID
            askForTouchIDAuth()
        } else {
            // if touch ID is not set or enabled, display login fields(username, pwd)
            askForLogin()
        }
    }
    
    private func askForLogin() {
        loginFieldsContainer.isHidden = false

        //usernameTextField.becomeFirstResponder()
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
       dummyLogin()
    }
    
    
    private func isFirstTimeLogin() -> Bool {
        if Utility.isKeyPresentInUserDefaults(key: KEY_VERY_FIRST_LOGIN) {
            return UserDefaults.standard.value(forKey: KEY_VERY_FIRST_LOGIN) as! Bool
        } else {
            return true
        }
    }
    
    //Use 'login()' method if realtime login is to be integrated.
    
    private func dummyLogin() {
        self.launchNextScreen()
    }
    
    private func login() {
       
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

        DispatchQueue.main.async {
            self.launchNextScreen()
        }
    }
    
    func launchNextScreen() {

        let firstTimeLogin = isFirstTimeLogin()
        
        if  firstTimeLogin {
            //if the key is not yet set in userdeault then its a very first login of user
            UserDefaults.standard.setValue(false, forKey: KEY_VERY_FIRST_LOGIN)
            
            //display Touch ID screen asking use if he wishes to enable it before proceeding
            performSegue(withIdentifier: "TouchIDEnablerVC", sender: nil)
       } else {
            //if user had logged in in the past, then display home screen
            //performSegue(withIdentifier: "HomeVC", sender: nil)
            launchHomeScreenAsFirstScreen()
       }
    }
    
    func launchHomeScreenAsFirstScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
        navigationController?.pushViewController(vc, animated: true)

        /**
         Important: set next viewcontroller as base(first) viewcontroller after login screen is closed.
         This will prevent the new first viewcontroller to go back to login screen agian.
         */
        let newViewControllersSequenceArray: NSMutableArray = NSMutableArray(object: vc)
        navigationController?.setViewControllers(newViewControllersSequenceArray as! [UIViewController], animated: false)
    }
    
    
    //MARK: Touch ID Auth Methods
    
    private func askForTouchIDAuth() {
        
        loginFieldsContainer.isHidden = true
        
        initiateTouchIDScan()
    }
    
    private func initiateTouchIDScan() {
        
        let context = LAContext()
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenication is required to access your account.", reply: {(success, error) in
            DispatchQueue.main.async {
                
                if success {
                    print("Authentication successful")
                    
                    //self.notifyUser(titleString: "Authentication successful", bodyString: "You now have full access")
                    self.launchHomeScreenAsFirstScreen()
                }
                else if error != nil {
                    switch error!._code {
                    case LAError.Code.systemCancel.rawValue:
                        print("Session cancelled")
                        break
                        
                    case LAError.Code.userCancel.rawValue:
                        print("User cancelled.")
                        break
                        
                    case LAError.Code.userFallback.rawValue:
                        print("Fallback to password")
                        break
                        
                    default:
                        print("Authentication failed")
                        break
                    }
                    self.askForLogin()
                }
            }
        })
    }

    
    private func isTouchIdAvailableOnDevice() -> Bool {
        var deviceTouchIDStatus: Bool = false
        
        let context = LAContext()
        
        context.invalidate()
        
        var error: NSError?
        
        //check if TouchID is available on device
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) == false {
            
            //Device cannot use TouchID
            switch error!.code {
                
            case LAError.Code.touchIDNotEnrolled.rawValue:
                //The user has not enrolled any fingerprints into TouchID on the device
                print("Touch ID is not enrolled")
                break
                
            case LAError.Code.passcodeNotSet.rawValue:
                //The user has not yet configured a passcode on the device.
                print("A passcode has not been set")
                break
                
            case LAError.Code.touchIDNotAvailable.rawValue:
                break
                
            default:
                //The device does not have a TouchID fingerprint scanner (LAError.touchIDNotAvailable)
                deviceTouchIDStatus = true
            }
            
        } else {
            
            deviceTouchIDStatus = true
        }
        
        return deviceTouchIDStatus
    }
    
    private func dismissTouchIDAuth() {
        
    }
    
    // MARK: Textfield delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            //if its a last text field (Go key), dismiss the keyboard and login.
            dismissKeyboard()
            dummyLogin()
        } else {
            passwordTextField.becomeFirstResponder()
        }
        
        return true
    }
}
