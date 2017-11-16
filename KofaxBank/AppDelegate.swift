//
//  AppDelegate.swift
//  KofaxBank
//
//  Created by Rupali on 30/05/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        customizeNavigationBar(application: application)
        
        //TODO: move license check at appropriate place
        // Set Kofax SDK license. Replace the MyLicenseString below with your license string.
        if(kfxLicense.setMobileSDK("ttz,L@xtN#VD$B,#vF8vt@&4BXX$ljRnPf[089@p5n[6qb04[(NPIUEAWGUNKl;dfvkhzdf7rglcvjck=,mIOF&^BUL?!!!!!!0t")
            == false) {
            print("Error: Kofax license is not valid or expired!");
        }
        
        Utility.checkDataStore()
        
        loadDefaults()

        return true
    }
    
    func customizeNavigationBar(application: UIApplication) {
        //make navigationbar transparent
        let navigationController = application.windows[0].rootViewController as! UINavigationController
        
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.backgroundColor = UIColor.clear
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "KofaxBank")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    

    
    
    
    private func loadDefaults() {
        
        if UserDefaults.standard.value(forKey: KEY_DEFAULTS_LOADED) != nil {
            return
        }
        
        //region properties
        UserDefaults.standard.setValue(ID_DEFAULT_REGION_PROPERTIES_MODEL_FILE, forKey: KEY_ID_REGION_PLIST_FILE_NAME)
        
        UserDefaults.standard.setValue(ID_DEFAULT_REGION_PROPERTIES_REGION_NAME, forKey: KEY_ID_REGION_NAME)
        UserDefaults.standard.setValue(ID_DEFAULT_REGION_PROPERTIES_COUNTRY_CODE, forKey: KEY_ID_COUNTRY_CODE)
        UserDefaults.standard.setValue(ID_DEFAULT_REGION_PROPERTIES_COUNTRY_DISPLAY_NAME, forKey: KEY_ID_COUNTRY_NAME)
        UserDefaults.standard.setValue(ID_DEFAULT_REGION_PROPERTIES_FLAG_IMAGE_NAME, forKey: KEY_ID_REGION_FLAG_NAME)
        UserDefaults.standard.setValue(ID_DEFAULT_REGION_PROPERTIES_IMAGE_RESIZE, forKey: KEY_ID_IMAGE_RESIZE)
        
        
        //Mobile ID Version - default 2x
        UserDefaults.standard.set(ServerVersion.VERSION_1X.rawValue, forKey: KEY_ID_MOBILE_ID_VERSION)
        
        UserDefaults.standard.setValue(true, forKey: KEY_DEFAULTS_LOADED)
    }

}





let ad = UIApplication.shared.delegate as! AppDelegate
let context = ad.persistentContainer.viewContext
