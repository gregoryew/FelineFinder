//
//  BreedGalleryPet.swift
//  FelineFinder
//
//  Created by Gregory Williams on 12/2/20.
//

import Foundation

struct BreedGalleryPet {
    var pet: Pet
    var thumbNail: picture2
    init (pet: Pet, thumbNail: picture2) {
        self.pet = pet
        self.thumbNail = thumbNail
    }
}

class RescueGroups {
    
    var status = ""
    var task: URLSessionTask?
    var catData: animal?
    var picturesCache: [String: PicturesTemp] = [:]
    var foundRows = 0
    
    var session: URLSession!

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func getPets(zipCode: String, breed: Breed) -> Result<[Pet]?, NetworkError> {
        let path = "https://api.rescuegroups.org/v5/public/animals/search/available?fields[animals]=id,breedPrimaryID&limit=25"

        var pets2 = [Pet]()
        
        guard let url = URL(string: path) else {
            return .failure(.url)
        }

        var urlRequest = URLRequest(url: url)
                                
        if (Utilities.isNetworkAvailable() == false) {
            return .failure(.server)
        }

        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(RescueGroupsKey, forHTTPHeaderField: "Authorization")
        
        var filters: [[String: Any]] = [["fieldName": "species.singular", "operation": "equals", "criteria": "cat"]]
        filters.append(["fieldName": "animals.breedPrimaryId", "operation": "equals", "criteria": breed.RescueBreedID])
        let json = [
             "data" : [
                 "filterRadius": ["miles": 1000, "postalcode": zipCode],
                 "filters": filters
             ]
        ] as [String : [String : Any]]

        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        let semaphore = DispatchSemaphore(value: 0)

        session.uploadTask(with: urlRequest, from: jsonData, completionHandler: { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let data = data
            else {
                semaphore.signal()
                return
            }
            let decodedResponse = try? JSONDecoder().decode(animal.self, from: data)

            self.catData = (decodedResponse as animal?)
            self.foundRows = self.catData?.meta?.count ?? 0
            
            self.cachePictures()
            self.cacheShelters()
            
            if let catData = self.catData, let data = catData.data {
            for i in 0..<data.count {
                if let cat = data[i].attributes {
                    let breed: Set<String> = [cat.breedPrimary ?? ""]
                    let pictures: [picture2] = self.getPicturesForAnAnimal(id: cat.id ?? "")
                    
                    let upd = dateFromString(str: cat.updatedDate ?? "", format: "MM/dd/yyyy HH:mm:ss Z") ?? Date()
                    
                    let organizationID = self.catData?.data?[i].relationships?.orgs?.data![0].id
                    
                    var p = Pet(pID: cat.id ?? "", n: cat.name ?? "", b: breed, m: false, a: cat.ageGroup ?? "", s: cat.sex ?? "", s2: cat.sizeGroup ?? "", o: [], d: cat.descriptionText ?? "", m2: pictures, v: [], s3: organizationID ?? "", z: "", dis: -1, stat: "", bd: cat.birthDate ?? "", upd: upd, adoptionFee: "NA" , location: "")
                    p.descriptionHtml = cat.descriptionHtml ?? ""
                    pets2.append(p)
                }
            }
            }
            semaphore.signal()
        }).resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return .success(pets2)
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

}

