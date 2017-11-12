//
//  ImageProcessManager.swift
//  KofaxBank
//
//  Created by Rupali on 16/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
//import ImageProcessParameters


class ImageProcessManager: NSObject, kfxKIPDelegate {

    typealias CompletionCallback = ((Any?, NSError?) -> Void)
    typealias ProgressCallBack = ((Int) -> Void)
    
    var completionCallback: CompletionCallback!
    var progressCallback: ProgressCallBack!
    var sharedImageProcessor: kfxKENImageProcessor!

    override init() {
        
    }
    
    
    func processImage(parameters: ImageProcessParameters, completionCallback: @escaping CompletionCallback, progressCallback: @escaping ProgressCallBack) {
        self.completionCallback = completionCallback
        self.progressCallback = progressCallback
        
        if sharedImageProcessor == nil {
            sharedImageProcessor = kfxKENImageProcessor.init()
        }
        
        sharedImageProcessor.delegate = self
        sharedImageProcessor.imagePerfectionProfile = parameters.profile
        if parameters.processedImageFilePath == nil {
            sharedImageProcessor.processedImageRepresentation = IMAGE_REP_BITMAP
        } else {
            sharedImageProcessor.processedImageRepresentation = IMAGE_REP_FILE
            sharedImageProcessor.processedImageMimetype = parameters.processedImageMimeType
            sharedImageProcessor.specifyProcessedImageFilePath(parameters.processedImageFilePath)
        }
        
        let imageToBeProcessed = self.cloneImage(inputImage: parameters.inputImage)
        
        let status = sharedImageProcessor.processImage(imageToBeProcessed)
        if status != KMC_SUCCESS {
            completionCallback(nil, Utility.mapSDKStatus(status: Int(status)))
        }
    }
    
    
    //TODO: TBD: usage of this method???
    func cancelProcessing(completionCallback: @escaping CompletionCallback, progressCallback: @escaping ProgressCallBack) {
        self.completionCallback = completionCallback
        self.progressCallback = progressCallback
        
        if sharedImageProcessor == nil {
            sharedImageProcessor = kfxKENImageProcessor.init()
        }
        sharedImageProcessor.delegate = self
        sharedImageProcessor.cancelProcessing()
    }
    
    deinit {
        if self.sharedImageProcessor != nil {
            self.sharedImageProcessor.delegate = nil;
            self.sharedImageProcessor = nil;
        }
    }
    
    // MARK: - Quick Analysis
    
    func fetchQuickAnalysisSettings() -> kfxKEDQuickAnalysisSettings {
        let quickAnalysisSettings: kfxKEDQuickAnalysisSettings = kfxKEDQuickAnalysisSettings()
        quickAnalysisSettings.enableSaturationDetection = true
        quickAnalysisSettings.enableShadowDetection = true
        quickAnalysisSettings.enableGlareDetection = true
        quickAnalysisSettings.enableBlurDetection = true
        quickAnalysisSettings.enableMissingBordersDetection = true
        quickAnalysisSettings.enableSkewDetection = true
        quickAnalysisSettings.enableLowContrastBackgroundDetection = true
        
        return quickAnalysisSettings
    }

    func doQuickAnalysis(inputImage: kfxKEDImage, shouldGenerateImage: Bool, quickAnalysisSettings: kfxKEDQuickAnalysisSettings, completionCallback: @escaping CompletionCallback, progressCallback: @escaping ProgressCallBack) {
        
        self.completionCallback = completionCallback
        self.progressCallback = progressCallback
        
        if sharedImageProcessor == nil {
            sharedImageProcessor = kfxKENImageProcessor.instance()
        }
        
        self.sharedImageProcessor.delegate = self

        let imageToBeProcessed = self.cloneImage(inputImage: inputImage)
        
        let status = sharedImageProcessor.doQuickAnalysis(imageToBeProcessed, andGenerateImage: shouldGenerateImage, with: quickAnalysisSettings)

        if status != KMC_SUCCESS {
            self.completionCallback(nil, Utility.mapSDKStatus(status: Int(status)))
        }
    }
    
    // MARK: kfxKIPDelegate methods

    func imageOut(_ status: Int32, withMsg errorMsg: String!, andOutputImage kfxImage: kfxKEDImage!) {
        
        
        if kfxImage != nil {
        print("Image DPI ==> \(kfxImage.imageDPI)")
        }
        
        
        if status == KMC_SUCCESS || status == Int32(KMC_EV_USER_ABORT.rawValue) {
            self.completionCallback(kfxImage, nil)
        } else {
            self.completionCallback(nil, Utility.mapSDKStatus(status: Int(status)))
        }
    }

    func processProgress(_ status: Int32, withMsg errorMsg: String!, imageID: String!, andProgress percent: Int32) {
        if status == KMC_SUCCESS {
            self.progressCallback(Int(percent))
        } else {
            self.completionCallback(nil, Utility.mapSDKStatus(status: Int(status)))
        }
    }
    
    func analysisComplete(_ status: Int32, withMsg errorMsg: String!, andOutputImage kfxImage: kfxKEDImage!) {
        if status == KMC_SUCCESS {
            let feedback: kfxKEDQuickAnalysisFeedback = kfxImage.imageQuickAnalysisFeedback
            self.completionCallback(feedback, nil)
        } else {
            self.completionCallback(nil, Utility.mapSDKStatus(status: Int(status)))
        }
    }
    
    func analysisProgress(_ status: Int32, withMsg errorMsg: String!, imageID: String!, andProgress percent: Int32) {
        if status == KMC_SUCCESS {
            self.progressCallback(Int(percent))
        } else {
            self.completionCallback(nil, Utility.mapSDKStatus(status: Int(status)))
        }
    }

    // MARK: private methods
    
    private func cloneImage(inputImage: kfxKEDImage) -> kfxKEDImage {
        var newImage: kfxKEDImage!
        
        if inputImage.imageRepresentation == IMAGE_REP_FILE {
            //read image from file
            newImage = inputImage
            let result = newImage.imageReadFromFile()
            if result != KMC_SUCCESS {
                self.completionCallback(nil, Utility.mapSDKStatus(status: Int(result)))
            }
        }
        else if inputImage.imageRepresentation == IMAGE_REP_BOTH {
            newImage = kfxKEDImage.init(image: inputImage.getBitmap())
            newImage.imageDPI = inputImage.imageDPI
            newImage.imageMimeType = inputImage.imageMimeType
            newImage.clearFileBuffer()
        }
        else {
            newImage = inputImage
        }
        return newImage
    }
    
    func unload() {
        //TODO: clear parameters
    }
}
