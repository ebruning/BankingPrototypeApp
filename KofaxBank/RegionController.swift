//
//  RegionControlManager.swift
//  KofaxBank
//
//  Created by Rupali on 28/09/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import Foundation

protocol RegionControlDelegate {
    func regionSelectorDidSaveNewRegion(regionProperties: RegionProperties)
    func regionSelectorDidCancel()
}

class RegionController {

    // MARK: Public variables
    
    var delegate: RegionControlDelegate?
    
    // MARK: Private variables
    
    private var privateNavController: UINavigationController?
    
    private var launcherVC: UIViewController! = nil
    
    private var regionProperties: RegionProperties!
    
    // MARK: initializers
    init() {
        
    }
    
    // MARK: Public mathods

    func showRegionSelection(launcherViewConroller: UIViewController, andRegionProperties: RegionProperties!) -> Bool {
    
        self.launcherVC = launcherViewConroller
        self.regionProperties = andRegionProperties

        if self.launcherVC == nil {
            return false
        }

        let regionViewController = RegionViewController.init(nibName: "RegionViewController", bundle: nil)
        
        if self.regionProperties == nil {
            //self.regionProperties = loadDefaultProperties()
            return false
        }
        
        regionViewController.currentRegionProperties = self.regionProperties
        regionViewController.saveHandler = onRegionSaved(properties:)
        regionViewController.cancelHandler = onRegionCancel
        //regionViewController.regionDataPropertyListName = withPListFile //propertyList file name for region data

        if self.privateNavController == nil {
            self.privateNavController = UINavigationController.init(rootViewController: regionViewController)
        }

        self.privateNavController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.privateNavController?.navigationBar.shadowImage = UIImage()
        self.privateNavController?.navigationBar.backgroundColor = UIColor.clear
        self.privateNavController?.navigationBar.isTranslucent = true
        
        launcherVC.present(self.privateNavController!, animated: true, completion: nil)

        return true
    }
/*
    func loadDefaultProperties() -> RegionProperties {
        let properties = RegionProperties()
        
        properties.regionDisplayName = UNITED_STATES
        properties.countryCode = DEFAULT_REGION_PROPERTIES_COUNTRY_CODE
        properties.countryDisplayName = UNITED_STATES
        properties.imageResize = DEFAULT_REGION_PROPERTIES_IMAGE_RESIZE
        properties.flagName = DEFAULT_REGION_PROPERTIES_FLAG_IMAGE_NAME
        properties.odcRegionCode = DEFAULT_REGION_PROPERTIES_ODC_REGION_CODE
        properties.propertyListFileNameForRegion = DEFAULT_REGION_PROPERTIES_MODEL_FILE
        
        return properties
    }
*/
    
    // MARK: Private mathods
    
    
    // RegionViewController delegates
    
    func onRegionSaved(properties: RegionProperties) {
        delegate?.regionSelectorDidSaveNewRegion(regionProperties: properties)
    }
    
    func onRegionCancel() {
        delegate?.regionSelectorDidCancel()
    }
    
    // MARK: deinitializer
    deinit {
       privateNavController = nil
    }
}
