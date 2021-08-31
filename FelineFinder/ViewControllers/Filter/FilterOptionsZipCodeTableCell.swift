//
//  FilterOptionsZipCodeCustomCellView.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/8/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import SwiftLocation

class FilterOptionsZipCodeTableCell: UITableViewCell, textFieldButtons, UITextFieldDelegate {
    
    @IBOutlet weak var ZipCodeTextbox: UITextFieldWithButtons!
    
    func configure(zipCode: String) {
        ZipCodeTextbox.text = zipCode
        ZipCodeTextbox.buttonsDelegate = self
        ZipCodeTextbox.delegate = self
        ZipCodeTextbox.setupLeftImage(imageName: "filter_target")
        ZipCodeTextbox.setupRightImage(imageName: "filter_cross")
        self.selectionStyle = .none
    }
    
    func leftButtonTapped() {
        if Reachability.isLocationServiceEnabled() == true {
        DispatchQueue.main.async(execute: {
            self.ZipCodeTextbox.leftView?.rotate360Degrees()
        })

        SwiftLocation.gpsLocationWith {
            // configure everything about your request
            $0.subscription = .single // continous updated until you stop it
            $0.accuracy = .house
            $0.activityType = .otherNavigation
            $0.timeout = .delayed(5) // 5 seconds of timeout after auth granted
            $0.avoidRequestAuthorization = true
        }.then { result in // you can attach one or more subscriptions via `then`.
            switch result {
            case .success(let newData):
                let service = Geocoder.Apple(lat: newData.coordinate.latitude, lng: newData.coordinate.longitude)
                SwiftLocation.geocodeWith(service).then { result in
                    zipCode = result.data?.first?.clPlacemark?.postalCode ?? "66952"
                    let keyStore = NSUbiquitousKeyValueStore()
                    keyStore.set(zipCode, forKey: "zipCode")
                    keyStore.synchronize()
                    DispatchQueue.main.async(execute: {
                        self.ZipCodeTextbox.text = zipCode
                        self.ZipCodeTextbox.leftView?.layer.removeAllAnimations()
                    })
                }
            case .failure(let error):
                zipCode = "66952"
                let keyStore = NSUbiquitousKeyValueStore()
                keyStore.set(zipCode, forKey: "zipCode")
                keyStore.synchronize()
                DispatchQueue.main.async(execute: {
                    Utilities.displayAlert("ERROR", errorMessage: error.localizedDescription)
                    self.ZipCodeTextbox.text = zipCode
                    self.ZipCodeTextbox.leftView?.layer.removeAllAnimations()
                })
            }
        }
        } else {
            let alertController = UIAlertController(title: "Location Serives Disabled", message: "Please enable location services for this app.", preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in

                 guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                     return
                 }

                 if UIApplication.shared.canOpenURL(settingsUrl) {
                     UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                         print("Settings opened: \(success)") // Prints true
                     })
                 }
             }
             alertController.addAction(settingsAction)
             let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
             alertController.addAction(cancelAction)

            findViewController()?.present(alertController, animated: true, completion: nil)
        }
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        zipCode = ZipCodeTextbox.text!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
    func rightButtonTapped() {
        ZipCodeTextbox.text = ""
        zipCode = ZipCodeTextbox.text!
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == ZipCodeTextbox {
            if range.location > 6 {
                return false
            }
        }
        return true
    }
}
