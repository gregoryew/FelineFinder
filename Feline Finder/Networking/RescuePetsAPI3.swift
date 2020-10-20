import Foundation

final class RescuePetsAPI3: PetList {
    private lazy var baseURL: URL = {
        return URL(string: "https://api.rescuegroups.org/http/v2.json")!
    }()
    
    let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    var isLoading = false
    
    func loadPets3(bn: Breed, zipCode: String, more: Bool = false, completion: @escaping (Result<PetList, DataResponseError>) -> Void) {
        
        if zipCode == "" {return}
        
        if isLoading {return}
        
        isLoading = true
        
        if more {
            zipCodeGlobal = zipCode
            bnGlobal = bn.BreedName
        }
        else if zipCodeGlobal == zipCode  && bnGlobal == bn.BreedName {
            isLoading = false
            return
        } else {
            zipCodeGlobal = zipCode
            bnGlobal = bn.BreedName
        }
        
        dateCreated = Date() //Reset the cache time
        
        if (Utilities.isNetworkAvailable() == false) {
            isLoading = false
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
        //filters.append(["fieldName": "animalID" as AnyObject, "operation": "equals" as AnyObject, "criteria": "8610893" as AnyObject])
        var order = "desc"
        if sortFilter == "animalLocationDistance" {
            order = "asc"
        }
        //resultLimit = 5
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["resultStart": String(resultStart), "resultLimit":String(resultLimit), "resultSort": sortFilter, "resultOrder": order, "calcFoundRows": "Yes", "filters": filters, "fields": ["animalID", "animalName", "animalBreed", "animalGeneralAge", "animalSex", "animalPrimaryBreed", "animalUpdatedDate", "animalOrgID", "animalLocationDistance" , "animalLocationCitystate", "animalPictures", "animalStatus", "animalBirthdate", "animalAvailableDate", "animalGeneralSizePotential", "animalVideoUrls"]]] as [String : Any]
        // 1
        //let urlRequest = URLRequest(url: baseURL.appendingPathComponent(request.path))
        var urlRequest = URLRequest(url: baseURL)

        urlRequest.httpMethod = "POST"
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 2
        //let parameters = [].merging(request.parameters, uniquingKeysWith: +)
        // 3
        //let encodedURLRequest = urlRequest.encode(with: parameters)
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        session.uploadTask(with: urlRequest, from: jsonData, completionHandler: { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.hasSuccessStatusCode,
                let data = data
            else {
                completion(Result.failure(DataResponseError.network))
                return
            }
            
            guard let decodedResponse = try? JSONDecoder().decode(Cats.self, from: data) else {
                    completion(Result.failure(DataResponseError.decoding))
                    return
                }
            
            let catData = (decodedResponse as Cats)
            self.foundRows = catData.foundRows
            var pets2 = [Pet]()
            for (key, cat) in catData.data {
                let breed: Set<String> = [cat.animalPrimaryBreed ?? ""]
                let options: Set<String> = self.getOptions(pet: cat)
                let pictures: [picture2] = self.parsePictures2(picts: cat.animalPictures ?? [])
                //print("animalPictures = \(String(describing: cat.animalPictures))")
                let videos: [video] = self.parseVideos2(videos: cat.animalVideoUrls ?? [])
                let status = self.animalStatus(pending: cat.animalAdoptionPending ?? "", animalStatus: cat.animalStatus ?? "", availableDate: cat.animalAvailableDate ?? "", animalAdoptedDate: cat.animalAdoptedDate ?? "", adoptionFee: cat.animalAdoptionFee ?? "")
                
                let p = Pet(pID: cat.animalID ?? "", n: cat.animalName ?? "", b: breed, m: false, a: cat.animalGeneralAge ?? "", s: cat.animalSex ?? "", s2: cat.animalSizePotential ?? "", o: options, d: cat.animalDescriptionPlain ?? "", m2: pictures, v: videos, s3: cat.animalOrgID ?? "", z: "", dis: cat.animalLocationDistance!, stat: status, bd: cat.animalBirthdate ?? "", upd: dateFromString(str: cat.animalUpdatedDate ?? "", format: "MM/dd/yyyy HH:mm:ss Z") ?? Date(), adoptionFee: cat.adoptionFee ?? "", location: cat.animalLocationCitystate ?? "")
                pets2.append(p)
            }
            
            pets2.sort { $0.distance < $1.distance }
            
            if more {
                self.resultStart += self.resultLimit
                self.Pets.append(contentsOf: pets2)
            } else {
                self.resultStart = self.resultLimit
                self.Pets = pets2
            }
            
            self.isLoading = false
            completion(Result.success(self))
        }).resume()
    }
    
