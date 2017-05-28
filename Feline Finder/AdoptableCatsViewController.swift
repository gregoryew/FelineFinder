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
    
    deinit {
        print ("AdoptableCatsViewController deinit")
    }
    
    let handlerDelay = 0.01
    
    var pets: RescuePetList?
    var zipCodes: Dictionary<String, zipCoordinates> = [:]
    var locationManager: CLLocationManager? = CLLocationManager()
    var titles:[String] = []
    var totalRow = 0
    var times = 0
    //let lm = CLLocationManager()
    weak var tr_pushTransition: TRNavgationTransitionDelegate?
    weak var tr_presentTransition: TRViewControllerTransitionDelegate?
    var observer : Any!
    
    @IBAction func backTapped(_ sender: Any) {
        pets = nil
        locationManager = nil
        if (collectionView?.infiniteScrollingHasBeenSetup)! {
            collectionView?.infiniteScrollingHasBeenSetup = false
            collectionView?.removeObserver((collectionView?.infiniteScrollingView)!, forKeyPath: "contentOffset")
            collectionView?.removeObserver((collectionView?.infiniteScrollingView)!, forKeyPath: "contentSize")
            collectionView?.infiniteScrollingView.resetScrollViewContentInset()
            collectionView?.delegate = nil
            //collectionView?.infiniteScrollingView.isObserving = false
        }
        
        NotificationCenter.default.removeObserver(observer)
        
        //_ = navigationController?.tr_popToRootViewController()
        
        let TitleScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Title") as! TitleScreenViewController
        self.navigationController?.tr_pushViewController(TitleScreen, method: DemoTransition.CIZoom(transImage: transitionImage.cat))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func introOptions() {
        let alertController = UIAlertController(title: "Welcome to Feline Finder", message: "To start, what would you like to do?  These features will also available by tapping the menu button on the top left.", preferredStyle: .alert)
        
        let introAction = UIAlertAction(title: "Introduction Video", style: .default) { (action:UIAlertAction!) in
            firstTime = true
            let onboardingVideo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "onboarding") as! OnboardingVideoViewController
            self.navigationController?.tr_pushViewController(onboardingVideo, method: DemoTransition.CIZoom(transImage: transitionImage.cat))
        }
        let suggestABreedAction = UIAlertAction(title: "Breed Suggestion", style: .default) { (action:UIAlertAction!) in
            firstTime = true
            let survey = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Search") as! ManagePageViewController
            self.navigationController?.tr_pushViewController(survey, method: DemoTransition.CIZoom(transImage: transitionImage.cat))
        }
        let startLookingForACatAction = UIAlertAction(title: "Look At Cats For Adoption", style: .default) { (action:UIAlertAction!) in
            self.findZipCode()
        }
        alertController.addAction(introAction)
        alertController.addAction(suggestABreedAction)
        alertController.addAction(startLookingForACatAction)
        
        // Present Dialog message
        self.present(alertController, animated: true, completion:nil)
    }
    
    @IBAction func searchOptions(_ sender: Any) {
        let PetFinderFind = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PetFinderFind") as! PetFinderFindViewController
        PetFinderFind.breed = globalBreed
        navigationController?.tr_pushViewController(PetFinderFind, method: DemoTransition.Flip)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let breed: Breed = Breed(id: 0, name: "All Breeds", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "");
        globalBreed = breed
        
        let nc = NotificationCenter.default
        observer = nc.addObserver(forName:petsLoadedMessage, object:nil, queue:nil) { [weak self] notification in
            self?.petsLoaded(notification: notification)
        }
        
        collectionView?.delegate = self
        
        collectionView?.backgroundColor = lightBackground
        
        var width: CGFloat = 0.0
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = view.frame.width / 3.0
                //collectionView!.frame.width / 3.0
        } else {
            width = collectionView!.frame.width / 2.0
        }
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width + 30)
        
        // Sticky Headers
        layout.sectionHeadersPinToVisibleBounds = true
        
        if #available(iOS 10.0, *) {
            collectionView?.isPrefetchingEnabled = false
        } else {
            // Fallback on earlier versions
        }

        pets = RescuePetList()
        
        navigationItem.title = "\(globalBreed!.BreedName)"
    }
    
    func findZipCode() {
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        if zipCode == "" {
            locationManager?.startUpdatingLocation()
        } else {
            setFilterDisplay()
            self.pets?.loading = true
            DownloadManager.loadPetList()
            setupReloadAndScroll()
        }
    }
    
    func petsLoaded(notification:Notification) -> Void {
        print("petLoaded notification")
        
        guard let userInfo = notification.userInfo,
            let p = userInfo["petList"] as? RescuePetList,
            let t = userInfo["titles"] as? [String] else {
                print("No userInfo found in notification")
                return
        }
        
        pets = p
        titles = t
        
        self.pets?.loading = false
        
        DispatchQueue.main.async { [unowned self] in
            self.collectionView?.reloadData()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            zipCode = ""
            PetFinderBreeds[(globalBreed?.BreedName)!] = nil
        }
        if zipCode == "" {
            determineLocationAuthorization()
            locationManager?.startUpdatingLocation()
            if status == .denied || status == .restricted {
                self.pets?.loading = true
                DownloadManager.loadPetList()
            }
        }
    }
    
    func determineLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .restricted, .denied:
                self.askForZipCode()
            case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                zipCode = ""
            }
        } else {
            self.askForZipCode()
        }
        setFilterDisplay()
    }
    
    func askForZipCode() {
        let alert = UIAlertController(title: "Please Enter Zip Code", message: "Please enter a zip code for the area you want to search?", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            zipCode = (textField?.text)!
            if DatabaseManager.sharedInstance.validateZipCode(zipCode: zipCode) {
                self.pets?.loading = true
                self.setFilterDisplay()
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                DownloadManager.loadPetList()
            } else {
                Utilities.displayAlert("Error", errorMessage: "You have not allowed Feline Finder to know where you are located so it cannot find cats which are closest to you.  The zip code has been set to the middle of the US population.  Zip code 66952.  You can change it from the find screen.  You can allow the app to use location services again by fliping the switch for Feline Finder in the iOS app system preferences.")
                zipCode = "66952"
                self.pets?.loading = true
                self.setFilterDisplay()
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                DownloadManager.loadPetList()
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupReloadAndScroll() {
        // Pull to refresh
        /*
        collectionView?.addPullToRefreshWithActionHandler {[unowned self] () -> Void in
            let delayTime = DispatchTime.now() + Double(Int64(self.handlerDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) { [unowned self] () -> Void in
                self.collectionView?.stopPullToRefresh()
                self.Refresh()
            }
        }
        collectionView?.pullRefreshColor = UIColor.white
        */
        
        collectionView?.addInfiniteScrollingWithActionHandler {[unowned self] () -> Void in
            
            //let strongSelf = self
            
            let delayTime = DispatchTime.now() + Double(Int64(self.handlerDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                //withExtendedLifetime(self) {
                if let cv = self.collectionView {
                    cv.infiniteScrollingView.stopAnimating()
                }
                zipCodeGlobal = ""
                self.pets?.loading = true
                DownloadManager.loadPetList(more: true)
        }
        self.collectionView?.infiniteScrollingView.color = UIColor.white

        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        setFilterDisplay()
        if viewPopped {
            PetFinderBreeds[(globalBreed?.BreedName)!] = nil
            zipCodeGlobal = ""
            self.pets?.loading = true
            collectionView?.reloadData()
            DownloadManager.loadPetList()
            viewPopped = false
        }
        let breed: Breed = Breed(id: 0, name: "All Breeds", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "");
        globalBreed = breed
        let firstTimeLoadingApp = UserDefaults.standard.string(forKey: "firstTimeLoadingApp") ?? "YES"
        if (firstTime || firstTimeLoadingApp == "YES")  && Utilities.isNetworkAvailable() {
            if (!firstTime) {introOptions()}
            UserDefaults.standard.set("NO", forKey: "firstTimeLoadingApp")
            if (firstTime) {self.findZipCode()}
            firstTime = false
        } else {
            self.findZipCode()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFilterDisplay() {
        let promptString = "Zip:\(zipCode)"
        navigationItem.prompt = promptString
        if currentFilterSave != "Touch Here To Load/Save..." {
            navigationItem.title = currentFilterSave
        } else {
            let breeds = filterOptions.breedOption?.getDisplayValues() ?? ""
            if ((breeds.contains(",")) || breeds == "" || breeds=="Any") {
                navigationItem.title = "Cats for Adoption"
            } else {
                navigationItem.title = breeds
            }
        }
    }
    
    func Refresh() {
        zipCodeGlobal = ""
        PetFinderBreeds[(globalBreed?.BreedName)!] = nil
        self.pets?.loading = true
        DownloadManager.loadPetList()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (zipCode != "") {
            return
        }
        self.locationManager?.stopUpdatingLocation()
        self.locationManager?.delegate = nil
        if let loc = manager.location { 
            CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {[unowned self] (placemarks, error)->Void in
                if (error != nil) {
                    Utilities.displayAlert("Alert", errorMessage: "Reverse geocoder failed with error " + error!.localizedDescription)
                    return
                }
                
                if let pm = placemarks {
                    if pm.count > 0 {
                        if let zc = pm[0].postalCode {
                            zipCode = zc
                            self.setFilterDisplay()
                            if (zipCode != "") {
                                self.pets?.loading = true
                                DownloadManager.loadPetList()
                            }
                            self.setupReloadAndScroll()
                        } else {
                            Utilities.displayAlert("Alert", errorMessage: "Problem with the data received from geocoder")
                        }
                    } else {
                        Utilities.displayAlert("Alert", errorMessage: "Problem with the data received from geocoder")
                    }
                } else {
                    Utilities.displayAlert("Alert", errorMessage: "Problem with the data received from geocoder")
                }
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if zipCode == "" {
            self.askForZipCode()
        }
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
        tr_presentViewController(navEditorViewController, method: DemoPresent.CIZoom(transImage: .cat), completion: {
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

        var d: [Pet]?
        if let p = self.pets {
            d = p.distances[titles[indexPath.section]]
        }
        
        if d == nil {
            return cell
        }
        
        if (d?.count)! == 0 || indexPath.row >= (d?.count)! {
            return cell
        }
 
        let petData = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
        
        if petData.videos.count > 0 {
            cell.Video.isHidden = false
            cell.Video.image = UIImage(named: "video_small")
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
        
        cell.CatImager.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"))
        
        return cell
    }
}
