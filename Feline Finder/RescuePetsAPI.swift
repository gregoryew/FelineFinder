//
//  RescuePetsAPI.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/1/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class RescuePetList: PetList {

    var status = ""
    var task: URLSessionTask?
    
    //var resultLimit: Int = 100
    override func loadSinglePet(_ petID: String, completion: @escaping (Pet) -> Void) -> Void {
        super.loadSinglePet(petID, completion: completion)
        if let p2 = PetsGlobal[petID] {
            //Supposed to refresh the PetFinder data every 24 hours
            let hoursSinceCreation = (Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: p2.dateCreated as Date, to: Date(), options: []).hour
            if hoursSinceCreation! < 24 && p2.description != "" {
                completion(p2)
                return
            }
        }
        
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["resultStart": "0", "resultLimit":"100", "resultSort": "animalLocationDistance", "resultOrder": "asc", "calcFoundRows": "Yes", "filters": [["fieldName": "animalSpecies", "operation": "equals", "criteria": "cat"],["fieldName": "animalID", "operation": "equals", "criteria": splitPetID(petID)]], "fields": ["animalID","animalOrgID","animalAltered","animalBreed","animalDeclawed","animalDescription","animalDescriptionPlain","animalGeneralAge","animalGeneralSizePotential","animalHousetrained","animalLocation","animalLocationCoordinates","animalLocationDistance","animalName","animalSpecialneeds","animalSpecialneedsDescription","animalOKWithAdults","animalOKWithCats","animalOKWithDogs","animalOKWithKids","animalPrimaryBreed","animalRescueID","animalSex","animalSizePotential","animalUpdatedDate","animalPictures","animalVideoUrls","animalUptodate","animalStatus","animalAdoptedDate","animalAvailableDate","animalAdoptionPending","animalBirthdate", "animalBirthdateExact",      "animalApartment", "animalYardRequired","animalIndoorOutdoor","animalNoCold", "animalNoHeat", "animalOKForSeniors", "animalActivityLevel", "animalEnergyLevel", "animalExerciseNeeds", "animalNewPeople", "animalVocal", "animalAffectionate", "animalCratetrained", "animalEagerToPlease", "animalEscapes", "animalEventempered", "animalGoodInCar", "animalHousetrained", "animalIntelligent", "animalLap", "animalNeedsCompanionAnimal", "animalPlayful", "animalPlaysToys", "animalPredatory", "animalTimid", "animalCoatLength", "animalEyeColor", "animalGroomingNeeds", "animalShedding", "animalTailType", "animalColor", "animalHearingImpaired", "animalHypoallergenic", "animalMicrochipped", "animalOngoingMedical", "animalSpecialDiet", "animalSpecialneeds", "animalAdoptionFee"]]] as [String : Any]
        
        if Utilities.isNetworkAvailable() {
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
                    } else {
                        //var error:NSError?
                        do {
                            let jsonObj:AnyObject =  try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! NSDictionary
                            
                            if let dict = jsonObj as? [String: AnyObject] {
                                for (key, data) in dict {
                                    if key == "foundRows" {
                                        if data as! Int == 0 {
                                            completion(Pet(pID: "ERROR", n: "", b: [""], m: true, a: "", s: "", s2: "", o: [], d: "", m2: [], s3: "", z: "", dis: 0, adoptionFee: ""))
                                            return
                                        }
                                    }
                                }
                                
                                for (key, data) in dict {
                                    if key == "status" {
                                        self.status = data as! String
                                    } else if key == "data" {
                                        for (_, data2) in (data as? [String: AnyObject])! {
                                            let cachedPet = self.createPet(data2)
                                            PetsGlobal[cachedPet.petID] = cachedPet
                                            completion(cachedPet)
                                        }
                                    }
                                }
                            }
                        } catch let error as NSError {
                            // error handling
                            print(error.localizedDescription)
                        }
                    }
                }) 
                task.resume() } catch { }
            }
    }
    
    override func loadPets(bn: Breed, zipCode: String, completion: @escaping (_ p: PetList) -> Void) -> Void {
        super.loadPets(bn: bn, zipCode: zipCode, completion: completion)
        
        if zipCodeGlobal == zipCode  && bnGlobal == bn.BreedName {
            return
        } else {
            zipCodeGlobal = zipCode
            bnGlobal = bn.BreedName
        }
        
        loading = true
        
        dateCreated = Date() //Reset the cache time
        
        if (Utilities.isNetworkAvailable() == false) {
            return
        }
        
        var filters:[filter] = []
        
        filters += filterOptions.getFilters()
        
        filters.append(["fieldName": "animalStatus" as AnyObject, "operation": "notequals" as AnyObject, "criteria": "Adopted" as AnyObject])
        filters.append(["fieldName": "animalSpecies" as AnyObject, "operation": "equals" as AnyObject, "criteria": "cat" as AnyObject])
        filters.append(["fieldName": "animalLocationDistance" as AnyObject, "operation": "radius" as AnyObject, "criteria": distance as AnyObject])
        //print("Distance=\(distance)")
        filters.append(["fieldName": "animalLocation" as AnyObject, "operation": "equals" as AnyObject, "criteria": zipCode as AnyObject])
        if bn.BreedName != "All Breeds" {
            if bn.RescueBreedID == "" {
                //print(bn.BreedName)
                filters.append(["fieldName": "animalPrimaryBreed" as AnyObject, "operation": "contains" as AnyObject, "criteria": bn.BreedName as AnyObject])
            } else {
                //print(bn.RescueBreedID)
                filters.append(["fieldName": "animalPrimaryBreedID" as AnyObject, "operation": "equals" as AnyObject, "criteria": bn.RescueBreedID as AnyObject])
            }
        }
        /*
        print(String(resultStart))
        print(String(resultLimit))
        print("filters=\(filters)")
        */
        /*
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["resultStart": String(resultStart), "resultLimit":String(resultLimit), "resultSort": "animalLocationDistance", "resultOrder": "asc", "calcFoundRows": "Yes", "filters": filters, "fields": ["animalID", "animalOrgID", "animalAltered", "animalBreed", "animalDeclawed", "animalGeneralAge", "animalGeneralSizePotential", "animalHousetrained", "animalLocation", "animalLocationCoordinates", "animalLocationDistance", "animalName", "animalSpecialneeds", "animalOKWithAdults", "animalOKWithCats", "animalOKWithDogs", "animalOKWithKids", "animalPrimaryBreed", "animalRescueID", "animalSex", "animalSizePotential", "animalUpdatedDate", "animalPictures","animalVideoUrls", "animalUptodate", "animalStatus", "animalAdoptedDate", "animalAvailableDate", "animalAdoptionPending", "animalBirthdate", "animalBirthdateExact", "animalApartment", "animalYardRequired", "animalIndoorOutdoor", "animalNoCold", "animalNoHeat", "animalOKForSeniors", "animalActivityLevel", "animalEnergyLevel", "animalExerciseNeeds", "animalNewPeople", "animalVocal", "animalAffectionate", "animalCratetrained", "animalEagerToPlease", "animalEscapes", "animalEventempered", "animalGoodInCar", "animalHousetrained", "animalIntelligent", "animalLap", "animalNeedsCompanionAnimal", "animalPlayful", "animalPlaysToys", "animalPredatory", "animalTimid", "animalCoatLength", "animalEyeColor", "animalGroomingNeeds", "animalShedding", "animalTailType", "animalColor", "animalHearingImpaired", "animalHypoallergenic", "animalMicrochipped", "animalOngoingMedical", "animalSpecialDiet", "animalSpecialneeds"]]] as [String : Any]
        */
        var order = "desc"
        if sortFilter == "animalLocationDistance" {
            order = "asc"
        }
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["resultStart": String(resultStart), "resultLimit":String(resultLimit), "resultSort": sortFilter, "resultOrder": order, "calcFoundRows": "Yes", "filters": filters, "fields": ["animalID", "animalName", "animalBreed", "animalGeneralAge", "animalSex", "animalPrimaryBreed", "animalUpdatedDate", "animalOrgID", "animalLocationDistance" , "animalPictures", "animalStatus", "animalBirthdate", "animalAvailableDate", "animalGeneralSizePotential", "animalVideoUrls"]]] as [String : Any]

        /*
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["resultStart": String(resultStart), "resultLimit":String(resultLimit), "resultSort": "animalUpdatedDate,animalLocationDistance", "resultOrder": "desc,asc", "calcFoundRows": "Yes", "filters": filters, "fields": ["animalID", "animalName", "animalBreed", "animalGeneralAge", "animalSex", "animalPrimaryBreed", "animalUpdatedDate", "animalOrgID", "animalLocationDistance" , "animalPictures", "animalStatus", "animalBirthdate", "animalAvailableDate", "animalGeneralSizePotential", "animalVideoUrls",]]] as [String : Any]
        */
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            let myURL = URL(string: "https://api.rescuegroups.org/http/v2.json")!
            let request = NSMutableURLRequest(url: myURL)
            request.httpMethod = "POST"
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            request.httpBody = jsonData
            
            task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
                data, response, error in
                if error != nil {
                    print("Get Error")
                    Utilities.displayAlert("Sorry There Was A Problem", errorMessage: "An error occurred while trying to display pet data.")
                } else {
                    //var error:NSError?
                    do {
                        let jsonObj:AnyObject =  try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! NSDictionary
                        if let dict = jsonObj as? [String: AnyObject] {
                            for (key, data) in dict {
                                if key == "status" {
                                    self.status = data as! String
                                    print("Status = |\(self.status)|")
                                } else if key == "data" {
                                    if let d = data as? [String: AnyObject] {
                                        for (_, data2) in d {
                                            let cachedPet = self.createPet(data2)
                                            self.Pets.append(cachedPet)
                                            PetsGlobal[cachedPet.petID] = cachedPet
                                        }
                                    }
                                }
                            }
                        }
                        self.resultStart += self.resultLimit
                        self.assignDistances()
                        self.loading = false
                        completion(self)
                    } catch let error as NSError {
                        // error handling
                        Utilities.displayAlert("Sorry There Was A Problem", errorMessage: error.description)
                        print(error.localizedDescription)
                    }
                }
            }) 
            task?.resume() } catch { }
    }
    
    func validateDouble(_ d: AnyObject) -> Double {
        var data: Double
        if d is Double {
            data = d as! Double
        } else {
            data = 0.0
        }
        return data
    }
    
    func validateValue(_ d: AnyObject) -> String {
        var data: String
        if d is String {
            data = d as! String
        } else {
            data = ""
        }
        return data
    }
    
    func createPet(_ p: AnyObject) -> Pet {
        var petID: String?
        var name: String?
        var breeds: Set<String> = Set<String>()
        var age: String?
        var sex: String?
        var size: String?
        var options: Set<String> = Set<String>()
        var description: String?
        var distance: Double = 0.0
        var pictures: [picture] = [picture]()
        var videos: [video] = [video]()
        var sID: String?
        let zipCode: String = ""
        var animalStatus: String?
        var animalAdoptedDate: String?
        var animalAvailableDate: String?
        var animalAdoptionPending: String?
        var animalBirthdate: String?
        var lastUpdated = Date()
        var adoptionFee: String = ""
        description = ""
        //var animalBirthdateExact: String?
        if let dict = p as? [String: AnyObject] {
            for (key, data) in dict {
                switch key {
                case "animalOKWithDogs" : options = hasOption(validateValue(data), option1: "OK With Dogs", option2: "Not OK With Dogs", options: options)
                case "animalPrimaryBreed": breeds.insert(validateValue(data))
                case "animalUpdatedDate": lastUpdated = parseDate(value: validateValue(data))
                case "animalID": petID = validateValue(data)
                case "animalAltered": options = hasOption(validateValue(data), option1: "Spayed/Neutered", option2: "Not Spayed/Neutered", options: options)
                case "animalOKWithAdults": options = hasOption(validateValue(data), option1: "OK With Adults", option2: "Not OK With Adults",  options: options)
                case "animalDescriptionPlain": description = validateValue(data)
                case "animalSpecialneeds": options = hasOption((data as? String)!, option1: "Has Special Needs", option2: "Does not have special needs", options: options)
                    //case "animalBreed": options.insert(data as! String)
                case "animalOKWithCats": options = hasOption(validateValue(data), option1: "OK With Cats", option2: "Not OK with Cats", options: options)
                    case "animalOrgID": sID = validateValue(data)
                case "animalHousetrained": options = hasOption(validateValue(data), option1: "House Trained", option2: "Not House Trained", options: options)
                case "animalOKWithKids": options = hasOption(validateValue(data), option1: "Good with Kids", option2: "Not Good with Kids", options: options)
                case "animalGeneralAge": age = validateValue(data)
                case "animalSex": sex = validateValue(data)
                case "animalGeneralSizePotential": size = validateValue(data)
                case "animalName": name = validateValue(data)
                case "animalPictures": pictures = parsePictures(data as! [AnyObject])
                case "animalVideoUrls": videos = parseVideos(data as! [AnyObject])
                case "animalLocationDistance": distance = validateDouble(data)
                case "animalDeclawed": options = hasOption(validateValue(data), option1: "Declawed", option2: "Has claws",options: options)
                case "animalUptodate": options = hasOption(validateValue(data), option1: "Uptodate", option2: "Not Uptodate", options: options)
                case "animalStatus": animalStatus = validateValue(data)
                case "animalAdoptedDate": animalAdoptedDate = validateValue(data)
                case "animalAvailableDate": animalAvailableDate = validateValue(data)
                case "animalAdoptionPending": animalAdoptionPending = validateValue(data)
                case "animalBirthdate": animalBirthdate = validateValue(data)
                //case "animalBirthdateExact": animalBirthdateExact = validateValue(data)
                case "animalApartment": options = hasOption(validateValue(data), option1: "OK with apartment", option2: "Not OK with apartment", options: options)
                case "animalYardRequired": options = hasOption(validateValue(data), option1: "Requires yard", option2: "Does not require yard", options: options)
                case "animalNoCold": options = hasOption(validateValue(data), option1: "Cold Sensitive", option2: "Not Cold Sensitive", options: options)
                case "animalNoHeat": options = hasOption(validateValue(data), option1: "Heat Sensitive", option2: "Not Heat Sensitive", options: options)
                case "animalOKForSeniors": options = hasOption(validateValue(data), option1: "OK for Seniors", option2: "Not for Seniors", options: options)
                case "animalYardRequired": options = hasOption(validateValue(data), option1: "Yard Required", option2: "Yard Not Required", options: options)
                case "animalAffectionate": options = hasOption(validateValue(data), option1: "Affectionate", option2: "Not Affectionate", options: options)
                case "animalCratetrained": options = hasOption(validateValue(data), option1: "Crate Trained", option2: "Not Crate Trained", options: options)
                case "animalEagerToPlease": options = hasOption(validateValue(data), option1: "Eager to Please", option2: "Not Eager to Please", options: options)
                case "animalEscapes": options = hasOption(validateValue(data), option1: "Escapes", option2: "Does not Escape", options: options)
                case "animalEventempered": options = hasOption(validateValue(data), option1: "Eventempered", option2: "Not Eventempered", options: options)
                case "animalFetches": options = hasOption(validateValue(data), option1: "Fetches", option2: "Does not Fetch", options: options)
                case "animalGentle": options = hasOption(validateValue(data), option1: "Gentle", option2: "Not Gentle", options: options)
                case "animalGoodInCar": options = hasOption(validateValue(data), option1: "Good In Car", option2: "Not Good In Car", options: options)
                case "animalGoofy": options = hasOption(validateValue(data), option1: "Goofy", option2: "Not Goofy", options: options)
                case "animalHousetrained": options = hasOption(validateValue(data), option1: "Housetrained", option2: "Not Housetrained", options: options)
                case "animalIndependent": options = hasOption(validateValue(data), option1: "Independent", option2: "Not Independent", options: options)
                case "animalIntelligent": options = hasOption(validateValue(data), option1: "Intelligent", option2: "Not Intelligent", options: options)
                case "animalLap": options = hasOption(validateValue(data), option1: "Lap", option2: "Not Lap", options: options)
                case "animalLeashtrained": options = hasOption(validateValue(data), option1: "Lease Trained", option2: "Not Lease Trained", options: options)
                case "animalNeedsCompanionAnimal": options = hasOption(validateValue(data), option1: "Needs Companion Animal", option2: "No Companion Animal", options: options)
                case "animalObedient": options = hasOption(validateValue(data), option1: "Obedient", option2: "Not Obedient", options: options)
                case "animalPlayful": options = hasOption(validateValue(data), option1: "Playful", option2: "Not Playful", options: options)
                case "animalPredatory": options = hasOption(validateValue(data), option1: "Predatory", option2: "Not Predatory", options: options)
                    
                    
                    
                case "animalIndoorOutdoor": if (data as! String) != "" {options = hasOption(validateValue(data), option1: data as! String, option2: "", options: options)}
                case "animalActivityLevel": if (data as! String) != "" {options = hasOption(validateValue(data), option1: data as! String, option2: "", options: options)}
                case "animalEnergyLevel": if (data as! String) != "" {options = hasOption(validateValue(data), option1: data as! String, option2: "", options: options)}
                case "animalExerciseNeeds": if (data as! String) != "" {options = hasOption(validateValue(data), option1: data as! String, option2: "", options: options)}
                case "animalNewPeople": if (data as! String) != "" {options = hasOption(validateValue(data), option1: data as! String, option2: "", options: options)}
                case "animalVocal": if (data as! String) != "" {options = hasOption(validateValue(data), option1: data as! String, option2: "", options: options)}
                case "animalTimid": options = hasOption(validateValue(data), option1: "Timid", option2: "Not Timid", options: options)
                case "animalCoatLength": options = hasOption(validateValue(data), option1: " coat length", options: options)
                case "animalEyeColor": options = hasOption(validateValue(data), option1: " eyes", options: options)
                case "animalGroomingNeeds": options = hasOption(validateValue(data), option1: " grooming needs", options: options)
                case "animalShedding": options = hasOption(validateValue(data), option1: " shedding", options: options)
                case "animalTailType": options = hasOption(validateValue(data), option1: " tail", options: options)
                case "animalColor": options = hasOption(validateValue(data), option1: " color coat", options: options)
                case "animalHearingImpaired": options = hasOption(validateValue(data), option1: "Hearing Impaired", option2: "Not Hearing Imparied", options: options)
                case "animalHypoallergenic": options = hasOption(validateValue(data), option1: "Hypoallergenic", option2: "Not Hypoallergenic", options: options)
                case "animalMicrochipped": options = hasOption(validateValue(data), option1: "Microchipped", option2: "Not Microchipped", options: options)
                case "animalOngoingMedical": options = hasOption(validateValue(data), option1: "Has Ongoing Medical Needs", option2: "Does Not Have Ongoing Medical Needs", options: options)
                case "animalSpecialDiet": options = hasOption(validateValue(data), option1: "Has A Special Diet", option2: "Does Not Have A Special Diet", options: options)
                case "animalAdoptionFee":
                    adoptionFee = validateValue(data)
                    if adoptionFee != "" {
                        print("adoption Fee \(adoptionFee)")
                    }
                default: break
                }
            }
        }
        var status: String = ""
        if animalAdoptionPending == "Yes" {
            status = "Adoption Pending"
        } else if animalStatus == "Adopted" {
            status = animalStatus! + " " + animalAdoptedDate!
        } else if animalStatus == "Available" {
            status = animalStatus! + " " + animalAvailableDate!
        }
        
        if adoptionFee != "" {
            status += "<BR/><BR/>Adoption Fee: \(adoptionFee)"
        }
        
        let p = Pet(pID: petID!, n: name!, b: breeds, m: false, a: age!, s: sex!, s2: size!, o: options, d: description!, m2: pictures, v: videos, s3: sID!, z: zipCode, dis: distance, stat: status, bd: animalBirthdate!, upd: lastUpdated, adoptionFee: adoptionFee)
        return p
    }
}

