//
//  BillManager.swift
//  KofaxBank
//
//  Created by Rupali on 11/09/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

protocol BillManagerDelegate {
    func billPaymentSucceded()
    func billPaymentFailed(error: AppError!)
    func billPaymentCancelled()
}

class BillManager: BaseFlowManager, BillDataPreviewDelegate, InstructionsDelegate, PreviewDelegate, UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {
   
    private enum BillFlowStates {
        case NOOP
        case IMAGE_RETRIEVED
        case IMAGE_RETRIEVEL_CANCELLED
        case IMAGE_PREVIEWED
        case IMAGE_PROCESSED
        case IMAGE_PROCESSING_FAILED
        case IMAGE_DATA_EXTRACTED
        case IMAGE_DATA_EXTRACTION_FAILED
        case IMAGE_DATA_DISPLAYED
        case IMAGE_DATA_SAVED
        case CYCLE_COMPLETE
    }
    
    // MARK: Public variables
    var account: AccountsMaster?

    var delegate: BillManagerDelegate! = nil

    // MARK: Local variables
    
    private var navigationController: UINavigationController!

    private var instructionPopup: InstructionsPopup! = nil
    
    private var billDataPreview: BillDataPreviewViewController!
    

    private var captureController: ImageCaptureViewController! = nil

    private var capturedImage: kfxKEDImage! = nil
    
    private var processedImage: kfxKEDImage! = nil
    
    private var capturedImagePath: String! = nil
    
    private var processedImagePath: String! = nil
    
    private var previewPopup: PreviewViewController!

    private var imageProcessManager: ImageProcessManager! = nil
    
    private var extractionManager: ExtractionManager! = nil
    
    private var flowState = BillFlowStates.NOOP
    
    private var billData: kfxBillData! = nil
    
    private var errObj: AppError! = nil

    private let serverType = SERVER_TYPE_TOTALAGILITY
    
    
    override init() {
        super.init()
    }
    
    override func loadManager(navigationController: UINavigationController) {
        super.loadManager(navigationController: navigationController)
        
        self.navigationController = navigationController

        errObj = AppError.init()
    }
    
    // MARK: Private methods

    private func handleBillFlow(err: AppError!) {
        switch flowState {
            
        case .IMAGE_RETRIEVED:
            self.showPreviewPopup()
            break
            
        case .IMAGE_PREVIEWED:
            showBillDataPreviewScreen()
            self.processCapturedImage()
            break
            
        case .IMAGE_RETRIEVEL_CANCELLED:
            flowState = BillFlowStates.CYCLE_COMPLETE
            self.delegate?.billPaymentCancelled()
            break
            
        case .IMAGE_PROCESSED:
            if billDataPreview != nil {
                //display processed image on screen
                billDataPreview.processedImagePath = processedImagePath
                billDataPreview.processedImageReady()
            }
            extractData()
            break
            
        case .IMAGE_PROCESSING_FAILED:
            billDataPreview.billDataNotAvailable(err: err)
            flowState = BillFlowStates.CYCLE_COMPLETE
            //self.delegate?.newBillPaymentFailed(error: err)
            break
            
        case .IMAGE_DATA_EXTRACTION_FAILED:
            billDataPreview.billDataNotAvailable(err: err)
            flowState = BillFlowStates.CYCLE_COMPLETE
            //self.delegate?.newBillPaymentFailed(error: err)
            break
            
        case .IMAGE_DATA_EXTRACTED:
            billDataPreview.billDataAvailable(billData: self.billData)
            break
            
        case .CYCLE_COMPLETE:
            flowState = BillFlowStates.NOOP
            unloadManager()
            
        case .NOOP:
            unloadManager()
            break
            
        default:
            break
        }
    }


