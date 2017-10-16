//
//  RescuePetsAPI2.swift
//  Feline Finder
//
//  Created by gregoryew1 on 9/21/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit

struct messages: Codable {
    var generalMessages: [String]
    var recordMessages: [String]
}

struct video2: Codable {
    var mediaID: String?
    var mediaOrder: String?
    var videoUrl: String?
    var videoID: String?
    var urlThumbnail: String?
}

struct picture2: Codable {
    var type: String?
    var fileSize: String?
    var resolutionX: String?
    var resolutionY: String?
    var url: String?
}

struct animalPicture: Codable {
    var mediaID: String?
    var mediaOrder: String?
    var lastUpdated: String?
    var fileSize: String?
    var resolutionX: String?
    var resolutionY: String?
    var fileNameFullsize: String?
    var fileNameThumbnail: String?
    var urlSecureFullsize: String?
    var urlSecureThumbnail: String?
    var urlInsecureFullsize: String?
    var urlInsecureThumbnail: String?
    var original: picture2?
    var large: picture2?
    var small: picture2?
}

struct cat: Codable {
    var animalID: String?
    var animalName: String?
    var animalBreed: String?
    var animalGeneralAge: String?
    var animalSex: String?
    var animalPrimaryBreed: String?
    var animalOrgID: String?
    var animalLocationDistance: Int?
    var animalStatus: String?
    var animalBirthdate: String?
    var animalAvailableDate: String?
    var animalGeneralSizePotential: String?
    var animalAltered: String?
    var animalDeclawed: String?
    var animalDescription: String?
    var animalDescriptionPlain: String?
    var animalHousetrained: String?
    var animalLocationCoordinates: String?
    var animalSpecialneeds: String?
    var animalSpecialneedsDescription: String?
    var animalOKWithAdults: String?
    var animalOKWithCats: String?
    var animalOKWithDogs: String?
    var animalOKWithKids: String?
    var animalRescueID: String?
    var animalSizePotential: String?
    var animalUpdatedDate: String?
    var animalPictures: [animalPicture]?
    var animalVideoUrls: [video2]?
    var animalUptodate: String?
    var animalAdoptedDate: String?
    var animalAdoptionPending: String?
    var animalBirthdateExact: String?
    var animalApartment: String?
    var animalYardRequired: String?
    var animalIndoorOutdoor: String?
    var animalNoCold: String?
    var animalNoHeat: String?
    var animalOKForSeniors: String?
    var animalActivityLevel: String?
    var animalEnergyLevel: String?
    var animalExerciseNeeds: String?
    var animalNewPeople: String?
    var animalVocal: String?
    var animalAffectionate: String?
    var animalCratetrained: String?
    var animalEagerToPlease: String?
    var animalEscapes: String?
    var animalEventempered: String?
    var animalGoodInCar: String?
    var animalIntelligent: String?
    var animalLap: String?
    var animalNeedsCompanionAnimal: String?
    var animalPlayful: String?
    var animalPlaysToys: String?
    var animalPredatory: String?
    var animalTimid: String?
    var animalCoatLength: String?
    var animalEyeColor: String?
    var animalGroomingNeeds: String?
    var animalShedding: String?
    var animalTailType: String?
    var animalColor: String?
    var animalHearingImpaired: String?
    var animalHypoallergenic: String?
    var animalMicrochipped: String?
    var animalSpecialDiet: String?
    var animalAdoptionFee: String?
    var animalLocationCitystate: String?
    var animalFetches: String?
    var animalGentle: String?
    var animalGoofy: String?
    var animalIndependent: String?
    var animalLeashtrained: String?
    var adoptionFee: String?
    var animalObedient: String?
    var animalOngoingMedical: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        do {
        animalID = try values.decode(String.self, forKey: .animalID)
        } catch {
            animalID = nil
        }

        do {
            animalName = try values.decode(String.self, forKey: .animalName)
        } catch {
            animalName = nil
        }

        do {
            animalBreed = try values.decode(String.self, forKey: .animalBreed)
        } catch {
            animalBreed = nil
        }
        
        do {
            animalGeneralAge = try values.decode(String.self, forKey: .animalGeneralAge)
        } catch {
            animalGeneralAge = nil
        }

