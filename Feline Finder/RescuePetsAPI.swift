//
//  RescuePetsAPI.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/1/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation

class RescuePetList: PetList {
    var resultStart: Int = 0
    var resultLimit: Int = 25
    override func loadSinglePet(petID: String, completion: (Pet) -> Void) -> Void {
        super.loadSinglePet(petID, completion: completion)
        if let p2 = PetsGlobal[petID] {
            //Supposed to refresh the PetFinder data every 24 hours
            let hoursSinceCreation = NSCalendar.currentCalendar().components(NSCalendarUnit.Hour, fromDate: p2.dateCreated, toDate: NSDate(), options: []).hour
            if hoursSinceCreation < 24 {
                completion(p2)
                return
            }
        }
        
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["resultStart": "0", "resultLimit":"100", "resultSort": "animalLocationDistance", "resultOrder": "asc", "calcFoundRows": "Yes", "filters": [["fieldName": "animalSpecies", "operation": "equals", "criteria": "cat"],["fieldName": "animalID", "operation": "equals", "criteria": splitPetID(petID)]], "fields": ["animalID","animalOrgID","animalAltered","animalBreed","animalDeclawed","animalDescription","animalDescriptionPlain","animalGeneralAge","animalGeneralSizePotential","animalHousetrained","animalLocation","animalLocationCoordinates","animalLocationDistance","animalName","animalSpecialneeds","animalSpecialneedsDescription","animalOKWithAdults","animalOKWithCats","animalOKWithDogs","animalOKWithKids","animalPrimaryBreed","animalRescueID","animalSex","animalSizePotential","animalUpdatedDate","animalPictures","animalVideoUrls","animalUptodate","animalStatus","animalAdoptedDate","animalAvailableDate","animalAdoptionPending","animalBirthdate", "animalBirthdateExact"]]]
        
