//
//  DownloadManager.swift
//  Feline Finder
//
//  Created by gregoryew1 on 4/2/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

let petsLoadedMessage = Notification.Name(rawValue:"petsLoaded")

class DownloadManager {
    static let sharedInstance = DownloadManager()

    static func loadPetList(more: Bool = false) {
        var pets = RescuePetList()
        
        if let p = PetFinderBreeds[(globalBreed?.BreedName)!]
        {
            pets = p as! RescuePetList
        }
        
        let date = pets.dateCreated
        
        let hoursSinceCreation: Int = (Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: date as Date, to: Date(), options: []).hour!
        
        var b = false
        
        if (pets.count == 0) {
            b = true
        }
        
        if hoursSinceCreation > 24 {
            b = true
        }
        
        if more == true {
            b = true
        }
        
        if b == true
        {
            if more == false {
                zipCodeGlobal = ""
                bnGlobal = ""
            }
            pets.loadPets(bn: globalBreed!, zipCode: zipCode) { (petList) -> Void in
                pets = (petList as? RescuePetList)!
                if pets.status == "ok" {
                    let titles = pets.distances.keys.sorted{ $0 < $1 }
                    PetFinderBreeds[(globalBreed?.BreedName)!] = pets
                    let nc = NotificationCenter.default
                    nc.post(name:petsLoadedMessage,
                            object: nil,
                            userInfo:["petList": pets, "titles": titles])
                } else {
                    zipCodeGlobal = ""
                    bnGlobal = ""
                    sleep(1)
                    pets.resultStart = 0
                    pets.loadPets(bn: globalBreed!, zipCode: zipCode) { (petList) -> Void in
                        pets = (petList as? RescuePetList)!
                        if pets.status == "ok" {
                            let titles = pets.distances.keys.sorted{ $0 < $1 }
                            PetFinderBreeds[(globalBreed?.BreedName)!] = pets
                            let nc = NotificationCenter.default
                            nc.post(name:petsLoadedMessage,
                                    object: nil,
                                    userInfo:["petList": pets, "titles": titles])
                        }
                    }
                }
            }
        } else {
            let titles = pets.distances.keys.sorted{ $0 < $1 }
            PetFinderBreeds[(globalBreed?.BreedName)!] = pets
            let nc = NotificationCenter.default
            nc.post(name:petsLoadedMessage,
                    object: nil,
                    userInfo:["petList": pets, "titles": titles])
        }
    }
    
    static func loadPet() {
        
    }
    
    static func loadShelter() {
        
    }
}
