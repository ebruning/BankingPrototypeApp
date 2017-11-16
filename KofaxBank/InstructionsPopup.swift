//
//  InstructionsPopup.swift
//  
//
//  Created by Rupali on 04/09/17.
//
//

import UIKit

protocol InstructionsDelegate {
    func onInstructionOptionSelected(command: CommandOptions)
}

class InstructionsPopup: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var messageBodyLabel: UILabel!
    
    @IBOutlet weak var sampleImageView: UIImageView!
    
    @IBOutlet weak var instructionLabel: UILabel!
    
    
    // MARK: Public variables
    
    // MARK: Private variables
    
    private var _titleText: String! = nil
    
    private var _bodyMessageText: String! = nil
    
    private var _sampleImageName: String! = nil
    
    
    var titleText: String! {
        get {
            return _titleText
        } set {
            _titleText = newValue
        }
    }
    
    var bodyMessageText: String! {
        get {
            return _bodyMessageText 
        } set {
            _bodyMessageText = newValue
        }
    }
    
    var sampleImageName: String! {
        get {
            return _sampleImageName
        } set {
            _sampleImageName = newValue
        }
    }

    //Mark: - Delegate
    
    var delegate: InstructionsDelegate?

    // MARK: private variables

    private var wasNavigationHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        customizeScreenControls()

        hideNavigationBar()
        
        if _titleText != nil {
            titleLabel.text = _titleText
        }

        if _bodyMessageText != nil {
            messageBodyLabel.text = _bodyMessageText
        }

        if _sampleImageName != nil {
            sampleImageView.image = UIImage.init(named: _sampleImageName)
        }
    }
    
    private func customizeScreenControls() {
        let screenStyler = AppStyleManager.sharedInstance().get_app_screen_styler()
        
        instructionLabel.backgroundColor = screenStyler?.get_accent_color()
    }

    func hideNavigationBar() {
        wasNavigationHidden = (self.navigationController?.navigationBar.isHidden)!
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    @IBAction func mainViewOnTap(_ sender: UITapGestureRecognizer) {

        close(command: CommandOptions.CANCEL)
    }
    
    @IBAction func showCamera(_ sender: UIButton) {
        close(command: CommandOptions.CAMERA)
    }
    
    @IBAction func showGallery(_ sender: UIButton) {
        close(command: CommandOptions.GALLERY)
    }
    
    
    // MARK: Public methods
    

    // MARK: Private methods
    
    private func close(command: CommandOptions) {
        //reset navigationbar visibility to same as it was before this screen was shown
        self.navigationController?.setNavigationBarHidden(wasNavigationHidden, animated: false)

        delegate?.onInstructionOptionSelected(command: command)

        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.view.alpha = 0
            self.dismiss(animated: true, completion: nil)
        }, completion: nil)
        
    }

}
