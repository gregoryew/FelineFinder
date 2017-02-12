//
//  AdoptableCatsViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 12/18/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import UIKit
import TransitionTreasury
import TransitionAnimation

class AdoptableCatsViewController: UICollectionViewController, CLLocationManagerDelegate, NavgationTransitionable, ModalTransitionDelegate {

    @IBAction func backButtonTapped(_ sender: AnyObject) {
        _ = navigationController?.tr_popViewController()
    }
    
    let handlerDelay = 1.5
    
    var pets: RescuePetList?
    var zipCodes: Dictionary<String, zipCoordinates> = [:]
    var locationManager: CLLocationManager?
    var titles:[String] = []
    var totalRow = 0
    var times = 0
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    @IBAction func backTapped(_ sender: Any) {
        _ = navigationController?.tr_popToRootViewController()
    }
    
    @IBAction func searchOptions(_ sender: Any) {
        let PetFinderFind = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PetFinderFind") as! PetFinderFindViewController
        PetFinderFind.breed = globalBreed
        navigationController?.tr_pushViewController(PetFinderFind, method: DemoTransition.Flip)
    }
    
    @IBAction func detailsTapped(_ sender: Any) {
        let Details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Details") as! DetailViewController
        navigationController?.tr_pushViewController(Details, method: DemoTransition.Slide(direction: DIRECTION.left))
    }
    
    @IBAction func breedStats(_ sender: Any) {
        let BreedStats = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "breedStats") as! BreedStatsViewController
        navigationController?.tr_pushViewController(BreedStats, method: DemoTransition.Slide(direction: DIRECTION.left))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.delegate = self
        
        self.collectionView?.backgroundColor = lightBackground
        
