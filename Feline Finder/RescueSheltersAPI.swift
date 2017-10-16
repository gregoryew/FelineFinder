//
//  RescueSheltersAPI.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/1/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation

class RescueGroupShelterList: ShelterList {
    override func loadSingleShelter(_ shelterID: String, completion: @escaping (shelter) -> Void) -> Void {
        super.loadSingleShelter(shelterID, completion: completion)
        if let s = sh[shelterID] {
            print("shelter in cache = |\(shelterID)|")
            //Supposed to refresh the PetFinder data every 24 hours
            let hoursSinceCreation = (Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: s.dateCreated as Date, to: Date(), options: []).hour
            if hoursSinceCreation! < 24 {
                print("returning cached shelter = |\(shelterID)|")
                completion(s)
                return
            }
        }

        let json = ["apikey":"0doJkmYU","objectType":"orgs","objectAction":"publicSearch", "search": ["resultStart": "0", "resultLimit":"1", "resultSort": "orgID", "resultOrder": "asc", "filters": [["fieldName": "orgID", "operation": "equals", "criteria": shelterID]], "fields": ["orgID","orgName","orgAddress","orgCity","orgState","orgLocation","orgCountry","orgPhone","orgFax","orgEmail"]]] as [String : Any]

        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            var cachedShelter: shelter?
            
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
                } else {
                    do {
                        let jsonObj:AnyObject =  try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! NSDictionary
                        
                        if let dict = jsonObj as? [String: AnyObject] {
                            for (key, data) in dict {
                                if key == "foundRows" {
                                    let rows = (data as? Int)
                                    if rows == 0 {
                                        completion(shelter(i: "ERROR", n: "", a1: "", a2: "", c: "", s: "", z: "", lat: 0.0, lng: 0.0, c2: "", p: "", f: "", e: ""))
                                        return
                                    }
                                }
                            }
                            for (key, data) in dict {
                                if key == "data" {
                                    for (_, data2) in (data as? [String: AnyObject])! {
                                        cachedShelter = self.createShelter(data2)
                                        self.sh[cachedShelter!.id] = cachedShelter
                                    }
                                }
                            }
                        }
                        
                        if let cs = cachedShelter {
                            completion(cs)
                        } else {
                            completion(shelter(i: "ERROR", n: "", a1: "", a2: "", c: "", s: "", z: "", lat: 0.0, lng: 0.0, c2: "", p: "", f: "", e: ""))
                        }
                    } catch let error as NSError {
                        // error handling
                        print(error.localizedDescription)
                    }
                }
            }) 
            task.resume()
        } catch { }
    }
    
    func vaidateValue(_ d: AnyObject) -> String {
        var data: String = ""
        if d is String {
            data = d as! String
        } else {
            data = ""
        }
        return data
    }
    
    func createShelter(_ s: AnyObject) -> shelter {
        var id: String = ""
        var name: String = "'"
        var address1: String = ""
        let address2: String = ""
        var city: String = ""
        var state: String = ""
        var zipCode: String = ""
        var zipCode2: String = ""
        let latitude: Double = 0.0
        let longitude: Double = 0.0
        var country: String = ""
        var phone: String = ""
        var fax: String = ""
        var email: String = ""
        
        if let dict = s as? [String: AnyObject] {
            for (key, data) in dict {
                switch key {
                case "orgID": id = vaidateValue(data)
                case "orgName": name = vaidateValue(data)
                case "orgAddress": address1 = vaidateValue(data)
                case "orgCity": city = vaidateValue(data)
                case "orgState": state = vaidateValue(data)
                case "orgPostalCode": zipCode = vaidateValue(data)
                case "orgLocation": zipCode2 = vaidateValue(data)
                case "orgCountry": country = vaidateValue(data)
                case "orgPhone": phone = vaidateValue(data)
                case "orgFax": fax = vaidateValue(data)
                case "orgEmail": email = vaidateValue(data)
                default: break
                }
            }
        }
        
        if zipCode == "" {zipCode = zipCode2}
        
        return shelter(i: id, n: name, a1: address1, a2: address2, c: city, s: state, z: zipCode, lat: latitude, lng: longitude, c2: country, p: phone, f: fax, e: email)
    }
}

struct RescueShelterTags {
    static let PETFINDER_TAG = "petfinder"
    static let SHELTERS_TAG = "shelters"
    static let SHELTER_TAG = "shelter"
    static let ID_TAG = "id"
    static let T_TAG = "$t"
    static let NAME_TAG = "name"
    static let ADRESS1_TAG = "address1"
    static let ADRESS2_TAG = "address2"
    static let CITY_TAG = "city"
    static let STATE_TAG = "state"
    static let ZIP_TAG = "zip"
    static let COUNTRY_TAG = "country"
    static let LATITUDE_TAG = "latitude"
    static let LONGITUDE_TAG = "longitude"
    static let PHONE_TAG = "phone"
    static let FAX_TAG = "fax"
    static let EMAIL_TAG = "email"
    static let LASTOFFSET_TAG = "lastOffset"
}