    func hasOption(_ optionValue: String, option1:  String, option2: String) -> String {
        if optionValue == "Yes" {
            return option1
        } else if optionValue == "No" {
            return option2
        }
        return ""
    }

    func hasOption(_ optionValue: String, option1:  String) -> String {
        if optionValue != "" {
            return "\(optionValue) \(option1)"
        } else {
            return "\(optionValue) Unknown"
        }
    }

    func animalStatus(pending: String, animalStatus: String, availableDate: String, animalAdoptedDate: String, adoptionFee: String) -> String {
        var status: String = ""
        if pending == "Yes" {
            status = "Adoption Pending"
        } else if animalStatus == "Adopted" {
            status = animalStatus + " " + animalAdoptedDate
        } else if animalStatus == "Available" {
            status = animalStatus + " " + availableDate
        }
        if adoptionFee != "" {
            status += " Adoption Fee: \(adoptionFee)"
        }
        return status
    }
    
    func parsePictures2(picts: [pictures]) -> [picture2] {
        var pictoutput = [picture2]()
        pictoutput = []
        var counter = 1
        for animalPic in picts {
            if let pic = animalPic.small {
                pictoutput.append(picture2(i: counter, s: "pnt", u: pic.url ?? "", h: Int(pic.resolutionX ?? "0") ?? 0, w: Int(pic.resolutionY ?? "0") ?? 0))
            }
            if let pic = animalPic.original {
                pictoutput.append(picture2(i: counter, s: "pn", u: pic.url ?? "", h: Int(pic.resolutionX ?? "0") ?? 0, w: Int(pic.resolutionY ?? "0") ?? 0))
            }
            if let pic = animalPic.large {
                pictoutput.append(picture2(i: counter, s: "x", u: pic.url ?? "", h: Int(pic.resolutionX ?? "0") ?? 0, w: Int(pic.resolutionY ?? "0") ?? 0))
            }
            counter += 1
        }
        return pictoutput
    }
    
    func parseVideos2(videos: [video2]) -> [video] {
        var videooutput = [video]()
        for v in videos {
            videooutput.append(video(i: v.mediaID ?? "", o: v.mediaOrder ?? "", t: v.urlThumbnail ?? "", v: v.videoID ?? "", u: v.videoUrl ?? ""))
        }
        return videooutput
    }
    
