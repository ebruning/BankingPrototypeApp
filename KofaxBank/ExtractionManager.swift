//
//  ExtractionManager.swift
//  KofaxBank
//
//  Created by Rupali on 21/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

protocol ExtractionManagerProtocol {

      func extractionSucceeded(statusCode: NSInteger, results: Data)
      func extractionFailedWithError(error: Error!, responseCode: NSInteger, errorData: Data!)
}


class ExtractionManager: NSObject, KFXServerExtractorDelegate, URLSessionDelegate {

    // Mark: Private initializer
    private override init() {
        super.init()
        
    }
    
    // MARK: Shared Instance
    
    static let shared = ExtractionManager()
    
    //Mark: - Delegate
    var delegate: ExtractionManagerProtocol?
    
    // MARK: Constants

    
    // MARK: Global variables
    var serverType = SERVER_TYPE_TOTALAGILITY

    // MARK: Local Variable
    
    private var serverExtractor: kfxKLOServerExtractor!
    private var ktaServerConnection: KFXKTAServerConnection!
    
    // MARK: Methods

    
    func extractData(fromProcecssedImagePaths: NSMutableArray, serverUrl: URL, extractionParams: NSDictionary, imageMimeType:
        KEDImageMimeType) -> Int32 {
        
        var errorCode: Int32! = 0
        
        //let processedFilePaths = NSMutableArray.init(array: fromProcecssedImagePaths)
        let url = serverUrl
        let params = extractionParams
        let mimeType = imageMimeType
        
        
        var processedImageArray: NSMutableArray! = NSMutableArray.init()
        
        //iterate through image paths and read corresponding processed images
        for index in (0..<fromProcecssedImagePaths.count) {
            
            var image = kfxKEDImage.init()
            
            errorCode = image?.specifyFilePath(fromProcecssedImagePaths.object(at: index) as! String)
            
            if errorCode != KMC_SUCCESS {
                break
            }
            
            errorCode = image?.imageReadFromFile()
            if errorCode != KMC_SUCCESS {
                break
            }
            
            print("Image DPI ==> \(image!.imageDPI)")

            //Allocate a new image with the bitmap of image in file path. This is needed for us to be able to write to the file buffer and read the file buffer subsequently
            var tempImg = kfxKEDImage.init()
            tempImg?.specifyImageBitmap(image?.getBitmap())
            tempImg?.imageDPI = (image?.imageDPI)!
            
            print("Image DPI ==> \(tempImg!.imageDPI)")

            processedImageArray.add(tempImg!)
            
            ImageUtilities.clearImage(image: image)
            image = nil
            tempImg = nil
        }
        
        DispatchQueue.global().async {
            self.extractImagesData(fromProcecssedImageArray: processedImageArray, serverUrl: url, paramsDict: params, imageMimeType: mimeType)

            ImageUtilities.clearImages(fromArray: processedImageArray)
            processedImageArray = nil
        }
        return errorCode
    }
    
    
    func extractData(img: kfxKEDImage, serverUrl: URL, extractionParams: NSDictionary, imageMimeType:
        KEDImageMimeType) -> Int32 {
        
        let errorCode: Int32! = 0
        
        //let processedFilePaths = NSMutableArray.init(array: fromProcecssedImagePaths)
        let url = serverUrl
        let params = extractionParams
        let mimeType = imageMimeType
        
        
        var processedImageArray: NSMutableArray! = NSMutableArray.init()
        
        //iterate through image paths and read corresponding processed images
        
            //Allocate a new image with the bitmap of image in file path. This is needed for us to be able to write to the file buffer and read the file buffer subsequently
            var tempImg = kfxKEDImage.init()
            tempImg?.specifyImageBitmap(img.getBitmap())
            tempImg?.imageDPI = (img.imageDPI)
            tempImg?.imageMimeType = imageMimeType

            print("Image DPI ==> \(tempImg!.imageDPI)")
            
            processedImageArray.add(tempImg!)
            
            tempImg = nil
        
        DispatchQueue.global().async {
            self.extractImagesData(fromProcecssedImageArray: processedImageArray, serverUrl: url, paramsDict: params, imageMimeType: mimeType)
            
            ImageUtilities.clearImages(fromArray: processedImageArray)
            processedImageArray = nil
        }
        return errorCode
    }

    
    // MARK: Private methods
    //This method makes a mulit-part request to the RTTI server Send's the processed and unprocessed images and the server URL Required parameters can be passed as a dictionary and all the keys and values are added as parameters The same method can be used to send even one image
    
    func extractImagesData(fromProcecssedImageArray: NSArray, serverUrl: URL, paramsDict: NSDictionary, imageMimeType:
        KEDImageMimeType) {
        
        //let imgArr = fromProcecssedImageArray.copy()
        
        //guard let strongSelf = self else { return }
        
        print("serverUrl =====> \(serverUrl)");

        let imageArrCopy: NSMutableArray! = NSMutableArray.init()
        
        //Adding all images to array to retain our "processed" and "original" images, Unified server internally clears all images bitmap.
        if fromProcecssedImageArray.count > 0 {
            for index in (0..<fromProcecssedImageArray.count) {
                let inputImg: kfxKEDImage = (fromProcecssedImageArray.object(at: index) as! kfxKEDImage)
                let newKfxKedImage = kfxKEDImage.init(image: inputImg.getBitmap())
                newKfxKedImage?.imageMimeType = imageMimeType
                newKfxKedImage?.imageFileOutputColor = inputImg.imageFileOutputColor
                newKfxKedImage?.imageDPI = inputImg.imageDPI
                
                imageArrCopy.add(newKfxKedImage!)
            }
        }

        if serverType == SERVER_TYPE_TOTALAGILITY {
            ktaServerConnection = nil
            
            ktaServerConnection = KFXKTAServerConnection.init(url: serverUrl)
            let params: NSDictionary = NSDictionary.init(dictionary: paramsDict)
            
            print("Parameters =====> \(params)");

            
            let extractionParams: KFXServerExtractionParameters = KFXServerExtractionParameters.init(images: imageArrCopy as! [Any])
            
            //let dict: NSDictionary = NSDictionary.init(dictionary: params)
            
            extractionParams.parameters = params as! [AnyHashable : Any]

            print("extractionParams.parameters ========> \(extractionParams.parameters)")

//            print("ExtractionRequest ======> \(extractionRequest)")
            
            serverExtractor = kfxKLOServerExtractor.init(connection: ktaServerConnection)
            serverExtractor.delegate = self
            serverExtractor.extract(extractionParams)
        }
    }
    

    // MARK:  KFXServerExtractorDelegate
    func extractionFailed(_ error: Error!, response: URLResponse!, errorData data: Data!) {
        var errorCode: NSInteger! = -1
        
        if response != nil {
            let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
            errorCode = httpResponse.statusCode
        }
        print("\(data)")
        self.delegate?.extractionFailedWithError(error: error, responseCode: errorCode, errorData: data)
    }

    func extractionSucceded(_ extractionData: Data!, response: URLResponse!) {
        
        let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
        self.delegate?.extractionSucceeded(statusCode: httpResponse.statusCode, results: extractionData)
    }
    
    
    // MARK: NSURLSessionDelegate
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
    }
    
    /*
     if processedImgFilePathArr != nil {
     for index in (0..<processedImgFilePathArr.count) {
     clearImage(image: processedImgFilePathArr[index])
     }
     processedImgFilePathArr.removeAllObjects()
     processedImgFilePathArr = nil
     }
     

 */
    func unload() {
        serverExtractor = nil
        ktaServerConnection = nil
        delegate = nil
    }
    
    deinit {
        unload()
    }
    
}
