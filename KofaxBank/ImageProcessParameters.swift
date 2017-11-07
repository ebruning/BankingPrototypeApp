//
//  ImageProcessParameters.swift
//  KofaxBank
//
//  Created by Rupali on 16/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import Foundation

class ImageProcessParameters: NSObject {
    var inputImage: kfxKEDImage!
    var profile: kfxKEDImagePerfectionProfile!
    var processedImageMimeType: KEDImageMimeType!
    var processedImageFilePath: String!
}

