//
//  ImageUtilities.swift
//  KofaxBank
//
//  Created by Rupali on 24/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import Photos

// MARK: Local constants

let DEFAULT_DPI: Int32 = 72

let DEFAULT_DPIFOREXTRACTION: Int32 = 300

class ImageUtilities: NSObject {

    class func createKfxKEDImage(sourceImage: UIImage, dpiValue: Int32) -> kfxKEDImage! {
        
        var resultantImage: kfxKEDImage! = nil
        var dpi = dpiValue
        
        if dpiValue == 0 {
            dpi = DEFAULT_DPIFOREXTRACTION
        }
        if let cgImg = sourceImage.cgImage {
            let dpiImage = UIImage.init(cgImage: cgImg, scale: CGFloat(dpi/DEFAULT_DPI), orientation: UIImageOrientation.up)
            resultantImage = kfxKEDImage.init(image: dpiImage)
            resultantImage.imageDPI = dpi
        }
        return resultantImage
    }
    
    class func getImageDPI(imageUrl: URL) -> Int32 {
        var dpi: Int32 = DEFAULT_DPI
        
        var imageProperties = NSDictionary()
        
        let imageAsset = PHAsset.fetchAssets(withALAssetURLs: [imageUrl], options: nil).firstObject
        
        if let asset = imageAsset {
            // get photo info from this asset
            let imageRequestOptions = PHImageRequestOptions.init()
            imageRequestOptions.isSynchronous = true
            PHImageManager.default().requestImageData(for: asset, options: imageRequestOptions, resultHandler: { (result, string, orientation, info) -> Void in
                
                let imageData: Data = result!
                if let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) {
                    imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as NSDictionary
                    //now you have got meta data in imageProperties, you can display PixelHeight, PixelWidth, etc.
                    print("Image properties===> \(imageProperties)")
                    if imageProperties.value(forKey: "DPIHeight") != nil {
                        dpi = imageProperties.value(forKey: "DPIHeight") as! Int32
                    } else {
                        print("DPI is nil, setting default DPI")
                        dpi = 200
                    }
                    print("Image DPI height ===> \(dpi)")
                }
            })
        }
        return dpi
    }
    
    class func clearImage(image: kfxKEDImage!) {
        if image != nil {
            image.clearBitmap()
            image.clearFileBuffer()
        }
    }
    
    class func clearImages(fromArray: NSMutableArray!) {
        if (fromArray != nil) {
            
            for index in (0..<fromArray.count) {
                clearImage(image: fromArray.object(at: index) as! kfxKEDImage)
            }
            fromArray.removeAllObjects()
        }
    }
    

}
