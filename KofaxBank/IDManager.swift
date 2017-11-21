//
//  IDManager.swift
//  KofaxBank
//
//  Created by Rupali on 03/10/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData

protocol IDManagerDelegate {
    func IDDataReadCompleteWithSelfieVerification(idData: kfxIDData!)
    func IDDataReadCompleteWithoutSelfieVerification(idData: kfxIDData!)
    func IDDataReadFailed(error: AppError!)
    func IDDataReadCancelled()
}


class IDManager: BaseFlowManager, UINavigationControllerDelegate, UIImagePickerControllerDelegate,
InstructionsDelegate, PreviewDelegate, BarcodeReadViewControllerDelegate, IDHomeVCDelegate, SelfieCaptureExprienceViewControllerDelegate, SelfieResultsViewControllerDelegate {
    
    private enum IDFlowStates {
        case NOOP
        case IMAGE_RETRIEVED
        case IMAGE_RETRIEVEL_CANCELLED
        case IMAGE_PREVIEWED
        case IMAGE_PROCESSED
        case IMAGE_PROCESSING_FAILED
        case BACK_SIDE_SKIPPED
        case IMAGE_DATA_EXTRACTED
        case IMAGE_DATA_EXTRACTION_FAILED
        case IMAGE_DATA_DISPLAYED
        case IMAGE_DATA_SAVED
        case CYCLE_COMPLETE
        case CYCLE_CANCELLED
        
    }

    // MARK: Public variables

    var delegate: IDManagerDelegate? = nil
    
    // MARK: Local variables
    private let IPP_GERMAN_FRANCE = "_DeviceType_2_"
    
    private var navigationController: UINavigationController!
    
    private var captureController: ImageCaptureViewController! = nil
    
    private var capturedImage: kfxKEDImage! = nil
    
    private var processedImage: kfxKEDImage! = nil
    
    private var capturedImagePath: String! = nil
    
    private var frontRawImagePath: String! = nil
    
    private var backRawImagePath: String! = nil
    
    private var frontProcessedImagePath: String! = nil
    
    private var backProcessedImagePath: String! = nil
    
    private var previewPopup: PreviewViewController!
    
    private var idHomeScreen: IDHomeVC?
    
    private var instructionPopup: InstructionsPopup! = nil
    
    private var imageProcessManager: ImageProcessManager! = nil
    
    private var extractionManager: ExtractionManager! = nil
    
    private var flowState = IDFlowStates.NOOP
    
    private var idData: kfxIDData! = nil
    
    private var errObj: AppError! = AppError.init()
    
    private var idSide: DocumentSide = .FRONT
    
    private var regionProperties: RegionProperties! = nil
    
    //Selfie parameters
    
    private var selfieImage: UIImage! = nil
    
    //TODO: temp constant
    private let serverType = SERVER_TYPE_TOTALAGILITY
    
    private var mobileIDVersion: String!
    
    //MARK: Authentication Parameters
    
    private var authenticationResultModel: AuthenticationResultModel! = nil

    private var selfieVerificationResults: SelfieVerificationResultModel! = nil
    
    override init() {
        super.init()
    }
    
    override func loadManager(navigationController: UINavigationController) {
        super.loadManager(navigationController: navigationController)
        
        self.navigationController = navigationController
        
        authenticationResultModel = nil
        
        showInstructionPopupForDriverLicense()
        
        self.mobileIDVersion = getMobileIDVersion()
    }
    
    private func showInstructionPopupForDriverLicense() {
        DispatchQueue.main.async {
            let parentView = self.navigationController.topViewController
            self.instructionPopup = InstructionsPopup.init(nibName: "InstructionsPopup", bundle: nil)
            self.instructionPopup.delegate = self
            
            self.instructionPopup.titleText = "Driver License ID"
            self.instructionPopup.bodyMessageText = "Take picture of your drivering license."
            self.instructionPopup.sampleImageName = "DriverLicensex150"
            
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
    
    
    
    private func handleScreenFlow(err: AppError!) {
        switch flowState {
            
        case .IMAGE_RETRIEVED:
            showPreviewPopup()
            break
            
        case .IMAGE_RETRIEVEL_CANCELLED:
            flowState = IDFlowStates.CYCLE_COMPLETE
            handleScreenFlow(err: err)
            break
            
        case .IMAGE_PREVIEWED:
            if idHomeScreen == nil {
                self.showIDHomScreen()
            }
            processCapturedImage()
            break
            
        case .IMAGE_PROCESSED:
            
            //display processed image on ID home screen
            if idSide == .FRONT {
                idHomeScreen?.frontImageFilePath = frontProcessedImagePath
            } else {
                if backProcessedImagePath != nil {
                    idHomeScreen?.backImageFilePath = backProcessedImagePath
                }
            }
            idHomeScreen?.imageReady(side: idSide)
            
            if idSide == .FRONT {
                //ask for back side of ID
                showOptionsAlertForBackSide()
            } else {
                idHomeScreen?.idDataFetchBegun()
                //since both of sides are captured, begin with data extraction
                extractData()
            }
            break
            
        case .BACK_SIDE_SKIPPED:
            
            //send front image for extraction
            idHomeScreen?.idDataFetchBegun()
            extractData()
            break
            
        case .IMAGE_PROCESSING_FAILED:
            idHomeScreen?.idDataNotAvailable(err: err)
            flowState = .CYCLE_COMPLETE
            handleScreenFlow(err: nil)
            break
            
        case .IMAGE_DATA_EXTRACTION_FAILED:
            idHomeScreen?.idDataNotAvailable(err: err)
            flowState = .CYCLE_COMPLETE
            handleScreenFlow(err: err)
            break
            
        case .IMAGE_DATA_EXTRACTED:
            if mobileIDVersion == MobileIDVersion.VERSION_2X.rawValue {
                idHomeScreen?.authenticationResultModel = self.authenticationResultModel
            }
            idHomeScreen?.idDataAvailable(idData: self.idData)
            break
            
        case .CYCLE_COMPLETE:
            if err != nil {
                delegate?.IDDataReadFailed(error: err)
            } else {
                
            }
            
            break
            
        case .CYCLE_CANCELLED:
            delegate?.IDDataReadCancelled()
            break
            
        default:
            break
        }
    }
    
    // MARK:
    private func showOptionsAlertForBackSide() {
        DispatchQueue.main.async {
            self.idSide = .BACK
            
            let alert = UIAlertController.init(title: "ID back-side", message: "How would you like to capture back of ID?", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let captureImageAction = UIAlertAction.init(title: "Take Photo", style: UIAlertActionStyle.default) { (UIAlertAction) in
                print("Take photo")
                self.showCamera()
            }
            alert.addAction(captureImageAction)
            
            let readBarcodeAction = UIAlertAction.init(title: "Read Barcode", style: UIAlertActionStyle.default) { (UIAlertAction) in
                print("Read barcode")
                self.backSideIsBarcode = true
                
                self.showBarcodeReader()
            }
            alert.addAction(readBarcodeAction)
            
            let skipAction = UIAlertAction.init(title: "Skip Back Side", style: UIAlertActionStyle.cancel) { (UIAlertAction) in
                print("Skip!")
                self.flowState = .BACK_SIDE_SKIPPED
                self.handleScreenFlow(err: nil)
            }
            alert.addAction(skipAction)
            
            self.idHomeScreen?.present(alert, animated: true, completion: nil)
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
            flowState = IDFlowStates.CYCLE_COMPLETE
            handleScreenFlow(err: nil)
            
        } else if command == CommandOptions.CAMERA {
            showCamera()
            
        } else if command == CommandOptions.GALLERY {
            showGallery()
        }
    }
    
    
    override func showGallery() {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        navigationController.topViewController?.present(picker, animated: true, completion: nil)
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
    
    
    // MARK: Camera related methods
    
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
        experienceOptions.longAxisThreshold = 90
        experienceOptions.shortAxisThreshold = 90
        experienceOptions.staticFrameAspectRatio = 0.629629611
        experienceOptions.documentSide = DocumentSide.FRONT
        experienceOptions.captureExperienceType = CaptureExperienceType.DOCUMENT_CAPTURE
        experienceOptions.zoomMaxFillFraction = 1.1
        experienceOptions.zoomMinFillFraction = 0.7
        experienceOptions.movementTolerance = 0.0
        
        //messages options -- use defaults for now
        
        let messages = ExperienceMessages()
        messages.holdSteadyMessage = "Hold steady"
        messages.moveCloserMessage = "Move closer"
        messages.userInstruction = "Fill viewable area with ID card"
        messages.centerMessage = "Center ID Card"
        messages.zoomOutMessage = "Move back"
        messages.capturedMessage = "Done!"
        messages.holdParallelMessage = "Hold device level"
        messages.orientationMessage = "Rotate device"
        
        experienceOptions.messages = messages
        
        loadRegionPropertiesObject()
        
        if self.captureController != nil {
            self.captureController.delegate = nil
            self.captureController = nil
        }
        
        
        
        self.captureController = ImageCaptureViewController.init(options: captureOptions,
                                                                 experienceOptions: experienceOptions,
                                                                 regionProperties: self.regionProperties, showRegionSelection: self.idSide == .FRONT ? true : false)
        
        let navController = UINavigationController.init(rootViewController: self.captureController)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.backgroundColor = UIColor.clear

        self.captureController.delegate = self
        let parentView: UIViewController! = self.navigationController.topViewController
        parentView.present(navController, animated: true, completion: nil)
    }
    
    
    private func loadRegionPropertiesObject() {
        
        let savedRegionName = UserDefaults.standard.value(forKey: KEY_ID_REGION_NAME) as? String
        
        self.regionProperties = nil
        
        //if some region was saved in database earlier, then load it from there.
        if savedRegionName != nil {
            self.regionProperties = RegionProperties()
            
            //TODO: Reset the region properties to USA in UserDefault when server type is changed from 1.x to 2.x and vise versa
            regionProperties!.regionDisplayName = savedRegionName!
            regionProperties!.countryDisplayName = UserDefaults.standard.value(forKey: KEY_ID_COUNTRY_NAME) as! String
            regionProperties!.countryCode = UserDefaults.standard.value(forKey: KEY_ID_COUNTRY_CODE) as! String
            regionProperties!.imageResize = UserDefaults.standard.value(forKey: KEY_ID_IMAGE_RESIZE) as! String
            regionProperties!.flagName = UserDefaults.standard.value(forKey: KEY_ID_REGION_FLAG_NAME) as! String
            
            var regionFileName = UserDefaults.standard.value(forKey: KEY_ID_REGION_PLIST_FILE_NAME) as? String
            if regionFileName == nil || regionFileName == "" {
                regionFileName = ID_DEFAULT_REGION_PROPERTIES_MODEL_FILE
            }
            self.regionProperties!.propertyListFileNameForRegion = regionFileName
        } else {
            self.regionProperties = loadDefaultRegionProperties()
        }
    }
    
    private func loadDefaultRegionProperties() -> RegionProperties {
        //return RegionController().loadDefaultProperties()
        
        let properties = RegionProperties()
        properties.regionDisplayName = ID_DEFAULT_REGION_PROPERTIES_REGION_NAME
        properties.countryCode = ID_DEFAULT_REGION_PROPERTIES_COUNTRY_CODE
        properties.countryDisplayName = ID_DEFAULT_REGION_PROPERTIES_COUNTRY_DISPLAY_NAME
        properties.flagName = ID_DEFAULT_REGION_PROPERTIES_FLAG_IMAGE_NAME
        properties.imageResize = ID_DEFAULT_REGION_PROPERTIES_IMAGE_RESIZE
        properties.odcRegionCode = ID_DEFAULT_REGION_PROPERTIES_ODC_REGION_CODE
        properties.propertyListFileNameForRegion = ID_DEFAULT_REGION_PROPERTIES_MODEL_FILE
        
        return properties
    }
    
    override func imageCaptured(image: kfxKEDImage) {
        print("Image Captured!")
        performPostImageRetrievalTasks(image: image)
        closeCamera()
    }
    
    override func cancelCamera() {
        closeCamera()
        flowState = IDFlowStates.CYCLE_COMPLETE
        handleScreenFlow(err: nil)
    }
    
    private func closeCamera() {
        captureController.dismiss(animated: true, completion: nil)
        captureController.delegate = nil
        
    }
    
    override func onRegionUpdated(regionProperties: RegionProperties) {
        UserDefaults.standard.set(regionProperties.regionDisplayName, forKey: KEY_ID_REGION_NAME)
        UserDefaults.standard.set(regionProperties.countryDisplayName, forKey: KEY_ID_COUNTRY_NAME)
        UserDefaults.standard.set(regionProperties.countryCode, forKey: KEY_ID_COUNTRY_CODE)
        UserDefaults.standard.set(regionProperties.imageResize, forKey: KEY_ID_IMAGE_RESIZE)
        UserDefaults.standard.set(regionProperties.flagName, forKey: KEY_ID_REGION_FLAG_NAME)
        if regionProperties.propertyListFileNameForRegion != nil {
            UserDefaults.standard.set(regionProperties.propertyListFileNameForRegion, forKey: KEY_ID_REGION_PLIST_FILE_NAME)
        }
    }
    
    // MARK: Post capture methods
    private func performPostImageRetrievalTasks(image: kfxKEDImage) {
        DispatchQueue.global().async {
            ImageUtilities.clearImage(image: self.capturedImage)
            self.capturedImage = nil  //clear old image before assigning new one
            //DiskUtility.shared.removeFile(atPath: self.capturedImagePath) //not required here, save method removes file before saving new one
            
            self.capturedImage  = image;
            
            var side: ImageType?
            if self.idSide == .FRONT {
                side = ImageType.FRONT_RAW
            } else {
                side = ImageType.BACK_RAW
            }
            
            //save image on to disk in JPG format
            self.capturedImagePath = DiskUtility.shared.saveAsKfxKEDImageToDisk(image: self.capturedImage, side: side!, mimeType: MIMETYPE_JPG)
            
            if side == ImageType.FRONT_RAW {
                self.frontRawImagePath = self.capturedImagePath
            } else {
                self.backRawImagePath = self.capturedImagePath
            }
            
            //TODO: display captured image on screen
            self.flowState = IDFlowStates.IMAGE_RETRIEVED
            self.handleScreenFlow(err: nil)
        }
    }
    
    
    // MARK: Image preview methods
    
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
    
    // MARK : Preview screen delegate
    func onPreviewOptionSelected(command: CommandOptions) {
        print("onPreviewOptionSelected")
        
        if previewPopup != nil {
            previewPopup.removeFromParentViewController()
            previewPopup.delegate = nil
            previewPopup = nil
        }
        if command == CommandOptions.USE {
            
            flowState = IDFlowStates.IMAGE_PREVIEWED
            
        } else if command == CommandOptions.RETAKE {
            
            flowState = IDFlowStates.IMAGE_RETRIEVEL_CANCELLED
            
        } else if command == CommandOptions.CANCEL {
            
            flowState = IDFlowStates.IMAGE_RETRIEVEL_CANCELLED
        }
        handleScreenFlow(err: nil)
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
        
        let ipp: kfxKEDImagePerfectionProfile!
        
        var evrsProcessingString: String! = nil
        
        if isGermanID() || (isFrenchID() && !isFranceOldId()) {
            ipp = kfxKEDImagePerfectionProfile()
            ipp.ipOperations = IPP_GERMAN_FRANCE
            ipp.useTargetFrameCrop = KED_USETARGETFRAMECROP_ON
            
        } else {
            
            let USE_DEFAULTS = true
            
            // if not ODE
            
            //default processing params
            if USE_DEFAULTS {
                evrsProcessingString = getDefaultIPStringForID()
            } else {
                
            }
            print("evrsSettingsString ====> \(evrsProcessingString)")
            
            ipp = kfxKEDImagePerfectionProfile.init(name: "PerfectionProfile", andOperations: evrsProcessingString)
            ipp.useTargetFrameCrop = KED_USETARGETFRAMECROP_ON  //for portrait mode
        }
        
        return ipp
    }
    
    private func isGermanID() -> Bool {
        //        if ([self.dlRegion.xRegion isEqualToString:Region_Europe] && [self.dlRegion.strDisplayRegion isEqualToString:Country_Germany]) {
        if (UserDefaults.standard.string(forKey: KEY_ID_REGION_NAME) == EUROPE) && (UserDefaults.standard.string(forKey: KEY_ID_COUNTRY_NAME) == GERMANY) {
            return true
        }
        return false
    }
    
    private func isFrenchID() -> Bool {
        if (UserDefaults.standard.string(forKey: KEY_ID_REGION_NAME) == EUROPE) && (UserDefaults.standard.string(forKey: KEY_ID_COUNTRY_NAME) == FRANCE) {
            return true
        }
        return false
    }
    
    private func isFranceOldId() -> Bool {
        if (UserDefaults.standard.string(forKey: KEY_ID_COUNTRY_NAME) == FRANCE) && (UserDefaults.standard.string(forKey: KEY_ID_IMAGE_RESIZE) == ImageResizeFranceOldID2) {
            return true
        }
        return false
    }
    
    
    private func getDefaultIPStringForID() -> String {
        
        //this string is for device processing. Sever processing string is different

        if mobileIDVersion == MobileIDVersion.VERSION_1X.rawValue {
            return "_DeviceType_2_ScalingMode_2.4__DoSkewCorrectionPage__DoCropCorrection__Do90DegreeRotation_4__DoScaleImageToDPI_300_DocDimSmall_2.123_DocDimLarge_3.363_LoadSetting_<Property Name=\"CSkewDetect.prorate_error_sum_thr_bkg_brightness.Bool\" Value=\"1\" Comment=\"DEFAULT 0\" />_LoadSetting_<Property Name=\"CSkwCor.Do_Fast_Rotation.Bool\" Value=\"0\" Comment=\"DEFAULT 1\" />_LoadSetting_<Property Name=\"CSkewDetect.correct_illumination.Bool\" Value=\"0\" Comment=\"DEFAULT 1\" />_LoadSetting_<Property Name=\"CSkwCor.Fill_Color_Scanner_Bkg.Bool\" Value=\"0\" Comment=\"DEFAULT 1 \" />_LoadSetting_<Property Name=\"CSkwCor.Fill_Color_Red.Byte\" Value=\"255\" Comment=\"DEFAULT 0 \" />_LoadSetting_<Property Name=\"CSkwCor.Fill_Color_Green.Byte\" Value=\"255\" Comment=\"DEFAULT 0 \" />_LoadSetting_<Property Name=\"CSkwCor.Fill_Color_Blue.Byte\" Value=\"255\" Comment=\"DEFAULT 0\" />_LoadSetting_<Property Name=\"EdgeCleanup.Enable\" Value=\"0\" Comment=\"DEFAULT 1\" />"
        } else {
            return "_DeviceType_2__Do90DegreeRotation_4__DoCropCorrection__DoScaleImageToDPI_500_DoSkewCorrectionPage__DocDimLarge_3.375_DocDimSmall_2.125_LoadInlineSetting_[CSkewDetect.correct_illumination.Bool=0]"
        }
        
    }
    
    func processImage(processParams: ImageProcessParameters)  {
        
        DispatchQueue.global().async {
            
            if self.imageProcessManager == nil {
                self.imageProcessManager = ImageProcessManager.init()
            }
            
            self.imageProcessManager.processImage(parameters: processParams, completionCallback: {outputImage, error in
                
                self.imageProcessManager.unload()
                self.imageProcessManager = nil
                
                //ImageUtilities.clearImage(image: self.capturedImage)
                //DiskUtility.shared.removeFile(atPath: self.capturedImagePath)
                //self.capturedImage = nil
                //self.capturedImagePath = nil
                
                if error == nil {
                    
                    //image processing successful
                    ImageUtilities.clearImage(image: self.processedImage)
                    self.processedImage = nil
                    
                    self.processedImage = outputImage as! kfxKEDImage
                    self.processedImage.imageMimeType = MIMETYPE_JPG
                    
                    print("Image DPI right after processing ==> \(self.processedImage.imageDPI)")
                    
                    var side: ImageType?
                    if self.idSide == .FRONT {
                        side = ImageType.FRONT_PROCESSED
                    } else {
                        side = ImageType.BACK_PROCESSED
                    }
                    let imagePath = DiskUtility.shared.saveAsKfxKEDImageToDisk(image: self.processedImage, side: side!, mimeType: MIMETYPE_JPG)
                    
                    if self.idSide == .FRONT {
                        self.frontProcessedImagePath = imagePath
                    } else {
                        self.backProcessedImagePath = imagePath
                    }
                    
                    self.flowState = .IMAGE_PROCESSED
                    self.handleScreenFlow(err: nil)
                }
                else {
                    self.flowState = .IMAGE_PROCESSING_FAILED
                    
                    self.errObj.title = "Image Processing Failed"
                    self.errObj.message  = error.debugDescription
                    self.handleScreenFlow(err: self.errObj)
                }
                
            }, progressCallback: { progressPercent in
                print("percentage = \(progressPercent)");
            })
        }
    }
    
    
    //MARK: - Barcode related methods
    
    var barcodeReaderVC: BarcodeReaderViewController? = nil
    
    private func showBarcodeReader() {
        barcodeString = ""
        barcodeReaderVC = BarcodeReaderViewController.init(nibName: "BarcodeReaderViewController", bundle: nil)
        
        if barcodeReaderVC != nil {
            barcodeReaderVC?.delegate = self
            
            let parentVC = self.navigationController.topViewController
            parentVC?.present(barcodeReaderVC!, animated: true, completion: nil)
        }
    }
    
    //MARK: BarcodeReaderViewController delegate
    
    func barcodeReadCancelled() {
        DispatchQueue.global().async {
            self.barcodeReaderVC?.delegate = nil
            self.backSideIsBarcode = false
            self.flowState = .BACK_SIDE_SKIPPED
            self.handleScreenFlow(err: nil)
        }
    }
    
    var barcodeString: String! = nil
    
    func barcodeReadCompleted(withResult: kfxKEDBarcodeResult, andImage: kfxKEDImage) {
        
        backSideIsBarcode = true
        
        barcodeReaderVC?.delegate = nil
        
        if self.capturedImage != nil {
            ImageUtilities.clearImage(image: self.capturedImage)
        }
        self.capturedImage = andImage
        
        //saving captured barcode image as back-processed-image instead of raw image because barcode image will not be processed
        self.backProcessedImagePath = DiskUtility.shared.saveAsKfxKEDImageToDisk(image: self.capturedImage, side: ImageType.BACK_PROCESSED, mimeType: MIMETYPE_JPG)
        
        kfxKEDBarcodeResult.decode(withResult.dataFormat)
        
        // let encodedData = NSData.init(base64Encoded: withResult.value, options: 0)
        if let resultString = withResult.value {
            
            
            
            let encodedData: Data! = Data.init(base64Encoded: resultString, options: NSData.Base64DecodingOptions(rawValue: 0))
            if encodedData != nil && encodedData.count > 0 {
                self.barcodeString = String.init(data: encodedData!, encoding: String.Encoding.utf8)
                print("----------------------------------------")
                print("Old Barcode String ** \(barcodeString)")
                print("----------------------------------------")
                
                //replace occurrrances of ":" (non-printable record separator) character by carriage-return
                self.barcodeString = self.barcodeString.replacingOccurrences(of: ":", with: "\r")
                
                //replace occurrrances of non-printable "" character (also represented as 0x001c or "\u{1C}") character by space. Extraction fails if this is not done
                self.barcodeString = self.barcodeString.replacingOccurrences(of: "\u{1C}", with: " ")
                
                print("New Barcode String ** \(barcodeString)")
                print("----------------------------------------")
            } else {
                print("Error: Invalid barcode string!")
                barcodeString = ""
            }
        }
        
        
        flowState = .IMAGE_PROCESSED
        handleScreenFlow(err: nil)
    }
    
    //MARK: ID Hom screen methods
    
    private func showIDHomScreen() {
        DispatchQueue.main.async {
            //idHomeScreen = IDHomeVC.init(nibName: "IDHomeVC", bundle: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.idHomeScreen = storyboard.instantiateViewController(withIdentifier: "IDHomeVC") as? IDHomeVC
            self.idHomeScreen?.delegate = self
            
            self.navigationController.pushViewController(self.idHomeScreen!, animated: true)
        }
    }

    override func unloadManager() {
        super.unloadManager()
        
        flowState = .NOOP
        idSide = .FRONT
        
        //self.idHomeScreen.delegate = nil
        if self.idHomeScreen != nil {
            self.idHomeScreen?.delegate = nil
            self.idHomeScreen = nil
        }

        self.regionProperties = nil
        
        self.captureController?.delegate = nil
        self.captureController = nil
        
        authenticationResultModel = nil
        
        DiskUtility.shared.removeFile(atPath: self.frontRawImagePath)
        DiskUtility.shared.removeFile(atPath: self.backRawImagePath)
        DiskUtility.shared.removeFile(atPath: self.frontProcessedImagePath)
        DiskUtility.shared.removeFile(atPath: self.backProcessedImagePath)
        ImageUtilities.clearImage(image: capturedImage)
        ImageUtilities.clearImage(image: processedImage)
        
        capturedImagePath = nil
        frontProcessedImagePath = nil
        backProcessedImagePath = nil
        frontRawImagePath = nil
        backRawImagePath = nil
        
        selfieImage = nil
        
        capturedImage = nil
        processedImage = nil
        
        idData = nil
        errObj = nil
        
        navigationController = nil
        
        barcodeString = nil
        barcodeReaderVC = nil
        
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
    
    private var parameters: NSMutableDictionary! = nil
    
    private var backSideIsBarcode: Bool = false
    
    // MARK: Data extraction methods
    override func extractData() {
        
        DispatchQueue.global().async {
            if (!Utility.isConnectedToNetwork()) {
                
                self.flowState = .IMAGE_DATA_EXTRACTION_FAILED
                self.errObj.title = "Network Error"
                self.errObj.message  = "A working network connection is required to read data from the ID. \nPlease check network connection and try again."
                self.handleScreenFlow(err: self.errObj)
                
                return
            }
            
            if self.extractionManager == nil {
                self.extractionManager = ExtractionManager.shared
            }
            self.extractionManager.delegate = self
            
            
            
            var arrProccessed: NSMutableArray!
            
            if self.parameters != nil {
                self.parameters.removeAllObjects()
                self.parameters = nil
            }
            self.parameters = NSMutableDictionary.init()
            
            var serverURL: URL?
            
            if self.serverType == SERVER_TYPE_TOTALAGILITY {
                self.extractionManager.serverType = SERVER_TYPE_TOTALAGILITY
                
                //We need to send login credentials to the server if the server type is KTA.
                //let serverURL: URL! = URL.init(string: "http://t4cgm8rclt1mnw5.asia.kofax.com/totalagility/services/sdk/")
                
                
                arrProccessed = self.loadProcessedImageArray()
                
                //set true if image processing needs to be done on server side
                self.parameters.setValue("false", forKey: "processImage")
                
                self.parameters.setValue(UserDefaults.standard.value(forKey: KEY_ID_REGION_NAME) as! String, forKey: "Region")
                
                if self.backSideIsBarcode {
                    if self.barcodeString != nil && self.barcodeString.characters.count > 0 {
                        self.parameters.setValue(self.barcodeString, forKey: "Barcode")
                    } else {
                        self.parameters.setValue(NSNull.init(), forKey: "Barcode")
                    }
                }
                else {
                    self.parameters.setValue(NSNull.init(), forKey: "Barcode")
                }
                
                let stateCode = UserDefaults.standard.value(forKey: KEY_ID_COUNTRY_CODE) as! String!
                
                if stateCode != nil && (stateCode?.characters.count)! > 0 {
                    self.parameters.setValue(stateCode, forKey: "State")
                } else {
                    self.parameters.setValue("", forKey: "State")
                }
                
                self.parameters.setValue("", forKey: "documentName")
                self.parameters.setValue("", forKey: "documentGroupName")
                
                
                if self.mobileIDVersion != nil && self.mobileIDVersion == MobileIDVersion.VERSION_2X.rawValue {   //TODO: check if all eralier code block is required, else move this to the beginning of if condition.
                    self.initiateExtractionWithAuthentication()
                    return
                } else {
                    //serverURL = URL.init(string: "http://ktaperf02.kofax.com/TotalAgility/Services/SDK")
                    let urlString = UserDefaults.standard.value(forKey: KEY_ID_SERVER_URL)
                    if urlString != nil {
                        serverURL = URL.init(string: urlString as! String)
                    }
                    
                    self.parameters.setValue("false", forKey: "CropImage")
                    self.parameters.setValue(self.getProcessIdentityName(), forKey: "processIdentityName") //TODO: make this configurable in settings
                    self.parameters.setValue("0", forKey: "IDType")
                    self.parameters.setValue("true", forKey: "ExtractFaceImage")
                    self.parameters.setValue("true", forKey: "ExtractSignatureImage")
                    let imageResize = UserDefaults.standard.value(forKey: KEY_ID_IMAGE_RESIZE) as! String
                    self.parameters.setValue(imageResize, forKey: "ImageResize")
                    let sessionId = self.getSessionId()
                    self.parameters.setValue(sessionId, forKey: "sessionId")
                }
                
                self.parameters.setValue("0", forKey: "storeFolderAndDocuments") //TODO: Check if required
                
                self.extractionManager.extractImagesData(fromProcecssedImageArray: arrProccessed, serverUrl: serverURL!, paramsDict: self.parameters, imageMimeType: MIMETYPE_JPG)
                
                arrProccessed = nil
                self.parameters.removeAllObjects()
                self.parameters = nil
            }
        }
    }
    
    private func loadProcessedImageArray() -> NSMutableArray {
        
        var processedFront: kfxKEDImage! = nil
        var processedBack: kfxKEDImage! = nil
        
        let imgArray: NSMutableArray = NSMutableArray.init()
        
        if frontProcessedImagePath != nil {
            processedFront = DiskUtility.shared.getImage(side: ImageType.FRONT_PROCESSED, mimeType: MIMETYPE_JPG)
            imgArray.add(processedFront)
        }
        
        if backProcessedImagePath != nil && !backSideIsBarcode {
            processedBack = DiskUtility.shared.getImage(side: ImageType.BACK_PROCESSED, mimeType: MIMETYPE_JPG)
            imgArray.add(processedBack)
        }
        
        return imgArray
    }
    
    //var dictAuthenticationResults: [AnyHashable : Any]! = nil
    
    private func initiateExtractionWithAuthentication() {
        performExtractionWithAuthenticationWithCompletionHandler { (responseData: Any?, status: Int, error: Error?) in
            print("Response status==> \(status)")
            
            var appError: AppError! = nil
            
            self.flowState = .IMAGE_DATA_EXTRACTION_FAILED  //setting to failed by-default and updating it below with extraction is successful
            
            if status == REQUEST_SUCCESS {
                
                let (dictAuthenticationResults, error) = self.getAuthenticationResults(responseData: responseData, status: status, error: error)
                
                if error != nil {
                    appError = AppError()
                    appError.message = error?.localizedDescription
                    
                } else {
                    if dictAuthenticationResults != nil {

                        if self.authenticationResultModel != nil {
                            self.authenticationResultModel = nil
                        }
                        self.authenticationResultModel = AuthenticationResultModel.init(dictionary: dictAuthenticationResults)

                        do {
                            let data = try JSONSerialization.data(withJSONObject: dictAuthenticationResults!, options: JSONSerialization.WritingOptions.prettyPrinted)
                            
                            let (idRawData, errorField) = self.getParsedRawDataFields(data: data)
                            
                            if errorField == nil {
                                
                                if idRawData != nil {
                                    
                                    print("Data Extraction with Authentication is Successful. Extracted data is ==> \(idRawData!)")
                                    
                                    self.idData = self.getParsedIDFields(rawData: idRawData!)
                                }
                                
                                if self.authenticationResultModel?.errorInfo != nil && (self.authenticationResultModel?.errorInfo.characters.count)! > 0 {
                                    
                                    appError = AppError()
                                    appError.title = "Authentication failed"
                                    appError.message = self.authenticationResultModel?.errorInfo
                                    
                                    //Utility.showAlert(onViewController: self.navigationController.topViewController!, titleString: "Authentication failed", messageString: authenticationResultModel?.errorInfo)
                                }
                                
                                self.flowState = .IMAGE_DATA_EXTRACTED
                                
                            } else {
                                do {
                                    if errorField?.value != nil {
                                    let errorDescriptionJSON = errorField?.value as NSString?
                                    let data = errorDescriptionJSON!.data(using: String.Encoding.utf8.rawValue)
                                    
                                    let dictErrorDescription = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                                    
                                    let errorCode: NSInteger = dictErrorDescription["errorcode"] as! NSInteger
                                    
                                    var errorTitle: String!
                                    
                                    if errorCode == KTA_CLASSIFICATION_ERROR_CODE {
                                        errorTitle = "ODE Classification failed"
                                    } else {
                                        errorTitle = "Extraction Failed"
                                    }
                                    
                                    let errorMessage = dictErrorDescription["errordescription"] as! String
                                    
                                    appError = AppError()
                                    appError.title = errorTitle
                                    appError.message = errorMessage
                                    }
                                } catch {
                                    print("Error while parsing json response \(error.localizedDescription)")
                                    appError = AppError()
                                    appError.message = error.localizedDescription
                                }
                                }
                                
                            }
                         catch {
                            print("Error while parsing json data \(error.localizedDescription)")
                            appError = AppError()
                            appError.message = error.localizedDescription
                        }
                        
                    }
                    
                }
                
            }
            appError = AppError()
            if error != nil {
                appError.message = error?.localizedDescription
            } else {
                if status == 500 {
                    appError.message = "Internal Server Error"
                } else {
                    appError.message = "Error occurred while reading data from ID"
                }
            }
            self.handleScreenFlow(err: appError)
        }
    }
    
    private func getAuthenticationResults(responseData: Any?, status: Int, error: Error?) -> ( [AnyHashable: Any]?, Error?) {
        var authenticationResults:  [AnyHashable: Any]! = nil
        var error: Error!
        
        do {
            authenticationResults = try JSONSerialization.jsonObject(with: responseData as! Data, options: JSONSerialization.ReadingOptions.mutableContainers) as?  [AnyHashable: Any]
        }
        catch let err {
            error = err
            print(err.localizedDescription)
        }
        return (authenticationResults, error)
    }
    
//    let ktaKofaxServerUrl = "https://mobiledemo4.kofax.com/TotalAgility/Services/Sdk/"
//    let KTAAUTHENTICJOBSERVICE = "JobService.svc/json/CreateJobSyncWithDocuments"
    
    private func performExtractionWithAuthenticationWithCompletionHandler(handler: ((Any?, Int, Error?) -> ())!) {
        //let authenticationURL = NSString(format: "%s%s", ktaKofaxServerUrl, KTAAUTHENTICJOBSERVICE) as String
        
//        let authenticationURLString = ktaKofaxServerUrl + KTAAUTHENTICJOBSERVICE
        let authenticationURLString = getAuthenticationURLString()
        
        let authenticationURL = URL.init(string: authenticationURLString)
        
        let params: NSMutableDictionary = NSMutableDictionary.init()

        params.setValue(getProcessIdentityName(), forKey: "processIdentityName")
        params.setValue("0", forKey: "storeFolderAndDocuments")
        params.setValue("false", forKey: "ProcessImage")
        params.setValue(UserDefaults.standard.value(forKey: KEY_ID_REGION_NAME) as! String, forKey: "Region")
        
        
        //server authentication parameters
        params.setValue("true", forKey: "Verification")
        params.setValue("true", forKey: "ExtractPhotoImage")
        
        params.setValue("ID", forKey: "IDType")
        
        if self.backSideIsBarcode {
            params.setValue(self.barcodeString, forKey: "Barcode")
        } else {
            //params.setValue(NSNull.init(), forKey: "Barcode")
        }
        
        let authenticationManager = IDAuthenticationService.init(sessionId: getSessionId())
        
        print("authenticationURLString ==> \(authenticationURLString)")
        print("Params ==> \(params)")
        
        authenticationManager?.performIDAuthentication(with: authenticationURL, forParameters: params as! [AnyHashable : Any], onImages: bytesArrayForIDImages() as! [Any], withCompletionHandler: { (responseData, status, error) in
            
            print("Status code ==> \(status)")
            
            handler(responseData, status, error)
        })
    }
    
    override func extractionSucceeded(statusCode: NSInteger, results: Data) {
        
        flowState = .IMAGE_DATA_EXTRACTED
        var idRawData: NSMutableDictionary? = nil
        
        (idRawData, _) = getParsedRawDataFields(data: results)
        
        if idRawData != nil {
            
            print("Data Extraction is Successful. Extracted data is ==> \(idRawData!)")
            
            self.idData = getParsedIDFields(rawData: idRawData!)
            
            print("Data found during ID parsing")
        } else {
            print("No data found during ID parsing")
        }
        
        handleScreenFlow(err: nil)
    }
    
    override func extractionFailedWithError(error: Error!, responseCode: NSInteger, errorData: Data!) {
        flowState = .IMAGE_DATA_EXTRACTION_FAILED
        if self.errObj == nil {
            self.errObj = AppError.init()
        }
        self.errObj.title = "Data read failed"
        if errorData != nil {
            self.errObj.message  = "ID data read failed with error Data==> \(errorData)"
        } else {
            self.errObj.message  = "ID data read failed"
        }
        
        print("Error Message :: \(self.errObj.message)")
        
        self.handleScreenFlow(err: self.errObj)
    }
    

    
    // MARK: Data parsing
    
    private func getParsedRawDataFields(data: Data) -> (NSMutableDictionary?, kfxDataField?) {
        
        var idRawData: NSMutableDictionary! = nil
        var errorField: kfxDataField! = nil
        
        do {
            var response: [AnyHashable: Any]! = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [AnyHashable: Any]
            
            var responseDictionary: NSMutableDictionary! = DataParser.parseKTAResponseFields(response)! as NSMutableDictionary
            if responseDictionary.value(forKey: STATIC_SERVER_FIELDS) != nil {
                var fieldDataArray: NSMutableArray! = responseDictionary.value(forKey: STATIC_SERVER_FIELDS) as! NSMutableArray
                //print("Extraction Results::: \(fieldDataArray) ")
                
                idRawData = NSMutableDictionary.init()
                
                for arrEle in fieldDataArray {
                    
                    let eleDict: NSDictionary = arrEle as! NSDictionary
                    // print("EleDict element ===> \(eleDict)")
                    
                    let dataField: kfxDataField = kfxDataField.init()
                    dataField.value = eleDict.value(forKey: "text") as! String
                    dataField.confidence = eleDict.value(forKey: "confidence") as! CGFloat
                    
                    let name = eleDict.value(forKey: "name") as! String
                    
                    //split string for proper field-name
                    let component = name.components(separatedBy: "_")
                    
                    let key: String!
                    if component.count > 1 {
                        key = component[1]
                    } else {
                        key = component[0]
                    }
                    
                    print("key ===> \(key) and Value ===> \(dataField.value) and confidence ===> \(dataField.confidence)")
                    
                    dataField.name = key
                    //store this field entry in dictionary with key as the field name (for a convinient search later)
                    idRawData.setValue(dataField, forKey: key)
                    
                    
                    if dataField.name == "ErrorDetails" && dataField.value != nil && dataField.value != "" &&  errorField == nil {
                        errorField = kfxDataField()
                        errorField.confidence = dataField.confidence
                        errorField.name = dataField.name
                        errorField.value = dataField.value
                    }
                }
                fieldDataArray.removeAllObjects()
                fieldDataArray = nil
                responseDictionary.removeAllObjects()
                responseDictionary = nil
                response.removeAll()
                response = nil
                
                if idRawData.count > 0 {
                    
                }
                
            }
        } catch {
            print(error)
        }
        return (idRawData, errorField)
    }
    
    
    private func getParsedIDFields(rawData: NSMutableDictionary) -> kfxIDData {
        
        idData = nil
        
        idData = kfxIDData.init()
        
        /*
         @property (nonatomic, strong) NSString* faceImageId;
         @property (nonatomic, strong) NSString* signatureImageId;
         */
        
        if let faceImageString = rawData.value(forKey: "FaceImage64") as? kfxDataField {
            idData.faceImageId = faceImageString.value
        }
        else if let faceImageString = rawData.value(forKey: "VerificationPhoto64") as? kfxDataField {   //this is in case of ID verification - 2_X
            idData.faceImageId = faceImageString.value
        }
        
        if let signatureImageString = rawData.value(forKey: "SignatureImage64") as? kfxDataField {
            idData.signatureImageId = signatureImageString.value
        }
        
        var idNumberDataField = rawData.value(forKey: "IDNumber") as? kfxDataField
        if idNumberDataField == nil || idNumberDataField?.value == nil || idNumberDataField?.value.characters.count == 0 {
            idNumberDataField = rawData.value(forKey: "License") as? kfxDataField
        }
        
        if idNumberDataField != nil {
            idData.idNumber = idNumberDataField
        }
        
        if let issueDate = rawData.value(forKey: "IssueDate") as? kfxDataField {
            idData.issueDate = issueDate
        }
        
        if let expDateField = rawData.value(forKey: "ExpirationDate") as? kfxDataField {
            idData.expirationDate = expDateField
        }
        
        if let idClass = rawData.value(forKey: "Class") as? kfxDataField {
            idData.idClass = idClass
        }
        
        //concatenate name
        let suffixField = rawData.value(forKey: "NameSuffix") as? kfxDataField
        let firstNameField = rawData.value(forKey: "FirstName") as? kfxDataField
        
        var nameString: String! = nil
        nameString = (suffixField?.value != nil || suffixField?.value != "") ? ((suffixField?.value)! + " ") : ""
        
        if firstNameField != nil && firstNameField?.value != nil || firstNameField?.value != "" {
            nameString = nameString + (firstNameField?.value)! + " "
        }
        
        /*        if middleNameField != nil && middleNameField?.value != nil || middleNameField?.value != "" {
         nameString = nameString + (middleNameField?.value)! + " "
         }
         
         if lastNameField != nil && lastNameField?.value != nil || lastNameField?.value != "" {
         nameString = nameString + (lastNameField?.value)! + " "
         }
         */
        let nameField = kfxDataField.init()
        nameField.name = "FirstName"
        nameField.value = nameString
        nameField.confidence = (firstNameField?.confidence)!
        idData.firstName = nameField
        
        
        if let middleNameField = rawData.value(forKey: "MiddleName") as? kfxDataField {
            idData.middleName = middleNameField
        }
        if let lastNameField = rawData.value(forKey: "LastName") as? kfxDataField {
            idData.lastName = lastNameField
        }
        
        if let birthDate = rawData.value(forKey: "DateOfBirth") as? kfxDataField {
            idData.dateOfBirth = birthDate
        }
        if let genderField = rawData.value(forKey: "Gender") as? kfxDataField {
            idData.gender = genderField
        }
        
        if let addressField = rawData.value(forKey: "Address") as? kfxDataField {
            idData.address = addressField
        }
        if let cityField = rawData.value(forKey: "City") as? kfxDataField {
            idData.city = cityField
        }
        if let stateField = rawData.value(forKey: "State") as? kfxDataField {
            idData.state = stateField
        }
        if let zipField = rawData.value(forKey: "ZIP") as? kfxDataField {
            idData.zip = zipField
        }
        if let countryShortField = rawData.value(forKey: "CountryShort") as? kfxDataField {
            idData.countryShort = countryShortField
        }
        if let countryField = rawData.value(forKey: "Country") as? kfxDataField {
            idData.country = countryField
        }
        
        if let eyesField = rawData.value(forKey: "Eyes") as? kfxDataField {
            idData.eyes = eyesField
        }
        if let hairField = rawData.value(forKey: "Hair") as? kfxDataField {
            idData.hair = hairField
        }
        if let heightField = rawData.value(forKey: "Height") as? kfxDataField {
            idData.height = heightField
        }
        if let weightField = rawData.value(forKey: "Weight") as? kfxDataField {
            idData.weight = weightField
        }
        if let nationalityField = rawData.value(forKey: "Nationality") as? kfxDataField {
            idData.nationality = nationalityField
        }
        
        if let barcodeReadField = rawData.value(forKey: "IsBarcodeRead") as? kfxDataField {
            idData.isBarcodeRead = barcodeReadField.value == "true" ? true : false
        }
        
        if let ocrReadField = rawData.value(forKey: "IsOcrRead") as? kfxDataField {
            idData.isOcrRead = ocrReadField.value == "true" ? true : false
        }
        
        if let idVerificationField = rawData.value(forKey: "IsIDVerified") as? kfxDataField {
            idData.isIDVerified = idVerificationField.value == "true" ? true : false
        }
        
        if let confidenceRatingField = rawData.value(forKey: "DocumentVerificationConfidenceRating") as? kfxDataField {
            idData.documentVerificationConfidenceRating = CGFloat((confidenceRatingField.value as NSString).floatValue)
        }
        
        return idData
    }
    
    
    
    //MARK: IDHomeVCDelegate methods
    
    var selfieCaptureExprienceVC: SelfieCaptureExprienceViewController! = nil
    
    func authenticateWithSelfie(idData: kfxIDData) {
        if self.idData != nil {
            self.idData = nil
        }
        self.idData = idData

        if selfieCaptureExprienceVC == nil {
            idHomeScreen?.selfieAuthenticationBegun()
            selfieCaptureExprienceVC = SelfieCaptureExprienceViewController(nibName: "SelfieCaptureExprienceViewController", bundle: nil)
            selfieCaptureExprienceVC.delegate = self
        }
        self.navigationController?.pushViewController(selfieCaptureExprienceVC, animated: true)
    }
    
    func onIDHomeCancel() {
        //unload IDmanager if ID capture flow is cancelled
        idHomeScreen?.delegate = nil
        idHomeScreen = nil
        
        self.unloadManager()
        
        flowState = .CYCLE_CANCELLED
        handleScreenFlow(err: nil)
    }
    
    
    func onIDHomeDoneWithData(idData: kfxIDData) {
        if self.idData != nil {
            self.idData = nil
        }
        self.idData = idData
        updateUserDetails(idData: idData)
        
        if mobileIDVersion == MobileIDVersion.VERSION_1X.rawValue {
            delegate?.IDDataReadCompleteWithoutSelfieVerification(idData: self.idData)
        } else {
            delegate?.IDDataReadCompleteWithSelfieVerification(idData: self.idData)
        }
    }
    
    
    private func getAuthenticationProcessIdentityName() -> String {
        let authProcessIdentity = UserDefaults.standard.value(forKey: KEY_ID_AUTHENTICATION_PROCESS_IDENTITY_NAME)
        if authProcessIdentity != nil {
            return authProcessIdentity as! String
        }
        return ""
    }
    
    
    private func getAuthenticationURLString() -> String {
        let authUrlString = UserDefaults.standard.value(forKey: KEY_ID_AUTHENTICATION_URL)
        if authUrlString != nil {
            return authUrlString as! String
        }
        return ""
    }

    
    private func getMobileIDVersion() -> String {
        let version = UserDefaults.standard.value(forKey: KEY_ID_MOBILE_ID_VERSION)
        if version != nil {
            print("Mobile ID Version ::: \(version as! String)")

            return version as! String
        }
        return ""
    }
    
    private func getSessionId() -> String {
        let sessionID = UserDefaults.standard.value(forKey: KEY_ID_SESSION_ID)
        
        print("sessionID ::: \(sessionID as! String)")
        
        if sessionID != nil {
            return sessionID as! String
        }
        return ""
    }
    
    //let ktaKofaxProcessName = "KofaxMobileIDCaptureSync"    //TODO: Move to settings
    //let ktaProcessName = "KofaxMobileIDSync"            //TODO: Move to settings

    
    private func getProcessIdentityName() -> String {
        let mobileIDVersion =  getMobileIDVersion()
        
        var processIdentityName: Any?
        
        if mobileIDVersion == MobileIDVersion.VERSION_1X.rawValue {
            processIdentityName = UserDefaults.standard.value(forKey: KEY_ID_PROCESS_IDENTITY_NAME_1X)
        } else if mobileIDVersion == MobileIDVersion.VERSION_2X.rawValue {
            processIdentityName = UserDefaults.standard.value(forKey: KEY_ID_PROCESS_IDENTITY_NAME_2X)
        }
        
        if processIdentityName != nil {
            print("Process Identity Name::: \(processIdentityName as! String)")
            return processIdentityName as! String
        } else {
            print("Process Identity Name is Nil!!!")
        }
        return ""
    }
    
    private func bytesArrayForIDImages() -> NSMutableArray {
        
        let unprocessedFilePathArr = NSMutableArray.init()
        let processedFilePathArr = NSMutableArray.init()
        
        if DiskUtility.shared.isImageInDisk(filePath: frontRawImagePath) {
            unprocessedFilePathArr.add(frontRawImagePath)
        }
        if !backSideIsBarcode && DiskUtility.shared.isImageInDisk(filePath: backRawImagePath) {
            unprocessedFilePathArr.add(backRawImagePath)
        }
        if DiskUtility.shared.isImageInDisk(filePath: frontProcessedImagePath) {
            processedFilePathArr.add(frontProcessedImagePath)
        }
        if !backSideIsBarcode && DiskUtility.shared.isImageInDisk(filePath: backProcessedImagePath) {
            processedFilePathArr.add(backProcessedImagePath)
        }
        
        let imagesArr = NSMutableArray.init()
        
        for fileName in processedFilePathArr {
            let img: kfxKEDImage! = getImage(imagePath: fileName as! String)
            
            if img != nil {
                imagesArr.add(img)
            }
        }
        
        for fileName in unprocessedFilePathArr {
            let img: kfxKEDImage! = getImage(imagePath: fileName as! String)
            
            if img != nil {
                imagesArr.add(img)
            }
        }
        
        let dataBytesArray = NSMutableArray.init()
        
        for img in imagesArr {
            
            if let imgObj = img as? kfxKEDImage {
                let err = imgObj.imageWriteToFileBuffer()
                
                if err == KMC_SUCCESS {
                    let data = NSData.init(bytes: imgObj.getFileBuffer(), length: Int(imgObj.imageFileBufferSize))
                    dataBytesArray.add(data)
                }
                imgObj.clearFileBuffer()
            }
        }
        
        return dataBytesArray
    }
    
    
    
    private func getImage(imagePath: String!) -> kfxKEDImage! {
        var image = DiskUtility.shared.getImage(fromPath: imagePath)
        
        if image != nil {
            let imageCopy = kfxKEDImage.init(image: image?.getBitmap())
            imageCopy?.imageMimeType = MIMETYPE_JPG
            imageCopy?.imageDPI = (image?.imageDPI)!
            
            image?.clearBitmap()
            image = nil
            
            return imageCopy
        }
        return nil
    }
    
    
    //MARK: Selfie related methods
    
    private func performSelfieVerificationWithCompletionHandler(handler: ((Any?, Int) -> ())!) {
    
//        let ktaKofaxServerUrl = "https://mobiledemo4.kofax.com/TotalAgility/Services/Sdk/"
//        let KTAAUTHENTICJOBSERVICE = "JobService.svc/json/CreateJobSyncWithDocuments"
        
        // if not ODE
        
//        let authenticationURLString = ktaKofaxServerUrl + KTAAUTHENTICJOBSERVICE
        let authenticationURLString = getAuthenticationURLString()

        let authenticationURL = URL.init(string: authenticationURLString)

        let params = NSMutableDictionary()
        params.setValue(getAuthenticationProcessIdentityName(), forKey: "processIdentityName")
        params.setValue(self.authenticationResultModel.transactionID, forKey: "TransactionId")
        params.setValue("0", forKey: "storeFolderAndDocuments") //TODO: Check if required

        let selfieManager = SelfieVerificationService.init(sessionId: getSessionId())
        selfieManager?.performSelfieVerification(with: authenticationURL, forParameters: params as! [AnyHashable : Any], onImages: bytesArrayForSelfieImage() as! [Any], withCompletionHandler: { (responseData: Any?, status: Int) in
            print("Selfie verification status ==> \(status)")
            handler(responseData,status)
        })
    }
    
    
    private func bytesArrayForSelfieImage() -> NSArray {
        var dataBytesArray = NSArray()
        
        let imgObj = kfxKEDImage.init(image: self.selfieImage)
        
        if imgObj != nil {
            imgObj?.imageMimeType = MIMETYPE_JPG
            let err = imgObj?.imageWriteToFileBuffer()
            
            if err == KMC_SUCCESS {
                let data = NSData.init(bytes: imgObj?.getFileBuffer(), length: Int((imgObj?.imageFileBufferSize)!))
                dataBytesArray = NSArray.init(object: data)
            }
            imgObj?.clearFileBuffer()
        }
        return dataBytesArray
    }
    
    
    private func getSelfieAuthenticationResults(responseData: Any?, status: Int) -> ( [AnyHashable: Any]?, Error?) {
        var authenticationResults:  [AnyHashable: Any]! = nil
        var error: Error!
        
        do {
            authenticationResults = try JSONSerialization.jsonObject(with: responseData as! Data, options: JSONSerialization.ReadingOptions.mutableContainers) as?  [AnyHashable: Any]
        }
        catch let err {
            error = err
            print(err.localizedDescription)
        }
        return (authenticationResults, error)
    }
    

    //MARK: SelfieCaptureExprienceViewControllerDelegate methods
    
    func cancelledSelfieCapture() {
        print("Selfie capture was cancelled.")
        idHomeScreen?.selfieAuthenticationEnded()
    }
    

    func selfieCapturedWithImage(image: UIImage!) {
        self.selfieImage = nil
        self.selfieImage = image
        

        DispatchQueue.global().async {
            self.performSelfieVerificationWithCompletionHandler(handler: { (responseData: Any?, status: Int) in
                
                print("Selfie verification status ==> \(status)")
                
                var appError: AppError! = nil

                self.idHomeScreen?.selfieAuthenticationEnded()
                
                if status == 200 {
                    print("Selfie verification successful")
                    if responseData != nil {
                        self.showSelfieResultsScreenWithResponse(response: responseData!)
                    } else {
                        print("Selfie verification response is nil")
                        Utility.showAlert(onViewController: self.navigationController.topViewController!, titleString: "Empty response", messageString: "Selfie verification response is empty.")
                    }
                } else {
                    let (dictSelfieAuthenticationResults, error) = self.getSelfieAuthenticationResults(responseData: responseData, status: status) // JSONSerialization.jsonObject(with: responseData as! Data, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    if error != nil {
                        appError = AppError()
                        appError.message = error?.localizedDescription
                    }
                    
                    var errorMessage = "Unable to read selfie results"
                    
                    //Fetching error message from response data.
                    if dictSelfieAuthenticationResults != nil {
                        let errorDict = NSDictionary(dictionary: dictSelfieAuthenticationResults!)
                        
                        if (errorDict.object(forKey: "Message") != nil) {
                            errorMessage = errorDict.object(forKey: "Message") as! String
                        }
                    }
                    
                    Utility.showAlert(onViewController: self.navigationController.topViewController!, titleString: "Selfie Authentication Failed", messageString: errorMessage)
                }
            })
        }
        
    }
    
    var dictSelfieResults: NSDictionary! = nil
    
    // SelfieResultController methods
    private func showSelfieResultsScreenWithResponse(response: Any) {

        dictSelfieResults = nil
        
        do {
            let dictSelfieResults = try JSONSerialization.jsonObject(with: response as! Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [AnyHashable : Any]
            
            self.selfieVerificationResults = SelfieVerificationResultModel.init(dictionary: dictSelfieResults, andHeadShot: self.authenticationResultModel.headShotBase64ImageString)
            
            self.showSelfieResultViewController()
            
        } catch {
            print("\(error)")
        }
    }

    var selfieResultsVC: SelfieResultsViewController! = nil
    
    private func showSelfieResultViewController() {
        DispatchQueue.main.async {
            //self.selfieResultsVC = SelfieResultsViewController(nibName: "SelfieResultsViewController", bundle: nil)
            self.selfieResultsVC = SelfieResultsViewController.init(selfieResults: self.selfieVerificationResults)
            
            self.selfieResultsVC.delegate = self
            
            self.selfieResultsVC.selfieImage = self.selfieImage
            
            self.navigationController.pushViewController(self.selfieResultsVC, animated: true)
        }
    }
    
    //MARK: - SelfieCaptureExprienceViewControllerDelegate methods
    
    func submitWithSelfieResults() {
        
        updateUserDetails(idData: self.idData)
        
        //navigationController.popToRootViewController(animated: true)

        navigationController.popToRootViewController(animated: true)
        
        delegate?.IDDataReadCompleteWithSelfieVerification(idData: self.idData)
    }

    
    private func updateUserDetails(idData: kfxIDData!) {
        if idData == nil {
            print("Error: idData is nil. cannot update user details")
            return
        }
        
        if  let user = fetchUser() {

            if idData.dateOfBirth != nil && idData.dateOfBirth.value != nil {
             //   user.birthdate = Utility.convertStringToDate(format: LongDateFormatWithNumericMonth, dateStr: idData.dateOfBirth.value)! as NSDate    //TODO: check the issue with nil birthdate later
            }
            
            if idData.address != nil && idData.address.value != nil {
                user.address = idData.address.value
            } else {
                user.address = ""
            }
            
            if idData.city != nil && idData.city.value != nil {
                user.city = idData.city.value
            } else {
                user.city = ""
            }

            if idData.state != nil && idData.state.value != nil {
                user.state = idData.state.value
            } else {
                user.state = ""
            }
            
            if idData.country != nil && idData.country.value != nil {
                user.country = idData.country.value
            } else {
                user.country = ""
            }
            
            if idData.zip != nil && idData.zip.value != nil {
                user.zip = idData.zip.value
            } else {
                user.zip = ""
            }

            user.profileupdatestatus = true
            
            ad.saveContext()
        }
    }
    
    
    private func fetchUser() -> UserMaster! {
        
        var user: UserMaster! = nil
        
        let fetchRequest: NSFetchRequest<UserMaster>! = UserMaster.fetchRequest()
        
        do{
            let users = try context.fetch(fetchRequest)
            if users.count > 0 {
                user = users[0]
            }
        } catch {
            print("\(error)")
        }
        
        return user
    }

    
    
    func sendPushNotificationServiceOnSelfiVerification() {
        //TODO: needs to be completed
    }
    
    func backFromSelfieResultScreen() {
        selfieResultsVC.delegate = nil
        selfieResultsVC = nil
    }
}
