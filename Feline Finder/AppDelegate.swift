//
//  AppDelegate.swift
//  Feline Finder
//
//  Created by Gregory Williams on 6/4/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var warningShown: Bool = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        pathToFile()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.rotated), name: UIDeviceOrientationDidChangeNotification, object: nil)
        return true
    }
    
    func sharedInstance() -> AppDelegate{
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func rotated()
    {
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
        {
            //println("landscape")
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
            //println("Portrait")
        }
    }
    
    func pathToFile(){
        var c = 0

        let filemanager = NSFileManager.defaultManager()
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        let destinationPath:NSString = documentsPath.stringByAppendingString("/CatFinder.db")
        if (!filemanager.fileExistsAtPath(destinationPath as String) ) {
            let fileForCopy = NSBundle.mainBundle().pathForResource("CatFinder",ofType:"db")
            do {
                try filemanager.copyItemAtPath(fileForCopy!,toPath:destinationPath as String)
            } catch {
                print (error)
            }
        } else {
            DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
                let querySQL = "SELECT count(*) c FROM sqlite_master WHERE type='table' AND name='Version' COLLATE NOCASE"
                if let results = db.executeQuery(querySQL, withArgumentsInArray: []) {
                    while results.next() == true {
                        c = Int(results.intForColumn("c"));
                    }
                    results.close()
                }
            }
            
            if (c == 0) {
                let fileForCopy = NSBundle.mainBundle().pathForResource("CatFinder",ofType:"db")
                do {
                    try filemanager.copyItemAtPath(fileForCopy!,toPath:destinationPath as String)
                } catch {
                    print (error)
                }
            } else {
                if upgradeDB() {
                    let oldFileForCopy = documentsPath.stringByAppendingString("/CatFinderOld.db")
                    DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
                        if (!db.executeStatements("ATTACH DATABASE \"\(oldFileForCopy)\" AS OLD")) {
                            print("Error")
                        }
                        if (!db.executeStatements("DELETE FROM Favorites")) {
                            print("Error")
                        }
                        if (!db.executeStatements("DELETE FROM SavedSearch")) {
                            print("Error")
                        }
                        if (!db.executeStatements("DELETE FROM SavedSearchDetail")) {
                            print("Error")
                        }
                        if (!db.executeStatements("UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME='Favorites'")) {
                            print("Error")
                        }
                        if (!db.executeStatements("UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME='SavedSearch'")) {
                            print("Error")
                        }
                        if (!db.executeStatements("UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME='SavedSearchDetail'")) {
                            print("Error")
                        }
                        if (!db.executeStatements("INSERT INTO Favorites(PetID, PetName, ImageName, Breed, DataSource) SELECT PetID, PetName, ImageName, Breed, 'PetFinder' FROM OLD.Favorites")) {
                            print("Error")
                        }
                        if (!db.executeStatements("INSERT INTO SavedSearch SELECT * FROM OLD.SavedSearch")) {
                            print("Error")
                        }
                        if (!db.executeStatements("INSERT INTO SavedSearchDetail SELECT * FROM OLD.SavedSearchDetail")) {
                            print("Error")
                        }
                    }
                }
            }
        }
    }
    
    func upgradeDB() -> Bool {
        var copyOverDB = false
        let currentVersion = version()
        var destinationPath2 : NSString = ""
        let filemanager = NSFileManager.defaultManager()
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        let destinationPath:NSString = documentsPath.stringByAppendingString("/CatFinder.db")
        if (!filemanager.fileExistsAtPath(destinationPath as String) ) {
            let fileForCopy = NSBundle.mainBundle().pathForResource("CatFinder",ofType:"db")
            do {
                try filemanager.copyItemAtPath(fileForCopy!,toPath:destinationPath as String)
            } catch {
                print (error)
            }
            copyOverDB = false
         } else {
            var hasOldVersion = false
            DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
                let querySQL = "select VersionNumber from Version"
                if let results = db.executeQuery(querySQL, withArgumentsInArray: []) {
                    while results.next() == true {
                        let dbVersion = results.stringForColumn("VersionNumber");
                        if currentVersion != dbVersion {
                            hasOldVersion = true
                        }
                    }
                    results.close()
                }
            }
            if hasOldVersion {
                do {
                    destinationPath2 = documentsPath.stringByAppendingString("/CatFinderOld.db")
                    let docsPathDB = documentsPath.stringByAppendingString("/CatFinder.db")
                    if filemanager.fileExistsAtPath(destinationPath2 as String) {
                        do {
                            try filemanager.removeItemAtPath(destinationPath2 as String)
                        }
                        catch let error as NSError {
                            print("Ooops! Something went wrong: \(error)")
                        }
                    }
                    try filemanager.moveItemAtPath(docsPathDB, toPath: destinationPath2 as String)
                    let fileForCopy = NSBundle.mainBundle().pathForResource("CatFinder",ofType:"db")
                    do {
                        DatabaseManager.sharedInstance.dbQueue!.close()
                        try filemanager.copyItemAtPath(fileForCopy!,toPath:destinationPath as String)
                        DatabaseManager.sharedInstance.dbQueue = FMDatabaseQueue(path: destinationPath as String)
                    } catch {
                        print ("Ooops! Something went wrong: \(error)")
                    }
                }
                catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }
                copyOverDB = true
            } else {
                copyOverDB = false
            }
         }
        return copyOverDB
    }

    func version() -> String {
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }

    func showWarning() {
        if warningShown == false {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "This App is provided as is without any guarantees or warranty.  In association with the production Gregory Edward Williams makes no warranties of any kind, either express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, of title, or of noninfringment of third party rights.  Use of the product by a user is at the user's risk."
            alert.addButtonWithTitle("Understood")
            alert.show()
            warningShown = true
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        warningShown = false
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

