//
//  Utilities.swift
//  FelineFinder
//
//  Created by Gregory Williams on 8/28/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

func dateFromString(str: String, format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
    return dateFormatter.date(from: str) ?? nil
}

class Utilities {
    class func isNetworkAvailable() -> Bool {
        if (!RSUtilities.isNetworkAvailable("api.petfinder.com")) {
            //var networkType = RSUtilities.networkConnectionType("api.petfinder.com")
            
            //If host is not reachable, display a UIAlertController informing the user
            let alert = UIAlertController(title: "No Internet Connection", message: "For this function to work you need to be connected to the internet and you are not connected.", preferredStyle: UIAlertController.Style.alert)
            
            //Add alert action
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            //Present alert
            AppDelegate().sharedInstance().window?.rootViewController?.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
        
    class func displayAlert(_ errorTitle: String, errorMessage: String) {
        //If host is not reachable, display a UIAlertController informing the user
        
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        
        //Add alert action
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    
        DispatchQueue.main.async(execute: {
            //Present alert
            AppDelegate().sharedInstance().window?.rootViewController?.present(alert, animated: true, completion: nil)
        })
    }
        
    class func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        
        return ""
    }
}
