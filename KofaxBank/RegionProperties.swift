//
//  RegionProperties.swift
//  KofaxBank
//
//  Created by Rupali on 21/09/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import Foundation


class RegionProperties: NSObject {
    var regionDisplayName: String = "United States"
    var odcRegionCode: kfxKOEIDRegion = kfxKOEIDRegion.US
    var countryDisplayName: String = "United States"
    var countryCode: String = ""
    var imageResize: String = "ID"
    var flagName: String = ""
    var propertyListFileNameForRegion: String!
}
