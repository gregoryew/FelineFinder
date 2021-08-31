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
import CoreData
import Instabug

@UIApplicationMain
class AppDelegate: UIResponder { //}, UITabBarControllerDelegate {
    var window: UIWindow?
    let notificationDelegate = NotificationDelegate()
    lazy var persistentContainer: NSPersistentContainer = {
      let container = NSPersistentContainer(name: "PushNotifications")
      container.loadPersistentStores(completionHandler: { (_, error) in
        if let error = error as NSError? {
          fatalError("Unresolved error \(error), \(error.userInfo)")
        }
      })

      return container
    }()
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Instabug.start(withToken: "dafbc579501c606b557501d7da83d74d", invocationEvents: [.shake, .screenshot])
                
        pathToFile()
        
        zipCode = ""
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
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
            distance = "8000"
            UserDefaults.standard.set(distance, forKey: "distance")
        }
          
        let kvStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default;
        let notificationsCenter: NotificationCenter = NotificationCenter.default
        notificationsCenter.addObserver(self, selector: #selector(AppDelegate.ubiquitousKeyValueStoreDidChange), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: kvStore)
        kvStore.synchronize()
        
        let keyStore = NSUbiquitousKeyValueStore()
        if let id = keyStore.string(forKey: "UserID") {
            userID = UUID(uuidString: id as String)
        } else {
            userID = UUID()
            keyStore.set(userID?.uuidString, forKey: "UserID")
        }
        
        registerForPushNotifications(application: application)
        
        return true
    }
    
    func saveUser(userID: UUID, token: String) {
        let userQuery = User(userId: userID, token: token)
        
        let offlineQueryRequest = OfflineQueryRequest(resourceString: "https://feline-finder-server-5-4a4nx.ondigitalocean.app/api/user")
        
        offlineQueryRequest.saveUserId(userQuery, completion: { result in
            switch result {
            case .success(_):
                print("success")
            case .failure(let error):
                print("There has been an error saving the user object.  The error is \(error).")
            }
        })
    }
        
    @objc func ubiquitousKeyValueStoreDidChange() {
        let _ = Favorites.loadIDs()
        let nc = NotificationCenter.default
        nc.post(name:NSNotification.Name(rawValue: "reloadFavorites"),
                object: nil,
                userInfo:nil)
        FitValues.loadValues()
    }
    
    func sharedInstance() -> AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
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
                    Favorites.LoadFavorites()
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
        
    func applicationWillResignActive(_ application: UIApplication) {
        if FitValues.count > 0 {
            FitValues.storeIDs()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
      let context = persistentContainer.viewContext
      guard context.hasChanges else { return }

      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }

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
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        saveUser(userID: userID!, token: token)
        print("Device Token: \(token)")
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void)
    {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound])
        } else {
            completionHandler([.alert,.sound])
        }
    }
        
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}
