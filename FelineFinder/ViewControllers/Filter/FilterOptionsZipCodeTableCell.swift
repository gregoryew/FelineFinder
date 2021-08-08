//
//  FilterOptionsZipCodeCustomCellView.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/8/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import WhereAmI

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
        DispatchQueue.main.async(execute: {
            self.ZipCodeTextbox.leftView?.rotate360Degrees()
        })
        if (!WhereAmI.userHasBeenPromptedForLocationUse()) {
            WhereAmI.sharedInstance.askLocationAuthorization({ [unowned self] (locationIsAuthorized) -> Void in
                    coreLocation()
            });
        } else {
            coreLocation()
        }
    }
    
    func coreLocation() {
        whatIsThisPlace { (response) -> Void in
          switch response {
          case .success(let placemark):
            zipCode = placemark.postalCode ?? "66952"
            let keyStore = NSUbiquitousKeyValueStore()
            keyStore.set(zipCode, forKey: "zipCode")
            self.ZipCodeTextbox.text = zipCode
          case .placeNotFound:
            Utilities.displayAlert("ERROR", errorMessage: "Could not find where you are")
          case .failure (let error):
            Utilities.displayAlert("ERROR", errorMessage: "An Error occurred: \(error)")
          case .unauthorized:
            Utilities.displayAlert("ERROR", errorMessage: "You did not authorize this app to get your location")
          }
          DispatchQueue.main.async(execute: {
            self.ZipCodeTextbox.leftView?.layer.removeAllAnimations()
          })
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
            if range.location > 4 {
                return false
            }
        }
        return true
    }
}