    func getOptions(pet: cat) -> Set<String> {
        var opts = Set<String>()
        
        if let o = pet.animalOKWithDogs {
            opts.insert(hasOption(o, option1: "OK With Dogs", option2: "Not OK With Dogs"))
        }
        
        if let o = pet.animalAltered {
            opts.insert(hasOption(o, option1: "Spayed/Neutereds", option2: "Not Spayed/Neutered"))
        }
        if let o = pet.animalOKWithAdults {
            opts.insert(hasOption(o, option1: "OK With Adults", option2: "Not OK With Adults"))
        }
        if let o = pet.animalSpecialneeds {
            opts.insert(hasOption(o, option1: "Has Special Needs", option2: "Does not have special needs"))
        }
        if let o = pet.animalOKWithCats {
            opts.insert(hasOption(o, option1: "OK With Cats", option2: "Not OK with Cats"))
        }
        if let o = pet.animalHousetrained {
            opts.insert(hasOption(o, option1: "House Trained", option2: "Not House Trained"))
        }
        if let o = pet.animalOKWithKids {
            opts.insert(hasOption(o, option1: "Good with Kids", option2: "Not Good with Kids"))
        }
        if let o = pet.animalDeclawed {
            opts.insert(hasOption(o, option1: "Declawed", option2: "Has claws"))
        }
        if let o = pet.animalUptodate {
            opts.insert(hasOption(o, option1: "Uptodate", option2: "Not Uptodate"))
        }
        if let o = pet.animalApartment {
            opts.insert(hasOption(o, option1: "OK with apartment", option2: "Not OK with apartment"))
        }
        if let o = pet.animalYardRequired {
            opts.insert(hasOption(o, option1: "Requires yard", option2: "Does not require yard"))
        }
        if let o = pet.animalNoCold {
            opts.insert(hasOption(o, option1: "Cold Sensitive", option2: "Not Cold Sensitive"))
        }
        if let o = pet.animalNoHeat {
            opts.insert(hasOption(o, option1: "Heat Sensitive", option2: "Not Heat Sensitive"))
        }
        if let o = pet.animalOKForSeniors {
            opts.insert(hasOption(o, option1: "OK for Seniors", option2: "Not for Seniors"))
        }
        if let o = pet.animalAffectionate {
            opts.insert(hasOption(o, option1: "Affectionate", option2: "Not Affectionate"))
        }
        if let o = pet.animalCratetrained {
            opts.insert(hasOption(o, option1: "Crate Trained", option2: "Not Crate Trained"))
        }
        if let o = pet.animalEagerToPlease {
            opts.insert(hasOption(o, option1: "Eager to Please", option2: "Not Eager to Please"))
        }
        if let o = pet.animalEscapes {
            opts.insert(hasOption(o, option1: "Escapes", option2: "Does not Escape"))
        }
        if let o = pet.animalEventempered {
            opts.insert(hasOption(o, option1: "Eventempered", option2: "Not Eventempered"))
        }
        if let o = pet.animalFetches {
            opts.insert(hasOption(o, option1: "Fetches", option2: "Does not Fetch"))
        }
        if let o = pet.animalGentle {
            opts.insert(hasOption(o, option1: "Gentle", option2: "Not Gentle"))
        }
        if let o = pet.animalGoodInCar {
            opts.insert(hasOption(o, option1: "Good In Car", option2: "Not Good In Car"))
        }
        if let o = pet.animalGoofy {
            opts.insert(hasOption(o, option1: "Goofy", option2: "Not Goofy"))
        }
        if let o = pet.animalIndependent {
            opts.insert(hasOption(o, option1: "Independent", option2: "Not Independent"))
        }
        if let o = pet.animalIntelligent {
            opts.insert(hasOption(o, option1: "Intelligent", option2: "Not Intelligent"))
        }
        if let o = pet.animalLap {
            opts.insert(hasOption(o, option1: "Lap", option2: "Not Lap"))
        }
        if let o = pet.animalLeashtrained {
            opts.insert(hasOption(o, option1: "Lease Trained", option2: "Not Lease Traine"))
        }
        if let o = pet.animalNeedsCompanionAnimal {
            opts.insert(hasOption(o, option1: "Needs Companion Animal", option2: "No Companion Animal"))
        }
        if let o = pet.animalObedient {
            opts.insert(hasOption(o, option1: "Obedient", option2: "Not Obedient"))
        }
        if let o = pet.animalPlayful {
            opts.insert(hasOption(o, option1: "Playful", option2: "Not Playful"))
        }
        if let o = pet.animalPredatory {
            opts.insert(hasOption(o, option1: "Predatory", option2: "Not Predatory"))
        }
        if let o = pet.animalIndoorOutdoor {
            opts.insert(hasOption(o, option1: ""))
        }
        if let o = pet.animalActivityLevel {
            opts.insert(hasOption(o, option1: ""))
        }
        if let o = pet.animalEnergyLevel {
            opts.insert(hasOption(o, option1: ""))
        }
        if let o = pet.animalExerciseNeeds {
            opts.insert(hasOption(o, option1: ""))
        }
        if let o = pet.animalNewPeople {
            opts.insert(hasOption(o, option1: ""))
        }
        if let o = pet.animalVocal {
            opts.insert(hasOption(o, option1: ""))
        }
        if let o = pet.animalTimid {
            opts.insert(hasOption(o, option1: "Timid", option2: "Not Timid"))
        }
        if let o = pet.animalCoatLength {
            opts.insert(hasOption(o, option1: "coat length"))
        }
        if let o = pet.animalEyeColor {
            opts.insert(hasOption(o, option1: "eyes"))
        }
        if let o = pet.animalGroomingNeeds {
            opts.insert(hasOption(o, option1: "grooming needs"))
        }
        if let o = pet.animalShedding {
            opts.insert(hasOption(o, option1: "shedding"))
        }
        if let o = pet.animalTailType {
            opts.insert(hasOption(o, option1: "tail"))
        }
        if let o = pet.animalColor {
            opts.insert(hasOption(o, option1: "color coat", option2: "Not OK With Dogs"))
        }
        if let o = pet.animalHearingImpaired {
            opts.insert(hasOption(o, option1: "Hearing Impaired", option2: "Not Hearing Impaired"))
        }
        if let o = pet.animalHypoallergenic {
            opts.insert(hasOption(o, option1: "Hypoallergenic", option2: "Not Hypoallergenic"))
        }
        if let o = pet.animalMicrochipped {
            opts.insert(hasOption(o, option1: "Microchipped", option2: "Not Microchipped"))
        }
        if let o = pet.animalOngoingMedical {
            opts.insert(hasOption(o, option1: "Has Ongoing Medical Needs", option2: "Does Not Have Ongoing Medical Needs"))
        }
        if let o = pet.animalSpecialDiet {
            opts.insert(hasOption(o, option1: "Has A Special Diet", option2: "Does Not Have A Special Diet"))
        }
        return opts
    }
}

func dateFromString(str: String, format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
    return dateFormatter.date(from: str) ?? nil
}
