//
//  CheckDepositManager.swift
//  KofaxBank
//
//  Created by Rupali on 04/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

protocol  CheckDepositManagerDelegate{
    func checkDepositComplete()
    func checkDepositCancelled()
    func checkDepositFailed(error: AppError!)
}
class CheckDepositManager: BaseFlowManager, PreviewDelegate, CheckDepositHomeViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private enum CheckStates {
        case CDNOOP
        case CDCAPTURING
        case CDCAPTURED
        case CDPROCESSING
        case CDPROCESSED
        case CDCANCELLING
        case CDCANCELLED
        case CDEXTRRACTING
        case CDEXTRACTED
        case CDFAILED
        //case CDPROCESSING_USECLICKED
        case CDREPROCESSING
        case CDREPROCESSED

    }
    
    
    // MARK: Public variables
    var account: AccountsMaster?
    var delegate: CheckDepositManagerDelegate? = nil

    // MARK: Local constants
        
    
    //TODO: temp constant
    let serverType = SERVER_TYPE_TOTALAGILITY
    
    
    // MARK: Local variables
    private var navigationController: UINavigationController!
    
    private var previewPopup: PreviewViewController!
    
    private var currentCapturedImage: kfxKEDImage! = nil
    private var currentProcessedImage: kfxKEDImage! = nil

    private var documentSide: DocumentSide = DocumentSide.FRONT
    
    private var checkHomeViewController: CheckDepositHomeViewController! = nil
    
    private var imageProcessManager: ImageProcessManager!
    
    private var captureController: ImageCaptureViewController! = nil
    private var frontCheckProcessed: Bool!
    private var backCheckProcessed: Bool!
    
    private var checkFlowState = CheckStates.CDNOOP
    
    private var extractionManager: ExtractionManager! = nil

    private var checkData: kfxCheckData! = nil
    private var checkIQData: kfxCheckIQAData! = nil

    override init() {
        print("CheckDepositManager init")
    }
    
    override func loadManager(navigationController: UINavigationController) {
        super.loadManager(navigationController: navigationController)
        self.navigationController = navigationController
        
        showCheckDepositHomeScreen()
    }

    private func showCheckDepositHomeScreen() {
        checkHomeViewController = CheckDepositHomeViewController.init(nibName: "CheckDepositHomeViewController", bundle: nil)
        navigationController?.pushViewController(checkHomeViewController, animated: true)
        checkHomeViewController.account = account
        checkHomeViewController.delegate = self
    }
    
    override func showCamera() {
        
        let captureOptions = CaptureOptions()
        captureOptions.showAutoTorch = false
        captureOptions.showGallery = false
        captureOptions.useVideoFrame = true

        
        let experienceOptions = ExperienceOptions()
        experienceOptions.stabilityThresholdEnabled = true
        experienceOptions.pitchThresholdEnabled = true
        experienceOptions.rollThresholdEnabled = true
        experienceOptions.focusConstraintEnabled = true
        experienceOptions.doShowGuidingDemo = true
        experienceOptions.portraitMode = false
        experienceOptions.edgeDetection = 0
        experienceOptions.stabilityThreshold = 95
        experienceOptions.pitchThreshold = 15
        experienceOptions.rollThreshold = 15
        experienceOptions.longAxisThreshold = 85
        experienceOptions.shortAxisThreshold = 85
        experienceOptions.staticFrameAspectRatio = 2.18000007
        experienceOptions.documentSide = documentSide
        experienceOptions.captureExperienceType = CaptureExperienceType.CHECK_CAPTURE
        experienceOptions.zoomMaxFillFraction = 0
        experienceOptions.zoomMinFillFraction = 0
        experienceOptions.movementTolerance = 0
        //experienceOptions.messages = nil
        //experienceOptions.tutorialSampleImage = nil
        
        //messages options -- use defaults for now
        
        let messages = ExperienceMessages()
        messages.holdSteadyMessage = "Hold Steady"
        messages.moveCloserMessage = "Move Closer"
        messages.userInstruction = "Fill viewable area with check"
        messages.centerMessage = "Center check"
        messages.zoomOutMessage = "Move back"
        messages.capturedMessage = "Done!"
        messages.holdParallelMessage = "Hold device level"
        messages.orientationMessage = "Rotate device"
        experienceOptions.messages = messages
        
        if(documentSide == DocumentSide.BACK){
            //messages.userInstruction = Klm([componentObject.texts.cameraText valueForKey:USERINSTRUCTIONBACK]);
            experienceOptions.staticFrameAspectRatio = fetchAspectRatioForBackCaptureExperience()
        }
        
        //self.navigationController.pushViewController(captureController, animated: true)
        if self.captureController != nil {
            self.captureController.delegate = nil
            self.captureController = nil
        }
        self.captureController = ImageCaptureViewController.init(options: captureOptions,
                                                                 experienceOptions: experienceOptions,
                                                                 regionProperties: nil, showRegionSelection: false)
        
        let navController = UINavigationController.init(rootViewController: self.captureController)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.backgroundColor = UIColor.clear
        
        self.captureController.delegate = self
        let parentView: UIViewController! = self.navigationController.topViewController
        parentView.present(navController, animated: true, completion: nil)
    }
    
    override func cancelCamera() {
      //  let vc = self.navigationController.popViewController(animated: true) as! ImageCaptureViewController
//        vc.delegate = nil
        self.captureController.delegate = nil
        self.captureController.dismiss(animated: true, completion: nil)
        
        //checkFlowState = CheckStates.CDNOOP
    }
    
    override func imageCaptured(image: kfxKEDImage) {
        print("Image Captured!")
        
        //checkFlowState = CheckStates.CDCAPTURED
        
        cancelCamera()
        performPostImageRetrievalTasks(image: image)
    }

    func performPostImageRetrievalTasks(image: kfxKEDImage) {
        ImageUtilities.clearImage(image: currentCapturedImage)
        currentCapturedImage = nil
        
        currentCapturedImage  = image;

        let imageSide = documentSide == DocumentSide.FRONT ? ImageType.FRONT_RAW : ImageType.BACK_RAW
        
        DispatchQueue.global(qos: .userInitiated).async {
            _ = DiskUtility.shared.saveAsJPEGToDisk(image: self.currentCapturedImage, side: imageSide)
        }

        DispatchQueue.main.async {
            self.previewPopup = self.showPreviewPopup()
        }
        
        DispatchQueue.global(qos: .background).async {
            //TODO: Do quick analysis here
        }
    }
    
    func showPreviewPopup() -> PreviewViewController  {
        
        let parentView = checkHomeViewController!
        var previewVC: PreviewViewController!
        
        previewVC = PreviewViewController.init(nibName: "PreviewViewController", bundle: nil)
        previewVC.delegate = self
        
        if currentCapturedImage != nil {
            previewVC.image = currentCapturedImage.getBitmap()
        }
        
        parentView.addChildViewController(previewVC)
        previewVC.view.frame = parentView.view.frame
        
        parentView.view.addSubview(previewVC.view)
        previewVC.view.alpha = 0
        previewVC.didMove(toParentViewController: parentView)
        
        UIView.animate(withDuration: 0.50, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            previewVC.view.alpha = 1
        }, completion: nil)
        
        return previewVC
    }
    

    // MARK : Aspect Ratio For Back Check Capture
    func fetchAspectRatioForBackCaptureExperience() -> Float {
        
        var aspectRatio:Float = 1
        
        let frontCheckImage = DiskUtility.shared.getImage(side: ImageType.FRONT_PROCESSED, mimeType: MIMETYPE_TIF)
        
        if let img = frontCheckImage {
            aspectRatio = Float(img.imageWidth) / Float(img.imageHeight)
        }
        
        ImageUtilities.clearImage(image: frontCheckImage)
        return aspectRatio
    }

    
    // MARK : Preview screen delegate
    func onPreviewOptionSelected(command: CommandOptions) {
        print("onPreviewOptionSelected")
        
        if previewPopup != nil {
            previewPopup.removeFromParentViewController()
            previewPopup.delegate = nil
            previewPopup = nil
        }
        DispatchQueue.main.async {
            if command == CommandOptions.USE {
                if self.documentSide == DocumentSide.FRONT {
                    //display front captured(raw) image
                    self.checkHomeViewController.displayFrontImage(image: self.currentCapturedImage, isProcessed: false)
                }
                else {
                    //display back captured(raw) image
                    self.checkHomeViewController.displayBackImage(image: self.currentCapturedImage, isProcessed: false)
                }
                self.checkFlowState = CheckStates.CDCAPTURED

            } else if command == CommandOptions.RETAKE {
                
                self.checkFlowState = CheckStates.CDNOOP
                
            } else if command == CommandOptions.CANCEL {
                
                self.checkFlowState = CheckStates.CDNOOP
                
            }
            self.handleCheckLifeCycle()
        }
    }

    func handleCheckLifeCycle()  {
        //start processing of captured image
        if (self.checkFlowState == CheckStates.CDCAPTURED/* || self.checkFlowState == CheckStates.CDNOOP */){
                processCapturedImage()

        } else if (self.checkFlowState == CheckStates.CDPROCESSED) {
            self.documentSide == DocumentSide.FRONT ? (self.frontCheckProcessed = true) : (self.backCheckProcessed = true)
            
            // if front image proceseed
            if documentSide == DocumentSide.FRONT {

                let resultArr = CheckValidation.validateSignature(onCheckFront: currentProcessedImage, isFrontSide: true) as NSMutableArray!
                
                if  let arr = resultArr {
                
                    //show error message
                    Utility.showAlert(onViewController: checkHomeViewController, titleString: arr.object(at: 0) as! String, messageString: arr.object(at: 1) as! String)

                    handleError(forSide: DocumentSide.FRONT)
                    
                } else {
                    // save front processed image on to disk
                    print("Image DPI before saving front image ==> \(self.currentProcessedImage.imageDPI)")
                    
                    let path = DiskUtility.shared.saveAsKfxKEDImageToDisk(image: self.currentProcessedImage, side: ImageType.FRONT_PROCESSED, mimeType: MIMETYPE_TIF)

                    if path == nil {
                        print("Failed to write image object to disk.")
                        Utility.showAlert(onViewController: checkHomeViewController, titleString: "", messageString: "Failed to save image on disk. Please try again.")
                        ImageUtilities.clearImage(image: self.currentProcessedImage)
                        checkFlowState = CheckStates.CDNOOP
                    }
                    else {
                        //display front processed image scaled-down version on CDHome screen
                        DispatchQueue.main.async {
                            self.checkHomeViewController.displayFrontImage(image: self.currentProcessedImage, isProcessed: true)
                        }
                    }
                }
            } else{
                // save back processed image on to disk
                print("Image DPI before saving back image ==> \(self.currentProcessedImage.imageDPI)")

                let path = DiskUtility.shared.saveAsKfxKEDImageToDisk(image: self.currentProcessedImage, side: ImageType.BACK_PROCESSED, mimeType: MIMETYPE_TIF)

                if path == nil {
                    print("Failed to write image object to disk.")
                    Utility.showAlert(onViewController: checkHomeViewController, titleString: "", messageString: "Failed to save image on disk. Please try again.")

                    handleError(forSide: DocumentSide.BACK)
                }
                else {
                    //display front processed image scaled-down version on CDHome screen
                    DispatchQueue.main.async {
                        self.checkHomeViewController.displayBackImage(image: self.currentProcessedImage, isProcessed: true)
                    }
                    
                    //validate check back side first
                    let metaData = self.currentProcessedImage.getMetaData() as String!
                    let isValid = validateCheckBack(metaData: metaData)
                    
                    //if valid - reprocess check to correct image orientation
                    if isValid {
                        reprocessCheckBackImage()
                    } else {
                        handleError(forSide: DocumentSide.BACK)
                    }
                }
            }
            //self.currentProcessedImage = nil    //TODO: right place to reset?
        }
            //TODO : as per this condition, currently, front of check should always be captured and processed first before back. Make it generic later.
        else if checkFlowState == CheckStates.CDREPROCESSED {  //back reprocessing done
            checkFlowState = CheckStates.CDPROCESSED
            //submit check images for extraction
            
            ImageUtilities.clearImage(image: currentCapturedImage)
            ImageUtilities.clearImage(image: currentProcessedImage)

            extractData()
        }
    }
    
    //verify endorsement and signature
    func validateCheckBack(metaData: String!) -> Bool {
        
        var isValid = false
        
        if (metaData) != nil {
            if CheckValidation.checkBackHasEndorsement(metaData) == false {
                
                Utility.showAlert(onViewController: checkHomeViewController, titleString: "Endorsement not found", messageString: "An endorsement could not be found on the back of the check. Please retry.")
                
            }  //verify MICR and Signature
            else if CheckValidation.verifySignatureAndMicr(metaData, isFrontSide: false) == 2 {
                Utility.showAlert(onViewController: checkHomeViewController, titleString: "Invalid check back", messageString: "This appears to be the front for the check. Please capture the back of the check")
            } else {
                isValid = true
            }
        }
        
        return isValid
    }
    
    
    private func handleError(forSide: DocumentSide) {

        ImageUtilities.clearImage(image: self.currentCapturedImage)
        ImageUtilities.clearImage(image: self.currentProcessedImage)
        checkFlowState = CheckStates.CDNOOP
        
        checkHomeViewController.handleError(checkSide: forSide)
    }
    
    private func processCapturedImage() {
    
        checkFlowState = CheckStates.CDPROCESSING
    
        let processParams = ImageProcessParameters()
        processParams.inputImage = currentCapturedImage
        processParams.profile = self.getProcessingProfile()
        processParams.processedImageFilePath = nil
        
        self.processImage(processParams: processParams)
    }

    private func reprocessCheckBackImage() {
        checkFlowState = CheckStates.CDREPROCESSING //set to re-processing status
        
        let backProcessedImg: kfxKEDImage? = DiskUtility.shared.getImage(side: ImageType.BACK_PROCESSED, mimeType: MIMETYPE_TIF)
        
        let processParams = ImageProcessParameters()
        processParams.inputImage = backProcessedImg
        processParams.profile = self.getReProcessingProfile()
        processParams.processedImageFilePath = nil
        
        self.processImage(processParams: processParams)
    }
    
    private func processImage(processParams: ImageProcessParameters)  {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            if self.imageProcessManager == nil {
                self.imageProcessManager = ImageProcessManager.init()
            }
            
            self.imageProcessManager.processImage(parameters: processParams, completionCallback: {outputImage, error in
                
                self.imageProcessManager.unload()
                self.imageProcessManager = nil
                
                if error == nil {
                    
                    //image processing successful
                    ImageUtilities.clearImage(image: self.currentProcessedImage)
                    self.currentProcessedImage = nil
                    
                    self.currentProcessedImage = outputImage as! kfxKEDImage
                    
                    print("Image DPI right after processing ==> \(self.currentProcessedImage.imageDPI)")

                    if(self.checkFlowState == CheckStates.CDREPROCESSING) {
                        self.checkFlowState = CheckStates.CDREPROCESSED
                    }
                    else {
                        self.checkFlowState = CheckStates.CDPROCESSED
                    }
                    self.handleCheckLifeCycle()
                }
                else {
                    Utility.showAlert(onViewController: self.navigationController.topViewController!, titleString: "Image Processing Failed", messageString: "with error \(error.debugDescription)")
                    self.checkFlowState = CheckStates.CDNOOP
                    ImageUtilities.clearImage(image: self.currentCapturedImage)
                }

            }, progressCallback: { progressPercent in
                print("percentage = \(progressPercent)");
            })
        }
    }
    
    
    // MARK :- Private methods
    
    private func getReProcessingProfile() -> kfxKEDImagePerfectionProfile {
        let kPerfectionProf: kfxKEDImagePerfectionProfile = kfxKEDImagePerfectionProfile.init(name: "PerfectionProfile", andOperations: "_DoBinarization_DeviceType_0_DoNoPageDetection__Do90DegreeRotation_3")
    
        return kPerfectionProf
    }
    
    private func getProcessingProfile() -> kfxKEDImagePerfectionProfile {
        var strImageWidth: String = ""
        
        if documentSide == DocumentSide.BACK && DiskUtility.shared.isImageInDisk(side: ImageType.FRONT_PROCESSED, mimeType: MIMETYPE_TIF) {
            // Fetch the Front Image Width
            strImageWidth = calculatCheckFrontWidth(frontProcessedImage: DiskUtility.shared.getImage(side: ImageType.FRONT_PROCESSED, mimeType: MIMETYPE_TIF))
        }
        
        let isFront = documentSide == DocumentSide.FRONT ? true : false
        
        let ppf: kfxKEDImagePerfectionProfile!
        let evrsSettingsString = IPPUtilities.getEVRSImagePerfectionString(fromSettings: nil, of: CHECKDEPOSIT, isFront: isFront, withScale: CGSize.zero, withFrontImageWidth: strImageWidth, isODEActive: false) as String
        
        print("evrsSettingsString ====> \(evrsSettingsString)")
        
        ppf = kfxKEDImagePerfectionProfile.init(name: "PerfectionProfile", andOperations: evrsSettingsString)
        
        return ppf
    }
    
    private func calculatCheckFrontWidth(frontProcessedImage:kfxKEDImage!) -> String {
        var strCheckFrontWidth: String = ""
        
        if frontProcessedImage != nil && frontProcessedImage.imageDPI != 0 {
            let width: Float = Float(frontProcessedImage.imageWidth) / Float(frontProcessedImage.imageDPI)
            strCheckFrontWidth = "\(width)"
            return strCheckFrontWidth
        }
        return strCheckFrontWidth
    }
    
    // MARK: CheckDepositHomeViewController Delegate
    
    func checkDepositCancelled() {
        delegate?.checkDepositCancelled()
        unloadManager()
    }
    
    func checkDeposited() {
        delegate?.checkDepositComplete()
        unloadManager()
    }
        
    func showGallery(side: DocumentSide) {
        documentSide = side
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        navigationController.topViewController?.present(picker, animated: true, completion: nil)
    }
    
    func showCamera(side: DocumentSide) {
        documentSide = side
        showCamera()
    }
    
    
    
    // MARK :- Extraction methods 
    
    var processedImgFilePathArr: NSMutableArray! = nil
    var parameters: NSMutableDictionary! = nil
    
    override func extractData() {

        if (!Utility.isConnectedToNetwork()) {
            Utility.showAlert(onViewController: checkHomeViewController, titleString: "Network Error", messageString: "A working network connection is required to read data from check. \nPlease check network connection and try again.")
        }
        
        if extractionManager == nil {
            extractionManager = ExtractionManager.shared
            extractionManager.delegate = self
        }
        
        if processedImgFilePathArr != nil {
            processedImgFilePathArr.removeAllObjects()
            processedImgFilePathArr = nil
        }
        processedImgFilePathArr = NSMutableArray.init()
        
        processedImgFilePathArr.add(DiskUtility.shared.getFilePathWithType(side: ImageType.FRONT_PROCESSED, type: MIMETYPE_TIF))

        processedImgFilePathArr.add(DiskUtility.shared.getFilePathWithType(side: ImageType.BACK_PROCESSED, type: MIMETYPE_TIF))

        print("File -- 1 \(processedImgFilePathArr.object(at: 0))")
        print("File -- 2 \(processedImgFilePathArr.object(at: 1))")

        //var arrUnProccessed: NSMutableArray = NSMutableArray.init()   //TODO: required if going to store original image

        if parameters != nil {
            parameters.removeAllObjects()
            parameters = nil
        }
        parameters = NSMutableDictionary.init()
        
        if serverType == SERVER_TYPE_TOTALAGILITY {
            extractionManager.serverType = SERVER_TYPE_TOTALAGILITY
            
            parameters.setValue("US", forKey: "Country")
            
            //We need to send login credentials to the server if the server type is KTA.
//            let serverURL: URL! = URL.init(string: "https://mobiledemo.kofax.com:443/mobilesdk/api/CheckDeposit?customer=Kofax")
            
            let serverURL: URL! = URL.init(string: "http://t4cgm8rclt1mnw5.asia.kofax.com/totalagility/services/sdk/")
            //let serverURL: URL! = URL.init(string: "http://hyd-mob-kta73.asia.kofax.com/totalagility/services/sdk")
          
            parameters.setValue("KofaxCheckDepositSync", forKey: "processIdentityName")
            parameters.setValue("", forKey: "documentName")
            parameters.setValue("", forKey: "documentGroupName")
            
            parameters.setValue("", forKey: "username")
            parameters.setValue("", forKey: "password")

            parameters.setValue("0", forKey: "storeFolderAndDocuments")
            
            //let sessionId = UserDefaults.standard.value(forKey: "SessionId") as! String
            parameters.setValue("C640521793431F4486D4EF1586672385", forKey: "sessionId")    //TODO: use session ID from login response
            
            checkHomeViewController.showWaitIndicator()
            
            let errorStatus = extractionManager.extractData(fromProcecssedImagePaths: processedImgFilePathArr, serverUrl: serverURL, extractionParams: parameters, imageMimeType: MIMETYPE_TIF)
            
            if errorStatus != KMC_SUCCESS {
                //Utility.showAlert(onViewController: checkHomeViewController, titleString: "Check data extraction failed", messageString: "\(errorStatus)")
                checkHomeViewController.checkDataNotAvailable()
            }
        }
        
        //processedImgFilePathArr.removeAllObjects()
        //parameters.removeAllObjects()
        
//        [self talkToRTTIwithFront:[appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF] AndBack:[appStateMachine getImage:BACK_PROCESSED mimeType:MIMETYPE_TIF]];

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
        //checkFlowState = CheckStates.CDCAPTURED
        performPostImageRetrievalTasks(image: ImageUtilities.createKfxKEDImage(sourceImage: image!, dpiValue: dpi))

        image = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: ExtractionManagerProtocol methods

    
    override func extractionFailedWithError(error: Error!, responseCode: NSInteger, errorData: Data!) {
        
        print("CheckDepositManager -- extraction failed with error delegate....")
        if error != nil {
      //      print("Error is ==> \(error.description)")
        }
        
        checkHomeViewController.checkDataNotAvailable()
        checkFlowState = CheckStates.CDNOOP
    }

    override func extractionSucceeded(statusCode: NSInteger, results: Data) {
        print("CheckDepositManager -- extractionSucceeded delegate.... \(results)")

        if statusCode != REQUEST_SUCCESS {
            Utility.showAlert(onViewController: checkHomeViewController, titleString: "Data Extraction Error", messageString: "Error occurred while reading data from check.")
        } else {
            checkFlowState = CheckStates.CDEXTRACTED
            let checkRawData: NSMutableDictionary! = parseResponse(data: results)
            
            if checkRawData != nil {

                checkData = getCheckDisplayData(rawData: checkRawData)
                checkIQData = getCheckIQData(rawData: checkRawData)

                checkHomeViewController.checkDataAvailable(checkData: checkData, checkIQAData: checkIQData)
            } else {
                print("No data found during check parsing")
            }
        }

    }
    
    // MARK: Data Parse methods
    
    func parseResponse(data: Data) -> NSMutableDictionary! {
        
        var checkRawData: NSMutableDictionary! = nil
        
        do {
            var response: [AnyHashable: Any]! = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [AnyHashable: Any]
        
            var responseDictionary: NSMutableDictionary! = DataParser.parseKTAResponseFields(response)! as NSMutableDictionary
            if responseDictionary.value(forKey: STATIC_SERVER_FIELDS) != nil {
                var fieldDataArray: NSMutableArray! = responseDictionary.value(forKey: STATIC_SERVER_FIELDS) as! NSMutableArray
                //print("Extraction Results::: \(fieldDataArray) ")
                
                checkRawData = NSMutableDictionary.init()
                
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
                    checkRawData.setValue(dataField, forKey: key)
                
                //checkData.checkNumber = dataField
                }
                fieldDataArray.removeAllObjects()
                fieldDataArray = nil
                responseDictionary.removeAllObjects()
                responseDictionary = nil
                response.removeAll()
                response = nil
                
                if checkRawData.count > 0 {

                }
                
            }
        } catch {
            print(error)
        }
        return checkRawData
    }

    private func getCheckDisplayData(rawData: NSMutableDictionary) -> kfxCheckData {
        
        checkData = nil

        checkData = kfxCheckData.init()

        
        if let amtDataField = rawData.value(forKey: "CheckAmount") as? kfxDataField {
            checkData.amount = amtDataField
        }
        
        if let carDataField = rawData.value(forKey: "CheckCAR") as? kfxDataField {
            checkData.car = carDataField
        }

        if let larDataField = rawData.value(forKey: "CheckLAR") as? kfxDataField {
            checkData.lar = larDataField
        }

        if let checkNumberDataField = rawData.value(forKey: "CheckNumber") as? kfxDataField {
            checkData.checkNumber = checkNumberDataField
        }
        
        if let dateDataField = rawData.value(forKey: "CheckDate") as? kfxDataField {
            checkData.date = dateDataField
        }
        
        if let payeeDataField = rawData.value(forKey: "CheckPayeeName") as? kfxDataField {
            checkData.payeeName = payeeDataField
        }

      //  data.micr????
      
        return checkData
    }
    
    private func getCheckIQData(rawData: NSMutableDictionary) -> kfxCheckIQAData {
        
        checkIQData = nil
        checkIQData = kfxCheckIQAData.init()
        
        
        if let dataField = rawData.value(forKey: "FoldedOrTornDocumentEdges") as? kfxDataField {
            checkIQData.foldedOrTornDocumentEdges = dataField
        }
        
        if let dataField = rawData.value(forKey: "FoldedOrTornDocumentCorners") as? kfxDataField {
            checkIQData.foldedOrTornDocumentCorners = dataField
        }

        if let dataField = rawData.value(forKey: "DocumentSkew") as? kfxDataField {
            checkIQData.documentSkew = dataField
        }

        if let dataField = rawData.value(forKey: "ImageTooLight") as? kfxDataField {
            checkIQData.imageTooLight = dataField
        }
        
        if let dataField = rawData.value(forKey: "ImageTooDark") as? kfxDataField {
            checkIQData.imageTooDark = dataField
        }
        
        if let dataField = rawData.value(forKey: "ImageDimensionMismatch") as? kfxDataField {
            checkIQData.imageDimensionMismatch = dataField
        }

        if let dataField = rawData.value(forKey: "OutOfFocus") as? kfxDataField {
            checkIQData.outOfFocus = dataField
        }

        return checkIQData
    }
    
    override func unloadManager() {
        
        if checkHomeViewController != nil {
            checkHomeViewController.delegate = nil
            checkHomeViewController.account = nil
            checkHomeViewController = nil
        }
        if self.captureController != nil {
            self.captureController.delegate = nil
            self.captureController = nil
        }
        
        //remove files from disk

        let diskUtilityObj = DiskUtility.shared
        
        let frontRawImgPath = diskUtilityObj.getFilePathWithType(side: ImageType.FRONT_RAW, type: MIMETYPE_JPG)
        
        diskUtilityObj.removeFile(atPath: frontRawImgPath as String!)

        let frontProcessedImgPath = diskUtilityObj.getFilePathWithType(side: ImageType.FRONT_PROCESSED, type: MIMETYPE_TIF)
        
        diskUtilityObj.removeFile(atPath: frontProcessedImgPath as String!)

        let backRawImgPath = diskUtilityObj.getFilePathWithType(side: ImageType.BACK_RAW, type: MIMETYPE_JPG)
        
        diskUtilityObj.removeFile(atPath: backRawImgPath as String!)

        let backProcessedImgPath = diskUtilityObj.getFilePathWithType(side: ImageType.BACK_PROCESSED, type: MIMETYPE_TIF)

        diskUtilityObj.removeFile(atPath: backProcessedImgPath as String!)

        account = nil
        extractionManager = nil
        imageProcessManager = nil
        checkHomeViewController = nil
        processedImgFilePathArr = nil
        parameters = nil
        ImageUtilities.clearImage(image: currentProcessedImage)
        ImageUtilities.clearImage(image: currentCapturedImage)
        previewPopup = nil
        checkData = nil
        checkIQData = nil
    }
    
    deinit {
        unloadManager()
    }
}