        do {
            animalSex = try values.decode(String.self, forKey: .animalSex)
        } catch {
            animalSex = nil
        }
        
        do {
            animalPrimaryBreed = try values.decode(String.self, forKey: .animalPrimaryBreed)
        } catch {
            animalPrimaryBreed = nil
        }

        do {
            animalOrgID = try values.decode(String.self, forKey: .animalOrgID)
        } catch {
            animalOrgID = nil
        }

        do {
            animalLocationDistance = try values.decode(Int.self, forKey: .animalLocationDistance)
        } catch {
            animalLocationDistance = nil
        }

        do {
            animalStatus = try values.decode(String.self, forKey: .animalStatus)
        } catch {
            animalStatus = nil
        }

        do {
            animalBirthdate = try values.decode(String.self, forKey: .animalBirthdate)
        } catch {
            animalBirthdate = nil
        }

        do {
            animalAvailableDate = try values.decode(String.self, forKey: .animalAvailableDate)
        } catch {
            animalAvailableDate = nil
        }

        do {
            animalGeneralSizePotential = try values.decode(String.self, forKey: .animalGeneralSizePotential)
        } catch {
            animalGeneralSizePotential = nil
        }

        do {
            animalAltered = try values.decode(String.self, forKey: .animalAltered)
        } catch {
            animalAltered = nil
        }

        do {
            animalDeclawed = try values.decode(String.self, forKey: .animalDeclawed)
        } catch {
            animalDeclawed = nil
        }

        do {
            animalDescription = try values.decode(String.self, forKey: .animalDescription)
        } catch {
            animalDescription = nil
        }

        do {
            animalDescriptionPlain = try values.decode(String.self, forKey: .animalDescriptionPlain)
        } catch {
            animalDescription = nil
        }

        do {
            animalHousetrained = try values.decode(String.self, forKey: .animalHousetrained)
        } catch {
            animalHousetrained = nil
        }

        do {
            animalLocationCoordinates = try values.decode(String.self, forKey: .animalLocationCoordinates)
        } catch {
            animalLocationCoordinates = nil
        }

        do {
            animalSpecialneeds = try values.decode(String.self, forKey: .animalSpecialneeds)
        } catch {
            animalSpecialneeds = nil
        }

        do {
            animalSpecialneedsDescription = try values.decode(String.self, forKey: .animalSpecialneedsDescription)
        } catch {
            animalSpecialneedsDescription = nil
        }

        do {
            animalOKWithAdults = try values.decode(String.self, forKey: .animalOKWithAdults)
        } catch {
            animalOKWithAdults = nil
        }

        do {
            animalOKWithCats = try values.decode(String.self, forKey: .animalOKWithCats)
        } catch {
            animalOKWithCats = nil
        }

        do {
            animalOKWithDogs = try values.decode(String.self, forKey: .animalOKWithDogs)
        } catch {
            animalOKWithDogs = nil
        }

        do {
            animalOKWithKids = try values.decode(String.self, forKey: .animalOKWithKids)
        } catch {
            animalOKWithKids = nil
        }

        do {
            animalRescueID = try values.decode(String.self, forKey: .animalRescueID)
        } catch {
            animalRescueID = nil
        }

        do {
            animalSizePotential = try values.decode(String.self, forKey: .animalSizePotential)
        } catch {
            animalSizePotential = nil
        }

        do {
            animalUpdatedDate = try values.decode(String.self, forKey: .animalUpdatedDate)
        } catch {
            animalUpdatedDate = nil
        }

        do {
            animalPictures = try values.decode([animalPicture].self, forKey: .animalPictures)
        } catch {
            animalPictures = nil
        }
        
        do {
            animalVideoUrls = try values.decode([video2].self, forKey: .animalVideoUrls)
        } catch {
            animalVideoUrls = nil
        }

        do {
            animalUptodate = try values.decode(String.self, forKey: .animalUpdatedDate)
        } catch {
            animalUptodate = nil
        }

        do {
            animalAdoptedDate = try values.decode(String.self, forKey: .animalAdoptedDate)
        } catch {
            animalAdoptedDate = nil
        }

        do {
            animalAdoptionPending = try values.decode(String.self, forKey: .animalAdoptionPending)
        } catch {
            animalAdoptionPending = nil
        }