        var width: CGFloat = 0.0
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = collectionView!.frame.width / 3.0
        } else {
            width = collectionView!.frame.width / 2.0
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

        self.pets = RescuePetList()
        
        self.navigationItem.title = "\(globalBreed!.BreedName)"
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
                self.pets!.loadPets(self.collectionView!, bn: globalBreed!, zipCode: zipCode) { (petList) -> Void in
                    self.pets = petList as? RescuePetList
                    self.totalRow = -1
                    self.titles = self.pets!.distances.keys.sorted{ $0 < $1 }
                    PetFinderBreeds[(globalBreed?.BreedName)!] = self.pets
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                    self.times += 1
                    if self.pets?.status == "error" {
                        zipCodeGlobal = ""
                    }
                }
            print("Status = \(self.pets?.status) Times = \(self.times)")
            } while self.pets?.status != "ok" && self.pets?.status != "warning" && self.times < 3
            self.times = 0
        }
        self.collectionView?.infiniteScrollingView.color = UIColor.white

        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        setFilterDisplay()
        if PetFinderBreeds[(globalBreed?.BreedName)!] != nil {
            if (PetFinderBreeds[(globalBreed?.BreedName)!]?.count)! == 0 {
                PetFinderBreeds[(globalBreed?.BreedName)!] = nil
                zipCodeGlobal = ""
            }
        }
        if viewPopped {loadPets(); viewPopped = false}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if globalBreed!.BreedName == "All Breeds" {
            self.navigationController?.setToolbarHidden(true, animated:false);
        } else {
            self.navigationController?.setToolbarHidden(false, animated:false);
        }
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated:false);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFilterDisplay() {
        if let navigationBar = self.navigationController?.navigationBar {
            let filter = "Zip:\(zipCode)"
            navigationBar.topItem!.prompt = filter
        }
    }
    
    func Refresh() {
        zipCodeGlobal = ""
        PetFinderBreeds[(globalBreed?.BreedName)!] = nil
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
                        UserDefaults.standard.set(zipCode, forKey: "zipCode")
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
        
        if let p = PetFinderBreeds[(globalBreed?.BreedName)!]
        {
            self.pets = p as? RescuePetList
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
            zipCodeGlobal = ""
            bnGlobal = ""
            self.pets!.loadPets(self.collectionView!, bn: globalBreed!, zipCode: zipCode) { (petList) -> Void in
                self.pets = petList as? RescuePetList
                if self.pets?.status == "ok" {
                    self.totalRow = -1
                    self.titles = self.pets!.distances.keys.sorted{ $0 < $1 }
                    PetFinderBreeds[(globalBreed?.BreedName)!] = self.pets
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                } else {
                    zipCodeGlobal = ""
                    bnGlobal = ""
                    sleep(1)
                    self.pets!.resultStart = 0
                    self.pets!.loadPets(self.collectionView!, bn: globalBreed!, zipCode: zipCode) { (petList) -> Void in
                        self.pets = petList as? RescuePetList
                        if self.pets?.status == "ok" {
                            self.totalRow = -1
                            self.titles = self.pets!.distances.keys.sorted{ $0 < $1 }
                            PetFinderBreeds[(globalBreed?.BreedName)!] = self.pets
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        } else {
                            self.pets?.loading = false
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        }
                    }
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let petData = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
        let FelineDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FelineDetail") as! PetFinderViewDetailController
        FelineDetail.pet = petData
        FelineDetail.petID = petData.petID
        FelineDetail.petName = petData.name
        FelineDetail.breedName = globalBreed!.BreedName
        FelineDetail.modalDelegate = self
        let navEditorViewController: UINavigationController = UINavigationController(rootViewController: FelineDetail)
        tr_presentViewController(navEditorViewController, method: TRPresentTransitionMethod.fade, completion: {
            print("Present finished.")
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderViewCollectionReusableView
    
        if self.pets?.loading == false && titles.count == 0 {
            sectionHeaderView.SectionHeaderLabel.text = "Please broaden the search."
            if sectionHeaderView.ActivityIndicator.isAnimating {
                sectionHeaderView.ActivityIndicator.stopAnimating()
                sectionHeaderView.ActivityIndicator.isHidden = true
                sectionHeaderView.SectionImage.isHidden = false
            }
            return sectionHeaderView
        } else if self.pets?.loading == true {
            if !sectionHeaderView.ActivityIndicator.isAnimating {
                sectionHeaderView.ActivityIndicator.isHidden = false
                sectionHeaderView.SectionImage.isHidden = true
                sectionHeaderView.ActivityIndicator.startAnimating()
            }
            sectionHeaderView.SectionHeaderLabel.text = "Please wait while the cats are loading..."
            return sectionHeaderView
        }
        
        if sectionHeaderView.ActivityIndicator.isAnimating {
            sectionHeaderView.ActivityIndicator.stopAnimating()
            sectionHeaderView.ActivityIndicator.isHidden = true
            sectionHeaderView.SectionImage.isHidden = false
        }
        
        switch titles[indexPath.section] {
        case "         Within about 5 miles": sectionHeaderView.SectionImage.image = UIImage(named: "travel_walk")
        case "       Within about 20 miles": sectionHeaderView.SectionImage.image = UIImage(named: "travel_bike")
        case "    Within about 50 miles": sectionHeaderView.SectionImage.image = UIImage(named: "travel_bike_faster")
        case "   Within about 100 miles": sectionHeaderView.SectionImage.image = UIImage(named: "travel_bus")
        case "  Within about 200 miles": sectionHeaderView.SectionImage.image = UIImage(named: "travel_car")
        case " Over 200 miles": sectionHeaderView.SectionImage.image = UIImage(named: "travel_plane")
 
        case "     Updated Today": sectionHeaderView.SectionImage.image = UIImage(named: "time_day")
        case "    Updated Within A Week": sectionHeaderView.SectionImage.image = UIImage(named: "time_week")
        case "   Updated Within A Month": sectionHeaderView.SectionImage.image = UIImage(named: "time_month")
        case "  Updated Within A Year": sectionHeaderView.SectionImage.image = UIImage(named: "time_year")
        case " Updated Over A Year Ago": sectionHeaderView.SectionImage.image = UIImage(named: "time_over_a_year")

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
        
        cell.CatNameLabel.text = petData.name
        
        if urlString == "" {
            cell.CatImager?.image = UIImage(named: "NoCatImage")
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
                    DispatchQueue.main.async(execute: {
                        if let cellToUpdate = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                            cellToUpdate.CatImager?.image = UIImage(named: "NoCatImage")
                        }
                    })
                    print("Error: \(error!.localizedDescription)")
                }
            }).resume()
        }
        
        return cell
    }
}
