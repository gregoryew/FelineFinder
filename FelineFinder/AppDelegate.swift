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
import FMDB
//import PushNotifications
//import UserNotifications
    
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate { //}, UITabBarControllerDelegate {

    var window: UIWindow?
    var warningShown: Bool = false
        
    //let pushNotifications = PushNotifications.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //UINavigationBar.appearance().barTintColor = UIColor.blue //UIColor(red: 1/255, green: 168/255, blue: 188/255, alpha: 1)
        //UINavigationBar.appearance().tintColor = UIColor.white
        //UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        //UINavigationBar.appearance().isTranslucent = false
        
        // set up your background color view
        //let colorView = UIView()
        ///colorView.backgroundColor = UIColor.lightGray
        
        // use UITableViewCell.appearance() to configure
        // the default appearance of all UITableViewCells in your app
        ///UITableViewCell.appearance().selectedBackgroundView = colorView
        
        ///UITabBar.appearance().barTintColor = UIColor.white
        
        //setStatusBarBackgroundColor(color: UIColor(red:0.537, green:0.412, blue:0.761, alpha:1.0))
        
        // Override point for customization after application launch.
        pathToFile()
        
        //zipCode = UserDefaults.standard.string(forKey: "zipCode") ?? ""

        zipCode = ""
        
        let rescueGroupsLastQueriedString = UserDefaults.standard.string(forKey: "rescueGroupsLastQueriedString") ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        var minusAYearAgo = DateComponents()
        minusAYearAgo.year = -1
        let userCalendar = Calendar.current
        updated = userCalendar.date(byAdding: minusAYearAgo, to: Date())!
        
        if rescueGroupsLastQueriedString == "" {
            let d = dateFormatter.string(from: updated)
            UserDefaults.standard.set(d, forKey: "rescueGroupsLastQueriedString")
        } else {
            rescueGroupsLastQueried = dateFormatter.date(from: rescueGroupsLastQueriedString)!
        }
        
        distance = UserDefaults.standard.string(forKey: "distance") ?? ""
        
        if distance == "" {
            distance = "4000"
            UserDefaults.standard.set(distance, forKey: "distance")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
  
        let kvStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default;
        let notificationsCenter: NotificationCenter = NotificationCenter.default
        notificationsCenter.addObserver(self, selector: #selector(AppDelegate.ubiquitousKeyValueStoreDidChange), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: kvStore)
        kvStore.synchronize()

        self.window = UIWindow(frame: UIScreen.main.bounds)
            
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //let defaults = UserDefaults.standard
        
        //if defaults.bool(forKey: "hideTitleScreen") == false {
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        /*
        } else {
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainTabViewController")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        */
        
        filterOptions.load(nil)
        
        //self.pushNotifications.register(instanceId: "a1ec1d97-a842-4f3d-998b-bdda0c65e066")
        //registerForPushNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        /*self.pushNotifications.registerDeviceToken(deviceToken) {
            print("subscribed")
            self.pushNotifications.subscribe(interest: "hello") // + AppMisc.USER_ID)
        }
        */
    }
    
    /*
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("*************MESSAGE")
        print(userInfo)
    }
    */
    
    @objc func ubiquitousKeyValueStoreDidChange() {
        Favorites.loadIDs()
        let nc = NotificationCenter.default
        nc.post(name:NSNotification.Name(rawValue: "reloadFavorites"),
                object: nil,
                userInfo:nil)
    }
    
/*
    func setStatusBarBackgroundColor(color: UIColor) {
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        
        statusBar.backgroundColor = color
    }
 
*/
    func sharedInstance() -> AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    @objc func rotated()
    {
        if(UIDevice.current.orientation.isLandscape)
        {
            //println("landscape")
        }
        
        if(UIDevice.current.orientation.isPortrait)
        {
            //println("Portrait")
        }
    }
    
    func pathToFile(){
        var c = 0

        let filemanager = FileManager.default
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as AnyObject
        let destinationPath:NSString = documentsPath.appending("/CatFinder.db") as NSString
        if (!filemanager.fileExists(atPath: destinationPath as String) ) {
            let fileForCopy = Bundle.main.path(forResource: "CatFinder",ofType:"db")
            do {
                try filemanager.copyItem(atPath: fileForCopy!,toPath:destinationPath as String)
            } catch {
                print (error)
            }
        } else {
            DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
                let querySQL = "SELECT count(*) c FROM sqlite_master WHERE type='table' AND name='Version' COLLATE NOCASE"
                if let results = db?.executeQuery(querySQL, withArgumentsIn: []) {
                    while results.next() == true {
                        c = Int(results.int(forColumn: "c"));
                    }
                    results.close()
                }
            }
            
            if (c == 0) {
                let fileForCopy = Bundle.main.path(forResource: "CatFinder",ofType:"db")
                do {
                    try filemanager.copyItem(atPath: fileForCopy!,toPath:destinationPath as String)
                } catch {
                    print (error)
                }
            } else {
                if upgradeDB() {
                    let oldFileForCopy = documentsPath.appending("/CatFinderOld.db")
                    DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
                        if (!(db?.executeStatements("ATTACH DATABASE \"\(oldFileForCopy)\" AS OLD"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("DELETE FROM Favorites"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("DELETE FROM SavedSearch"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("DELETE FROM SavedSearchDetail"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("DELETE FROM PetListFilterDetails"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("DELETE FROM PetListFilter"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME='Favorites'"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME='SavedSearch'"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME='SavedSearchDetail'"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME='PetListFilterDetails'"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME='PetListFilter'"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("INSERT INTO Favorites(PetID, PetName, ImageName, Breed, DataSource) SELECT PetID, PetName, ImageName, Breed, 'PetFinder' FROM OLD.Favorites"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("INSERT INTO SavedSearch SELECT * FROM OLD.SavedSearch"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("INSERT INTO SavedSearchDetail SELECT * FROM OLD.SavedSearchDetail"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("INSERT INTO PetListFilter SELECT * FROM OLD.PetListFilter"))!) {
                            print("Error")
                        }
                        if (!(db?.executeStatements("INSERT INTO PetListFilterDetails SELECT * FROM OLD.PetListFilterDetails"))!) {
                            print("Error")
                        }
                    }
                    Favorites.LoadFavorites(tv: nil)
                }
            }
        }
    }
    
    func upgradeDB() -> Bool {
        var copyOverDB = false
        let currentVersion = version()
        var destinationPath2 : NSString = ""
        let filemanager = FileManager.default
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as AnyObject
        let destinationPath:NSString = documentsPath.appending("/CatFinder.db") as NSString
        if (!filemanager.fileExists(atPath: destinationPath as String) ) {
            let fileForCopy = Bundle.main.path(forResource: "CatFinder",ofType:"db")
            do {
                try filemanager.copyItem(atPath: fileForCopy!,toPath:destinationPath as String)
            } catch {
                print (error)
            }
            copyOverDB = false
         } else {
            var hasOldVersion = false
            DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
                let querySQL = "select VersionNumber from Version"
                if let results = db?.executeQuery(querySQL, withArgumentsIn: []) {
                    while results.next() == true {
                        let dbVersion = results.string(forColumn: "VersionNumber");
                        if currentVersion != dbVersion {
                            hasOldVersion = true
                        }
                    }
                    results.close()
                }
            }
            if hasOldVersion {
                do {
                    destinationPath2 = documentsPath.appending("/CatFinderOld.db") as NSString
                    let docsPathDB = documentsPath.appending("/CatFinder.db")
                    if filemanager.fileExists(atPath: destinationPath2 as String) {
                        do {
                            try filemanager.removeItem(atPath: destinationPath2 as String)
                        }
                        catch let error as NSError {
                            print("Ooops! Something went wrong: \(error)")
                        }
                    }
                    DatabaseManager.sharedInstance.dbQueue!.close()
                    try filemanager.moveItem(atPath: docsPathDB, toPath: destinationPath2 as String)
                    let fileForCopy = Bundle.main.path(forResource: "CatFinder",ofType:"db")
                    do {
                        //DatabaseManager.sharedInstance.dbQueue!.close()
                        try filemanager.copyItem(atPath: fileForCopy!,toPath:destinationPath as String)
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
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    /*
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
 */
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        warningShown = false
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
/*
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
  */
}

var Favorites = FavoritesList()
//var details: BreedInfoDetailViewController = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BreedInfoDetail2") as? BreedInfoDetailViewController)!

