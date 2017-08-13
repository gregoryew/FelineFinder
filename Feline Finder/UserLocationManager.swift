//
//  UserLocationManager.swift
//  Feline Finder
//
//  Created by gregoryew1 on 8/12/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import MapKit

protocol LocationUpdateProtocol {
    func locationDidUpdateToLocation(location : CLLocation)
}

/// Notification on update of location. UserInfo contains CLLocation for key "location"
let kLocationDidChangeNotification = "LocationDidChangeNotification"

class UserLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let SharedManager = UserLocationManager()
    
    private var locationManager = CLLocationManager()
    
    var currentLocation : CLLocation?
    
    var delegate : LocationUpdateProtocol!
    
    private override init () {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        currentLocation = newLocation
        let userInfo2 : NSDictionary = ["location" : currentLocation!]
        
        DispatchQueue.main.async() { () -> Void in
            self.delegate.locationDidUpdateToLocation(location: self.currentLocation!)
            
            NotificationCenter.default.post(name:NSNotification.Name(rawValue: kLocationDidChangeNotification),
                    object: self,
                    userInfo: userInfo2 as? [String : Any])
        }
    }
    
}
