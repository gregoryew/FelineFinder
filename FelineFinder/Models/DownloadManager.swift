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
let breedLoadToolbar = Notification.Name(rawValue:"breedLoadToolbar")

var isFetchInProgress = false

final class DownloadManager {
    static let sharedInstance = DownloadManager()
    
    private var currentPage = 1
    private var total = 0
        
    static func sizeImages(pets: RescuePetsAPI5) {
        
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
        
    static func canProceedCheck(reset: Bool, pets: RescuePetsAPI5) -> Bool {
        if isFetchInProgress {return false}
        isFetchInProgress = true
        
        if pets.dateCreated == INITIAL_DATE {
            return true
        }
        
        let hoursSinceCreation: Int = (Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: pets.dateCreated as Date, to: Date(), options: []).hour!

        var proceed = false
        
        if hoursSinceCreation > 24 || reset == false {
            proceed = true
        }
            
        return proceed
    }
    
    static func generatePetsJSON(filtered: Bool = true, filters filtersParam: [[String: Any]]) -> [String : [String : Any]] {
       var filters: [[String: Any]] = [["fieldName": "species.singular", "operation": "equals", "criteria": "cat"]]
        
        if filtered {
            filters.append(contentsOf: filterOptions.getFilters())

            if let bn = globalBreed {
                if bn.BreedName != "All Breeds" {
                    if bn.RescueBreedID == "" {
                        filters.append(["fieldName": "animals.PrimaryBreed", "operation": "contains", "criteria": bn.BreedName])
                    } else {
                        filters.append(["fieldName": "animals.PrimaryBreedID", "operation": "equals", "criteria": bn.RescueBreedID])
                }
            }
        }
        }
        
        filters.append(contentsOf: filtersParam)
        
            /*
        var order = "desc"
        if sortFilter == "animalLocationDistance" {
            order = "asc"
        }
    */

       let json = [
            "data" : [
                "filterRadius": ["miles": distance, "postalcode": zipCode],
                "filters": filters
            ]
       ] as [String : [String : Any]]
        
       return json
    }
    
    static func loadFavorites(reset: Bool = false) {
        let pets = RescuePetsAPI5()
        
        var json: [String: Any] = [:]
        
        if Favorites.catIDs.count > 0 {
            json = generatePetsJSON(filtered: false, filters: [["fieldName": "animals.id", "operation": "equal", "criteria": Favorites.catIDs]])
        } else {
            json = generatePetsJSON(filtered: false, filters: [["fieldName": "animals.id", "operation": "equal", "criteria": "-1"]])
        }
        
        let oldCount = pets.count
        
        pets.loadPets5(json: json, reset: reset) { result in
            switch result {
            case .failure(let error):
                let nc = NotificationCenter.default
                nc.post(name:petsFailedMessage,
                        object: nil,
                        userInfo: ["error": error.reason])
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
    }
    
    static func loadPetList(reset: Bool = false) {
        
        var pets: RescuePetsAPI5!
        
        if let p = PetFinderBreeds[(globalBreed?.BreedName)!]
        {
            pets = p as? RescuePetsAPI5
        } else {
            pets = RescuePetsAPI5()
        }
        
        var oldCount = 0
        if !reset {
            oldCount = pets.count
        }
                
        if canProceedCheck(reset: reset, pets: pets) == true
        {
            let jsonBase = generatePetsJSON(filtered: true, filters: [])
            pets.loadPets5(json: jsonBase, reset: reset) { result in
                switch result {
                case .failure(let error):
                    let nc = NotificationCenter.default
                    nc.post(name:petsFailedMessage,
                            object: nil,
                            userInfo: ["error": error.reason])
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
            //isFetchInProgress = false
        }
    }
    
    static func loadYouTubePlayList(playListID: String, obj: NSObject) {
        /*
        YouTubeAPI().getYouTubeVideos(playList: playListID) { (PlayList, Error) in
            if Error == nil {
                let nc = NotificationCenter.default
                nc.post(name:youTubePlayListLoadedMessage,
                        object: obj,
                        userInfo:["playList": PlayList])
            } else {
                Utilities.displayAlert("YouTube Playlist Load Error", errorMessage: Error.debugDescription)
            }
        }
        */
    }
    
     static func loadPetPictures(breed: Breed) {
        /*
        BreedInfoGalleryPhotoAPI().loadPhotos(bn: breed) { (breedPictures) in
            let nc = NotificationCenter.default
            nc.post(name: breedPicturesLoadedMessage, object: nil, userInfo: ["breedPictures": breedPictures])
        }
        */
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