        do {
            animalBirthdateExact = try values.decode(String.self, forKey: .animalBirthdateExact)
        } catch {
            animalBirthdateExact = nil
        }

        do {
            animalApartment = try values.decode(String.self, forKey: .animalApartment)
        } catch {
            animalApartment = nil
        }

        do {
            animalYardRequired = try values.decode(String.self, forKey: .animalYardRequired)
        } catch {
            animalYardRequired = nil
        }

        do {
            animalIndoorOutdoor = try values.decode(String.self, forKey: .animalIndoorOutdoor)
        } catch {
            animalIndoorOutdoor = nil
        }

        do {
            animalNoCold = try values.decode(String.self, forKey: .animalNoCold)
        } catch {
            animalNoCold = nil
        }

        do  {
            animalNoHeat = try values.decode(String.self, forKey: .animalNoHeat)
        } catch {
            animalNoHeat = nil
        }

        do {
            animalOKForSeniors = try values.decode(String.self, forKey: .animalOKForSeniors)
        } catch {
            animalOKForSeniors = nil
        }

        do  {
            animalActivityLevel = try values.decode(String.self, forKey: .animalActivityLevel)
        } catch {
            animalActivityLevel = nil
        }

        do {
            animalEnergyLevel = try values.decode(String.self, forKey: .animalEnergyLevel)
        } catch {
            animalEnergyLevel = nil
        }

        do {
            animalExerciseNeeds = try values.decode(String.self, forKey: .animalExerciseNeeds)
        } catch {
            animalExerciseNeeds = nil
        }

        do {
            animalNewPeople = try values.decode(String.self, forKey: .animalNewPeople)
        } catch {
            animalNewPeople = nil
        }

        do {
            animalVocal = try values.decode(String.self, forKey: .animalVocal)
        } catch {
            animalVocal = nil
        }

        do {
            animalAffectionate = try values.decode(String.self, forKey: .animalAffectionate)
        } catch {
            animalAffectionate = nil
        }

        do {
            animalCratetrained = try values.decode(String.self, forKey: .animalCratetrained)
        } catch {
            animalCratetrained = nil
        }

        do {
            animalEagerToPlease = try values.decode(String.self, forKey: .animalEagerToPlease)
        } catch {
            animalEagerToPlease = nil
        }
        
        do {
            animalEscapes = try values.decode(String.self, forKey: .animalEscapes)
        } catch {
            animalEscapes = nil
        }
        
        do {
            animalEventempered = try values.decode(String.self, forKey: .animalEventempered)
        } catch {
            animalEventempered = nil
        }
        
        do {
            animalGoodInCar = try values.decode(String.self, forKey: .animalGoodInCar)
        } catch {
            animalGoodInCar = nil
        }
        
        do {
            animalIntelligent = try values.decode(String.self, forKey: .animalIntelligent)
        } catch {
            animalIntelligent = nil
        }
        
        do {
            animalLap = try values.decode(String.self, forKey: .animalLap)
        } catch {
            animalLap = nil
        }
        
        do {
            animalNeedsCompanionAnimal = try values.decode(String.self, forKey: .animalNeedsCompanionAnimal)
        } catch {
            animalNeedsCompanionAnimal = nil
        }
        
        do {
            animalPlayful = try values.decode(String.self, forKey: .animalPlayful)
        } catch {
            animalPlayful = nil
        }
        
        do {
            animalPlaysToys = try values.decode(String.self, forKey: .animalPlaysToys)
        } catch {
            animalPlaysToys = nil
        }
        
        do {
            animalPredatory = try values.decode(String.self, forKey: .animalPredatory)
        } catch {
            animalPredatory = nil
        }
        
        do {
            animalTimid = try values.decode(String.self, forKey: .animalTimid)
        } catch {
            animalTimid = nil
        }
        
        do {
            animalCoatLength = try values.decode(String.self, forKey: .animalCoatLength)
        } catch {
            animalCoatLength = nil
        }
        
        do {
            animalEyeColor = try values.decode(String.self, forKey: .animalEyeColor)
        } catch {
            animalEyeColor = nil
        }
        
        do {
            animalGroomingNeeds = try values.decode(String.self, forKey: .animalGroomingNeeds)
        } catch {
            animalGroomingNeeds = nil
        }
        