        if Utilities.isNetworkAvailable() {
            do {
                
                let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
                
                let myURL = NSURL(string: "https://api.rescuegroups.org/http/v2.json")!
                let request = NSMutableURLRequest(URL: myURL)
                request.HTTPMethod = "POST"
                
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                request.HTTPBody = jsonData
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                    data, response, error in
                    if error != nil {
                        print("Get Error")
                    } else {
                        //var error:NSError?
                        do {
                            let jsonObj:AnyObject =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as! NSDictionary
                            
                            if let dict = jsonObj as? [String: AnyObject] {
                                for (key, data) in dict {
                                    if key == "data" {
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
                }
                task.resume() } catch { }
            }
    }
    
    override func loadPets(tv: UITableView, bn: Breed, zipCode: String, completion: (p: PetList) -> Void) -> Void {
        super.loadPets(tv, bn: bn, zipCode: zipCode, completion: completion)
        
        loading = true
        
        dateCreated = NSDate() //Reset the cache time
        
        if (Utilities.isNetworkAvailable() == false) {
            return
        }
        
        var filters:[filter] = []
        
        filters.append(["fieldName": "animalStatus", "operation": "notequals", "criteria": "Adopted"])
        filters.append(["fieldName": "animalSpecies", "operation": "equals", "criteria": "cat"])
        filters.append(["fieldName": "animalLocationDistance", "operation": "radius", "criteria": "3000"])
        filters.append(["fieldName": "animalLocation", "operation": "equals", "criteria": zipCode])
        if bn.BreedName != "All Breeds" {
            if bn.RescueBreedID == "" {
                print(bn.BreedName)
                filters.append(["fieldName": "animalPrimaryBreed", "operation": "contains", "criteria": bn.BreedName])
            } else {
                print(bn.RescueBreedID)
                filters.append(["fieldName": "animalPrimaryBreedID", "operation": "equals", "criteria": bn.RescueBreedID])
            }
        }
        filters += filterOptions.getFilters()
        print(String(resultStart))
        print(String(resultLimit))
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["resultStart": String(resultStart), "resultLimit":String(resultLimit), "resultSort": "animalLocationDistance", "resultOrder": "asc", "calcFoundRows": "Yes", "filters": filters, "fields": ["animalID", "animalOrgID", "animalAltered", "animalBreed", "animalDeclawed", "animalDescriptionPlain","animalGeneralAge","animalGeneralSizePotential","animalHousetrained","animalLocation","animalLocationCoordinates","animalLocationDistance","animalName","animalSpecialneeds","animalSpecialneedsDescription","animalOKWithAdults","animalOKWithCats","animalOKWithDogs","animalOKWithKids","animalPrimaryBreed","animalRescueID","animalSex","animalSizePotential","animalUpdatedDate","animalPictures","animalVideoUrls","animalUptodate","animalStatus","animalAdoptedDate","animalAvailableDate","animalAdoptionPending","animalBirthdate", "animalBirthdateExact"]]]
        
        do {
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            
            let myURL = NSURL(string: "https://api.rescuegroups.org/http/v2.json")!
            let request = NSMutableURLRequest(URL: myURL)
            request.HTTPMethod = "POST"
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            request.HTTPBody = jsonData
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
                if error != nil {
                    print("Get Error")
                    Utilities.displayAlert("Sorry There Was A Problem", errorMessage: error!.description)
                } else {
                    //var error:NSError?
                    do {
                        let jsonObj:AnyObject =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as! NSDictionary
                        if let dict = jsonObj as? [String: AnyObject] {
                            for (key, data) in dict {
                                if key == "data" {
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
                        completion(p: self)
                    } catch let error as NSError {
                        // error handling
                        Utilities.displayAlert("Sorry There Was A Problem", errorMessage: error.description)
                        print(error.localizedDescription)
                    }
                }
            }
            task.resume() } catch { }
    }
    
    func validateDouble(d: AnyObject) -> Double {
        var data: Double
        if d is Double {
            data = d as! Double
        } else {
            data = 0.0
        }
        return data
    }
    
    func validateValue(d: AnyObject) -> String {
        var data: String
        if d is String {
            data = d as! String
        } else {
            data = ""
        }
        return data
    }
    
    func createPet(p: AnyObject) -> Pet {
        var petID: String?
        var name: String?
        var breeds: Set<String> = Set<String>()
        var age: String?
        var sex: String?
        var size: String?
        var options: Set<String> = Set<String>()
        var description: String?
        var lastUpdated: String?
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
        var animalBirthdateExact: String?
        if let dict = p as? [String: AnyObject] {
            for (key, data) in dict {
                switch key {
                case "animalOKWithDogs" : options = hasOption(validateValue(data), option1: "OK With Dogs", option2: "Not OK With Dogs", options: options)
                    case "animalPrimaryBreed": breeds.insert(validateValue(data))
                    case "animalUpdatedDate": lastUpdated = validateValue(data)
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
                    case "animalPictures": pictures = parsePictures(data)
                    case "animalVideoUrls": videos = parseVideos(data)
                case "animalLocationDistance": distance = validateDouble(data)
                    case "animalDeclawed": options = hasOption(validateValue(data), option1: "Declawed", option2: "Has claws",options: options)
                case "animalUptodate": options = hasOption(validateValue(data), option1: "Uptodate", option2: "Not Uptodate", options: options)
                case "animalStatus": animalStatus = validateValue(data)
                case "animalAdoptedDate": animalAdoptedDate = validateValue(data)
                case "animalAvailableDate": animalAvailableDate = validateValue(data)
                case "animalAdoptionPending": animalAdoptionPending = validateValue(data)
                case "animalBirthdate": animalBirthdate = validateValue(data)
                case "animalBirthdateExact": animalBirthdateExact = validateValue(data)
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

        let p = Pet(pID: petID!, n: name!, b: breeds, m: false, a: age!, s: sex!, s2: size!, o: options, d: description!, lu: lastUpdated!, m2: pictures, v: videos, s3: sID!, z: zipCode, dis: distance, stat: status, bd: animalBirthdate!)
        return p
    }
}

func hasOption(optionValue: String, option1:  String, option2: String, options: Set<String>) -> Set<String> {
    var opts = Set<String>()
    opts = options
    if optionValue == "Yes" {
        opts.insert(option1)
    } else if optionValue == "No" {
        opts.insert(option2)
    }
    return opts
}

func parsePictures(data: AnyObject) -> [picture] {
    var pictures: [picture] = [picture]()
    var id = 1
    var d: AnyObject?
    var i = 0
    
    while i < data.count {
        d = data[i]
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

func parsePicture(id: Int, data: AnyObject) -> picture {
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


func convert(size: String) -> String {
    var s = ""
    switch size {
        case "Large": s = "x"
        case "Original": s = "pn"
        case "Small": s = "pnt"
    default: break
    }
    return s
}

func parseVideos(data: AnyObject) -> [video] {
    var videos: [video] = [video]()
    var i = 0
    var d: AnyObject?
    while i < data.count {
        d = data[i]
        if let dict = d as? [String: AnyObject] {
            videos.append(parseVideo(dict))
        }
        i += 1
    }
    return videos
}

func parseVideo(data: AnyObject) -> video {
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