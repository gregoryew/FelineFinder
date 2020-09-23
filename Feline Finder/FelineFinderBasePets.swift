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
    var height: Int
    var width: Int
    init (i: Int, s: String, u: String, h: Int, w: Int) {
        idnum = i
        size = s
        URL = u
        height = h
        width = w
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
    var lastUpdated: Date = Date()
    var zipCode: String = ""
    var distance: Double = 0
    var media = [picture]()
    var videos = [video]()
    var status: String = ""
    var birthdate: String = ""
    var row = 0
    var section = 0
    var adoptionFee = ""
    var location = ""
    init (pID: String, n: String, b: Set<String>, m: Bool, a: String, s: String, s2: String, o: Set<String>, d: String, m2: [picture], s3: String, z: String, dis: Double, adoptionFee: String, location: String) {
        petID = pID
        name = n
        breeds = b
        mix = m
        age = a
        sex = s
        size = s2
        options = o
        description = d
        media = m2
        shelterID = s3
        zipCode = z
        distance = dis
        videos = []
        status = ""
        birthdate = ""
        lastUpdated = Date()
        self.adoptionFee = adoptionFee
        self.location = location
    }

    init (pID: String, n: String, b: Set<String>, m: Bool, a: String, s: String, s2: String, o: Set<String>, d: String, m2: [picture], v: [video], s3: String, z: String, dis: Double, stat: String, bd: String, upd: Date, adoptionFee: String, location: String) {
        petID = pID
        name = n
        breeds = b
        mix = m
        age = a
        sex = s
        size = s2
        options = o
        description = d
        media = m2
        shelterID = s3
        zipCode = z
        distance = dis
        videos = v
        status = stat
        birthdate = bd
        lastUpdated = upd
        self.adoptionFee = adoptionFee
        self.location = location
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
    
    func getAllImagesObjectsOfACertainSize(_ size: String) -> [picture] {
        var images: [picture] = []
        for img: picture in media {
            if img.size == size {
                images.append(img)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
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
        var label: String = ""
        var i = 0
        var r = 0
        var s = 0
        let d = Double(distance)
        
        distances.removeAll()
        
         while i < self.Pets.count {
            if sortFilter == "animalLocationDistance" {
                if self.Pets[i].distance >= d! {
                    i += 1
                    continue
                }
                //print(self.Pets[i].distance)
                switch (self.Pets[i].distance) {
                case 0..<5:
                    label = "         Within about 5 miles"
                case 5..<20:
                    label = "       Within about 20 miles"
                case 20..<50:
                    label = "    Within about 50 miles"
                case 50..<100:
                    label = "   Within about 100 miles"
                case 100..<200:
                    label = "  Within about 200 miles"
                default:
                    label = " Over 200 miles"
                }
            } else {
                switch (calicuateDaysBetweenTwoDates(start: self.Pets[i].lastUpdated, end: Date())) {
                case 0...1:
                    label = "     Updated Today"
                case 2...8:
                    label = "    Updated Within A Week"
                case 9...30:
                    label = "   Updated Within A Month"
                case 31...365:
                    label = "  Updated Within A Year"
                default:
                    label = " Updated Over A Year Ago"
                }
            }
            
            if var dist = distances[label] {
                self.Pets[i].row = r
                self.Pets[i].section = s
                dist.append(self.Pets[i])
                distances[label] = dist
            } else {
                r = 0
                if i != 0 {
                    s += 1
                }
                self.Pets[i].row = r
                self.Pets[i].section = s
                var dist: [Pet] = []
                dist.append(self.Pets[i])
                distances[label] = dist
            }
            r += 1
            i += 1
        }
    }
    
    func loadPets(bn: Breed, zipCode: String, completion: @escaping (_ p: PetList) -> Void) -> Void {
    }
    
    private func calicuateDaysBetweenTwoDates(start: Date, end: Date) -> Int {
        
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }
}
