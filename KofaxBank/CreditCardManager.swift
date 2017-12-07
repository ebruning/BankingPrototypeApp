//
//  CreditCardManager.swift
//  KofaxBank
//
//  Created by Rupali on 01/09/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

protocol CreditCardManagerDelegate {
    
    func cardSubmittedForActivation(cardData: kfxCreditCardData)
}

class CreditCardManager: BaseFlowManager, UINavigationControllerDelegate,
                        UIImagePickerControllerDelegate,
                        PreviewDelegate, CreditCardDataPreviewDelegate, InstructionsDelegate {

    private enum CreditCardFlowStates {
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

    var delegate: CreditCardManagerDelegate? = nil
    
    // MARK: Local variables
    private var navigationController: UINavigationController!

    private var creditCardDataPreview: CreditCardDataPreviewViewController!
    
    private var captureController: ImageCaptureViewController! = nil

    private var capturedImage: kfxKEDImage! = nil
    
    private var processedImage: kfxKEDImage! = nil

    private var capturedImagePath: String! = nil

    private var processedImagePath: String! = nil
    
    private var previewPopup: PreviewViewController!
    
    private var instructionPopup: InstructionsPopup! = nil

    private var imageProcessManager: ImageProcessManager! = nil
    
    private var extractionManager: ExtractionManager! = nil
    
    private var flowState = CreditCardFlowStates.NOOP
    
    private var cardData: kfxCreditCardData! = nil

    private var errObj: AppError! = AppError.init()
    
    private var parameters: NSMutableDictionary! = nil
    
    private let serverType = SERVER_TYPE_TOTALAGILITY
    
    override init() {
        super.init()
    }
    
    override func loadManager(navigationController: UINavigationController) {
        super.loadManager(navigationController: navigationController)
        
        self.navigationController = navigationController

        showInstructionPopupForCreditCard()
    }
    
/*
    func loadManagerWithCamera(navigationController: UINavigationController) {
        super.loadManager()
        self.navigationController = navigationController
        

        showCreditCardDataPreviewScreen()
    
        showCamera()
    }
    
    func loadManagerWithGallery(navigationController: UINavigationController) {
        super.loadManager()

        self.navigationController = navigationController
        
        showCreditCardDataPreviewScreen()

        showGallery()
    }
    */
/*
    private func showInstructionPopupForCreditCard() {
        DispatchQueue.main.async {
            let parentView = self.navigationController.topViewController
            self.instructionPopup = InstructionsPopup.init(nibName: "InstructionsPopup", bundle: nil)
            self.instructionPopup.delegate = self
            
            self.instructionPopup.titleText = "Add Supplementary Card?"
            self.instructionPopup.bodyMessageText = "Provide image of your new supplementary card.\n\nMake sure that the captured side (FRONT or BACK) of the card image contains card number."
            self.instructionPopup.sampleImageName = "credit_card_sample_black"

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
*/
    
    private func showInstructionPopupForCreditCard() {
        DispatchQueue.main.async {
            let parentView = self.navigationController.topViewController
            self.instructionPopup = InstructionsPopup.init(nibName: "InstructionsPopup", bundle: nil)
            self.instructionPopup.delegate = self
            
            self.instructionPopup.titleText = "Activate Card?"
            self.instructionPopup.bodyMessageText = "Take picture of your new card.\n\nMake sure that the captured side (FRONT or BACK) of the card image contains card number."
            self.instructionPopup.sampleImageName = "credit_card_sample_black"
            
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

    private func showCreditCardDataPreviewScreen() {
        
        creditCardDataPreview = CreditCardDataPreviewViewController.init(nibName: "CreditCardDataPreviewViewController", bundle: nil)

        creditCardDataPreview.processedImagePath = self.processedImagePath
        creditCardDataPreview.rawImagePath = self.capturedImagePath

        let navController = UINavigationController.init(rootViewController: creditCardDataPreview)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.backgroundColor = UIColor.clear

        let parentView: UIViewController! = self.navigationController.topViewController

        parentView.present(navController, animated: true, completion: nil)
//        navigationController.pushViewController(creditCardDataPreview, animated: true)
    
        creditCardDataPreview.delegate = self
    }
    
    private func handleCreditCardFlow(err: AppError!) {
        switch flowState {
            
        case .IMAGE_RETRIEVED:
            self.showPreviewPopup()
            break
            
        case .IMAGE_RETRIEVEL_CANCELLED:
            flowState = CreditCardFlowStates.CYCLE_COMPLETE
            break

        case .IMAGE_PREVIEWED:
            showCreditCardDataPreviewScreen()
            self.processCapturedImage()
            break

        case .IMAGE_PROCESSED:
            if creditCardDataPreview != nil {
                //display processed image on screen
                creditCardDataPreview.processedImagePath = processedImagePath
                creditCardDataPreview.processedImageReady()
            }
            extractData()
            break
            
        case .IMAGE_PROCESSING_FAILED:
            creditCardDataPreview.cardDataNotAvailable(err: err)
            flowState = CreditCardFlowStates.CYCLE_COMPLETE
            break

        case .IMAGE_DATA_EXTRACTION_FAILED:
            creditCardDataPreview.cardDataNotAvailable(err: err)
            flowState = CreditCardFlowStates.CYCLE_COMPLETE
            break

        case .IMAGE_DATA_EXTRACTED:
            creditCardDataPreview.cardDataAvailable(cardData: self.cardData, company: self.cardCompanyField)
            break
            
        case .CYCLE_COMPLETE:
            flowState = CreditCardFlowStates.NOOP
            unloadManager()
            break
            
        case .NOOP:
            unloadManager()
            break

        default:
            break
        }
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
        experienceOptions.doShowGuidingDemo = true
        experienceOptions.portraitMode = true
        experienceOptions.edgeDetection = 1
        experienceOptions.stabilityThreshold = 95
        experienceOptions.pitchThreshold = 15
        experienceOptions.rollThreshold = 15
        experienceOptions.longAxisThreshold = 85
        experienceOptions.shortAxisThreshold = 85
        experienceOptions.staticFrameAspectRatio = 1.58
        experienceOptions.documentSide = DocumentSide.FRONT
        experienceOptions.captureExperienceType = CaptureExperienceType.DOCUMENT_CAPTURE
        experienceOptions.zoomMaxFillFraction = 1.1
        experienceOptions.zoomMinFillFraction = 0.7
        experienceOptions.movementTolerance = 0.07
        
        //messages options -- use defaults for now
        
        let messages = ExperienceMessages()
        messages.holdSteadyMessage = "Hold Steady"
        messages.moveCloserMessage = "Move Closer"
        messages.userInstruction = "Fill viewable area with credit card"
        messages.centerMessage = "Center credit card"
        messages.zoomOutMessage = "Move back"
        messages.capturedMessage = "Done!"
        messages.holdParallelMessage = "Hold device level"
        messages.orientationMessage = "Rotate device"
        
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
     //   self.creditCardDataPreview.present(self.captureController, animated: true, completion: nil)
    }
    
    override func imageCaptured(image: kfxKEDImage) {
        print("Image Captured!")
        closeCamera()
        performPostImageRetrievalTasks(image: image)
    }
    
    override func cancelCamera() {
        closeCamera()
        flowState = CreditCardFlowStates.CYCLE_COMPLETE
        handleCreditCardFlow(err: nil)
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

        //save image on to disk in JPG format
        self.capturedImagePath = DiskUtility.shared.saveAsJPEGToDisk(image: self.capturedImage, side: ImageType.FRONT_RAW)
        
        flowState = CreditCardFlowStates.IMAGE_RETRIEVED
        handleCreditCardFlow(err: nil)
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
            flowState = CreditCardFlowStates.CYCLE_COMPLETE
            handleCreditCardFlow(err: nil)
            
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
            
            flowState = CreditCardFlowStates.IMAGE_PREVIEWED
            
        } else if command == CommandOptions.RETAKE {
            
            flowState = CreditCardFlowStates.IMAGE_RETRIEVEL_CANCELLED

        } else if command == CommandOptions.CANCEL {
            
            flowState = CreditCardFlowStates.IMAGE_RETRIEVEL_CANCELLED
        }
        handleCreditCardFlow(err: nil)
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

    
    
    //MARK: - Image processing methods

    private func processCapturedImage() {
        
        let processParams = ImageProcessParameters()
        processParams.inputImage = capturedImage
        processParams.profile = self.getProcessingProfile()
        
        processImage(processParams: processParams)
    }

    private func getProcessingProfile() -> kfxKEDImagePerfectionProfile {
        
        let ppf: kfxKEDImagePerfectionProfile!
        
        var evrsProcessingString: String! = nil
        
        let USE_DEFAULTS = true
        
        //default processing params
        if USE_DEFAULTS {
            evrsProcessingString = getDefaultIPStringForCreditCard()
        } else {
            //evrsProcessingString = IPPUtilities.getEVRSImagePerfectionString(fromSettings: nil, of: CREDITCARD, isFront: isFront, withScale: CGSize.zero, withFrontImageWidth: strImageWidth, withRegion: nil, isODEActive: false) as String
        }
        print("evrsSettingsString ====> \(evrsProcessingString)")
        
        ppf = kfxKEDImagePerfectionProfile.init(name: "PerfectionProfile", andOperations: evrsProcessingString)
        ppf.useTargetFrameCrop = KED_USETARGETFRAMECROP_ON
        
        return ppf
    }
    
    private func getDefaultIPStringForCreditCard() -> String {
    
    return "_DeviceType_2_Do90DegreeRotation_4_DoCropCorrection_DoScaleImageToDPI_300_DoSkewCorrectionPage__DocDimLarge_3.375_DocDimSmall_2.125_LoadInlineSetting_[CSkewDetect.correct_illumination.Bool=0]_LoadInlineSetting_[CSkewDetect.double_bkg_check_variability_thr.Int=-1]_LoadInlineSetting_[CSkewDetect.color_stats_error_sum_thr_white_bkg=24]"
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
                    self.processedImage.imageMimeType = MIMETYPE_JPG
                    
                    print("Image DPI right after processing ==> \(self.processedImage.imageDPI)")

                    self.processedImagePath = DiskUtility.shared.saveAsJPEGToDisk(image: self.processedImage, side: ImageType.FRONT_PROCESSED)

                    self.flowState = CreditCardFlowStates.IMAGE_PROCESSED
                    self.handleCreditCardFlow(err: nil)
                }
                else {
                    self.flowState = CreditCardFlowStates.IMAGE_PROCESSING_FAILED
                    
                    self.errObj.title = "Image Processing Failed"
                    self.errObj.message  = error.debugDescription
                    self.handleCreditCardFlow(err: self.errObj)
                }

            }, progressCallback: { progressPercent in
                print("percentage = \(progressPercent)");
            })
        }
    }


    //MARK: Data extraction methods
    override func extractData() {
        if (!Utility.isConnectedToNetwork()) {

            flowState = CreditCardFlowStates.IMAGE_DATA_EXTRACTION_FAILED
            self.errObj.title = "Network Error"
            self.errObj.message  = "A working network connection is required to read data from credit card. \nPlease check network connection and try again."
            self.handleCreditCardFlow(err: self.errObj)
            
            return
        }
        let urlString = getServerUrlString()
        
        let sessionId = getSessionId()
        
        let processIdentityName = getProcessIdentityName()
        
        if urlString.characters.count == 0 || sessionId.characters.count == 0 || processIdentityName.characters.count == 0 {
            flowState = CreditCardFlowStates.IMAGE_DATA_EXTRACTION_FAILED
            self.errObj.title = "Parameters Error"
            self.errObj.message  = "Required server parameters are missing to read the data from credit card."
            self.handleCreditCardFlow(err: self.errObj)
            
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
                let url = URL.init(string: urlString)
//            let serverURL: URL! = URL.init(string: "http://t4cgm8rclt1mnw5.asia.kofax.com/totalagility/services/sdk/")

//            let serverURL: URL! = URL.init(string: "http://win2012r2-kta.kofax.com/totalagility/services/sdk/")
            //let serverURL: URL! = URL.init(string: "http://hyd-mob-kta73.asia.kofax.com/totalagility/services/sdk/")
            self.parameters.setValue("Detect", forKey: "ExtractMethod")
            self.parameters.setValue("false", forKey: "ImagePerfection")

            self.parameters.setValue(processIdentityName, forKey: "processIdentityName")

            self.parameters.setValue(sessionId, forKey: "sessionId")

            self.parameters.setValue("0", forKey: "storeFolderAndDocuments")
            
             self.extractionManager.extractImagesData(fromProcecssedImageArray: NSMutableArray.init(object: self.processedImage), serverUrl: url!, paramsDict: self.parameters, imageMimeType: MIMETYPE_JPG)
        }
        }
    }
    
    private func getServerUrlString() -> String {
        let urlString = UserDefaults.standard.value(forKey: KEY_CREDIT_CARD_URL)
        
        print("Credit card URL ::: \(urlString as! String)")
        
        if urlString != nil {
            return urlString as! String
        }
        return ""
    }

    
    private func getSessionId() -> String {
        let sessionID = UserDefaults.standard.value(forKey: KEY_CREDIT_CARD_SESSION_ID)
        
        print("Credit card sessionID ::: \(sessionID as! String)")
        
        if sessionID != nil {
            return sessionID as! String
        }
        return ""
    }

    private func getProcessIdentityName() -> String {
        let processIdentityName = UserDefaults.standard.value(forKey: KEY_CREDIT_CARD_PROCESS_IDENTITY_NAME)
        
        print("Credit card Process Identity Name ::: \(processIdentityName as! String)")
        
        if processIdentityName != nil {
            return processIdentityName as! String
        }
        return ""
    }
    
    override func extractionSucceeded(statusCode: NSInteger, results: Data) {
        
        flowState = CreditCardFlowStates.IMAGE_DATA_EXTRACTED
        
        let cardRawData: NSMutableDictionary! = parseResponse(data: results)
        
        if cardRawData != nil {
            
            self.cardData = getCardData(rawData: cardRawData)
            
            if isNewCardExpired {
                if self.errObj == nil {
                    self.errObj = AppError.init()
                }
                self.errObj.title = "Invalid Card"
                self.errObj.message  = "The card validity has already ended.\nPlease use valid card and try again."
                
                flowState = CreditCardFlowStates.IMAGE_DATA_EXTRACTION_FAILED
                self.handleCreditCardFlow(err: self.errObj)
            }
            
            print("Data found during credit card parsing")
        } else {
            if self.errObj == nil {
                self.errObj = AppError.init()
            }
            self.errObj.title = "No Data"
            self.errObj.message  = "No data found on creadit card read"
            
            flowState = CreditCardFlowStates.IMAGE_DATA_EXTRACTION_FAILED
            self.handleCreditCardFlow(err: self.errObj)

            print("No data found during credit card parsing")
        }
        
        handleCreditCardFlow(err: nil)
    }
    
    override func extractionFailedWithError(error: Error!, responseCode: NSInteger, errorData: Data!) {
        flowState = CreditCardFlowStates.IMAGE_DATA_EXTRACTION_FAILED
        if self.errObj == nil {
            self.errObj = AppError.init()
        }
        self.errObj.title = "Data read failed"
        if errorData != nil {
            self.errObj.message  = "Credit card data read failed with error Data==> \(errorData)"
        } else {
            self.errObj.message  = "Credit card data read failed"
        }
        self.handleCreditCardFlow(err: self.errObj)
    }

    //MARK: - CreditCardDataPreviewDelegate
    
    func creditCardOnDataSaved(data: kfxCreditCardData) {

        Utility.showAlertWithCallback(onViewController: navigationController.topViewController!, titleString: "Card Activated", messageString: " Your card is now ready for use.\n\nMake sure it is signed before using it.", positiveActionTitle: "OK", negativeActionTitle: nil, positiveActionResponse: {

            self.delegate?.cardSubmittedForActivation(cardData: data)

            self.flowState = CreditCardFlowStates.CYCLE_COMPLETE
            self.handleCreditCardFlow(err: nil)
            
        }, negativeActionResponse: {
            
        })
    }

    func creditCardOnCancelData() {
        flowState = CreditCardFlowStates.CYCLE_COMPLETE
        handleCreditCardFlow(err: nil)
    }
    
    // MARK: Data parsing
    
    private func parseResponse(data: Data) -> NSMutableDictionary! {
        
        var cardRawData: NSMutableDictionary! = nil
        
        do {
            var response: [AnyHashable: Any]! = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [AnyHashable: Any]
            
            var responseDictionary: NSMutableDictionary! = DataParser.parseKTAResponseFields(response)! as NSMutableDictionary
            if responseDictionary.value(forKey: STATIC_SERVER_FIELDS) != nil {
                var fieldDataArray: NSMutableArray! = responseDictionary.value(forKey: STATIC_SERVER_FIELDS) as! NSMutableArray
                //print("Extraction Results::: \(fieldDataArray) ")
                
                cardRawData = NSMutableDictionary.init()
                
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
                    
                    print("key ===> \(key) and Value ===> \(dataField.value) with confidence ===> \(dataField.confidence)")
                    
                    dataField.name = key
                    //store this field entry in dictionary with key as the field name (for a convinient search later)
                    cardRawData.setValue(dataField, forKey: key)
                }
                fieldDataArray.removeAllObjects()
                fieldDataArray = nil
                responseDictionary.removeAllObjects()
                responseDictionary = nil
                response.removeAll()
                response = nil
                
                if cardRawData.count > 0 {
                    
                }
                
            }
        } catch {
            print(error)
        }
        return cardRawData
    }
    
    private var cardCompanyField: kfxDataField?
    private var isNewCardExpired: Bool!
    
    private func getCardData(rawData: NSMutableDictionary) -> kfxCreditCardData {
        
        cardData = nil
        
        cardData = kfxCreditCardData.init()
        
        print("Raw data ===> \(rawData)")
        
        if let cardExpiredField = rawData.value(forKey: "CardExpired") as? kfxDataField {
            isNewCardExpired = cardExpiredField.value == "true" ? true : false
        }

        if let cardNumberDataField = rawData.value(forKey: "CardNumber") as? kfxDataField {
            cardData.cardNumber = cardNumberDataField
        } else {
            cardData.cardNumber = kfxDataField()
        }
    
        if let cvvDataField = rawData.value(forKey: "CVV") as? kfxDataField {
            cardData.cvv = cvvDataField
        } else {
            cardData.cvv = kfxDataField()
        }
        
        //concatenate name
       
        let suffixField = rawData.value(forKey: "NameSuffix") as? kfxDataField
        let firstNameField = rawData.value(forKey: "FirstName") as? kfxDataField
        let middleNameField = rawData.value(forKey: "MiddleInitial") as? kfxDataField
        let lastNameField = rawData.value(forKey: "LastName") as? kfxDataField
        
        var nameString: String! = nil
        nameString = (suffixField?.value != nil || suffixField?.value != "") ? ((suffixField?.value)! + " ") : ""

        if firstNameField?.value != nil || firstNameField?.value != "" {
            nameString = nameString + (firstNameField?.value)! + " "
        }
        
        if middleNameField?.value != nil || middleNameField?.value != "" {
            nameString = nameString + (middleNameField?.value)! + " "
        }

        if lastNameField?.value != nil || lastNameField?.value != "" {
            nameString = nameString + (lastNameField?.value)! + " "
        }
        
        let nameField = kfxDataField.init()
        nameField.name = "Name"
        nameField.value = nameString
        cardData.name = nameField

        //parse expiration date into month and year
        let expDateField = rawData.value(forKey: "ExpirationDate") as? kfxDataField
        if expDateField != nil {
            if let dateStr = expDateField?.value {
            let dateParsedarr = dateStr.components(separatedBy: "/")
            let month = dateParsedarr[0]
            let year = dateParsedarr[1]
            
            let monthField = kfxDataField.init()
            monthField.name = "ExpirationMonth"
            monthField.value = month
            monthField.confidence = (expDateField?.confidence)!
                
            cardData.expirationMonth = monthField

            let yearField = kfxDataField.init()
            yearField.name = "ExpirationYear"
            yearField.value = year
            yearField.confidence = (expDateField?.confidence)!
                
            cardData.expirationYear = yearField
            }
        } else {
            cardData.expirationYear = kfxDataField()
            cardData.expirationMonth = kfxDataField()
        }
        
        let companyNameData = rawData.value(forKey: "CardNetwork") as? kfxDataField
        
        if companyNameData != nil {
            self.cardCompanyField = companyNameData!
        } else {
            self.cardCompanyField = kfxDataField()
        }

        return cardData
    }

    

    override func unloadManager() {
        
        DiskUtility.shared.removeFile(atPath: self.capturedImagePath)
        DiskUtility.shared.removeFile(atPath: self.processedImagePath)
        
        cardData = nil
        errObj = nil
        ImageUtilities.clearImage(image: capturedImage)
        ImageUtilities.clearImage(image: processedImage)
        captureController = nil
        navigationController = nil
        creditCardDataPreview = nil

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
