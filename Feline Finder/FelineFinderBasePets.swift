//
//  FelineFinderBasePets.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/1/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation

struct picture {
    var idnum: Int
    var size: String //["pnt", "fpm", "x", "pn", "t"]
    var URL: String
    init (i: Int, s: String, u: String) {
        idnum = i
        size = s
        URL = u
    }
}

struct video {
    var mediaID: String
    var mediaOrder: String
    var urlThumbnail: String
    var videoID: String
    var videoUrl: String
    init (i: String, o: String, t: String, v: String, u: String) {
        mediaID = i
        mediaOrder = o
        urlThumbnail = t
        videoID = v
        videoUrl = u
    }
}

struct Pet {
    var dateCreated = Date()
    var petID: String
    var shelterID: String
    var name: String
    var breeds: Set<String>
    var mix: Bool
    var age: String //["Baby","Young","Adult","Senior"]
    var sex: String //["M","F"]
    var size: String //["S","M","L","XL"]
    var options: Set<String> //["specialNeeds", "noDogs", "noCats", "noKids", "noClaws", "hasShots", "houseBroken", "altered"]
    var description: String = ""
    var lastUpdated: String = ""
    var zipCode: String = ""
    var distance: Double = 0
    var media = [picture]()
    var videos = [video]()
    var status: String = ""
    var birthdate: String = ""
    var row = 0
    var section = 0
    init (pID: String, n: String, b: Set<String>, m: Bool, a: String, s: String, s2: String, o: Set<String>, d: String, lu: String, m2: [picture], s3: String, z: String, dis: Double) {
        petID = pID
        name = n
        breeds = b
        mix = m
        age = a
        sex = s
        size = s2
        options = o
        description = d
        lastUpdated = lu
        media = m2
        shelterID = s3
        zipCode = z
        distance = dis
        videos = []
        status = ""
        birthdate = ""
    }

    init (pID: String, n: String, b: Set<String>, m: Bool, a: String, s: String, s2: String, o: Set<String>, d: String, lu: String, m2: [picture], v: [video], s3: String, z: String, dis: Double, stat: String, bd: String) {
        petID = pID
        name = n
        breeds = b
        mix = m
        age = a
        sex = s
        size = s2
        options = o
        description = d
        lastUpdated = lu
        media = m2
        shelterID = s3
        zipCode = z
        distance = dis
        videos = v
        status = stat
        birthdate = bd
    }

    
    func getImage(_ idNum: Int, size: String) -> String {
        for img: picture in media {
            if img.idnum == idNum && img.size == size {
                return img.URL
            }
        }
        return ""
    }
    
    func getAllImagesOfACertainSize(_ size: String) -> [String] {
        var images: [String] = []
        for img: picture in media {
            if img.size == size {
                images.append(img.URL)
            }
        }
        return images
    }
}

var PetFinderBreeds = [String:PetList]()
var PetsGlobal = [String:Pet]()

class PetList {
    var Pets = [Pet]()
    var pet: Pet!
    var lastOffset: String = ""
    var dateCreated = Date()
    var loading: Bool = true
    var distances: Dictionary<String, [Pet]> = [:]
    var resultStart: Int = 0
    var resultLimit: Int = 0
    
    init() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            resultLimit = 100
        } else {
            resultLimit = 25
        }
    }
    
    func splitPetID(_ petID: String) -> String {
        return petID.components(separatedBy: "_")[0]
    }
    
    var count: Int {
        return Pets.count
    }
    
    func loadSinglePet(_ petID: String, completion: @escaping (Pet) -> Void) -> Void {
    }
    
    subscript(index: Int) -> Pet {
        get {
            return Pets[index]
        }
    }
    
    func assignDistances() {
        var distanceLabel: String = ""
        var i = 0
        var r = 0
        var s = 0
        
        distances.removeAll()
        //self.Pets.sort(by: {$0.distance < $1.distance})
        while i < self.Pets.count {
            switch (self.Pets[i].distance) {
            case 0..<5:
                distanceLabel = "         Within about 5 miles"
            case 5..<25:
                distanceLabel = "       Within about 25 miles"
            case 25..<50:
                distanceLabel = "    Within about 50 miles"
            case 50..<75:
                distanceLabel = "   Within about 75 miles"
            case 75..<100:
                distanceLabel = "  Within about 100 miles"
            default:
                distanceLabel = " Over 100 miles"
            }
            
            if var dist = distances[distanceLabel] {
                self.Pets[i].row = r
                self.Pets[i].section = s
                dist.append(self.Pets[i])
                distances[distanceLabel] = dist
            } else {
                r = 0
                if i != 0 {
                    s += 1
                }
                self.Pets[i].row = r
                self.Pets[i].section = s
                var dist: [Pet] = []
                dist.append(self.Pets[i])
                distances[distanceLabel] = dist
            }
            r += 1
            i += 1
        }
    }
    
    func loadPets(_ cv: UICollectionView, bn: Breed, zipCode: String, completion: @escaping (_ p: PetList) -> Void) -> Void {
    }

}
