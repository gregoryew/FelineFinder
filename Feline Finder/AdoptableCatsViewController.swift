//
//  AdoptableCatsViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 12/18/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import UIKit

class AdoptableCatsViewController: UICollectionViewController, CLLocationManagerDelegate {

    @IBAction func backButtonTapped(_ sender: AnyObject) {
        if breed?.BreedName == "All Breeds" {
            performSegue(withIdentifier: "MainMenu", sender: nil)
        } else {
            performSegue(withIdentifier: "MasterView", sender: nil)
        }
    }
    
    let handlerDelay = 1.5
    
    var breed: Breed?
    var pets: RescuePetList?
    var zipCodes: Dictionary<String, zipCoordinates> = [:]
    var locationManager: CLLocationManager?
    var titles:[String] = []
    var totalRow = 0
    var times = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.delegate = self
        
        var width: CGFloat = 0.0
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = collectionView!.frame.width / 6.0
        } else {
            width = collectionView!.frame.width / 3.0
        }
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        
        // Sticky Headers
        layout.sectionHeadersPinToVisibleBounds = true
        
        if #available(iOS 10.0, *) {
            collectionView?.isPrefetchingEnabled = false
        } else {
            // Fallback on earlier versions
        }

        //self.pets = PetFinderPetList()
        self.pets = RescuePetList()
        
        self.navigationItem.title = "\(breed!.BreedName)"
        if (zipCode != "")
        {
            self.loadPets()
            setFilterDisplay()
            setupReloadAndScroll()
        }
        else if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
            locationManager!.startUpdatingLocation()
        }
    }
    
    func setupReloadAndScroll() {
        // Pull to refresh
        collectionView?.addPullToRefreshWithActionHandler { () -> Void in
            let delayTime = DispatchTime.now() + Double(Int64(self.handlerDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.collectionView?.stopPullToRefresh()
                self.Refresh()
            }
        }
        collectionView?.pullRefreshColor = UIColor.white
        
        collectionView?.addInfiniteScrollingWithActionHandler { () -> Void in
            let delayTime = DispatchTime.now() + Double(Int64(self.handlerDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.collectionView?.infiniteScrollingView.stopAnimating()
                zipCodeGlobal = ""
                
                repeat {
                self.pets!.loadPets(self.collectionView!, bn: self.breed!, zipCode: zipCode) { (petList) -> Void in
                    self.pets = petList as? RescuePetList
                    self.totalRow = -1
                    self.titles = self.pets!.distances.keys.sorted{ $0 < $1 }
                    PetFinderBreeds[self.breed!.BreedName] = self.pets
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                self.times += 1
            }
            
                } while self.pets?.status != "ok" && self.pets?.status != "warning" && self.times < 3
        }
        self.collectionView?.infiniteScrollingView.color = UIColor.white

        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        setFilterDisplay()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue=\(segue.identifier)")
        if segue.identifier == "searchOptions" {
            (segue.destination as! PetFinderFindViewController).breed = breed
        }
        else if segue.identifier == "BreedStats" {
            (segue.destination as! BreedStatsViewController).whichSeque = "BreedList"
            let b = self.breed as Breed?
            (segue.destination as! BreedStatsViewController).breed = b!
        }
        else if (segue.identifier == "showDetail") {
            let b = self.breed as Breed?
            (segue.destination as! DetailViewController).breed = b!
        }
        else if segue.identifier == "MasterToDetail" {
            if let indexPath = self.collectionView?.indexPathsForSelectedItems?[0] {
                let petData = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
                (segue.destination as! PetFinderViewDetailController).pet = petData
                (segue.destination as! PetFinderViewDetailController).petID = petData.petID
                (segue.destination as! PetFinderViewDetailController).petName = petData.name
                (segue.destination as! PetFinderViewDetailController).breedName = breed!.BreedName
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if breed!.BreedName == "All Breeds" {
            self.navigationController?.setToolbarHidden(true, animated:true);
        } else {
            self.navigationController?.setToolbarHidden(false, animated:true);
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated:true);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFilterDisplay() {
        if let navigationBar = self.navigationController?.navigationBar {
            let filter = "Zip:\(zipCode) Filter:\(filterOptions.displayFilter())"
            navigationBar.topItem!.prompt = filter
        }
    }
    
    func Refresh() {
        zipCodeGlobal = ""
        PetFinderBreeds[self.breed!.BreedName] = nil
        self.loadPets()
        self.collectionView?.reloadData()
    }
    
    @IBAction func unwindToPetFinderList(_ sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        setFilterDisplay()
        self.loadPets()
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (zipCode != "") {
            return
        }
        self.locationManager!.stopUpdatingLocation()
        if let loc = manager.location {
            CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error)->Void in
                if (error != nil) {
                    Utilities.displayAlert("Alert", errorMessage: "Reverse geocoder failed with error " + error!.localizedDescription)
                    //println("Reverse geocoder failed with error" + error.localizedDescription)
                    return
                }
                
                if placemarks!.count > 0 {
                    if let validPlacemark = placemarks?[0] {
                        let pm = validPlacemark
                        zipCode = pm.postalCode!
                        self.setFilterDisplay()
                        print("locationManager")
                        if (zipCode != "") {
                            self.loadPets()
                        }
                        self.setupReloadAndScroll()
                    }
                } else {
                    Utilities.displayAlert("Alert", errorMessage: "Problem with the data received from geocoder")
                    //println("Problem with the data received from geocoder")
                }
            })
        }
    }
    
    func loadPets() {
        self.pets! = RescuePetList()
        //self.pets! = PetFinderPetList()
        
        if let p = PetFinderBreeds[self.breed!.BreedName]
        {
            self.pets = p as! RescuePetList
        }
        
        let date = self.pets?.dateCreated
        
        let hoursSinceCreation: Int = (Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: date! as Date, to: Date(), options: []).hour!
        
        var b = false
        
        if (self.pets!.count == 0) {
            b = true
        }
        
        if hoursSinceCreation > 24 {
            b = true
        }
        
        if b == true
        {
            self.collectionView?.reloadData()
            self.pets!.loadPets(self.collectionView!, bn: self.breed!, zipCode: zipCode) { (petList) -> Void in
                self.pets = petList as! RescuePetList
                self.totalRow = -1
                self.titles = self.pets!.distances.keys.sorted{ $0 < $1 }
                PetFinderBreeds[self.breed!.BreedName] = self.pets
                DispatchQueue.main.async {
                   self.collectionView?.reloadData()
                }
            }
        } else {
            self.totalRow = -1
            self.titles = self.pets!.distances.keys.sorted{ $0 < $1 }
            //self.collectionView?.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location \(error.localizedDescription)")
    }
    
    func totalRows(_ p: PetList) -> Int {
        var total = 0
        var i = 0
        if totalRow == -1 {
            while i < titles.count {
                total += self.pets!.distances[titles[i]]!.count
                i += 1
            }
            totalRow = total
        }
        return totalRow
    }

}

// MARK: UICollectionViewDataSource
extension AdoptableCatsViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        var t = 0
        if let p = self.pets {
            if p.loading || self.pets!.distances.count == 0 {
                t = 1
            }
            else {
                t = self.titles.count
            }
        }
        return t
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var c = 0
        
        if let p = self.pets {
            if p.loading || self.pets!.distances.count == 0 {
                c = 0
            } else {
                let sectionTitle = titles[section]
                c = self.pets!.distances[sectionTitle]!.count
            }
        }
        return c
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderViewCollectionReusableView
    
        if self.pets?.loading == false && titles.count == 0 {
            sectionHeaderView.SectionHeaderLabel.text = "Please broaden the search."
            return sectionHeaderView
        } else if self.pets?.loading == true {
            sectionHeaderView.SectionHeaderLabel.text = "Please wait while the cats are loading..."
            return sectionHeaderView
        }
        
        switch titles[indexPath.section] {
        case "         Within about 5 miles": sectionHeaderView.SectionImage.image = UIImage(named: "travel_walk")
        case "       Within about 25 miles": sectionHeaderView.SectionImage.image = UIImage(named: "travel_bike")
        case "    Within about 50 miles": sectionHeaderView.SectionImage.image = UIImage(named: "travel_bike_faster")
        case "   Within about 75 miles": sectionHeaderView.SectionImage.image = UIImage(named: "travel_bus")
        case "  Within about 100 miles": sectionHeaderView.SectionImage.image = UIImage(named: "travel_car")
        case " Over 100 miles": sectionHeaderView.SectionImage.image = UIImage(named: "travel_plane")
        default: sectionHeaderView.SectionImage.image = UIImage(named: "")
        }
        sectionHeaderView.SectionHeaderLabel.text = titles[indexPath.section]
        
        return sectionHeaderView
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        if titles.count == 0 || indexPath.section >= titles.count {
            return cell
        }

        let d = self.pets!.distances[titles[indexPath.section]]
        
        if d == nil {
            return cell
        }
        
        if (d?.count)! == 0 || indexPath.row >= (d?.count)! {
            return cell
        }
 
        let petData = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
        
        if petData.videos.count > 0 {
            cell.Video.isHidden = false
            cell.Video.image = UIImage(named: "video")
        } else {
            cell.Video.isHidden = true
        }
        
        let urlString: String? = petData.getImage(1, size: "pnt")
        /*
        if UIDevice.current.userInterfaceIdiom == .pad {
            urlString = petData.getImage(1, size: "pn")
        } else {
            urlString = petData.getImage(1, size: "pnt")
        }
        */
        
        cell.CatNameLabel.text = petData.name
        
        if urlString == "" {
            return cell
        }
        
        let imgURL = URL(string: urlString!)
        
        if let img = imageCache[urlString!] {
            cell.CatImager.image = img
        }
        else {
            let request: URLRequest = URLRequest(url: imgURL!)
            _ = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data!)
                    // Update the cell
                    DispatchQueue.main.async(execute: {
                        if let cellToUpdate = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                            cellToUpdate.CatImager?.image = image
                        }
                    })
                }
                else {
                    print("Error: \(error!.localizedDescription)")
                }
            }).resume()
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
/*
extension AdoptableCatsViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pet = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
        performSegue(withIdentifier: "MasterToDetail", sender: pet)
    }
    
}
*/
