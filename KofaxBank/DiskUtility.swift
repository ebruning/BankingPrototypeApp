//
//  DiskUtility.swift
//  KofaxBank
//
//  Created by Rupali on 09/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

final class DiskUtility: NSObject {


    // Mark: Private initializer
    private override init() {
        super.init()
        
        createPhotosDircetory()
    }
    
    // MARK: Shared Instance
    
    static let shared = DiskUtility()
    
    // MARK: Constants
    final let IMAGES_DIRECTORY: String = "IMAGES"

    // MARK: Local Variable
    
    var photoDirectoryPath: NSString! // Specifies directory path where images are stored

    
    // Mark: Methods

    // Creates Photo Directory and Directory Path
    func createPhotosDircetory() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let directoryPath = paths.object(at: 0) as! NSString
        let imgDirPath = directoryPath.strings(byAppendingPaths: [IMAGES_DIRECTORY])[0]
        
        var isDir : ObjCBool = true
        if FileManager.default.fileExists(atPath: imgDirPath, isDirectory: &isDir) == false {
            // Dir does not exists
            do {
                try FileManager.default.createDirectory(atPath: imgDirPath, withIntermediateDirectories: false, attributes: nil)
            }
            catch {
                print(error)
            }
        }
        self.photoDirectoryPath = imgDirPath as NSString
    }
    
    // Clears all the images on Disk
    func cleanUpDisk() {
        
        let filePaths = getAllFilePathsAtLocation(path: photoDirectoryPath as String)
        
        if filePaths != nil {
            for path in filePaths! {
                removeFile(atPath: photoDirectoryPath.appendingPathComponent(path))
            }
        }
    }
    
    func getAllFilePathsAtLocation(path: String) -> [String]?
    {
        return FileManager.default.subpaths(atPath: path)!
    }

    // Removes the specified file  from the disk .
    func removeFile(atPath: String!) {
        
        if atPath != nil {
            if FileManager.default.fileExists(atPath: atPath) {
                do {
                    try FileManager.default.removeItem(atPath: atPath)
                } catch {
                    print("Error in deleting file")
                    print(error)
                }
            }
        }
    }

    
    func saveAsKfxKEDImageToDisk(image: kfxKEDImage, side: ImageType, mimeType: KEDImageMimeType) -> String! {

        var filePath = getFilePathWithType(side: side, type: mimeType) as String!
        
        do {
            if FileManager.default.fileExists(atPath: filePath!) == true {
                try FileManager.default.removeItem(atPath: filePath!)
            }
        } catch  {
            print(error)
        }

        image.specifyFilePath(filePath)
        //image.imageMimeType = mimeType
        
        let result = image.imageWriteToFile()
        
        if result != KMC_SUCCESS {

            print(kfxError.findErrMsg(result))
            print(kfxError.findErrDesc(result))
            
            print("Error in writing image object to disk.")
            filePath = nil
        }
        return filePath
    }
    
    func saveAsJPEGToDisk(image: kfxKEDImage, side: ImageType) -> String! {
        
        var filePath = getFilePathWithType(side: side, type: MIMETYPE_JPG) as String!
        
        print("File Path ==> \(filePath!)")

        do {
            if FileManager.default.fileExists(atPath: filePath!) == true {
                try FileManager.default.removeItem(atPath: filePath!)
            }
        } catch  {
            print(error)
        }
        
        // store image bitmap as jpeg image instead of storing the complete image object
        var data = UIImageJPEGRepresentation(image.getBitmap(), 1.0)! as NSData!
        
        if data != nil && (data?.write(toFile: filePath!, atomically: true))! {
            print("Image stored on disk")
            
        } else {
            print("Error: Failed to store image on disk")
            filePath = nil
        }
        data = nil;

        return filePath
    }
    
    func readImageData(path: String!) -> Data! {
        if path == nil {
            return nil
        }
        var imageData: Data! = nil
        let url = URL.init(string: path)
        
        do {
           imageData = try Data.init(contentsOf: url!)
            
        } catch {
            print(error)
        }
        
        return imageData
    }
    
    
    func getFilePathWithType(side: ImageType, type: KEDImageMimeType) -> NSString {
        var fileName: NSString
        fileName = photoDirectoryPath.appendingPathComponent(side.rawValue) as NSString
        fileName = fileName.appendingPathExtension(type.KEDImageMimeType_toString())! as NSString
        return fileName;
    }
    
    func isImageInDisk(side: ImageType, mimeType: KEDImageMimeType) -> Bool {
        let filePath = self.getFilePathWithType(side: side, type: mimeType) as String
        
        if FileManager.default.fileExists(atPath: filePath) {
            return true
        }
        return false
    }
    
    func isImageInDisk(filePath: String!) -> Bool {

        if filePath != nil {
            if FileManager.default.fileExists(atPath: filePath) {
                return true
            }
        }
        return false
    }
    func getImage(side: ImageType, mimeType: KEDImageMimeType) -> kfxKEDImage! {
    
        let filePath = self.getFilePathWithType(side: side, type: mimeType) as String
            
        let image = self.getImage(fromPath: filePath)
        
        return image
    }
    
    func getImage(fromPath: String!) -> kfxKEDImage! {
        
        var image: kfxKEDImage! = nil
        
        guard let path = fromPath else {
            return nil
        }

        if FileManager.default.fileExists(atPath: path) {
            image = kfxKEDImage.init()
            
            image?.specifyFilePath(path)
            image?.imageReadFromFile()
            
            print("DPI of the image just read ===> \(image!.imageDPI)")
        }

        return image
    }
}
