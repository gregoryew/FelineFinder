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
let petLoadedMessage = Notification.Name(rawValue:"petLoaded")
let youTubePlayListLoadedMessage = Notification.Name(rawValue:"youTubePlayListLoaded")
let breedPicturesLoadedMessage = Notification.Name(rawValue:"breedPicturesLoaded")


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
    
    static func loadYouTubePlayList(playListID: String) {
        YouTubeAPI().getYouTubeVideos(playList: playListID) { (PlayList, Error) in
            if Error == nil {
                let nc = NotificationCenter.default
                nc.post(name:youTubePlayListLoadedMessage,
                        object: nil,
                        userInfo:["playList": PlayList])
            } else {
                Utilities.displayAlert("YouTube Playlist Load Error", errorMessage: Error.debugDescription)
            }
        }
    }
    
    static func loadPetPictures(breed: Breed) {
        BreedInfoGalleryPhotoAPI().loadPhotos(bn: breed) { (breedPictures) in
            let nc = NotificationCenter.default
            nc.post(name: breedPicturesLoadedMessage, object: nil, userInfo: ["breedPictures": breedPictures])
        }
    }
    
    static var timesQueryRan: Int = 0
    
    static func loadPet(petID: String) {
        let pets = RescuePetList()
        
        let sl = Shelters
        
        pets.status = ""
        
        var s: shelter?
        
        pets.loadSinglePet(petID, completion: { (pet) -> Void in
            if pets.status != "Error" {
            sl.loadSingleShelter(pet.shelterID, completion: { (shelter) -> Void in
                s = shelter
                if shelter.id != "Error" {
                    timesQueryRan = 0
                    print("Status success reseting timesQueryRan")
                    let nc = NotificationCenter.default
                    nc.post(name:petLoadedMessage,
                            object: nil,
                            userInfo:["pet": pet, "shelter": shelter])
                }
            })
        }
        })
        if (pets.status == "Error" || s?.id == "ERROR") && timesQueryRan < 4 {
            timesQueryRan += 1
            print("Status Error running for the \(timesQueryRan) time")
            loadPet(petID: petID)
        } else if timesQueryRan == 4 {
            timesQueryRan = 0
            print("Failure for 3rd and final time reseting timesQueryRan")
        }
    }
}