func parseDate(value: String) -> Date {
    let dateFormatter = DateFormatter()
    let date: Date
    dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss Z"
    
    guard dateFormatter.date(from: value) != nil else {
        return Date()
    }
    
    date = dateFormatter.date(from: value)!
    
    return date
}

func hasOption(_ optionValue: String, option1:  String, option2: String, options: Set<String>) -> Set<String> {
    var opts = Set<String>()
    opts = options
    if optionValue == "Yes" {
        opts.insert(option1)
    } else if optionValue == "No" {
        opts.insert(option2)
    }
    return opts
}

func hasOption(_ optionValue: String, option1:  String, options: Set<String>) -> Set<String> {
    var opts = Set<String>()
    opts = options
    if optionValue != "" {
        opts.insert("\(optionValue) \(option1)")
    }
    return opts
}

func parsePictures(_ data: [AnyObject]) -> [picture] {
    var pictures: [picture] = [picture]()
    var id = 1
    var d: Any?
    var i = 0
    
    while i < (data as [AnyObject]).count {
        d = data[i] as! [String: AnyObject]
        if let dict = d as? [String: AnyObject] {
            for (key, data2) in dict {
                switch key {
                case "large": pictures.append(parsePicture(id, data: data2))
                case "original": pictures.append(parsePicture(id, data: data2))
                case "small": pictures.append(parsePicture(id, data: data2))
                default: break
                }
            }
        }
        id += 1
        i += 1
    }
    return pictures
}

