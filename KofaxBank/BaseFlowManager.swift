//
//  BaseManager.swift
//  KofaxBank
//
//  Created by Rupali on 03/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class BaseFlowManager: NSObject, ImageCaptureControllerDelegate, ExtractionManagerProtocol {
    
    override init() {
        super.init()
    }
    
    func loadManager(navigationController: UINavigationController) {
        
    }
    
    func unloadManager() {
        
    }
    
    func showCamera() {
        
    }
    
    func showGallery() {
        
    }

    func extractData() {
        
    }
    
    // Mark: -ImageCaptureController Delegates
    
    func imageCaptured(image: kfxKEDImage) {
        
    }

    func cancelCamera() {
        
    }
    
    func onRegionUpdated(regionProperties: RegionProperties) {
        
    }
    
    func extractionSucceeded(statusCode: NSInteger, results: Data) {
        
    }
    
    func extractionFailedWithError(error: Error!, responseCode: NSInteger, errorData: Data!) {
        
    }
    
    deinit {
        
    }
}
