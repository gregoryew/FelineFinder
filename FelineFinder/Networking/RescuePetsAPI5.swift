//
//  RescueGroupsAnimalStructure.swift
//  RescueGroupsTest
//
//  Created by Gregory Williams on 10/25/20.
//

import Foundation

var globalShelterCache: [String: shelter] = [:]

final class RescuePetsAPI5: PetList {
    var catData: animal?
    var picturesCache: [String: PicturesTemp] = [:]
    var videosCache: [String: video] = [:]
    var page = 1
    
    private lazy var baseURL: String = {
        return "https://api.rescuegroups.org/v5/public/animals/search/available?sort=animals.distance&fields[animals]=id,name,breedPrimary,ageGroup,sex,updatedDate,birthDate,availableDate,sizeGroup,descriptionHtml,descriptionText,status&limit=25"
    }()
    
    var session: URLSession!

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    var isLoading = false
    
    func loadPets5(json: [String: Any], reset: Bool = false, completion: @escaping (Result<PetList, DataResponseError>) -> Void) {

        if reset {page = 1}
        
        let str: String = "\(baseURL)&page=\(page)"
        let url: URL = URL(string: str)!
        var urlRequest = URLRequest(url: url)
        
        if isLoading {return}
        
        isLoading = true
                        
        if (Utilities.isNetworkAvailable() == false) {
            isLoading = false
            return
        }
                
        dateCreated = Date() //Reset the cache time

        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(RescueGroupsKey, forHTTPHeaderField: "Authorization")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        session.uploadTask(with: urlRequest, from: jsonData, completionHandler: { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let data = data
            else {
                completion(Result.failure(DataResponseError.network))
                return
            }
            let decodedResponse = try? JSONDecoder().decode(animal.self, from: data)
            //let animalData = (decodedResponse as! animal)

            self.catData = (decodedResponse as animal?)
            self.foundRows = self.catData?.meta?.count ?? 0
            
            self.cachePictures()
            self.cacheVideos()
            self.cacheShelters()
            
            var pets2 = [Pet]()
            //for (key, cat) in catData.data {
            if let catData = self.catData, let data = catData.data {
            for i in 0..<data.count {
                if let cat = data[i].attributes {
                    let breed: Set<String> = [cat.breedPrimary ?? ""]
                    //let options: Set<String> = self.getOptions(pet: cat)
                    let pictures: [picture2] = self.getPicturesForAnAnimal(id: cat.id ?? "")
                    let videos: [video] = self.getVideosForAnAnimal(id: cat.id ?? "")
                    //print("animalPictures = \(String(describing: cat.animalPictures))")
                    //let videos: [video] = self.parseVideos2(videos: cat.animalVideoUrls ?? [])
                    let stat = self.animalStatus(id: cat.id ?? "") // ?? "", animalStatus: cat.animalStatus ?? "", availableDate: cat.animalAvailableDate ?? "", animalAdoptedDate: cat.animalAdoptedDate ?? "", adoptionFee: cat.animalAdoptionFee ?? "")
                    let organizationID = self.catData?.data?[i].relationships?.orgs?.data![0].id
                    //let dist = self.getDistanceToFirstOrg(lat1: 0, lon1: 0, petID: cat.id ?? "")
                    
                    let upd = dateFromString(str: cat.updatedDate ?? "", format: "MM/dd/yyyy HH:mm:ss Z") ?? Date()
                    
                    let cityState = self.getCityState(id: cat.id ?? "")
                
                    var p = Pet(pID: cat.id ?? "", n: cat.name ?? "", b: breed, m: false, a: cat.ageGroup ?? "", s: cat.sex ?? "", s2: cat.sizeGroup ?? "", o: [], d: cat.descriptionText ?? "", m2: pictures, v: videos, s3: organizationID ?? "", z: "", dis: cat.distance ?? -1, stat: stat, bd: cat.birthDate ?? "", upd: upd, adoptionFee: "NA" , location: cityState)
                    //p.descriptionHtml = cat.descriptionHtml ?? ""
                    p.descriptionHtml =  cat.descriptionHtml ?? cat.descriptionText ?? ""
                    pets2.append(p)
                }
            }
            }
            
            //Rescue Groups has fixed the distance sort error so this is not needed
            /*
            pets2 = self.lookupOrgZips(pets: pets2)
            DatabaseManager.sharedInstance.fetchDistancesFromZipCode (pets2) { (zC) -> Void in
                for i in 0..<pets2.count {
                    pets2[i].distance = (zC[pets2[i].zipCode]?.distance ?? -2).rounded()
                }
            
                pets2.sort { ($0.distance, $0.name) < ($1.distance, $1.name) }
                
                self.page += 1
                if reset {
                    self.Pets = pets2
                } else {
                    self.Pets.append(contentsOf: pets2)
                }
                
                self.isLoading = false
                completion(Result.success(self))
            }
            */

            self.page += 1
            if reset {
                self.Pets = pets2
            } else {
                self.Pets.append(contentsOf: pets2)
            }
            self.totalRows = self.Pets.count

            self.isLoading = false
            completion(Result.success(self))

        }).resume()
    }
    