func parsePicture(_ id: Int, data: AnyObject) -> picture {
    var type: String?
    var url: String?
    if let dict = data as? [String: AnyObject] {
        for (key, data) in dict {
            switch key {
                case "type": type = convert((data as? String)!)
                case "url": url = data as? String
            default: break
            }
        }
    }
    return picture(i: id, s: type!, u: url!)
}


func convert(_ size: String) -> String {
    var s = ""
    switch size {
        case "Large": s = "x"
        case "Original": s = "pn"
        case "Small": s = "pnt"
    default: break
    }
    return s
}

func parseVideos(_ data: [AnyObject]) -> [video] {
    var videos: [video] = [video]()
    var i = 0
    var d: Any?
    while i < data.count {
        d = data[i]
        if let dict = d as? [String: AnyObject] {
            videos.append(parseVideo(dict as AnyObject))
        }
        i += 1
    }
    return videos
}

func parseVideo(_ data: AnyObject) -> video {
    var mediaID: String?
    var mediaOrder: String?
    var urlThumbnail: String?
    var videoID: String?
    var videoUrl: String?
    if let dict = data as? [String: AnyObject] {
        for (key, data) in dict {
            switch key {
            case "mediaID": mediaID = data as? String
            case "mediaOrder": mediaOrder = data as? String
            case "urlThumbnail": urlThumbnail = data as? String
            case "videoID": videoID = data as? String
            case "videoUrl": videoUrl = data as? String
            default: break
            }
        }
    }
    return video(i: mediaID!, o: mediaOrder!, t: urlThumbnail!, v: videoID!, u: videoUrl!)
}

struct RescuePetTags {
    static let RESCUE_TAG = "data"
    static let PETS_TAG = "pets"
    static let PET_TAG = "pet"
    static let ID_TAG = "id"
    static let T_TAG = "$t"
    static let NAME_TAG = "name"
    static let BREEDS_TAG = "breeds"
    static let BREED_TAG = "breed"
    static let MIX_TAG = "mix"
    static let SEX_TAG = "sex"
    static let SIZE_TAG = "size"
    static let AGE_TAG = "age"
    static let OPTIONS_TAG = "options"
    static let OPTION_TAG = "option"
    static let DESCRIPTION_TAG = "description"
    static let LASTUPDATE_TAG = "lastUpdate"
    static let SHELTERID_TAG = "shelterId"
    static let MEDIA_TAG = "media"
    static let PHOTOS_TAG = "photos"
    static let PHOTO_TAG = "photo"
    static let LASTOFFSET_TAG = "lastOffset"
    static let ATID_TAG = "@id"
    static let ATSIZE_TAG = "@size"
    static let CONTACT_TAG = "contact"
    static let ZIP_TAG = "zip"
}
