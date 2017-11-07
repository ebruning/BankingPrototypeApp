//
//  BarcodeReaderViewController.swift
//  KofaxBank
//
//  Created by Rupali on 13/10/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

protocol BarcodeReadViewControllerDelegate {
    func barcodeReadCompleted(withResult: kfxKEDBarcodeResult, andImage: kfxKEDImage)
    func barcodeReadCancelled()
}

class BarcodeReaderViewController: UIViewController, kfxKUIBarCodeCaptureControlDelegate {

    var delegate: BarcodeReadViewControllerDelegate?
    
    private var barcodeReader: kfxKUIBarCodeCaptureControl?
    
    private var barcodeImage: kfxKEDImage?
    
    private let ORIENTATION_PORTRAIT = true
    
    //MARK: Navigationbar related parameters
    private var wasNavigationHidden: Bool = false
    
    private var oldBarTintColor: UIColor!
    
    private var oldStatusBarStyle: UIStatusBarStyle!
    

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        initializeBarcodeControl()
    }
    
    
    // MARK: Private methods
    private func initializeBarcodeControl() {
        
        //let statusBarHeight:CGFloat = 20.0
        
//        let frame = CGRect.init(x: 0, y: statusBarHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 60)
      
        self.barcodeReader = kfxKUIBarCodeCaptureControl.init(frame: frame)
        setReaderOrientation()
        barcodeReader?.symbologies = NSArray.init(object: kfxKUISymbologyPdf417.rawValue) as! [Any]

        self.barcodeReader?.delegate = self
        
        self.view.addSubview(self.barcodeReader!)

        self.barcodeReader?.readBarcode()
    }
    
    private func setReaderOrientation() {
        if ORIENTATION_PORTRAIT {
            self.barcodeReader?.guidingLine = kfxKUIGuidingLinePortrait
         //   self.barcodeReader?.searchDirection = NSArray.init(object: kfxKUIDirectionHorizontal) as? [AnyObject]
        } else {
            self.barcodeReader?.guidingLine = kfxKUIGuidingLineLandscape
          //  self.barcodeReader?.searchDirection = NSArray.init(object: kfxKUIDirectionVertical) as! [Any]
        }
        self.barcodeReader?.searchDirection = [kfxKUIDirectionAll.rawValue]
    }

    
    private func freeBarcodeControl() {
        barcodeReader?.delegate = nil
        barcodeReader?.removeFromSuperview()
        barcodeReader = nil
            
        ImageUtilities.clearImage(image: barcodeImage)
        barcodeImage = nil
    }
    
    private func closeScreen() {
        DispatchQueue.main.async {
            self.freeBarcodeControl()

            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: Cancel button action
    
    @IBAction func onCancelButtonClicked(_ sender: UIButton) {
        delegate?.barcodeReadCancelled()
        
        closeScreen()
    }
    
    //MARK: BarcodeCaptureControl Delegate 
    func barcodeCaptureControl(_ barcodeCaptureControl: kfxKUIBarCodeCaptureControl!, barcodeFound result: kfxKEDBarcodeResult!, image: kfxKEDImage!) {
        self.barcodeImage = image
        
        //self.performSelector(onMainThread: #selector(sendResponse(result:)), with: result, waitUntilDone: false)
        self.performSelector(inBackground: #selector(sendResponse(result:)), with: result)
    }
    
    func sendResponse(result: kfxKEDBarcodeResult) {
        print("In sendResponse...")
        delegate?.barcodeReadCompleted(withResult: result, andImage: self.barcodeImage!)
        
        closeScreen()
    }
}