        do {
            animalShedding = try values.decode(String.self, forKey: .animalShedding)
        } catch {
            animalShedding = nil
        }
        
        do {
            animalTailType = try values.decode(String.self, forKey: .animalTailType)
        } catch {
            animalTailType = nil
        }
        
        do {
            animalColor = try values.decode(String.self, forKey: .animalColor)
        } catch {
            animalColor = nil
        }
        
        do {
            animalHearingImpaired = try values.decode(String.self, forKey: .animalHearingImpaired)
        } catch {
            animalHearingImpaired = nil
        }
        
        do {
            animalHypoallergenic = try values.decode(String.self, forKey: .animalHypoallergenic)
        } catch {
            animalHypoallergenic = nil
        }
        
        do {
            animalMicrochipped = try values.decode(String.self, forKey: .animalMicrochipped)
        } catch {
            animalMicrochipped = nil
        }
        
        do {
            animalSpecialDiet = try values.decode(String.self, forKey: .animalSpecialDiet)
        } catch {
            animalSpecialDiet = nil
        }
        
        do {
            animalAdoptionFee = try values.decode(String.self, forKey: .animalAdoptionFee)
        } catch {
            animalAdoptionFee = nil
        }
        
        do {
            animalLocationCitystate = try values.decode(String.self, forKey: .animalLocationCitystate)
        } catch {
            animalLocationCitystate = nil
        }
        
        do {
            animalFetches = try values.decode(String.self, forKey: .animalFetches)
        } catch {
            animalFetches = nil
        }
        
        do {
            animalGentle = try values.decode(String.self, forKey: .animalGentle)
        } catch {
            animalGentle = nil
        }
        
        do {
            animalGoofy = try values.decode(String.self, forKey: .animalGoofy)
        } catch {
            animalGoofy = nil
        }
        
        do {
            animalIndependent = try values.decode(String.self, forKey: .animalIndependent)
        } catch {
            animalIndependent = nil
        }
        
        do {
            animalLeashtrained = try values.decode(String.self, forKey: .animalLeashtrained)
        } catch {
            animalLeashtrained = nil
        }
        
        do {
            adoptionFee = try values.decode(String.self, forKey: .animalAdoptionFee)
        } catch {
            adoptionFee = nil
        }
        
        do {
            animalObedient = try values.decode(String.self, forKey: .animalObedient)
        } catch {
            animalObedient = nil
        }
        
        do {
            animalOngoingMedical = try values.decode(String.self, forKey: .animalOngoingMedical)
        } catch {
            animalOngoingMedical = nil
        }
    }
}

struct cats: Codable {
    var status: String
    var messages: messages
    var foundRows: Int
    var data: [Int: cat]
}