    private func showInstructionPopupForBill() {
        DispatchQueue.main.async {
            let parentView = self.navigationController.topViewController
            self.instructionPopup = InstructionsPopup.init(nibName: "InstructionsPopup", bundle: nil)
            self.instructionPopup.delegate = self
            
            self.instructionPopup.titleText = "Make Bill Payment?"
//            self.instructionPopup.bodyMessageText = "Take photo or select exising coupon from photo library.\n\nMake sure that coupon text is clearly visible on image for better reading."
            self.instructionPopup.bodyMessageText = "Take picture of coupon.\n\nMake sure that coupon text is clearly visible on image for better reading."

            self.instructionPopup.sampleImageName = "bill_sample_black"
            
            parentView?.addChildViewController(self.instructionPopup)
            self.instructionPopup.view.frame = (parentView?.view.frame)!
            
            parentView?.view.addSubview(self.instructionPopup.view)
            self.instructionPopup.view.alpha = 0
            self.instructionPopup.didMove(toParentViewController: parentView)
            
            UIView.animate(withDuration: 0.50, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.instructionPopup.view.alpha = 1
            }, completion: nil)
        }
    }

    
    private func showBillDataPreviewScreen() {
        billDataPreview = BillDataPreviewViewController.init(nibName: "BillDataPreviewViewController", bundle: nil)
        
        billDataPreview.processedImagePath = self.processedImagePath
        billDataPreview.rawImagePath = self.capturedImagePath

        let navController = UINavigationController.init(rootViewController: billDataPreview)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.backgroundColor = UIColor.clear
        
        let parentView: UIViewController! = self.navigationController.topViewController
        
        parentView.present(navController, animated: true, completion: nil)
        
        billDataPreview.account = self.account
        billDataPreview.delegate = self

    }
    
    private func closeCamera() {
        captureController.dismiss(animated: true, completion: nil)
        captureController.delegate = nil
    }
    
    
    override func showCamera() {
        super.showCamera()
        
        let captureOptions = CaptureOptions()
        captureOptions.showAutoTorch = false
        captureOptions.showGallery = false
        captureOptions.useVideoFrame = false
        
        
        let experienceOptions = ExperienceOptions()
        experienceOptions.stabilityThresholdEnabled = true
        experienceOptions.pitchThresholdEnabled = true
        experienceOptions.rollThresholdEnabled = true
        experienceOptions.focusConstraintEnabled = true
        experienceOptions.doShowGuidingDemo = getGuidingDemoStatus()
        experienceOptions.portraitMode = false
        experienceOptions.edgeDetection = 1
        experienceOptions.stabilityThreshold = 95
        experienceOptions.pitchThreshold = 15
        experienceOptions.rollThreshold = 15
        experienceOptions.longAxisThreshold = 85
        experienceOptions.shortAxisThreshold = 85
        experienceOptions.staticFrameAspectRatio = 0
        experienceOptions.documentSide = DocumentSide.FRONT
        experienceOptions.captureExperienceType = CaptureExperienceType.DOCUMENT_CAPTURE
        experienceOptions.zoomMaxFillFraction = 1.3
        experienceOptions.zoomMinFillFraction = 0.4
        experienceOptions.movementTolerance = 0
        
        //messages options -- use defaults for now
        
        let messages = ExperienceMessages()
        messages.holdSteadyMessage = "Hold Steady"
        messages.moveCloserMessage = "Move Closer"
        messages.userInstruction = "Fill viewable area with payment coupon"
        messages.centerMessage = "Center Payment Coupon"
        messages.zoomOutMessage = "Move Back"
        messages.capturedMessage = "Done!"
        messages.holdParallelMessage = "Hold Device Level"
        messages.orientationMessage = "Rotate Device"
        
        experienceOptions.messages = messages
        
        if self.captureController != nil {
            self.captureController.delegate = nil
            self.captureController = nil
        }
        self.captureController = ImageCaptureViewController.init(options: captureOptions, experienceOptions: experienceOptions, regionProperties: nil, showRegionSelection: false)
        self.captureController.delegate = self
        
        let navController = UINavigationController.init(rootViewController: self.captureController)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.backgroundColor = UIColor.clear
        
        let parentView: UIViewController! = self.navigationController.topViewController
        parentView.present(navController, animated: true, completion: nil)
    }
    private func getGuidingDemoStatus() -> Bool {
        
        var captureGuidance: Bool = true
        
        if let status = UserDefaults.standard.value(forKey: KEY_BILLPAY_CAPTURE_GUIDANCE) as? Bool {
            captureGuidance = status
        }
        
        return captureGuidance
    }
    
    override func imageCaptured(image: kfxKEDImage) {
        print("Image Captured!")
        closeCamera()
        performPostImageRetrievalTasks(image: image)
    }
    
    override func cancelCamera() {
        closeCamera()
        flowState = BillFlowStates.CYCLE_COMPLETE
        handleBillFlow(err: nil)
    }
    
    override func showGallery() {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        navigationController.topViewController?.present(picker, animated: true, completion: nil)
    }
    
    private func performPostImageRetrievalTasks(image: kfxKEDImage) {
        ImageUtilities.clearImage(image: capturedImage)
        capturedImage = nil  //clear old image before assigning new one
        
        capturedImage  = image;
        capturedImage.imageMimeType = MIMETYPE_TIF
        
        //save image on to disk in JPG format
        self.capturedImagePath = DiskUtility.shared.saveAsJPEGToDisk(image: self.capturedImage, side: ImageType.FRONT_RAW)
        
        flowState = BillFlowStates.IMAGE_RETRIEVED
        handleBillFlow(err: nil)
    }
    
    private func showPreviewPopup() {
        DispatchQueue.main.async {
            var previewVC: PreviewViewController!
            
            let parentView = self.navigationController.topViewController!
            
            previewVC = PreviewViewController.init(nibName: "PreviewViewController", bundle: nil)
            previewVC.delegate = self
            
            if self.capturedImage != nil {
                previewVC.image = self.capturedImage.getBitmap()
            }
            
            parentView.addChildViewController(previewVC)
            previewVC.view.frame = parentView.view.frame
            
            parentView.view.addSubview(previewVC.view)
            previewVC.view.alpha = 0
            previewVC.didMove(toParentViewController: parentView)
            
            UIView.animate(withDuration: 0.50, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                previewVC.view.alpha = 1
            }, completion: nil)
            
            self.previewPopup = previewVC
        }
    }

    
    // MARK : Instruction screen delegate

    func onInstructionOptionSelected(command: CommandOptions) {
        
        if instructionPopup != nil {
            instructionPopup.removeFromParentViewController()
            instructionPopup.delegate = nil
            instructionPopup = nil
        }
        
        if command == CommandOptions.CANCEL {
            flowState = BillFlowStates.CYCLE_COMPLETE
            handleBillFlow(err: nil)

        } else if command == CommandOptions.CAMERA {
            showCamera()
            
        } else if command == CommandOptions.GALLERY {
            showGallery()
        }
    }
    
    // MARK : Preview screen delegate
    func onPreviewOptionSelected(command: CommandOptions) {
        print("onPreviewOptionSelected")
        
        if previewPopup != nil {
            previewPopup.removeFromParentViewController()
            previewPopup.delegate = nil
            previewPopup = nil
        }
        if command == CommandOptions.USE {
            
            flowState = BillFlowStates.IMAGE_PREVIEWED
            
        } else if command == CommandOptions.RETAKE {
            
            flowState = BillFlowStates.IMAGE_RETRIEVEL_CANCELLED
            
        } else if command == CommandOptions.CANCEL {
            
            flowState = BillFlowStates.IMAGE_RETRIEVEL_CANCELLED
        }
        handleBillFlow(err: nil)
    }
    
    // Mark: - ImagePickerController delegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.delegate = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.delegate = nil
        
        let imageFileUrl: URL = info[UIImagePickerControllerReferenceURL] as! URL
        var image: UIImage? = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        let dpi = ImageUtilities.getImageDPI(imageUrl: imageFileUrl)
        
        performPostImageRetrievalTasks(image: ImageUtilities.createKfxKEDImage(sourceImage: image!, dpiValue: dpi))
        
        image = nil
        picker.dismiss(animated: true, completion: nil)
    }


    // MARK: BillDataPreviewDelegate Methods
    func billPreviewOnCancelData() {
        delegate?.billPaymentCancelled()
        
        flowState = BillFlowStates.CYCLE_COMPLETE
        handleBillFlow(err: nil)
    }

    
    func billPreviewOnDataSaved(data: kfxBillData) {
//        Utility.showAlert(onViewController: self, titleString: "Bill Paid", messageString: "Bill for the required amount is paid.")
        //Utility.showAlertWithCallback(onViewController: navigationController.topViewController!, titleString: "Bill Paid", messageString: "Bill for the required amount is paid.", positiveActionTitle: "OK", negativeActionTitle: nil, positiveActionResponse: {

            self.delegate?.billPaymentSucceded()
            
            self.flowState = BillFlowStates.CYCLE_COMPLETE
            self.handleBillFlow(err: nil)
            
        //}, negativeActionResponse: {
            
        //})
    }

    //MARK: - Image processing methods
    
    private func processCapturedImage() {
        
        let processParams = ImageProcessParameters()
        processParams.inputImage = capturedImage
        
        processParams.profile = self.getProcessingProfile()
        processParams.processedImageFilePath = nil
        
        processImage(processParams: processParams)
    }
    
    private func getProcessingProfile() -> kfxKEDImagePerfectionProfile {
        
        let ppf: kfxKEDImagePerfectionProfile!
        
        var evrsProcessingString: String! = nil
        
        let USE_DEFAULTS = true
        
        //default processing params
        if USE_DEFAULTS {
            evrsProcessingString = getDefaultIPStringForBill()
        } else {

        }
        print("evrsSettingsString ====> \(evrsProcessingString)")
        
        ppf = kfxKEDImagePerfectionProfile.init(name: "PerfectionProfile", andOperations: evrsProcessingString)
        ppf.useTargetFrameCrop = KED_USETARGETFRAMECROP_ON
        
        return ppf
    }
    
    private func getDefaultIPStringForBill() -> String {
        
        return "_DoBinarization__DoCropCorrection__DoDocumentDetectorBasedCrop__DoSkewCorrectionAlt__Do90DegreeRotation_4_LoadSetting_<Property Name=\"CSkewDetect.convert_to_gray.Bool\" Value=\"1\" Comment=\"DEFAULT 0 \" />_LoadSetting_<Property Name=\"CSkewDetect.scale_image_down.Bool\" Value=\"1\" Comment=\"DEFAULT 0 \" />_LoadSetting_<Property Name=\"CSkewDetect.scale_down_factor.Int\" Value=\"80\"  Comment=\"DEFAULT  80:60 or  4:3 \" />_LoadSetting_<Property Name=\"CSkewDetect.document_size.Int\" Value=\"2\" Comment=\"MEDIUM, DEFAULT  0\" />_LoadSetting_<Property Name=\"CSkewDetect.correct_illumination.Bool\" Value = \"0\"/>"
    }
    
    func processImage(processParams: ImageProcessParameters)  {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            if self.imageProcessManager == nil {
                self.imageProcessManager = ImageProcessManager.init()
            }
            
            self.imageProcessManager.processImage(parameters: processParams, completionCallback: {outputImage, error in
                
                self.imageProcessManager.unload()
                self.imageProcessManager = nil
                
                ImageUtilities.clearImage(image: self.capturedImage)
                
                if error == nil {
                    
                    //image processing successful
                    ImageUtilities.clearImage(image: self.processedImage)
                    self.processedImage = nil
                    
                    self.processedImage = outputImage as! kfxKEDImage
                    self.processedImage.imageMimeType = MIMETYPE_TIF
                    
                    print("Image DPI right after processing ==> \(self.processedImage.imageDPI)")
                    
                    self.processedImagePath = DiskUtility.shared.saveAsJPEGToDisk(image: self.processedImage, side: ImageType.FRONT_PROCESSED)
                    
                    self.flowState = BillFlowStates.IMAGE_PROCESSED
                    self.handleBillFlow(err: nil)
                }
                else {
                    self.flowState = BillFlowStates.IMAGE_PROCESSING_FAILED
                    
                    self.errObj.title = "Image Processing Failed"
                    self.errObj.message  = error.debugDescription
                    self.handleBillFlow(err: self.errObj)
                }
                
            }, progressCallback: { progressPercent in
                print("percentage = \(progressPercent)");
            })
        }
    }
    
    var parameters: NSMutableDictionary! = nil
    
    //MARK: Data extraction methods
    override func extractData() {
        if (!Utility.isConnectedToNetwork()) {
            
            flowState = BillFlowStates.IMAGE_DATA_EXTRACTION_FAILED
            self.errObj.title = "Network Error"
            self.errObj.message  = "A working network connection is required to read data from bill. \nPlease check network connection and try again."
            self.handleBillFlow(err: self.errObj)
            
            return
        }
        
        let urlString = getServerUrlString()
        
        let sessionID = getSessionId()
        
        let processIdentityName = getProcessIdentityName()
        
        if urlString.characters.count == 0 || sessionID.characters.count == 0 || processIdentityName.characters.count == 0 {
            flowState = BillFlowStates.IMAGE_DATA_EXTRACTION_FAILED
            self.errObj.title = "Parameters Error"
            self.errObj.message  = "Required server parameters are missing to read the data from bill."
            self.handleBillFlow(err: self.errObj)
            
            return
        }
        DispatchQueue.global().async {
            if self.extractionManager == nil {
                self.extractionManager = ExtractionManager.shared
            }
            self.extractionManager.delegate = self
            
            
            //var arrUnProccessed: NSMutableArray = NSMutableArray.init()   //required if going to store original image
            
            if self.parameters != nil {
                self.parameters.removeAllObjects()
                self.parameters = nil
            }
            self.parameters = NSMutableDictionary.init()
            
            if self.serverType == SERVER_TYPE_TOTALAGILITY {
                self.extractionManager.serverType = SERVER_TYPE_TOTALAGILITY
                
                //We need to send login credentials to the server if the server type is KTA.
//                let serverURL: URL! = URL.init(string: "http://t4cgm8rclt1mnw5.asia.kofax.com/totalagility/services/sdk/")

                let url = URL.init(string: urlString)
                
               // let serverURL: URL! = URL.init(string: "http://hyd-mob-kta73.asia.kofax.com/totalagility/services/sdk")
                
                self.parameters.setValue(processIdentityName, forKey: "processIdentityName")
                
                self.parameters.setValue(sessionID, forKey: "sessionId")
                self.parameters.setValue("", forKey: "documentName")
                self.parameters.setValue("", forKey: "documentGroupName")
                self.parameters.setValue("", forKey: "username")
                self.parameters.setValue("", forKey: "password")
                
                self.parameters.setValue("0", forKey: "storeFolderAndDocuments")
                
                self.extractionManager.extractImagesData(fromProcecssedImageArray: NSMutableArray.init(object: self.processedImage), serverUrl: url!, paramsDict: self.parameters, imageMimeType: MIMETYPE_TIF)
            }
        }
    }
    private func getServerUrlString() -> String {
        let urlString = UserDefaults.standard.value(forKey: KEY_BILLPAY_SERVER_URL)
        
        print("Bill URL ::: \(urlString as! String)")
        
        if urlString != nil {
            return urlString as! String
        }
        return ""
    }
    
    
    private func getSessionId() -> String {
        let sessionID = UserDefaults.standard.value(forKey: KEY_BILLPAY_SESSION_ID)
        
        print("Bill sessionID ::: \(sessionID as! String)")
        
        if sessionID != nil {
            return sessionID as! String
        }
        return ""
    }
    
    private func getProcessIdentityName() -> String {
        let processIdentityName = UserDefaults.standard.value(forKey: KEY_BILLPAY_PROCESS_IDENTITY_NAME)
        
        print("Bill Process Identity Name ::: \(processIdentityName as! String)")
        
        if processIdentityName != nil {
            return processIdentityName as! String
        }
        return ""
    }

    override func extractionSucceeded(statusCode: NSInteger, results: Data) {
        
        flowState = BillFlowStates.IMAGE_DATA_EXTRACTED
        
        let billRawData: NSMutableDictionary! = parseResponse(data: results)
        
        if billRawData != nil {
            self.billData = getBillData(rawData: billRawData)
            print("Data found during Bill data parsing")
        } else {
            print("No data found during Bill data parsing")
        }
        
        handleBillFlow(err: nil)
    }
    
    override func extractionFailedWithError(error: Error!, responseCode: NSInteger, errorData: Data!) {
        flowState = BillFlowStates.IMAGE_DATA_EXTRACTION_FAILED
        if self.errObj == nil {
            self.errObj = AppError.init()
        }
        self.errObj.title = "Data read failed"
        if errorData != nil {
            self.errObj.message  = "Bill data read failed with error Data==> \(errorData)"
        } else {
            self.errObj.message  = "Bill data read failed"
        }
        self.handleBillFlow(err: self.errObj)
    }
    

    // MARK: Data parsing
    
    func parseResponse(data: Data) -> NSMutableDictionary! {
        
        var billRawData: NSMutableDictionary! = nil
        
        do {
            var response: [AnyHashable: Any]! = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [AnyHashable: Any]
            
            var responseDictionary: NSMutableDictionary! = DataParser.parseKTAResponseFields(response)! as NSMutableDictionary
            if responseDictionary.value(forKey: STATIC_SERVER_FIELDS) != nil {
                var fieldDataArray: NSMutableArray! = responseDictionary.value(forKey: STATIC_SERVER_FIELDS) as! NSMutableArray
                //print("Extraction Results::: \(fieldDataArray) ")
                
                billRawData = NSMutableDictionary.init()
                
                for arrEle in fieldDataArray {
                    
                    let eleDict: NSDictionary = arrEle as! NSDictionary
                    // print("EleDict element ===> \(eleDict)")
                    
                    let dataField: kfxDataField = kfxDataField.init()
                    dataField.value = eleDict.value(forKey: "text") as! String
                    dataField.confidence = eleDict.value(forKey: "confidence") as! CGFloat
                    
                    let text = eleDict.value(forKey: "name") as! String
                    
                    //split string for proper field-name
                    let component = text.components(separatedBy: "_")
                    
                    let key: String!
                    if component.count > 1 {
                        key = component[1]
                    } else {
                        key = component[0]
                    }
                    
                    print("key ===> \(key) and Value ===> \(dataField.value)")
                    
                    dataField.name = key
                    //store this field entry in dictionary with key as the field name (for a convinient search later)
                    billRawData.setValue(dataField, forKey: key)
                }
                fieldDataArray.removeAllObjects()
                fieldDataArray = nil
                responseDictionary.removeAllObjects()
                responseDictionary = nil
                response.removeAll()
                response = nil
                
                if billRawData.count > 0 {
                    
                }
                
            }
        } catch {
            print(error)
        }
        return billRawData
    }
    
    private func getBillData(rawData: NSMutableDictionary) -> kfxBillData {
        
        billData = nil

        billData = kfxBillData.init()

        if let name = rawData.value(forKey: "Name") as? kfxDataField {
            billData.name = name
        }
        
        if let addressLine1 = rawData.value(forKey: "AddressLine1") as? kfxDataField {
            billData.addressLine1 = addressLine1
        }

        if let addressLine2 = rawData.value(forKey: "AddressLine2") as? kfxDataField {
            billData.addressLine2 = addressLine2
        }
        
        if let city = rawData.value(forKey: "City") as? kfxDataField {
            billData.city = city
        }

        if let state = rawData.value(forKey: "State") as? kfxDataField {
            billData.state = state
        }

        if let zip = rawData.value(forKey: "Zip") as? kfxDataField {
            billData.zip = zip
        }

        if let accountNumber = rawData.value(forKey: "AccountNumber") as? kfxDataField {
            billData.accountNumber = accountNumber
        }

        if let amountDue = rawData.value(forKey: "AmountDue") as? kfxDataField {
            billData.amount = amountDue
        }

        if let dueDate = rawData.value(forKey: "DueDate") as? kfxDataField {
            billData.dueDate = dueDate
        }

        if let phoneNumber = rawData.value(forKey: "PhoneNumber") as? kfxDataField {
            billData.phoneNumber = phoneNumber
        }

        if let source = rawData.value(forKey: "Source") as? kfxDataField {
            billData.source = source
        }

        if let billers = rawData.value(forKey: "Billers") as? kfxDataField {
            billData.billers = billers
        }
        
        //TODO: add payer informationa as well. Its is received in extraction data but relevant fields are not available in billData
        //PayerName
        //PayerAddressLine1
        //PayerAddressLine2
        //PayerCity
        //PayerState
        //PayerZip
        //PayerSource

        return billData
    }
    
    //MARK: BillerViewControllerDelegate
    
    func paybillWithNewBiller(account: AccountsMaster) {
        self.account = account
        showInstructionPopupForBill()
    }
    

    override func unloadManager() {
        DiskUtility.shared.removeFile(atPath: self.capturedImagePath)
        DiskUtility.shared.removeFile(atPath: self.processedImagePath)
        
        billData = nil
        errObj = nil
        ImageUtilities.clearImage(image: capturedImage)
        ImageUtilities.clearImage(image: processedImage)
        captureController = nil
        navigationController = nil
        billDataPreview = nil

        if imageProcessManager != nil {
            imageProcessManager.unload()
            imageProcessManager = nil
        }
        if extractionManager != nil {
            extractionManager.unload()
            extractionManager = nil
        }
    }
    
    deinit {
        unloadManager()
    }
    
    
    
    
}
