//
//  DownloadManager.swift
//  Feline Finder
//
//  Created by gregoryew1 on 4/2/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

let imageProberFailedMessage = Notification.Name(rawValue:"imageProberFailed")
let imageProberLoadedMessage = Notification.Name(rawValue:"imageProberLoaded")
let petsLoadedMessage = Notification.Name(rawValue:"petsLoaded")
let petLoadedMessage = Notification.Name(rawValue:"petLoaded")
let petsFailedMessage = Notification.Name(rawValue:"petsFailed")
let youTubePlayListLoadedMessage = Notification.Name(rawValue:"youTubePlayListLoaded")
let breedPicturesLoadedMessage = Notification.Name(rawValue:"breedPicturesLoaded")

var isFetchInProgress = false

class DownloadManager {
    static let sharedInstance = DownloadManager()
    
    private var currentPage = 1
    private var total = 0
    //private var isFetchInProgress = false
        
    static func sizeImages(pets: RescuePetsAPI3) {
        
        var imgs = [String]()
        
        let imageProber = ImageSizeAPI()
        
        for pet in pets.Pets {
            for img in pet.media {
                if img.size == "pnt" {imgs.append(img.URL)}
            }
        }
        
        imageProber.probeImages(imageArray: imgs) { result in
            switch result {
            case .failure(let error):
                let nc = NotificationCenter.default
                nc.post(name:imageProberFailedMessage,
                        object: nil,
                        userInfo: ["error": error.reason])
            case .success(let response):
                let imgList = response as [String: PetImage]
                for i in 0..<pets.Pets.count {
                    for j in 0..<pets.Pets[i].media.count {
                        if pets.Pets[i].media[j].size == "pnt" {
                            if let petImg = imgList[pets.Pets[i].media[j].URL] {
                                pets.Pets[i].media[j].height = petImg.height
                                pets.Pets[i].media[j].width = petImg.width
                            }
                        }
                    }
                }

                var info = [String: Any]()
                info["petList"] = pets
                let nc = NotificationCenter.default
                nc.post(name:imageProberLoadedMessage,
                        object: nil,
                        userInfo: info)
            }
        }
    }
    
    static func loadPetList(more: Bool = false) {
        
        if isFetchInProgress {return}
        isFetchInProgress = true
        
        var pets: RescuePetsAPI3!
        
        if let p = PetFinderBreeds[(globalBreed?.BreedName)!]
        {
            pets = p as! RescuePetsAPI3
        } else {
            pets = RescuePetsAPI3()
        }
        
        let date = pets.dateCreated
        
        let hoursSinceCreation: Int = (Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: date as Date, to: Date(), options: []).hour!
        
        var b = false
        
        if pets.count == 0 {
            b = true
        }
        
        if hoursSinceCreation > 24 {
            b = true
        }
        
        if more == true {
            b = true
        }
        
        let oldCount = pets.count
        
        if b == true
        {
            //func loadPets(bn: Breed, zipCode: String, completion: @escaping (Result<Cats, DataResponseError>) -> Void) {
            pets.loadPets3(bn: globalBreed!, zipCode: zipCode, more: more) { result in
                switch result {
                case .failure(let error):
                    zipCodeGlobal = ""
                    bnGlobal = ""
                    sleep(1)
                    pets.resultStart = 0
                    pets.loadPets3(bn: globalBreed!, zipCode: zipCode) { result in
                        switch result {
                        case .failure(let error):
                            let nc = NotificationCenter.default
                            nc.post(name:petsFailedMessage,
                                    object: nil,
                                    userInfo: ["error": error.reason])
                        case .success(let response):
                            let petList = response as PetList
                            PetFinderBreeds[(globalBreed?.BreedName)!] = petList
                            var info = [String: Any]()
                            info["petList"] = pets
                            if oldCount > 0 {info["newIndexPathsToReload"] = calculateIndexPathsToReload(priorCount: oldCount, newCount: petList.count)}
                            let nc = NotificationCenter.default
                            nc.post(name:petsLoadedMessage,
                                    object: nil,
                                    userInfo: info)
                        }
                    }
                case .success(let response):
                    let petList = response as PetList
                    PetFinderBreeds[(globalBreed?.BreedName)!] = pets
                    var info = [String: Any]()
                    info["petList"] = pets
                    if oldCount > 0 {info["newIndexPathsToReload"] = calculateIndexPathsToReload(priorCount: oldCount, newCount: petList.count)}
                    let nc = NotificationCenter.default
                    nc.post(name:petsLoadedMessage,
                            object: nil,
                            userInfo: info)
            }
            }
        } else {
            PetFinderBreeds[(globalBreed?.BreedName)!] = pets
            var info = [String: Any]()
            info["petList"] = pets
            if oldCount > 0 {info["newIndexPathsToReload"] = calculateIndexPathsToReload(priorCount: oldCount, newCount: pets.count)}
            let nc = NotificationCenter.default
            nc.post(name:petsLoadedMessage,
                    object: nil,
                    userInfo: info)
            isFetchInProgress = false
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
    
    static private func calculateIndexPathsToReload(priorCount: Int, newCount: Int) -> [IndexPath] {
      let startIndex = newCount - priorCount
      let endIndex = startIndex + newCount
      return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}

protocol AlertDisplayer {
  func displayAlert(with title: String, message: String, actions: [UIAlertAction]?)
}

extension AlertDisplayer where Self: UIViewController {
  func displayAlert(with title: String, message: String, actions: [UIAlertAction]? = nil) {
    guard presentedViewController == nil else {
      return
    }
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    actions?.forEach { action in
      alertController.addAction(action)
    }
    present(alertController, animated: true)
  }
}

