//
//  BreedInfoGalleryPhotoAPI.swift
//  Feline Finder
//
//  Created by gregoryew1 on 8/10/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit

struct breedPicture {
    var Name = ""
    var PictureURL = ""
    var PetID = ""
    
    init (name: String, picURL: String, petID: String) {
        Name = name
        PictureURL = picURL
        PetID = petID
    }
}

class BreedInfoGalleryPhotoAPI: NSObject {
    var status = ""
    
    var photos: [breedPicture] = []
    
    func loadPhotos(bn: Breed, completion: @escaping (_ photos: [breedPicture] ) -> Void) -> Void {
        
        if (Utilities.isNetworkAvailable() == false) {
            return
        }
        
        var filters:[filter] = []
        filters.append(["fieldName": "animalStatus" as AnyObject, "operation": "notequals" as AnyObject, "criteria": "Adopted" as AnyObject])
        filters.append(["fieldName": "animalSpecies" as AnyObject, "operation": "equals" as AnyObject, "criteria": "cat" as AnyObject])
        filters.append(["fieldName": "animalLocationDistance" as AnyObject, "operation": "radius" as AnyObject, "criteria": distance as AnyObject])
        filters.append(["fieldName": "animalLocation" as AnyObject, "operation": "equals" as AnyObject, "criteria": zipCode as AnyObject])
        filters.append(["fieldName": "animalPrimaryBreed" as AnyObject, "operation": "contains" as AnyObject, "criteria": bn.BreedName as AnyObject])
        
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["resultStart": "0", "resultLimit":"20", "resultOrder": "asc", "calcFoundRows": "Yes", "filters": filters, "fields": ["animalID", "animalName", "animalPictures"]]] as [String : Any]
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            let myURL = URL(string: "https://api.rescuegroups.org/http/v2.json")!
            let request = NSMutableURLRequest(url: myURL)
            request.httpMethod = "POST"
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
                data, response, error in
                if error != nil {
                    print("Get Error")
                    Utilities.displayAlert("Sorry There Was A Problem", errorMessage: "An error occurred while trying to display pet data.")
                } else {
                    var id = ""
                    var name = ""
                    var pict = ""

                    let json = JSON(data: data!)
                            
                    if json["status"].stringValue == "ok" {
                        let dict = json["data"].dictionaryValue
                        for (_, d) in dict {
                            id = d["animalID"].stringValue
                            name = d["animalName"].stringValue
                            pict = d["animalPictures"][0]["small"]["url"].stringValue
                            self.photos.append(breedPicture(name: name, picURL: pict, petID: id))
                        }
                    }
                    completion(self.photos)
                }
            })
            task.resume() } catch { }
    }
}
