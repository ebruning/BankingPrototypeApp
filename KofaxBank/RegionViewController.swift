//
//  RegionViewController.swift
//  KofaxBank
//
//  Created by Rupali on 21/09/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class RegionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var pickerCountry: UIPickerView!
    @IBOutlet weak var labelCountry: UILabel!
    
    @IBOutlet weak var containerViewCanada: UIView!
    @IBOutlet weak var containerViewUSA: UIView!
    @IBOutlet weak var containerViewLatinAmerica: UIView!
    @IBOutlet weak var containerViewEurope: UIView!
    @IBOutlet weak var containerViewAfrica: UIView!
    @IBOutlet weak var containerViewAsia: UIView!
    @IBOutlet weak var containerViewAustralia: UIView!
    
    @IBOutlet weak var btnCanada: UIButton!
    @IBOutlet weak var btnUSA: UIButton!
    @IBOutlet weak var btnLatinAmerica: UIButton!
    @IBOutlet weak var btnEurope: UIButton!
    @IBOutlet weak var btnAfrica: UIButton!
    @IBOutlet weak var btnAsia: UIButton!
    @IBOutlet weak var btnAustralia: UIButton!

    @IBOutlet weak var imgPinCanada: UIImageView!
    @IBOutlet weak var imgPinUSA: UIImageView!
    @IBOutlet weak var imgPinLatinAmerica: UIImageView!
    @IBOutlet weak var imgPinEurope: UIImageView!
    @IBOutlet weak var imgPinAfrica: UIImageView!
    @IBOutlet weak var imgPinAsia: UIImageView!
    @IBOutlet weak var imgPinAustralia: UIImageView!
    
    @IBOutlet weak var imgDotCanada: UIImageView!
    @IBOutlet weak var imgDotUSA: UIImageView!
    @IBOutlet weak var imgDotLatinAmerica: UIImageView!
    @IBOutlet weak var imgDotEurope: UIImageView!
    @IBOutlet weak var imgDotAfrica: UIImageView!
    @IBOutlet weak var imgDotAsia: UIImageView!
    @IBOutlet weak var imgDotAustralia: UIImageView!
    
    
    
    // MARK: Global variables
    
    var currentRegionProperties: RegionProperties! = nil
    
    //var delegate: RegionViewControllerDelegate?
    
    typealias SaveHandler = (_ properties: RegionProperties)  -> Void
    typealias CancelHandler = ()  -> Void
    
    var saveHandler: SaveHandler?
    var cancelHandler: CancelHandler?
    
    // MARK: Local variables
    typealias StatesDictType = Dictionary<String, RegionProperties>

    private var regionDict = [String: StatesDictType]()
    
    private var statesDict: StatesDictType! = nil
    
    private var inputArray: NSArray! = nil

    private var regionPListFileName: String!
    
    private var currentPin: UIImageView!
    
    //MARK: Navigationbar related parameters
    private var wasNavigationHidden: Bool = false

    private var oldBarTintColor: UIColor!
    
    private var oldStatusBarStyle: UIStatusBarStyle!


    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationBar()

        loadRegions()
        loadDefaultsIfEmpty()
        
        if regionDict.count > 0 {
            updateViews(forRegions: regionDict)
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentRegionProperties != nil && currentRegionProperties.regionDisplayName != "" {
            refreshScreen(regionName: currentRegionProperties.regionDisplayName, useExisting: true)
        }
    }

    private func customizeNavigationBar() {
        
        oldStatusBarStyle = UIApplication.shared.statusBarStyle
        oldBarTintColor = navigationController?.navigationBar.tintColor
        
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        wasNavigationHidden = (navigationController?.navigationBar.isHidden)!
        
        // add save button on right side of navigationbar
        let saveAction = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(onSaveClicked))
        self.navigationItem.rightBarButtonItem = saveAction
        
        // add cancel button on left side of navigationbar
        let cancelAction = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: #selector(onCancelClicked))
        self.navigationItem.leftBarButtonItem = cancelAction
        
        //show navigation bar
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func restoreNavigationBar() {
        UIApplication.shared.statusBarStyle = oldStatusBarStyle
        navigationController?.navigationBar.tintColor = oldBarTintColor
        navigationController?.setNavigationBarHidden(wasNavigationHidden, animated: false)
    }
    
    private func refreshScreen(regionName: String!, useExisting: Bool) {

        if regionName == nil {
            return
        }
        
        let previousPin = currentPin
        var currentRegionName: String = regionName
        
        switch regionName {
        case CANADA:
            pickerCountry.isHidden = true
            currentPin = imgPinCanada
            break
            
        case UNITED_STATES:
            pickerCountry.isHidden = true
            currentPin = imgPinUSA
            break
            
        case LATIN_AMERICA:
            pickerCountry.isHidden = false
            currentPin = imgPinLatinAmerica
            break
            
        case EUROPE:
            pickerCountry.isHidden = false
            currentPin = imgPinEurope
            break
            
        case AFRICA:
            pickerCountry.isHidden = false
            currentPin = imgPinAfrica
            break
            
        case ASIA:
            pickerCountry.isHidden = false
            currentPin = imgPinAsia
            break
            
        case AUSTRALIA:
            pickerCountry.isHidden = false
            currentPin = imgPinAustralia
            break
            
        default:
            currentRegionName = ""
            break
        }
        
        if currentPin != previousPin {
            if currentRegionName != "" {
                self.statesDict = regionDict[currentRegionName]
            }
            
            var index: Int = 0
            
            //everytime new region is selected (screen is refreshed) assign first element from statesDictionary to currentRegionProperties obj
            if useExisting && currentRegionProperties != nil {
                let countryIndex = statesDict.keys.sorted().index(of: currentRegionProperties.countryDisplayName)
                if countryIndex != nil {
                     index = countryIndex!
                }
            }
            self.currentRegionProperties = statesDict[statesDict.keys.sorted()[index]]

            if previousPin != nil {
                previousPin!.isHidden = true
            }
            currentPin.isHidden = false

            if !pickerCountry.isHidden {
                updatePickerContent(regionName: currentRegionName)
            }

            updateCurrentCountryOnScreen()
        }
    }

    private func loadRegions() {

        if currentRegionProperties != nil {
        
            
            if (currentRegionProperties.propertyListFileNameForRegion != nil || currentRegionProperties.propertyListFileNameForRegion != "") {
                //save the file name in a local variable
                regionPListFileName = currentRegionProperties.propertyListFileNameForRegion
                
                let pListPath = Bundle.main.path(forResource: currentRegionProperties.propertyListFileNameForRegion, ofType: "plist")
                if let path = pListPath {
                    parseRegions(forpListPath: path)
                }
            }
        }
    }
    
    
    //TODO: move this method to caller screen later and only pass currently selected region/country to this screen
    private func loadDefaultsIfEmpty() {

        if currentRegionProperties != nil {
            return
        }
        
        if let defaultRegion = regionDict[UNITED_STATES] {
            currentRegionProperties = defaultRegion[UNITED_STATES]
            if currentRegionProperties != nil {
                print("\(currentRegionProperties.countryDisplayName)")
                print("\(currentRegionProperties.countryCode)")
                print("\(currentRegionProperties.flagName)")
            }
        }
    }
    

    private func parseRegions(forpListPath: String) {
        
        let root = NSDictionary.init(contentsOfFile: forpListPath)
        
        //print("Dict ===> \(root?.allKeys)")
        
        let allKeys = root?.allKeys
        
        if let keys = allKeys {
            for key in keys {
                //create RegionProperties object
                print("\(root?.value(forKey: key as! String) as! [NSDictionary])")
                let arrStateElementArr = buildRegionObject(stateArr: root?.value(forKey: key as! String) as! [NSDictionary], regionName: key as! String)
                if arrStateElementArr != nil && (arrStateElementArr?.count)! > 0 {
                    regionDict.updateValue(arrStateElementArr!, forKey: key as! String)
                 //   regionDict.setValue(arrStateElementArr!, forKey: key as! String)
                }
            }
            
            print("Count of regionDict is ===> \(regionDict.count)")
        }
    }
    
    
    private func buildRegionObject(stateArr: [NSDictionary], regionName: String!) -> StatesDictType! {
        if regionName == nil {
            return nil
        }

        if stateArr.count == 0 {
            return nil
        }
        var stateDict: StatesDictType = StatesDictType.init()
        
        for stateDictObj in stateArr {
            print("PList countryname => \(stateDictObj.value(forKey: "countryname")!)")
            print("PList flagname => \(stateDictObj.value(forKey: "flagname")!)")
            print("PList imageresize => \(stateDictObj.value(forKey: "imageresize")!)")
            print("PList regionname => \(stateDictObj.value(forKey: "regionname")!)")
            print("PList countrycode => \(stateDictObj.value(forKey: "countrycode")!)")

            print("-----------------------------")
            
            let obj = RegionProperties()
            
            //flagname
            if let flagname = stateDictObj.value(forKey: "flagname") {
                obj.flagName = flagname as! String
            }
            
            //image resize
            if let imageresize = stateDictObj.value(forKey: "imageresize") {
                obj.imageResize = imageresize as! String
            }
            
            //region name
            obj.regionDisplayName = regionName

            //get region code by using region display name
            obj.odcRegionCode = getkfxKOEIDRegion(fromRegionName: regionName)

            //country code
            if let countrycode = stateDictObj.value(forKey: "countrycode") {
                obj.countryCode = countrycode as! String
            }
            
            //country name
            if let countryname = stateDictObj.value(forKey: "countryname") {
                obj.countryDisplayName = countryname as! String
            }

            
            print("Obj countryDisplayName => \(obj.countryDisplayName)")
            print("Obj flagName => \(obj.flagName)")
            print("Obj imageResize => \(obj.imageResize)")
            print("Obj regionDisplayName => \(obj.regionDisplayName)")
            print("Obj odcRegionCode => \(obj.odcRegionCode)")
            print("Obj countryCode => \(obj.countryCode)")

            print("*******************************************")

            if obj.countryDisplayName != "" {
                //create object of StateElement (<String, RegionProperties>) and add obj into it add new StateElement into stateElementArr
                //let propertiesDict: PropertiesDict = PropertiesDict.init(dictionaryLiteral: (obj.countryDisplayName, obj))
                
                //add state properties obj to state dictionary
                stateDict.updateValue(obj, forKey: obj.countryDisplayName)
            }
        }

        print("Count of stateElementArr is ===> \(stateDict.count)")

        if stateDict.count > 0 {
            return stateDict
        }
        
        return nil
    }
    

    private func getkfxKOEIDRegion(fromRegionName: String) -> kfxKOEIDRegion {
        
        var koeIDRegion: kfxKOEIDRegion = kfxKOEIDRegion.US
        
        switch fromRegionName {
            
        case UNITED_STATES:
            koeIDRegion = kfxKOEIDRegion.US
            break
            
        case CANADA:
            koeIDRegion = kfxKOEIDRegion.canada
            break
            
        case LATIN_AMERICA:
            koeIDRegion = kfxKOEIDRegion.latinAmerica
            break
            
        case EUROPE:
            koeIDRegion = kfxKOEIDRegion.europe
            break
            
        case ASIA:
            koeIDRegion = kfxKOEIDRegion.asia
            break
            
        case AUSTRALIA:
            koeIDRegion = kfxKOEIDRegion.australia
            break
            
        case AFRICA:
            koeIDRegion = kfxKOEIDRegion.africa
            break

        default:
            break
        }
        
        return koeIDRegion
    }
    
    
    private func updateViews(forRegions: [String: StatesDictType]) {
        
        //update the visibility of region views on screen based on the regions available in data
        for region in forRegions {
            
            print("Key===> \(region.key)")

            switch region.key {
            case CANADA:
                containerViewCanada.isHidden = false
                break
            case UNITED_STATES:
                containerViewUSA.isHidden = false
                break
            case LATIN_AMERICA:
                containerViewLatinAmerica.isHidden = false
                break
            case EUROPE:
                containerViewEurope.isHidden = false
                break
            case AFRICA:
                containerViewAfrica.isHidden = false
                break
            case ASIA:
                containerViewAsia.isHidden = false
                break
            case AUSTRALIA:
                containerViewAustralia.isHidden = false
                break
            default:
                break
            }
        }
        
    }
    

    
    private func updatePickerContent(regionName: String) {

        if pickerCountry.delegate == nil {
            pickerCountry.delegate = self
            pickerCountry.dataSource = self
        }

        pickerCountry.reloadAllComponents()
        //select first country be default when new region is selected
        let countryIndex = statesDict.keys.sorted().index(of: currentRegionProperties.countryDisplayName)
        if let index = countryIndex, pickerCountry.numberOfRows(inComponent: 0) > index {
            pickerCountry.selectRow(index, inComponent: 0, animated: true)
        } else {
            pickerCountry.selectRow(0, inComponent: 0, animated: true)
        }
    }

    // method to display currently selected region and country name on screen label
    private func updateCurrentCountryOnScreen() {
        if self.currentRegionProperties != nil {
            
            let regionName = self.currentRegionProperties.regionDisplayName
            let stateName = self.currentRegionProperties.countryDisplayName
            
            if regionName == UNITED_STATES || regionName == CANADA {
                labelCountry.text = regionName
            } else {
                labelCountry.text = regionName + " - " + stateName
            }
        }
    }

    // MARK: button callbacks
    
    @IBAction func onRegionClicked(_ sender: UIButton) {
        
        var currentRegionName: String! = nil
        
        switch sender {
        case btnCanada:
            currentRegionName = CANADA
            break
            
        case btnUSA:
            currentRegionName = UNITED_STATES
            break
            
        case btnLatinAmerica:
            currentRegionName = LATIN_AMERICA
            break
            
        case btnEurope:
            currentRegionName = EUROPE
            break
            
        case btnAfrica:
            currentRegionName = AFRICA
            break
            
        case btnAsia:
            currentRegionName = ASIA
            break
            
        case btnAustralia:
            currentRegionName = AUSTRALIA
            break
            
        default:
            currentRegionName = nil
            break
        }
        
        refreshScreen(regionName: currentRegionName, useExisting: false)
    }

    
    //MARK: Pickerview delegate and methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.statesDict != nil {
            return self.statesDict.keys.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        if self.statesDict != nil {
            return self.statesDict.keys.sorted()[row]
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let stateName = statesDict.keys.sorted()[row]
        
        currentRegionProperties = statesDict[stateName]
        
        print("\(stateName)")
        
        updateCurrentCountryOnScreen()
    }
    
    
    
    //MARK: Navigationbar item actions
    func onSaveClicked() {

        //reload saved pList file name into currentRegionProperties
        currentRegionProperties.propertyListFileNameForRegion = regionPListFileName
        
        //delegate?.regionSelectorDidSaveNewRegion(properties: currentRegionProperties)
        saveHandler?(currentRegionProperties)
        closeScreen()
    }
    
    func onCancelClicked() {
        //delegate?.regionSelectionDidCancel()
        cancelHandler?()
        
        closeScreen()
    }
    
    func closeScreen() {
        dismiss(animated: true, completion: {
            self.restoreNavigationBar()
        })
    }
  
}