class RescuePetList2: PetList {
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
        
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["resultStart": "0", "resultLimit":"100", "resultSort": "animalLocationDistance", "resultOrder": "asc", "calcFoundRows": "Yes", "filters": [["fieldName": "animalSpecies", "operation": "equals", "criteria": "cat"],["fieldName": "animalID", "operation": "equals", "criteria": splitPetID(petID)]], "fields": ["animalID","animalOrgID","animalAltered","animalBreed","animalDeclawed","animalDescription","animalDescriptionPlain","animalGeneralAge","animalGeneralSizePotential","animalHousetrained","animalLocation","animalLocationCoordinates","animalLocationDistance","animalName","animalSpecialneeds","animalSpecialneedsDescription","animalOKWithAdults","animalOKWithCats","animalOKWithDogs","animalOKWithKids","animalPrimaryBreed","animalRescueID","animalSex","animalSizePotential","animalUpdatedDate","animalPictures","animalVideoUrls","animalUptodate","animalStatus","animalAdoptedDate","animalAvailableDate","animalAdoptionPending","animalBirthdate", "animalBirthdateExact",      "animalApartment", "animalYardRequired","animalIndoorOutdoor","animalNoCold", "animalNoHeat", "animalOKForSeniors", "animalActivityLevel", "animalEnergyLevel", "animalExerciseNeeds", "animalNewPeople", "animalVocal", "animalAffectionate", "animalCratetrained", "animalEagerToPlease", "animalEscapes", "animalEventempered", "animalGoodInCar", "animalHousetrained", "animalIntelligent", "animalLap", "animalNeedsCompanionAnimal", "animalPlayful", "animalPlaysToys", "animalPredatory", "animalTimid", "animalCoatLength", "animalEyeColor", "animalGroomingNeeds", "animalShedding", "animalTailType", "animalColor", "animalHearingImpaired", "animalHypoallergenic", "animalMicrochipped", "animalOngoingMedical", "animalSpecialDiet", "animalSpecialneeds", "animalAdoptionFee", "animalLocationCitystate"]]] as [String : Any]
        
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
                            
                            let jsonDecoder = JSONDecoder()
                            let Cats = try jsonDecoder.decode(cats.self, from: data!)
  
                            let cachedPet = self.createPet((Cats.data.first?.value)!)
                                PetsGlobal[cachedPet.petID] = cachedPet
                                completion(cachedPet)

                        } catch let error as NSError {
                            // error handling
                            print(error)
                        }
                    }
                })
                task.resume() } catch { }
        }
    }
    
    override func loadPets(bn: Breed, zipCode: String, completion: @escaping (_ p: PetList) -> Void) -> Void {
        super.loadPets(bn: bn, zipCode: zipCode, completion: completion)
        
        let methodStart = Date()
        
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
        filters.append(["fieldName": "animalLocation" as AnyObject, "operation": "equals" as AnyObject, "criteria": zipCode as AnyObject])
        if bn.BreedName != "All Breeds" {
            if bn.RescueBreedID == "" {
                filters.append(["fieldName": "animalPrimaryBreed" as AnyObject, "operation": "contains" as AnyObject, "criteria": bn.BreedName as AnyObject])
            } else {
                filters.append(["fieldName": "animalPrimaryBreedID" as AnyObject, "operation": "equals" as AnyObject, "criteria": bn.RescueBreedID as AnyObject])
            }
        }
        var order = "desc"
        if sortFilter == "animalLocationDistance" {
            order = "asc"
        }
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["resultStart": String(resultStart), "resultLimit":String(resultLimit), "resultSort": sortFilter, "resultOrder": order, "calcFoundRows": "Yes", "filters": filters, "fields": ["animalID", "animalName", "animalBreed", "animalGeneralAge", "animalSex", "animalPrimaryBreed", "animalUpdatedDate", "animalOrgID", "animalLocationDistance" , "animalLocationCitystate", "animalPictures", "animalStatus", "animalBirthdate", "animalAvailableDate", "animalGeneralSizePotential", "animalVideoUrls"]]] as [String : Any]
        
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

                        let queryFinish = Date()
                        let executionTime2 = queryFinish.timeIntervalSince(methodStart)
                        print("Query Execution time: \(executionTime2)")
                        
                        let jsonDecoder = JSONDecoder()
                        let Cats = try jsonDecoder.decode(cats.self, from: data!)

                        print("Status = |\(Cats.status)|")
                        
                        for (_, cat) in Cats.data {
                            let cachedPet = self.createPet(cat)
                            self.Pets.append(cachedPet)
                            PetsGlobal[cachedPet.petID] = cachedPet
                        }
                        self.resultStart += self.resultLimit
                        self.assignDistances()
                        self.loading = false
                        self.status = Cats.status
                        
                        let Finish = Date()
                        let executionTime3 = Finish.timeIntervalSince(methodStart)
                        print("Decode Finished: \(executionTime3)")
                        
                        completion(self)
                    }
                     catch let error as NSError {
                        // error handling
                        print(error)
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
    
    func createPet(_ p: cat) -> Pet {
        var breeds = Set<String>()
        
        breeds.insert(p.animalPrimaryBreed!)

        let pictures = parsePictures(p.animalPictures!)
        let videos = parseVideos(p.animalVideoUrls!)
        //let videos: [video] = []
        
        var status: String = ""
        if p.animalAdoptionPending == "Yes" {
            status = "Adoption Pending"
        } else if p.animalStatus == "Adopted" {
            status = p.animalStatus! + " " + p.animalAdoptedDate!
        } else if p.animalStatus == "Available" {
            status = p.animalStatus! + " " + p.animalAvailableDate!
        }
        
        /*
        if p.adoptionFee != "" {
            status += " Adoption Fee: \(p.adoptionFee!)"
        }
        */
 
        var options = Set<String>()
 
        if p.animalIndoorOutdoor != "" {options = hasOption(p.animalIndoorOutdoor, option1: p.animalIndoorOutdoor, option2: "", options: options)}
        if p.animalActivityLevel != "" {options = hasOption(p.animalActivityLevel, option1: p.animalActivityLevel, option2: "", options: options)}
        if p.animalEnergyLevel != "" {options = hasOption(p.animalEnergyLevel, option1: p.animalEnergyLevel, option2: "", options: options)}
        if p.animalExerciseNeeds != "" {options = hasOption(p.animalExerciseNeeds, option1: p.animalExerciseNeeds, option2: "", options: options)}
        if p.animalNewPeople != "" {options = hasOption(p.animalNewPeople, option1: p.animalNewPeople, option2: "", options: options)}
        if p.animalVocal != "" {options = hasOption(p.animalVocal, option1: p.animalVocal, option2: "", options: options)}
        
        options = hasOption(p.animalOKWithDogs, option1: "OK With Dogs", option2: "Not OK With Dogs", options: options)
        options = hasOption(p.animalAltered, option1: "Spayed/Neutered", option2: "Not Spayed/Neutered", options: options)
        options = hasOption(p.animalOKWithAdults, option1: "OK With Adults", option2: "Not OK With Adults",  options: options)
        options = hasOption(p.animalSpecialneeds, option1: "Has Special Needs", option2: "Does not have special needs", options: options)
        options = hasOption(p.animalOKWithCats, option1: "OK With Cats", option2: "Not OK with Cats", options: options)
        options = hasOption(p.animalHousetrained, option1: "House Trained", option2: "Not House Trained", options: options)
        options = hasOption(p.animalOKWithKids, option1: "Good with Kids", option2: "Not Good with Kids", options: options)
        options = hasOption(p.animalDeclawed, option1: "Declawed", option2: "Has claws",options: options)
        options = hasOption(p.animalUptodate, option1: "Uptodate", option2: "Not Uptodate", options: options)
        options = hasOption(p.animalApartment, option1: "OK with apartment", option2: "Not OK with apartment", options: options)
        options = hasOption(p.animalYardRequired, option1: "Requires yard", option2: "Does not require yard", options: options)
        options = hasOption(p.animalNoCold, option1: "Cold Sensitive", option2: "Not Cold Sensitive", options: options)
        options = hasOption(p.animalNoHeat, option1: "Heat Sensitive", option2: "Not Heat Sensitive", options: options)
        options = hasOption(p.animalOKForSeniors, option1: "OK for Seniors", option2: "Not for Seniors", options: options)
        options = hasOption(p.animalYardRequired, option1: "Yard Required", option2: "Yard Not Required", options: options)
        options = hasOption(p.animalAffectionate, option1: "Affectionate", option2: "Not Affectionate", options: options)
        options = hasOption(p.animalCratetrained, option1: "Crate Trained", option2: "Not Crate Trained", options: options)
        options = hasOption(p.animalEagerToPlease, option1: "Eager to Please", option2: "Not Eager to Please", options: options)
        options = hasOption(p.animalEscapes, option1: "Escapes", option2: "Does not Escape", options: options)
        options = hasOption(p.animalEventempered, option1: "Eventempered", option2: "Not Eventempered", options: options)
        options = hasOption(p.animalFetches, option1: "Fetches", option2: "Does not Fetch", options: options)
        options = hasOption(p.animalGentle, option1: "Gentle", option2: "Not Gentle", options: options)
        options = hasOption(p.animalGoodInCar, option1: "Good In Car", option2: "Not Good In Car", options: options)
        options = hasOption(p.animalGoofy, option1: "Goofy", option2: "Not Goofy", options: options)
        options = hasOption(p.animalHousetrained, option1: "Housetrained", option2: "Not Housetrained", options: options)
        options = hasOption(p.animalIndependent, option1: "Independent", option2: "Not Independent", options: options)
        options = hasOption(p.animalIntelligent, option1: "Intelligent", option2: "Not Intelligent", options: options)
        options = hasOption(p.animalLap, option1: "Lap", option2: "Not Lap", options: options)
        options = hasOption(p.animalLeashtrained, option1: "Lease Trained", option2: "Not Lease Trained", options: options)
        options = hasOption(p.animalNeedsCompanionAnimal, option1: "Needs Companion Animal", option2: "No Companion Animal", options: options)
        options = hasOption(p.animalObedient, option1: "Obedient", option2: "Not Obedient", options: options)
        options = hasOption(p.animalPlayful, option1: "Playful", option2: "Not Playful", options: options)
        options = hasOption(p.animalPredatory, option1: "Predatory", option2: "Not Predatory", options: options)
        options = hasOption(p.animalTimid, option1: "Timid", option2: "Not Timid", options: options)
        options = hasOption(p.animalCoatLength, option1: " coat length", options: options)
        options = hasOption(p.animalHearingImpaired, option1: "Hearing Impaired", option2: "Not Hearing Imparied", options: options)
        options = hasOption(p.animalHypoallergenic, option1: "Hypoallergenic", option2: "Not Hypoallergenic", options: options)
        options = hasOption(p.animalMicrochipped, option1: "Microchipped", option2: "Not Microchipped", options: options)
        options = hasOption(p.animalOngoingMedical, option1: "Has Ongoing Medical Needs", option2: "Does Not Have Ongoing Medical Needs", options: options)
        options = hasOption(p.animalSpecialDiet, option1: "Has A Special Diet", option2: "Does Not Have A Special Diet", options: options)
        options = hasOption(p.animalEyeColor, option1: " eyes", options: options)
        options = hasOption(p.animalGroomingNeeds, option1: " grooming needs", options: options)
        options = hasOption(p.animalShedding, option1: " shedding", options: options)
        options = hasOption(p.animalTailType, option1: " tail", options: options)
        options = hasOption(p.animalColor, option1: " color coat", options: options)

        let id = p.animalID ?? "0"
        let name = p.animalName ?? ""
        let age = p.animalGeneralAge ?? ""
        let sex = p.animalSex ?? ""
        let size = p.animalGeneralSizePotential ?? ""
        let description = p.animalDescriptionPlain ?? ""
        let orgID = p.animalOrgID ?? ""
        let birthDate = p.animalBirthdate ?? ""
        let updated = p.animalUpdatedDate ?? ""
        let fee = p.animalAdoptionFee ?? ""
        let loc = p.animalLocationCitystate ?? ""
        
        return Pet(pID: id, n: name, b: breeds, m: false, a: age, s: sex, s2: size, o: options, d: description, m2: pictures, v: videos, s3: orgID, z: zipCode, dis: validateDouble(p.animalLocationDistance as AnyObject), stat: status, bd: birthDate, upd: parseDate(value: updated), adoptionFee: fee, location: loc)
    }
}
 
