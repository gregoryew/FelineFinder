import UIKit
import TransitionTreasury
import TransitionAnimation

let handlerDelay = 1.5

class AdoptableCatsTabViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate, ModalTransitionDelegate { //, NavgationTransitionable {
    
    var viewDidLayoutSubviewsForTheFirstTime = true
    
    deinit {
        print ("AdoptableCatsTabViewController deinit")
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pets: RescuePetList?
    var zipCodes: Dictionary<String, zipCoordinates> = [:]
    var locationManager: CLLocationManager? = CLLocationManager()
    var titles:[String] = []
    var totalRow = 0
    var times = 0
    //let lm = CLLocationManager()
    var observer : Any!
    //weak var tr_pushTransition: TRNavgationTransitionDelegate?
    weak var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    @IBAction func searchOptions(_ sender: Any) {
        let PetFinderFind = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PetFinderFind") as! PetFinderFindViewController
        PetFinderFind.breed = globalBreed
        navigationController?.tr_pushViewController(PetFinderFind, method: DemoTransition.Flip)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
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
        if status == .authorizedAlways || status == .authorizedWhenInUse {
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
        let alert2 = UIAlertController(title: "Please Enter Zip Code", message: "Please enter a zip code for the area you want to search?", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert2.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (btn) in
            let textField = alert2.textFields![0] // Force unwrapping because we know it exists.
            zipCode = (textField.text)!
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
        self.present(alert2, animated: true, completion: nil)
    }
    
    func setupReloadAndScroll() {
        // Pull to refresh
        
        /*
        collectionView.addPullToRefreshWithActionHandler {
            let delayTime = DispatchTime.now() + Double(Int64(handlerDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.collectionView.stopPullToRefresh()
                zipCodeGlobal = ""
                PetFinderBreeds[(globalBreed?.BreedName)!] = nil
                DownloadManager.loadPetList()
            }
        }
        collectionView.pullRefreshColor = UIColor.white
        */
 
        collectionView.addInfiniteScrollingWithActionHandler {[unowned self] () -> Void in
            
            //let strongSelf = self
            
            let delayTime = DispatchTime.now() + Double(Int64(handlerDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                //withExtendedLifetime(self) {
                if let cv = self.collectionView {
                    cv.infiniteScrollingView.stopAnimating()
                }
                zipCodeGlobal = ""
                DownloadManager.loadPetList(more: true)
            }
            self.collectionView.infiniteScrollingView.color = UIColor.white
            
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
        self.pets?.loading = true
        DownloadManager.loadPetList()
    }
    
    @IBAction func unwindToPetFinderList(_ sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        setFilterDisplay()
        DownloadManager.loadPetList()
        // Pull any data from the view controller which initiated the unwind segue.
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
                                DownloadManager.loadPetList()
                            }
                            //self.setupReloadAndScroll()
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
extension AdoptableCatsTabViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let petData = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
        let FelineDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FelineDetail") as! PetFinderViewDetailController
        FelineDetail.pet = petData
        FelineDetail.petID = petData.petID
        FelineDetail.petName = petData.name
        FelineDetail.breedName = globalBreed!.BreedName
        FelineDetail.modalDelegate = self // Don't forget to set modalDelegate
        let navEditorViewController: UINavigationController = UINavigationController(rootViewController: FelineDetail)
       tr_presentViewController(navEditorViewController, method: DemoPresent.CIZoom(transImage: .cat), completion: {
            print("Present finished.")
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderViewCollectionReusableView
        
        if self.pets?.loading == false && titles.count == 0 {
            sectionHeaderView.SectionHeaderLabel.text = "Please broaden the search."
            return sectionHeaderView
        } else if self.pets?.loading == true {
            sectionHeaderView.SectionHeaderLabel.text = "Please wait while the cats are loading..."
            return sectionHeaderView
        }

        /*
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
 */
        sectionHeaderView.SectionHeaderLabel.text = titles[indexPath.section]
        
        return sectionHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
            cell.Video.image = UIImage(named: "video_small")
            print("\(cell.Video.frame)")
            print("\(String(describing: cell.Video.image))")
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