    func animalStatus(id: String) -> String {
        let r = catData?.data?.first(where: { (r) -> Bool in
            return r.id == id
        })
        let id = r?.relationships?.statuses?.data?[0].id
        let item = catData?.included?.first(where: { (i) -> Bool in
            return i.id == id && i.type == "statuses"
        })
        let status = item?.attributes?.name ?? ""

        /*
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
        */
        
        return status
    }
    
    struct PicturesTemp {
        let small: picture2
        let original: picture2
        let large: picture2
    }
    
    func cachePictures() {
        if let ta = catData?.included {
            for i in 0..<ta.count {
                if ta[i].type == "pictures" {
                    if let img = ta[i].attributes {
                        picturesCache[ta[i].id!] =
                        PicturesTemp(
                            small: (picture2(i: img.order ?? 1, s: "pnt", u: img.small?.url ?? "", h: Int(img.small?.resolutionY ?? 0), w: Int(img.small?.resolutionX ?? 0))),
                            original: picture2(i: img.order ?? 1, s: "pn", u: img.original?.url ?? "", h: Int(img.original?.resolutionY ?? 0), w: Int(img.original?.resolutionX ?? 0)),
                            large: picture2(i: img.order ?? 1, s: "x", u: img.large?.url ?? "", h: Int(img.large?.resolutionY ?? 0), w: Int(img.large?.resolutionX ?? 0)))
                    }
                }
            }
        }
    }
        
    func getPicturesForAnAnimal(id: String) -> [picture2] {
        var temp = [picture2]()
        let pet = catData?.data?.first(where: { (pet) -> Bool in
            return pet.id == id
        })
        if let picIDs = pet?.relationships?.pictures?.data {
            for i in 0..<picIDs.count {
                if let pic = picturesCache[picIDs[i].id ?? ""] {
                    temp.append(pic.small)
                    temp.append(pic.original)
                    temp.append(pic.large)
                }
            }
        }
        return temp
    }
    
    func cacheVideos() {
        if let catData = catData, let included = catData.included {
            for i in 0..<(included.count) {
                let videotemp = included[i]
                if videotemp.type == "videourls" {
                    videosCache[videotemp.id!] = video(i: String(i) , o: String(i), t: videotemp.attributes?.urlThumbnail ?? "", v: videotemp.attributes?.videoId ?? "", u: videotemp.attributes?.url ?? "")
                }
            }
        }
    }
    
    func getVideosForAnAnimal(id: String) -> [video] {
        var temp = [video]()
        let pet = catData?.data?.first(where: { (pet) -> Bool in
            return pet.id == id
        })
        if let p = pet, let r = p.relationships, let videoIDs = r.videourls, let data = videoIDs.data {
            for i in 0..<data.count {
                if let vid = videosCache[data[i].id ?? ""] {
                    temp.append(vid)
                }
            }
        }
        return temp
    }
    
    func cacheShelters() {
        if let catData = catData, let included = catData.included {
        for i in 0..<included.count {
            if let sh_a = included[i].attributes {
                if included[i].type == "orgs" {
                    globalShelterCache[included[i].id ?? ""] = shelter(i: "\(included[i].id ?? "")", n: sh_a.name ?? "", a1: sh_a.street ?? "", a2: "", c: sh_a.city ?? "", s: sh_a.state ?? "", z: sh_a.postalcode ?? "", lat: sh_a.lat ?? 0, lng: sh_a.lon ?? 0, c2: sh_a.country ?? "", p: sh_a.phone ?? "", f: sh_a.facebookUrl ?? "", e: sh_a.email ?? "", aw: sh_a.adoptionUrl ?? "", url: sh_a.url ?? "")
                }
            }
        }
        }
    }
    
