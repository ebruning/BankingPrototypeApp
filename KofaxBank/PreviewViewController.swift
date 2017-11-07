//
//  PreviewViewController.swift
//  KofaxBank
//
//  Created by Rupali on 10/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

//Mark: - Protocol

protocol PreviewDelegate {
    func onPreviewOptionSelected(command: CommandOptions)
}

class PreviewViewController: BaseViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var useButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    //MARK - Public variables

    var image: UIImage!
    
    //Mark: - Delegate
    
    var delegate: PreviewDelegate?
    
    //MARK - Private variables
    
    private var wasNavigationHidden: Bool = false

    //MARK: status bar visibility
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    //Mark: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideNavigationBar()
        
        self.view.backgroundColor = UIColor.init(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        if let img = image {
            self.imageView.image = img
        }
    }
    
    func hideNavigationBar() {
        
        wasNavigationHidden = (self.navigationController?.navigationBar.isHidden)!
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    @IBAction func mainViewOnTap(_ sender: UITapGestureRecognizer) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        close(command: CommandOptions.CANCEL)
    }

    //Mark: - Button Actions
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        close(command: CommandOptions.CANCEL)
    }

    @IBAction func retakeButtonClicked(_ sender: UIButton) {
        close(command: CommandOptions.CANCEL)
    }
    
    @IBAction func useButtonClicked(_ sender: UIButton) {
        close(command: CommandOptions.USE)
    }
    
    func close(command: CommandOptions) {
        //reset navigationbar visibility to same as it was before this screen was shown
        self.navigationController?.setNavigationBarHidden(wasNavigationHidden, animated: false)

        delegate?.onPreviewOptionSelected(command: command)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.view.alpha = 0
            self.dismiss(animated: true, completion: nil)
        }, completion: nil)
        
    }
}
