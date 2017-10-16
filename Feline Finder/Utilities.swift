//
//  Utilities.swift
//  FelineFinder
//
//  Created by Gregory Williams on 8/28/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

class Utilities {
    class func isNetworkAvailable() -> Bool {
        if (!RSUtilities.isNetworkAvailable("api.petfinder.com")) {
            //var networkType = RSUtilities.networkConnectionType("api.petfinder.com")
            
            //If host is not reachable, display a UIAlertController informing the user
            let alert = UIAlertController(title: "No Internet Connection", message: "For this function to work you need to be connected to the internet and you are not connected.", preferredStyle: UIAlertControllerStyle.alert)
            
            //Add alert action
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            //Present alert
            AppDelegate().sharedInstance().window?.rootViewController?.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
        
    class func displayAlert(_ errorTitle: String, errorMessage: String) {
        //If host is not reachable, display a UIAlertController informing the user
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
            
        //Add alert action
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
        //Present alert
        AppDelegate().sharedInstance().window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    class func apiKey() -> String {
        return "351841a21611f1d4dd8d9eba5a1ecc7a"
    }
    
    class func petFinderAPIURL() -> String {
        return "http://api.petfinder.com"
    }
}