    func deg2rad(deg:Double) -> Double {
        return deg * .pi / 180
    }

    ///////////////////////////////////////////////////////////////////////
    ///  This function converts radians to decimal degrees              ///
    ///////////////////////////////////////////////////////////////////////
    func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / .pi
    }

    func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        if (unit == "K") {
            dist = dist * 1.609344
        }
        else if (unit == "N") {
            dist = dist * 0.8684
        }
        return dist
    }
    
    func lookupOrgZips(pets: [Pet]) -> [Pet] {
        var tempPets = [Pet]()
        tempPets.append(contentsOf: pets)
        for i in 0..<tempPets.count {
            let r = catData?.data?.first(where: { (rel) -> Bool in
                return rel.id == tempPets[i].petID
            })
            let id = r?.relationships?.orgs?.data?[0].id
            let item = catData?.included?.first(where: { (i) -> Bool in
                return i.id == id && i.type == "orgs"
            })
            tempPets[i].zipCode = item?.attributes?.postalcode ?? ""
        }
        return tempPets
    }
    
    /*
    func getDistance() -> Int {
        return -1
        /*
        for i in 0..<(tempAnimal?.included?.count)! {
            if tempAnimal?.included?[i].type == "location" {
                return tempAnimal?.included?[i].attributes.distance
            }
        }
        */
    }
    */

    func getCityState(id: String) -> String {
        let r2 = catData?.data?.first(where: { (r) -> Bool in
            return r.id == id
        })
        let id = r2?.relationships?.orgs?.data?[0].id
        let item = catData?.included!.first(where: { (i) -> Bool in
            return i.id == id && i.type == "orgs"
        })
        let citystate = item?.attributes?.citystate ?? ""
        return citystate
    }
}

struct animal: Decodable{
    let meta: Meta?
    let data: [Data2]?
    let included: [Included]?
}

struct Meta: Decodable {
    let count: Int?
    let countReturned: Int?
    let pageReturned: Int?
    let limit: Int?
    let pages: Int?
    let transactionId: String?
}

struct Data2: Decodable {
    let type: String?
    let id: String?
    let attributes: Attribute?
    let relationships: Relationship?
}

struct Attribute: Decodable {
    let id: String?
    let name: String?
    let breedPrimary: String?
    let sex: String?
    let updatedDate: String?
    let birthDate: String?
    let sizeGroup: String?
    let descriptionHtml: String?
    let descriptionText: String?
    //Below new not sure if right
    let status: String?
    let ageGroup: String?
    let distance: Double?
}

struct Relationship: Decodable {
    let breeds: relationshipDataHeader?
    let colors: relationshipDataHeader?
    let patterns: relationshipDataHeader?
    let species:  relationshipDataHeader?
    let statuses:  relationshipDataHeader?
    let locations:  relationshipDataHeader?
    let orgs:  relationshipDataHeader?
    let pictures:  relationshipDataHeader?
    let videourls: relationshipDataHeader?
}

struct relationshipDataHeader: Decodable {
    let data: [relationshipData]?
}

struct relationshipData: Decodable {
    let type: String?
    let id: String?
}

enum ItemType: String, Decodable {
    case breeds, colors, species, statuses, locations, organization, pictures, videos
}

struct Included: Decodable {
    var type: String?
    var id: String?
    var attributes: IncludedAttributes?
    var links: linksHeader?
}

struct IncludedAttributes: Decodable {
    let name: String?
    let singular: String?
    let plural: String?
    let youngSingular: String?
    let youngPlural: String?
    let description: String?
    let street: String?
    let city: String?
    let state: String?
    let citystate: String?
    let postalcode: String?
    let country: String?
    let phone: String?
    let lat: Double?
    let lon: Double?
    let coordinates: String?
    let email: String?
    let url: String?
    let facebookUrl: String?
    let adoptionUrl: String?
    let services: String?
    let type: String?
    let original: picture?
    let large: picture?
    let small: picture?
    let order: Int?
    let created: String?
    let updated: String?
    let videoId: String?
    let urlThumbnail: String?
}

struct picture: Decodable {
    let filesize: Int?
    let resolutionX: Int?
    let resolutionY: Int?
    let url: String?
}

struct linksHeader: Decodable{
    let `self`: String?
}
