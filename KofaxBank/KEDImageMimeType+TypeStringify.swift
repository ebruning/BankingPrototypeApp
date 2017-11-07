//
//  KEDImageMimeType+TypeStringify.swift
//  KofaxBank
//
//  Created by Rupali on 09/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import Foundation

extension KEDImageMimeType {
    
    func KEDImageMimeType_toString() -> String {
        switch self {
        case MIMETYPE_UNKNOWN, MIMETYPE_JPG, MIMETYPE_LAST:
            return "jpg"
        case MIMETYPE_PNG:
            return "png"
        case MIMETYPE_TIF:
            return "tif"
        default:
            return "jpg"
        }
    }
}