func hasOption(_ optionValue: String?, option1:  String?, option2: String, options: Set<String>) -> Set<String> {
    var opts = Set<String>()
    opts = options
    if optionValue == "Yes" {
        opts.insert(option1!)
    } else if optionValue == "No" {
        opts.insert(option2)
    }
    return opts
}

func hasOption(_ optionValue: String?, option1:  String, options: Set<String>) -> Set<String> {
    var opts = Set<String>()
    opts = options
    if optionValue != "" && optionValue != nil {
        opts.insert("\(optionValue!) \(option1)")
    }
    return opts
}

func parsePictures(_ pics: [animalPicture?]) -> [picture] {
    var pictures: [picture] = [picture]()
    var id = 1
    
    for p in pics {
        pictures.append(picture(i: id, s: convert(p?.large!.type), u: (p?.large?.url!)!))
        pictures.append(picture(i: id, s: convert(p?.original!.type), u: (p?.original?.url!)!))
        pictures.append(picture(i: id, s: convert(p?.small!.type), u: (p?.small?.url!)!))
        id += 1
    }
    
    return pictures
}

func convert(_ size: String?) -> String {
    var s = ""
    switch size! {
    case "Large": s = "x"
    case "Original": s = "pn"
    case "Small": s = "pnt"
    default: break
    }
    return s
}

func parseVideos(_ vids:[video2?]) -> [video] {
    var videos = [video]()
    for v in vids {
        videos.append(video(i: (v?.mediaID!)!, o: (v?.mediaOrder!)!, t: (v?.urlThumbnail!)!, v: (v?.videoID!)!, u: (v?.videoUrl!)!))
    }
    return videos
}
